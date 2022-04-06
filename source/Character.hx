package;

// import sys.io.File;
import dev_toolbox.stage_editor.FlxStageSprite;
import mod_support_stuff.FlxColor_Helper;
import Script.HScript;
import openfl.utils.Assets;
import haxe.macro.ExprTools.ExprArrayTools;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
import EngineSettings.Settings;
import PlayState.PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

using StringTools;
/**
* Main Character class for Characters as BF, GF, Daddy Dearest, Mommy Mearest, etc...
* Also this is based off FlxStageSprite BUT since it doesn't override anything it won't interfere with anything so we good
*/
class Character extends FlxStageSprite
{
	/**
	 * Animation Offsets.
	 */
	public var animOffsets:Map<String, Array<Dynamic>>;
	/**
	 * If true, character's animations will be disabled, preventing the game from crashing and allowing debugging of the sprite
	 */
	public var debugMode:Bool = false;
	/**
	 * Character's global offset
	 */
	public var charGlobalOffset:FlxPoint = new FlxPoint(0, 0);
	/**
	 * Camera Offset, at the beginning of the song
	 */
	public var camOffset:FlxPoint = new FlxPoint(0, 0);

	/**
	 * Beat used for the animation (barely used)
	 */
	var curBeat:Int = 0;

	/**
	 * Whenever the character is the player or not
	 */
	public var isPlayer:Bool = false;
	/**
	 * Character name
	 */
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var longAnims:Array<String> = [];
	/**
	 * If the character is a variant of Boyfriend, or Boyfriend itself.
	 */
	public var isaBF:Bool = false;

	/**
	 * DO NOT USE, always results to null unless loadJSON is called.
	 */
	public var json:dev_toolbox.CharacterJSON = null;

	public var healthIcon(default, set):HealthIcon;
	public function set_healthIcon(h:HealthIcon):HealthIcon {
		healthIcon = h;
		if (characterScript != null) characterScript.executeFunc("healthIcon", [h]);
		return h;
	}

	public static var customBFAnims:Array<String> = [];
	public static var customBFOffsets:Array<String> = [];
	public static var customGFAnims:Array<String> = [];
	public static var customGFOffsets:Array<String> = [];

	public var characterScript:Script;

	/**
	 * Reconfigures animations for custom BF and GF.
	 */
	public function configureAnims() {
		var charName = curCharacter;
		var charSplit = curCharacter.split(":");
		if (charSplit.length > 1) charName = charSplit[1];
		if (charName.toLowerCase().startsWith("gf")) {
			for(anim in Character.customGFAnims) {
				var data:Array<String> = anim.trim().split(":");
				if (data[0] == "dance") {
					animation.addByIndices('danceLeft', data[1], [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', data[1], [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				} else if (data[0] == "sad") {
					animation.addByIndices('sad', data[1], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				} else if (data[0] == "hairBlow") {
					animation.addByIndices('hairBlow', data[1], [0, 1, 2, 3], "", 24);
				} else if (data[0] == "hairFall") {
					animation.addByIndices('hairFall', data[1], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				} else {
					animation.addByPrefix(data[0], data[1], 24, false);
				}
			}
		} else if (charName.toLowerCase().startsWith("bf")) {
			for(anim in Character.customBFAnims) {
				var data:Array<String> = anim.trim().split(":");
				animation.addByPrefix(data[0], data[1], 24, data[0] == "deathLoop");
			}
		}
	}

	/**
	 * Creates a new character at the specified location. Please note that the location will be altered by the character's global offsets.
	 * @param x					X position of the character
	 * @param y					Y position of the character
	 * @param character			Character (ex : `bf`, `gf`, `dad`), not identical as the spritesheet
	 * @param isPlayer			Whenever the character is the player or not.
	 * @param textureOverride 	Optional, allows you to override the texture. (ex : `bf` as char for Boyfriend's anims and assets, and `blammed` for the Boyfriend blammed appearance)
	 */
	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, cloneBitmap:Bool = false, ?textureOverride:String = "")
	{
		super(x, y);


		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		isaBF = PlayState.bfList.contains(character);
		antialiasing = true;


		
		var p = Paths.getCharacterFolderPath(curCharacter) + "/Character";
		characterScript = Script.create(p);
		if (characterScript == null) {
			trace(Paths.getCharacterFolderPath(curCharacter) + "/Character is missing");
			characterScript = new HScript();
		}
		characterScript.setVariable("curCharacter", curCharacter);
		characterScript.setVariable("character", this);
		characterScript.setVariable("textureOverride", textureOverride);
		characterScript.setVariable("dance", function() {playAnim("idle");});
		characterScript.setVariable("create", function() {});
		characterScript.setVariable("update", function(elapsed:Float) {});
		characterScript.setVariable("onAnim", function(animName:String) {});
		characterScript.setVariable("getColors", function(altAnim:Bool) {
			return [
				(this.isPlayer ? new FlxColor(0xFF66FF33) : new FlxColor(0xFFFF0000)),
				new FlxColor(Settings.engineSettings.data.arrowColor0),
				new FlxColor(Settings.engineSettings.data.arrowColor1),
				new FlxColor(Settings.engineSettings.data.arrowColor2),
				new FlxColor(Settings.engineSettings.data.arrowColor3)
			];
		});
		var sName = curCharacter.split(":");
		ModSupport.setScriptDefaultVars(characterScript, sName.length > 1 ? sName[0] : "Friday Night Funkin'", {"cloneBitmap" : cloneBitmap});
		try {
			characterScript.loadFile(p);
		} catch(e) {
			return;
		}


		try {
			characterScript.executeFunc("create");
		} catch(ex) {
			trace(ex);
		}
		this.animation.add("", [0], 24, true);

		this.x += charGlobalOffset.x;
		this.y += charGlobalOffset.y;

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			// if (!curCharacter.startsWith('bf'))
			// {
			// 	// var animArray
			// 	var oldRight = animation.getByName('singRIGHT').frames;
			// 	animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
			// 	animation.getByName('singLEFT').frames = oldRight;

			// 	// IF THEY HAVE MISS ANIMATIONS??
			// 	if (animation.getByName('singRIGHTmiss') != null)
			// 	{
			// 		var oldMiss = animation.getByName('singRIGHTmiss').frames;
			// 		animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
			// 		animation.getByName('singLEFTmiss').frames = oldMiss;
			// 	}
			// }
		}
	}

	

	/**
	 * Get the character's note colors and healthbar animation.
	 *
	 * The four first elements of the `Array<FlxColor>` returned are note color in order, while the 5th parameter (if existent), will return the health bar color.
	 *
	 * @param character			The character (`bf`, `gf`...)
	 * @param altAnim			Y position of the character
	 */

	public function loadJSON(overrideFuncs:Bool) {
		
		var charFull = CoolUtil.getCharacterFull(curCharacter, PlayState.songMod);
		/*
		var path = '${Paths.modsPath}/${charFull[0]}/characters/${charFull[1]}/Character.json';
		if (!FileSystem.exists(path)) return;
		try {
			json = Json.parse(Paths.getTextOutsideAssets(path));
		} catch(e) {
			return;
		}
		if (json == null) return;
		*/
		var path = Paths.getPath('characters/${charFull[1]}/character.json', TEXT, 'mods/${charFull[0]}');
		if (!Assets.exists(path)) {
			PlayState.trace('Character JSON for ${charFull.join(":")} doesn\'t exist.');
			return;
		}
		try {
			json = Json.parse(Assets.getText(path));
		} catch(e) {
			PlayState.trace('Character JSON for ${charFull.join(":")} is invalid\n\n$e.');
			return;
		}
		load(overrideFuncs);
	}

	public function load(overrideFuncs:Bool) {
		if (overrideFuncs) {
			var anims = [];
			@:privateAccess
			var it = animation._animations.keys();
			while (it.hasNext()) {
				anims.push(it.next());
			}
			for(a in anims) animation.remove(a);
		}
		this.antialiasing = json.antialiasing;
		if (json.camOffset != null) {
			this.camOffset.x = json.camOffset.x;
			this.camOffset.y = json.camOffset.y;
		}
		if (json.globalOffset != null) {
			this.charGlobalOffset.x = json.globalOffset.x;
			this.charGlobalOffset.y = json.globalOffset.y;
		}
		if (json.danceSteps != null) json.danceSteps = ["idle"];
		if (overrideFuncs) {
			var i = 0;
			characterScript.setVariable("dance", function() {
				playAnim(json.danceSteps[i]);
				i++;
				i = i % json.danceSteps.length;
			});
		}
		if (healthIcon != null) healthIcon.frameIndexes = json.healthIconSteps != null ? json.healthIconSteps : [[20, 0], [0, 1]];
		for (anim in json.anims) {
			if (anim.indices == null || anim.indices.length == 0) {
				animation.addByPrefix(anim.name, anim.anim, anim.framerate, anim.loop);
			} else {
				animation.addByIndices(anim.name, anim.anim, anim.indices, "", anim.framerate, anim.loop);
			}
			addOffset(anim.name, anim.x, anim.y);
		}
		playAnim(json.danceSteps[0]);
		if (json.scale != 1) setGraphicSize(Std.int(width * json.scale));
		if (json.flipX) flipX = !flipX;
		
		var healthColor = FlxColor.fromString(json.healthbarColor);
		if (healthColor == null) healthColor = 0xFFFF0000;
		var returnArray = [healthColor];
		var array = [];
		if (PlayState.current != null) {
			var array = [
				PlayState.current.engineSettings.arrowColor0,
				PlayState.current.engineSettings.arrowColor1,
				PlayState.current.engineSettings.arrowColor2,
				PlayState.current.engineSettings.arrowColor3
			];
		} else {
			var array = [
				Settings.engineSettings.data.arrowColor0,
				Settings.engineSettings.data.arrowColor1,
				Settings.engineSettings.data.arrowColor2,
				Settings.engineSettings.data.arrowColor3
			];
		}
		if (json.arrowColors != null) {
			if (json.arrowColors.length > 0) {
				array = [];
				for (k=>c in json.arrowColors) {
					var nC = FlxColor.fromString(c);
					if (nC != null) array[k] = nC;
				}
			}
		}
		for (e in array) {
			returnArray.push(e);
		}
		if (overrideFuncs) {
			characterScript.setVariable("getColors", function(altAnim) {
				return returnArray;
			});
		}
		scale.set(json.scale, json.scale);
	}

	public function getColors(altAnim:Bool = false):Array<FlxColor>
	{
		var defNoteColors = [
			Settings.engineSettings.data.arrowColor0,
			Settings.engineSettings.data.arrowColor1,
			Settings.engineSettings.data.arrowColor2,
			Settings.engineSettings.data.arrowColor3
		];
		var c2:Array<Dynamic> = characterScript.executeFunc("getColors", [altAnim]);
		if (c2 == null) c2 = [];
		var c:Array<Int> = [];
		for(e in c2) {
			if (Std.isOfType(e, Int)) {
				c.push(e);
			} else if (Std.isOfType(e, FlxColor_Helper)) {
				c.push(cast(e, FlxColor_Helper).color);
			}
		}
		var invalid = false;
		invalid = c == null;
		if (!invalid) invalid = c.length < 1;
		if (invalid) c = [
			(this.isPlayer ? 0xFF66FF33 : 0xFFFF0000),
			Settings.engineSettings.data.arrowColor0,
			Settings.engineSettings.data.arrowColor1,
			Settings.engineSettings.data.arrowColor2,
			Settings.engineSettings.data.arrowColor3
		];
		if (c.length < 5) {
			for (i in c.length...5) {
				c.push(switch(i) {
					case 0:
						(this.isPlayer ? 0xFF66FF33 : 0xFFFF0000);
					case 1:
						Settings.engineSettings.data.arrowColor0;
					case 2:
						Settings.engineSettings.data.arrowColor1;
					case 3:
						Settings.engineSettings.data.arrowColor2;
					case 4:
						Settings.engineSettings.data.arrowColor3;
					default:
						0xFFFFFFFF;
				});
			}
		}

		// for (i in 1...c.length) {
		// 	if (c[i] == 0) {
		// 		c[i] = defNoteColors[(i - 1) % defNoteColors.length];
		// 	}
		// }

		return c;
	}

	override function update(elapsed:Float)
	{
		if (!debugMode && animation.curAnim != null) {
			// if (isPlayer && (lastHit <= Conductor.songPosition - 500 || lastHit == 0) && animation.curAnim.name != "idle" && !isPlayer)
			// 	dance();
			if (!isPlayer)
			{
					if (animation.curAnim.name.startsWith('sing'))
					{
						holdTimer += elapsed;
					}
		
					var dadVar:Float = 4;
		
					if (curCharacter == 'dad')
						dadVar = 6.1;
					if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
					{
						dance();
						holdTimer = 0;
					}
			}
		
			switch (curCharacter)
			{
				case 'gf':
					if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
						playAnim('danceRight');
			}
		}
		

		characterScript.executeFunc("update", [elapsed]);
		super.update(elapsed);
	}

	

	/**
	 * Useful for character with two dancing animations (Girlfriend or Skid & Pump).
	 */
	private var danced:Bool = false;

	/**
	 * "FOR GF DANCING SHIT"
	 * Make the character dance
	 * @param left				Unused.
	 * @param down				Unused.
	 * @param up				Unused.
	 * @param right				Unused.
	 */
	public function dance(force:Bool = false, left:Bool = false, down:Bool = false, up:Bool = false, right:Bool = false)
	{
		if (lastNoteHitTime + 250 > Conductor.songPosition) return; // 250 ms until dad dances
		var dontDance = ["firstDeath", "deathLoop", "deathConfirm"];
		// if (animation.curAnim != null) if (dontDance.contains(animation.curAnim.name) || (longAnims.contains(animation.curAnim.name) && !animation.curAnim.finished)) return;
		if (animation.curAnim != null && !force) if (!animation.curAnim.name.startsWith("sing") &&!animation.curAnim.name.startsWith("dance") && !animation.curAnim.finished) return;
		if (!debugMode)
		{
			characterScript.executeFunc("dance");
			// switch (curCharacter)
			// {
			// 	case 'gf' | 'gf-christmas' | 'gf-car' | 'gf-pixel' | 'gfTankmen':
			// 		if (animation.curAnim != null)
			// 		{
			// 			if (!animation.curAnim.name.startsWith('hair'))
			// 			{
			// 				playAnim(danced ? 'danceRight' : 'danceLeft');
			// 			}
			// 		}

			// 	case 'spooky':
			// 		playAnim(danced ? 'danceRight' : 'danceLeft');
			// 	case 'tankman':
			// 		if (danced)
			// 			playAnim('idle');
			// 	default:
			// 		if (isPlayer)
			// 		{
			// 			if (lastHit <= Conductor.songPosition - 500 || lastHit == 0)
			// 				playAnim('idle');
			// 		}
			// 		else
			// 		{
			// 			playAnim('idle');
			// 		}
			// }
			// danced = !danced;
		}
	}

	public var lastHit:Float = -60000;


	/**
	 * Plays the specified animation.
	 * If the animation doesn't exist, the animation name is traced, preventing exceptions.
	 * @param AnimName			Animation Name
	 * @param Force				Whenever it should restart the animation or not if it's already playinh
	 * @param Reversed			Whenever it should play the animation backwards or not
	 * @param Frame				Frame to begin with
	 */

	public var lastNoteHitTime:Float = -60000;
	private var unknownAnimsAlerted:Array<String> = [];
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName.startsWith("sing")) {
			lastNoteHitTime = Conductor.songPosition;
		}
		var blockAnim:Null<Bool> = characterScript.executeFunc("onAnim", [AnimName]);

		if (blockAnim != true) {
			// will obviously not play the animation and "pause it", to prevent null exception. it will keep the current frame and not set the offset.
			animation.play(AnimName, Force, Reversed, Frame);
			if (animation.getByName(AnimName) == null) {
				if (!unknownAnimsAlerted.contains(AnimName)) {
					PlayState.log.push('Character.playAnim: $AnimName doesn\'t exist on character $curCharacter');
					unknownAnimsAlerted.push(AnimName);
				}
				return;
			}
			if (isPlayer && AnimName == "singLEFT" && flipX)
				AnimName = "singRIGHT";
			else if (isPlayer && AnimName == "singRIGHT" && flipX)
				AnimName = "singLEFT";
	
			var daOffset = animOffsets.get(AnimName);
			if (isPlayer && AnimName != "idle")
			{
				lastHit = Conductor.songPosition;
			}
			if (animOffsets.exists(AnimName))
			{
				offset.set(daOffset[0], daOffset[1]);
			}
			else
				offset.set(0, 0);
	
			if (curCharacter == 'gf')
			{
				if (AnimName == 'singLEFT')
				{
					danced = true;
				}
				else if (AnimName == 'singRIGHT')
				{
					danced = false;
				}
	
				if (AnimName == 'singUP' || AnimName == 'singDOWN')
				{
					danced = !danced;
				}
			}
		}
	}

	

	/**
	 * Add an offset
	 * @param name Name of the offset
	 * @param x X offset
	 * @param y Y offset
	 */
	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}



//
// Code below was for non hard coded characters, but i realised they would quickly get to their limits, so i cancelled the thing
//

// package;

// // import sys.io.File;
// import haxe.macro.Expr.Catch;
// import haxe.DynamicAccess;
// import haxe.Json;
// #if sys
// import sys.FileSystem;
// #end
// import lime.utils.Assets;
// import EngineSettings.Settings;
// import PlayState.PlayState;
// import flixel.FlxG;
// import flixel.FlxSprite;
// import flixel.animation.FlxBaseAnimation;
// import flixel.graphics.frames.FlxAtlasFrames;
// import flixel.math.FlxPoint;
// import flixel.util.FlxColor;

// using StringTools;

// class Character extends FlxSprite
// {
// 	public var animOffsets:Map<String, Array<Dynamic>>;
// 	public var debugMode:Bool = false;
// 	public var charGlobalOffset:FlxPoint = new FlxPoint(0, 0);
// 	public var camOffset:FlxPoint = new FlxPoint(0, 0);

// 	var curBeat:Int = 0;

// 	public var isPlayer:Bool = false;
// 	public var curCharacter:String = 'bf';

// 	public var holdTimer:Float = 0;
// 	public var isaBF:Bool = false;

// 	public var curIdleAnim = 0;

// 	public var data:CharacterData = {
// 		color: new FlxColor(0xFF31B0D1),
// 		flipX: false,
// 		pixel: false,
// 		globalOffset: new FlxPoint(0,0),
// 		anims: [],
// 		animsIndices: [],
// 		idleDanceSteps: ["idle"],
// 		emotes: ["idle"]
// 	};
// 	public static var customBFAnims:Array<String> = [];
// 	public static var customBFOffsets:Array<String> = [];
// 	public static var customGFAnims:Array<String> = [];
// 	public static var customGFOffsets:Array<String> = [];

// 	public function configureAnims() {
// 		switch(curCharacter) {
// 			case "gf" | "gf-christmas" | "gf-car":
// 				for(anim in Character.customGFAnims) {
// 					var data:Array<String> = anim.trim().split(":");
// 					if (data[0] == "dance") {
// 						animation.addByIndices('danceLeft', data[1], [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
// 						animation.addByIndices('danceRight', data[1], [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
// 					} else if (data[0] == "sad") {
// 						animation.addByIndices('sad', data[1], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
// 					} else if (data[0] == "hairBlow") {
// 						animation.addByIndices('hairBlow', data[1], [0, 1, 2, 3], "", 24);
// 					} else if (data[0] == "hairFall") {
// 						animation.addByIndices('hairFall', data[1], [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
// 					} else {
// 						animation.addByPrefix(data[0], data[1], 24, false);
// 					}
// 				}
// 			case "bf" | "bf-christmas" | "bf-car":
// 				for(anim in Character.customBFAnims) {
// 					var data:Array<String> = anim.trim().split(":");
// 					animation.addByPrefix(data[0], data[1], 24, data[0] == "deathLoop");
// 				}
// 		}
// 	}
// 	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
// 	{
// 		super(x, y);

// 		animOffsets = new Map<String, Array<Dynamic>>();
// 		curCharacter = character;
// 		this.isPlayer = isPlayer;
// 		isaBF = PlayState.bfList.contains(character);
// 		var tex:FlxAtlasFrames;
// 		antialiasing = true;
		
		
// 		var exists = Assets.exists('characters:assets/characters/$curCharacter/spritesheet.png'); // Checks if asset exists
// 		var useSys = false;
// 		var skin = false;
// 		#if sys
// 		if (!exists) {
// 			exists = FileSystem.exists('assets/characters/$curCharacter/spritesheet.png'); // Checks if it exists in the file system (for debug shit)
// 			useSys = exists;
// 		}
// 		#end
		
// 		if (!exists) {
// 			curCharacter = "unknown"; // Character doesn't exist
// 		}
// 		var t:String = "";
// 		#if sys
// 		var skinC = "";
// 			if (Settings.engineSettings.data.customBFSkin != "default") {
// 				var bfSkins = ["bf", "bf-christmas", "bf-car"];
// 				if (bfSkins.contains(curCharacter)) {
// 					curCharacter = "bf";
// 					useSys = true;
// 					skin = true;
// 					skinC = Settings.engineSettings.data.customBFSkin;
// 				}
// 			}
// 			if (Settings.engineSettings.data.customGFSkin != "default") {
// 				var bfSkins = ["gf", "gf-christmas", "gf-car"];
// 				if (bfSkins.contains(curCharacter)) {
// 					curCharacter = "gf";
// 					useSys = true;
// 					skin = true;
// 					skinC = Settings.engineSettings.data.customGFSkin;
// 				}
// 			}
// 			var cChar = curCharacter;
// 			var path = skin ? Paths.getSkinsPath() + '/$curCharacter/$skinC' : 'assets/characters/$curCharacter';
// 			if (useSys) {
// 				t = Paths.getTextOutsideAssets('$path/data.json');
// 			} else {
// 				t = Assets.getText('characters:assets/characters/$curCharacter/data.json');
// 			}

// 		if (useSys) {
// 			frames = Paths.getSparrowAtlas_Custom('$path/spritesheet');
// 		} else {
// 			frames = Paths.getCharacter(textureOverride != "" ? textureOverride : '$curCharacter/spritesheet');
// 		}
// 		#else
// 			t = Assets.getText('characters:assets/characters/$curCharacter/data.json');
// 			frames = Paths.getCharacter(textureOverride != "" ? textureOverride : '$curCharacter/spritesheet');
// 		#end
// 		var d:DynamicAccess<Dynamic> = Json.parse(t);

// 		// data = new CharacterData();
// 		// CoolUtil.populate(data, Json.parse(t));
// 		data = Json.parse(t);
// 		flipX = data.flipX;
// 		for (anim in data.anims) {
// 			trace(anim.name);
// 			trace(anim.anim);
// 			animation.addByPrefix(anim.name, anim.anim, anim.framerate, anim.loop, false, false);
// 			addOffset(anim.name, anim.x, anim.y);
// 		}
// 		for (anim in data.animsIndices) {
// 			animation.addByIndices(anim.name, anim.anim, anim.animPrefixKeys, "", anim.framerate, anim.loop, false, false);
// 			addOffset(anim.name, anim.x, anim.y);
// 		}

// 		antialiasing = !data.pixel;

// 		playAnim(data.idleDanceSteps[0]);
		
// 		if (data.pixel) {
// 			setGraphicSize(Std.int(width * 6));
// 		}
// 		// switch (curCharacter)
// 		// {
// 		// 	default:
// 		// 		// DAD ANIMATION LOADING CODE
// 		// 		tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'unknown-new');
// 		// 		frames = tex;
// 		// 		animation.addByPrefix('idle', 'Dad idle dance', 24, false);
// 		// 		animation.addByPrefix('singUP', 'Dad Sing note UP', 24);
// 		// 		animation.addByPrefix('singRIGHT', 'dad sing note right', 24);
// 		// 		animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
// 		// 		animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

// 		// 		addOffset('idle');
// 		// 		addOffset("singUP", -6, 50);
// 		// 		addOffset("singRIGHT", 0, 27);
// 		// 		addOffset("singLEFT", -10, 10);
// 		// 		addOffset("singDOWN", 0, -30);

// 		// 		camOffset.x = 400;
// 		// 		playAnim('idle');
// 		// }

// 		if (isPlayer)
// 		{
// 			flipX = !flipX;

// 			// Doesn't flip for BF, since his are already in the right place???
// 			// if (!curCharacter.startsWith('bf'))
// 			// {
// 			// 	// var animArray
// 			// 	var oldRight = animation.getByName('singRIGHT').frames;
// 			// 	animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
// 			// 	animation.getByName('singLEFT').frames = oldRight;

// 			// 	// IF THEY HAVE MISS ANIMATIONS??
// 			// 	if (animation.getByName('singRIGHTmiss') != null)
// 			// 	{
// 			// 		var oldMiss = animation.getByName('singRIGHTmiss').frames;
// 			// 		animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
// 			// 		animation.getByName('singLEFTmiss').frames = oldMiss;
// 			// 	}
// 			// }
// 		}
// 	}

// 	public static function getNoteColors(character:String = "bf", altAnim:Bool = false):Array<FlxColor>
// 	{
// 		switch (character)
// 		{
// 			default:
// 				return [
// 					new FlxColor(Settings.engineSettings.data.arrowColor0),
// 					new FlxColor(Settings.engineSettings.data.arrowColor1),
// 					new FlxColor(Settings.engineSettings.data.arrowColor2),
// 					new FlxColor(Settings.engineSettings.data.arrowColor3)
// 				];
// 			case "dad":
// 				return [
// 					new FlxColor(0xFFAF66CE),
// 					new FlxColor(0xFFAF66CE),
// 					new FlxColor(0xFFAF66CE),
// 					new FlxColor(0xFFAF66CE),
// 					new FlxColor(0xFFAF66CE)
// 				];
// 			case "spooky":
// 				// Skid : 0xFFFFFFFF
// 				// Pump : 0xFFFFA420
// 				return [
// 					new FlxColor(0xFFFFFFFF),
// 					new FlxColor(0xFFFFFFFF),
// 					new FlxColor(0xFFFFA420),
// 					new FlxColor(0xFFFFA420),
// 					new FlxColor(0xFFFFA420)
// 				];
// 			case "monster" | "monster-christmas":
// 				return [
// 					new FlxColor(0xFFF3FF6E),
// 					new FlxColor(0xFFF3FF6E),
// 					new FlxColor(0xFFF3FF6E),
// 					new FlxColor(0xFFF3FF6E),
// 					new FlxColor(0xFFF3FF6E)
// 				];
// 			case "pico":
// 				return [
// 					new FlxColor(0xFFFD6922),
// 					new FlxColor(0xFF55E858),
// 					new FlxColor(0xFF55E858),
// 					new FlxColor(0xFFFD6922),
// 					new FlxColor(0xFFFD6922)
// 				];
// 			case "mom" | "mom-car":
// 				return [
// 					new FlxColor(0xFF2B263C),
// 					new FlxColor(0xFFEE1536),
// 					new FlxColor(0xFFEE1536),
// 					new FlxColor(0xFF2B263C),
// 					new FlxColor(0xFFEE1536)
// 				];
// 			case "parents-christmas":
// 				if (altAnim) // Mom
// 					return [
// 						new FlxColor(0xFFD8558E),
// 						new FlxColor(0xFFD8558E),
// 						new FlxColor(0xFFD8558E),
// 						new FlxColor(0xFFD8558E),
// 						new FlxColor(0xFFD8558E)
// 					];
// 				else // Dad
// 					return [
// 						new FlxColor(0xFFAF66CE),
// 						new FlxColor(0xFFAF66CE),
// 						new FlxColor(0xFFAF66CE),
// 						new FlxColor(0xFFAF66CE),
// 						new FlxColor(0xFFAF66CE)
// 					];
// 			case "senpai" | "senpai-angry":
// 				return [
// 					new FlxColor(0xFFFF78BF),
// 					new FlxColor(0xFFA7B7F5),
// 					new FlxColor(0xFFA7B7F5),
// 					new FlxColor(0xFFFF78BF),
// 					new FlxColor(0xFFFFAA6F)
// 				];
// 			case "spirit":
// 				return [
// 					new FlxColor(0xFFFF3C6E),
// 					new FlxColor(0xFFFF3C6E),
// 					new FlxColor(0xFFFF3C6E),
// 					new FlxColor(0xFFFF3C6E),
// 					new FlxColor(0xFFFF3C6E)
// 				];
// 			case "tilf":
// 				return [
// 					new FlxColor(0xFFFF0000),
// 					new FlxColor(0xFFFFFFFF),
// 					new FlxColor(0xFFFFFFFF),
// 					new FlxColor(0xFFFF0000),
// 					new FlxColor(0xFFFF0000)
// 				];
// 			case "silf" | "shrek-pico":
// 				return [
// 					new FlxColor(0xFFBAA52C),
// 					new FlxColor(0xFFBAA52C),
// 					new FlxColor(0xFFBAA52C),
// 					new FlxColor(0xFFBAA52C),
// 					new FlxColor(0xFFBAA52C)
// 				];
// 			case "kapi":
// 				return [
// 					new FlxColor(0xFF4E68C2),
// 					new FlxColor(0xFFEABC53),
// 					new FlxColor(0xFFEABC53),
// 					new FlxColor(0xFF4E68C2),
// 					new FlxColor(0xFF76719E)
// 				];
// 			case "tankman":
// 				return [
// 					new FlxColor(0xFF2D2D2D),
// 					new FlxColor(0xFFFFFFFF),
// 					new FlxColor(0xFFFFFFFF),
// 					new FlxColor(0xFF2D2D2D),
// 					new FlxColor(0xFF2D2D2D)
// 				];
// 			case "gf" | "gf-christmas" | "gf-pixel" | "gfTankmen":
// 				return [
// 					new FlxColor(0xFFA5004D),
// 					new FlxColor(0xFFA5004D),
// 					new FlxColor(0xFFA5004D),
// 					new FlxColor(0xFFA5004D),
// 					new FlxColor(0xFFA5004D)
// 				];
// 		}
// 	}

// 	override function update(elapsed:Float)
// 	{
// 		if (isPlayer && (lastHit <= Conductor.songPosition - 500 || lastHit == 0) && animation.curAnim.name != "idle" && !isaBF)
// 			playAnim('idle');
// 		// if (!curCharacter.startsWith('bf')) // Ok, what the fuck ?
// 		if (!isPlayer)
// 		{
// 			if (animation.curAnim.name.startsWith('sing'))
// 			{
// 				holdTimer += elapsed;
// 			}

// 			var dadVar:Float = 4;

// 			if (curCharacter == 'dad')
// 				dadVar = 6.1;
// 			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
// 			{
// 				dance();
// 				holdTimer = 0;
// 			}
// 		}

// 		switch (curCharacter)
// 		{
// 			case 'gf':
// 				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
// 					playAnim('danceRight');
// 		}

// 		super.update(elapsed);
// 	}

// 	private var danced:Bool = false;

// 	/**
// 	 * FOR GF DANCING SHIT
// 	 */
// 	public function dance(left:Bool = false, down:Bool = false, up:Bool = false, right:Bool = false)
// 	{
// 		if (!debugMode)
// 		{
// 			// switch (curCharacter)
// 			// {
// 			// 	case 'gf' | 'gf-christmas' | 'gf-car' | 'gf-pixel' | 'gfTankmen':
// 			// 		if (animation.curAnim != null)
// 			// 		{
// 			// 			if (!animation.curAnim.name.startsWith('hair'))
// 			// 			{
// 			// 				playAnim(danced ? 'danceRight' : 'danceLeft');
// 			// 			}
// 			// 		}

// 			// 	case 'spooky':
// 			// 		playAnim(danced ? 'danceRight' : 'danceLeft');
// 			// 	case 'tankman':
// 			// 		if (danced)
// 			// 			playAnim('idle');
// 			// 	default:
// 			// 		if (isPlayer)
// 			// 		{
// 			// 			if (lastHit <= Conductor.songPosition - 500 || lastHit == 0)
// 			// 				playAnim('idle');
// 			// 		}
// 			// 		else
// 			// 		{
// 			// 			playAnim('idle');
// 			// 		}
// 			// }
// 			// danced = !danced;
// 			curIdleAnim++;
// 			if (curIdleAnim == data.idleDanceSteps.length) {
// 				curIdleAnim = 0;
// 			}
// 			playAnim(data.idleDanceSteps[curIdleAnim]);
// 		}
// 	}

// 	public var lastHit:Float = 0;

// 	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
// 	{
// 		if (animation.getByName(AnimName) == null) {
// 			trace(AnimName + " doesn't exist on character " + curCharacter);
// 			return;
// 		}
// 		if (isPlayer && AnimName == "singLEFT" && flipX)
// 			AnimName = "singRIGHT";
// 		else if (isPlayer && AnimName == "singRIGHT" && flipX)
// 			AnimName = "singLEFT";
// 		animation.play(AnimName, Force, Reversed, Frame);

// 		var daOffset = animOffsets.get(AnimName);
// 		if (isPlayer && AnimName != "idle")
// 		{
// 			lastHit = Conductor.songPosition;
// 		}
// 		if (animOffsets.exists(AnimName))
// 		{
// 			offset.set(daOffset[0], daOffset[1]);
// 		}
// 		else
// 			offset.set(0, 0);

// 		if (curCharacter == 'gf')
// 		{
// 			if (AnimName == 'singLEFT')
// 			{
// 				danced = true;
// 			}
// 			else if (AnimName == 'singRIGHT')
// 			{
// 				danced = false;
// 			}

// 			if (AnimName == 'singUP' || AnimName == 'singDOWN')
// 			{
// 				danced = !danced;
// 			}
// 		}
// 	}

// 	public function addOffset(name:String, x:Float = 0, y:Float = 0)
// 	{
// 		animOffsets[name] = [x, y];
// 	}
// }
