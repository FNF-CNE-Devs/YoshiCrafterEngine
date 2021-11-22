package;

// import sys.io.File;
import LoadSettings.Settings;
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
*/
class Character extends FlxSprite
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
	/**
	 * If the character is a variant of Boyfriend, or Boyfriend itself.
	 */
	public var isaBF:Bool = false;

	public static var customBFAnims:Array<String> = [];
	public static var customBFOffsets:Array<String> = [];
	public static var customGFAnims:Array<String> = [];
	public static var customGFOffsets:Array<String> = [];

	/**
	 * Reconfigures animations for custom BF and GF.
	 */
	public function configureAnims() {
		switch(curCharacter) {
			case "gf" | "gf-christmas" | "gf-car":
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
			case "bf" | "bf-christmas" | "bf-car":
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
	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false, ?textureOverride:String = "")
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		isaBF = PlayState.bfList.contains(character);
		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'gf' | 'gf-christmas' | 'gf-car':
				// GIRLFRIEND CODE
				// tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'fuck_you_border'); // Goodbye Strawberry Cookie

				var gfSprite = "GF_assets";
				switch(curCharacter) {
					case 'gf-christmas':
						gfSprite = "gfChristmas";
					case 'gf-car':
						gfSprite = "gfCar";
				}
				#if sys
					// Loads the custom default GF skin
					var cGF = Settings.engineSettings.data.customGFSkin;
					var tex =  Paths.getSparrowAtlas_Custom(textureOverride != "" ? Paths.getSkinsPath() + '/gf/$cGF/$textureOverride' : Paths.getSkinsPath() + '/gf/$cGF/spritesheet');
					frames = tex;
					Character.customGFOffsets = Paths.getTextOutsideAssets(Paths.getSkinsPath() + '/gf/$cGF/offsets.txt').trim().split("\n");
					Character.customGFAnims = Paths.getTextOutsideAssets(Paths.getSkinsPath() + '/gf/$cGF/anim_names.txt').trim().split("\n");
					// var color:Array<String> = Paths.getTextOutsideAssets(Paths.getSkinsPath() + '/gf/$cGF/color.txt').trim().split("\r");	//May come in use later
					configureAnims();
					for(offset in Character.customGFOffsets) {
						var data:Array<String> = offset.trim().split(" ");
						if (data[0] == "dance") {
							addOffset("danceLeft", Std.parseInt(data[1]), Std.parseInt(data[2]));
							addOffset("danceRight", Std.parseInt(data[1]), Std.parseInt(data[2]));
						} else {
							addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
						}
					}
				#else
					// Load default GF for targets that doesn't support sys
					var tex = Paths.getCharacter(gfSprite);
					frames = tex;
					animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
					animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
					animation.addByPrefix('cheer', 'GF Cheer', 24, false);
					animation.addByPrefix('singLEFT', 'GF left note', 24, false);
					animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
					animation.addByPrefix('singUP', 'GF Up Note', 24, false);
					animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
					animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
					animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
					animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
					animation.addByPrefix('scared', 'GF FEAR', 24);

					addOffset('cheer');
					addOffset('sad', -2, -2);
					addOffset('danceLeft', 0, -9);
					addOffset('danceRight', 0, -9);

					addOffset("singUP", 0, 4);
					addOffset("singRIGHT", 0, -20);
					addOffset("singLEFT", 0, -19);
					addOffset("singDOWN", 0, -20);
					addOffset('hairBlow', 45, -8);
					addOffset('hairFall', 0, -9);

					addOffset('scared', -2, -17);
				#end

				playAnim('danceRight');
			case 'gf-pixel':
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'gfPixel');
				frames = tex;
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				playAnim('danceRight');

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;
			case 'dad':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'DADDY_DEAREST');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				camOffset.x = 400;
				playAnim('idle');
			case 'matto':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'matto');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing note UP', 24);
				animation.addByPrefix('singLEFT', 'dad sing note right', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note LEFT', 24);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				playAnim('idle');
				camOffset.x = 400;
			case 'spooky':
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'spooky_kids_assets');
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				addOffset('danceLeft');
				addOffset('danceRight');

				addOffset("singUP", -20, 26);
				addOffset("singRIGHT", -130, -14);
				addOffset("singLEFT", 130, -10);
				addOffset("singDOWN", -50, -130);

				playAnim('danceRight');
				charGlobalOffset.y = 200;
			case 'mom':
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'Mom_Assets');
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				addOffset('idle');
				addOffset("singUP", 14, 71);
				addOffset("singRIGHT", 10, -60);
				addOffset("singLEFT", 250, -23);
				addOffset("singDOWN", 20, -160);

				playAnim('idle');
			case 'mom-car' | 'border-milf' | 'tilf' | 'silf' | 'matto-milf':
				tex = ('mom-car' == curCharacter) ? Paths.getCharacter(textureOverride != "" ? textureOverride : 'momCar') : Paths.getCharacter(textureOverride != "" ? textureOverride : '' + curCharacter);

				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, isPlayer);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, isPlayer);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, isPlayer);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, isPlayer);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, isPlayer);

				addOffset('idle');
				addOffset("singUP", 14, 71);
				addOffset("singRIGHT", 10, -60);
				addOffset("singLEFT", 250, -23);
				addOffset("singDOWN", 20, -160);

				playAnim('idle');
			case 'monster':
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'Monster_Assets');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -30, -40);
				charGlobalOffset.y = 100;
				playAnim('idle');
			case 'monster-christmas':
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'monsterChristmas');
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -40, -94);
				charGlobalOffset.y = 130;
				playAnim('idle');
			case 'pico':
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'Pico_FNF_assetss');
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				addOffset('idle');
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -68, -7);
				addOffset("singLEFT", 65, 9);
				addOffset("singDOWN", 200, -70);
				addOffset("singUPmiss", -19, 67);
				addOffset("singRIGHTmiss", -60, 41);
				addOffset("singLEFTmiss", 62, 64);
				addOffset("singDOWNmiss", 210, -28);

				playAnim('idle');

				flipX = true;
				charGlobalOffset.y = 300;
				camOffset.y = 600;
			case 'shrek-pico':
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'shrek_pico');
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24);
				animation.addByPrefix('singUP', 'pico Up note', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note', 24, false);
				animation.addByPrefix('singLEFT', 'Pico Note Right', 24, false);
				animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT', 24, false);
				addOffset('idle');
				addOffset("singUP", -29, 27);
				addOffset("singLEFT", -68, -7);
				addOffset("singRIGHT", 65, 9);
				addOffset("singDOWN", 200, -70);

				playAnim('idle');

				// flipX = true;
				charGlobalOffset.y = 300;
				charGlobalOffset.x = 300;
				camOffset.y = 600;
			case 'bf' | 'bf-christmas' | 'bf-car':
				var bfSprite = "BOYFRIEND";
				switch(curCharacter) {
					case 'bf-christmas':
						bfSprite = "bfChristmas";
					case 'bf-car':
						bfSprite = "bfCar";
				}
				if (textureOverride != "") bfSprite = textureOverride;
				#if sys
				var cBF = Settings.engineSettings.data.customBFSkin;
				var tex = (bfSprite == "BOYFRIEND" || Settings.engineSettings.data.customBFSkin != "default") ? Paths.getSparrowAtlas_Custom(textureOverride == "" ? Paths.getSkinsPath() + '/bf/$cBF/spritesheet' : Paths.getSkinsPath() + '/bf/$cBF/$textureOverride') : Paths.getCharacter(bfSprite);
				#else
				var tex = Paths.getCharacter(bfSprite);
				#end
				frames = tex;
				#if sys
				if (bfSprite != "BOYFRIEND" && Settings.engineSettings.data.customBFSkin == "default") {
				#end
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);
					animation.addByPrefix('singDODGE', 'boyfriend dodge', 24, false);
					animation.addByPrefix('hit', 'BF hit', 24, false);
	
					animation.addByPrefix('firstDeath', "BF dies", 24, false);
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
	
					animation.addByPrefix('scared', 'BF idle shaking', 24);
	
					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
					addOffset('firstDeath', 37, 11);
					addOffset('deathLoop', 37, 5);
					addOffset('deathConfirm', 37, 69);
					addOffset('scared', -4);
				#if sys
				} else {
					var offsets:Array<String> = Paths.getTextOutsideAssets(Paths.getSkinsPath() + '/bf/$cBF/offsets.txt').trim().split("\n");
					Character.customBFAnims = Paths.getTextOutsideAssets(Paths.getSkinsPath() + '/bf/$cBF/anim_names.txt').trim().split("\n");
					// trace(anim_names);
					// var color:Array<String> = Paths.getTextOutsideAssets(Paths.getSkinsPath() + '/bf/$cBF/color.txt').trim().split("\r");	//May come in use later
					configureAnims();
					for(offset in offsets) {
						var data:Array<String> = offset.trim().split(" ");
						addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
					}
				}
				#end
				

				playAnim('idle');
				charGlobalOffset.y = 350;
				flipX = true;
			// case 'bf-christmas':
			// 	var tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'bfChristmas');
			// 	frames = tex;
			// 	animation.addByPrefix('idle', 'BF idle dance', 24, false);
			// 	animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
			// 	animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
			// 	animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
			// 	animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
			// 	animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
			// 	animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
			// 	animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
			// 	animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
			// 	animation.addByPrefix('hey', 'BF HEY', 24, false);

			// 	addOffset('idle', -5);
			// 	addOffset("singUP", -29, 27);
			// 	addOffset("singRIGHT", -38, -7);
			// 	addOffset("singLEFT", 12, -6);
			// 	addOffset("singDOWN", -10, -50);
			// 	addOffset("singUPmiss", -29, 27);
			// 	addOffset("singRIGHTmiss", -30, 21);
			// 	addOffset("singLEFTmiss", 12, 24);
			// 	addOffset("singDOWNmiss", -11, -19);
			// 	addOffset("hey", 7, 4);

			// 	playAnim('idle');
			// 	charGlobalOffset.y = 350;

			// 	flipX = true;
			// case 'bf-car':
			// 	var tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'bfCar');
			// 	frames = tex;
			// 	animation.addByPrefix('idle', 'BF idle dance', 24, false);
			// 	animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
			// 	animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
			// 	animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
			// 	animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
			// 	animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
			// 	animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
			// 	animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
			// 	animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

			// 	addOffset('idle', -5);
			// 	addOffset("singUP", -29, 27);
			// 	addOffset("singRIGHT", -38, -7);
			// 	addOffset("singLEFT", 12, -6);
			// 	addOffset("singDOWN", -10, -50);
			// 	addOffset("singUPmiss", -29, 27);
			// 	addOffset("singRIGHTmiss", -30, 21);
			// 	addOffset("singLEFTmiss", 12, 24);
			// 	addOffset("singDOWNmiss", -11, -19);
			// 	playAnim('idle');
			// 	charGlobalOffset.y = 350;

			// 	flipX = true;
			case 'bf-pixel':
				frames = Paths.getCharacter(textureOverride != "" ? textureOverride : 'bfPixel');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");
				addOffset("singUPmiss");
				addOffset("singRIGHTmiss");
				addOffset("singLEFTmiss");
				addOffset("singDOWNmiss");

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				width -= 100;
				height -= 100;
				charGlobalOffset.y = 350;

				antialiasing = false;

				flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getCharacter(textureOverride != "" ? textureOverride : 'bfPixelsDEAD');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
				animation.play('firstDeath');

				addOffset('firstDeath');
				addOffset('deathLoop', -37);
				addOffset('deathConfirm', -37);
				playAnim('firstDeath');
				// pixel bullshit
				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				antialiasing = false;
				flipX = true;
			case 'kapi':
				// DAD ANIMATION LOADING CODE
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'kapi');
				frames = tex;
				animation.addByIndices('idle', 'Dad idle dance', [2, 4, 6, 8, 10, 0], "", 12, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);
				animation.addByPrefix('meow', 'Dad meow', 24, false);
				animation.addByPrefix('stare', 'Dad stare', 24, false);

				addOffset('idle');

				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				addOffset("stare");
				addOffset("meow");
				playAnim('idle');
			case 'senpai':
				frames = Paths.getCharacter(textureOverride != "" ? textureOverride : 'senpai');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();
				charGlobalOffset.x = 150;
				charGlobalOffset.y = 360;
				camOffset.x = getGraphicMidpoint().x + 300;
				camOffset.x = getGraphicMidpoint().y;

				antialiasing = false;
			case 'tankman':
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'tankmanCaptain');
				frames = tex;
				animation.addByPrefix('idle', 'Tankman Idle Dance instance 1', 24, false);
				animation.addByPrefix('singUP', 'Tankman UP note instance 1', 24);
				animation.addByPrefix('singUP-alt', 'TANKMAN UGH');
				animation.addByPrefix('singRIGHT', 'Tankman Note Left instance 1', 24);
				animation.addByPrefix('singDOWN', 'Tankman DOWN note instance 1', 24);
				animation.addByPrefix('singDOWN-alt', 'PRETTY GOOD', 24, false);
				animation.addByPrefix('singLEFT', 'Tankman Right Note instance 1', 24);

				playAnim('idle');
				addOffset("singRIGHT", -1, -14);
				addOffset("singLEFT", 100, -7);
				addOffset("singUP", 24, 56);
				// addOffset("singUP", 24, 56);
				// addOffset("singUP-alt", 24, 56);
				addOffset("singDOWN", 98, -90);
				// addOffset("singDOWN-alt", 98, -90);
				flipX = true;
				charGlobalOffset.y = 180;
			case 'senpai-angry':
				frames = Paths.getCharacter(textureOverride != "" ? textureOverride : 'senpai');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);
				playAnim('idle');
				charGlobalOffset.x = 150;
				charGlobalOffset.y = 360;
				camOffset.x = getGraphicMidpoint().x + 300;
				camOffset.x = getGraphicMidpoint().y;
				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
			case 'spirit':
				frames = Paths.getCharacterPacker('spirit');
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				addOffset('idle', -220, -280);
				addOffset('singUP', -220, -240);
				addOffset("singRIGHT", -220, -280);
				addOffset("singLEFT", -200, -280);
				addOffset("singDOWN", 170, 110);
				charGlobalOffset.x = -150;
				charGlobalOffset.y = 100;
				camOffset.x = getGraphicMidpoint().x + 300;
				camOffset.x = getGraphicMidpoint().y;
				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;
			case 'none':
				frames = Paths.getCharacter(textureOverride != "" ? textureOverride : 'none');
				animation.addByPrefix('idle', 'Animation', 2, false);
				animation.addByPrefix('singUP', 'singUP', 2, false);
				animation.addByPrefix('singDOWN', 'singDOWN', 2, false);
				animation.addByPrefix('singLEFT', 'singLEFT', 2, false);
				animation.addByPrefix('singRIGHT', 'singRIGHT', 2, false);
				addOffset('idle');
				addOffset("singUP");
				addOffset("singRIGHT");
				addOffset("singLEFT");
				addOffset("singDOWN");

				playAnim('idle');
				antialiasing = false;
			case 'parents-christmas':
				frames = Paths.getCharacter(textureOverride != "" ? textureOverride : 'mom_dad_christmas_assets');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				addOffset('idle');
				addOffset("singUP", -47, 24);
				addOffset("singRIGHT", -1, -23);
				addOffset("singLEFT", -30, 16);
				addOffset("singDOWN", -31, -29);
				addOffset("singUP-alt", -47, 24);
				addOffset("singRIGHT-alt", -1, -24);
				addOffset("singLEFT-alt", -30, 15);
				addOffset("singDOWN-alt", -30, -27);
				charGlobalOffset.x = -500;
				playAnim('idle');
			case 'gfTankmen':
				// GIRLFRIEND CODE
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'gfTankmen');
				frames = tex;
				// animation.addByPrefix('idle', 'GF Dancing at Gunpoint', 48, false);
				animation.addByPrefix('sad', 'GF Crying at Gunpoint ', 24, false);
				animation.addByIndices("danceLeft", "GF Dancing at Gunpoint", [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices("danceRight", "GF Dancing at Gunpoint", [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);
				addOffset('sad', -2, -21);

				playAnim('danceLeft');
			default:
				// DAD ANIMATION LOADING CODE
				tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'unknown-new');
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing note UP', 24);
				animation.addByPrefix('singRIGHT', 'dad sing note right', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				camOffset.x = 400;
				playAnim('idle');
		}

		this.x += charGlobalOffset.x;
		this.y += charGlobalOffset.y;

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
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
	public static function getNoteColors(character:String = "bf", altAnim:Bool = false):Array<FlxColor>
	{
		switch (character)
		{
			default:
				return [
					new FlxColor(Settings.engineSettings.data.arrowColor0),
					new FlxColor(Settings.engineSettings.data.arrowColor1),
					new FlxColor(Settings.engineSettings.data.arrowColor2),
					new FlxColor(Settings.engineSettings.data.arrowColor3)
				];
			case "dad":
				return [
					new FlxColor(0xFFAF66CE),
					new FlxColor(0xFFAF66CE),
					new FlxColor(0xFFAF66CE),
					new FlxColor(0xFFAF66CE),
					new FlxColor(0xFFAF66CE)
				];
			case "spooky":
				// Skid : 0xFFFFFFFF
				// Pump : 0xFFFFA420
				return [
					new FlxColor(0xFFFFFFFF),
					new FlxColor(0xFFFFFFFF),
					new FlxColor(0xFFFFA420),
					new FlxColor(0xFFFFA420),
					new FlxColor(0xFFFFA420)
				];
			case "monster" | "monster-christmas":
				return [
					new FlxColor(0xFFF3FF6E),
					new FlxColor(0xFFF3FF6E),
					new FlxColor(0xFFF3FF6E),
					new FlxColor(0xFFF3FF6E),
					new FlxColor(0xFFF3FF6E)
				];
			case "pico":
				return [
					new FlxColor(0xFFFD6922),
					new FlxColor(0xFF55E858),
					new FlxColor(0xFF55E858),
					new FlxColor(0xFFFD6922),
					new FlxColor(0xFFFD6922)
				];
			case "mom" | "mom-car":
				return [
					new FlxColor(0xFF2B263C),
					new FlxColor(0xFFEE1536),
					new FlxColor(0xFFEE1536),
					new FlxColor(0xFF2B263C),
					new FlxColor(0xFFEE1536)
				];
			case "parents-christmas":
				if (altAnim) // Mom
					return [
						new FlxColor(0xFFD8558E),
						new FlxColor(0xFFD8558E),
						new FlxColor(0xFFD8558E),
						new FlxColor(0xFFD8558E),
						new FlxColor(0xFFD8558E)
					];
				else // Dad
					return [
						new FlxColor(0xFFAF66CE),
						new FlxColor(0xFFAF66CE),
						new FlxColor(0xFFAF66CE),
						new FlxColor(0xFFAF66CE),
						new FlxColor(0xFFAF66CE)
					];
			case "senpai" | "senpai-angry":
				return [
					new FlxColor(0xFFFF78BF),
					new FlxColor(0xFFA7B7F5),
					new FlxColor(0xFFA7B7F5),
					new FlxColor(0xFFFF78BF),
					new FlxColor(0xFFFFAA6F)
				];
			case "spirit":
				return [
					new FlxColor(0xFFFF3C6E),
					new FlxColor(0xFFFF3C6E),
					new FlxColor(0xFFFF3C6E),
					new FlxColor(0xFFFF3C6E),
					new FlxColor(0xFFFF3C6E)
				];
			case "tilf":
				return [
					new FlxColor(0xFFFF0000),
					new FlxColor(0xFFFFFFFF),
					new FlxColor(0xFFFFFFFF),
					new FlxColor(0xFFFF0000),
					new FlxColor(0xFFFF0000)
				];
			case "silf" | "shrek-pico":
				return [
					new FlxColor(0xFFBAA52C),
					new FlxColor(0xFFBAA52C),
					new FlxColor(0xFFBAA52C),
					new FlxColor(0xFFBAA52C),
					new FlxColor(0xFFBAA52C)
				];
			case "kapi":
				return [
					new FlxColor(0xFF4E68C2),
					new FlxColor(0xFFEABC53),
					new FlxColor(0xFFEABC53),
					new FlxColor(0xFF4E68C2),
					new FlxColor(0xFF76719E)
				];
			case "tankman":
				return [
					new FlxColor(0xFF2D2D2D),
					new FlxColor(0xFFFFFFFF),
					new FlxColor(0xFFFFFFFF),
					new FlxColor(0xFF2D2D2D),
					new FlxColor(0xFF2D2D2D)
				];
			case "gf" | "gf-christmas" | "gf-pixel" | "gfTankmen":
				return [
					new FlxColor(0xFFA5004D),
					new FlxColor(0xFFA5004D),
					new FlxColor(0xFFA5004D),
					new FlxColor(0xFFA5004D),
					new FlxColor(0xFFA5004D)
				];
		}
	}

	override function update(elapsed:Float)
	{
		if (isPlayer && (lastHit <= Conductor.songPosition - 500 || lastHit == 0) && animation.curAnim.name != "idle" && !isaBF)
			playAnim('idle');
		// if (!curCharacter.startsWith('bf')) // Ok, what the fuck ?
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
	public function dance(left:Bool = false, down:Bool = false, up:Bool = false, right:Bool = false)
	{
		if (lastNoteHitTime + 250 > Conductor.songPosition) return; // 250 ms until dad dances
		
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-christmas' | 'gf-car' | 'gf-pixel' | 'gfTankmen':
					if (animation.curAnim != null)
					{
						if (!animation.curAnim.name.startsWith('hair'))
						{
							playAnim(danced ? 'danceRight' : 'danceLeft');
						}
					}

				case 'spooky':
					playAnim(danced ? 'danceRight' : 'danceLeft');
				case 'tankman':
					if (danced)
						playAnim('idle');
				default:
					if (isPlayer)
					{
						if (lastHit <= Conductor.songPosition - 500 || lastHit == 0)
							playAnim('idle');
					}
					else
					{
						playAnim('idle');
					}
			}
			danced = !danced;
		}
	}

	public var lastHit:Float = 0;


	/**
	 * Plays the specified animation.
	 * If the animation doesn't exist, the animation name is traced, preventing exceptions.
	 * @param AnimName			Animation Name
	 * @param Force				Whenever it should restart the animation or not if it's already playinh
	 * @param Reversed			Whenever it should play the animation backwards or not
	 * @param Frame				Frame to begin with
	 */

	public var lastNoteHitTime:Float = -500;
	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		var singAnims = ["singLEFT", "singRIGHT", "singUP", "singDOWN"];
		if (singAnims.contains(AnimName)) {
			lastNoteHitTime = Conductor.songPosition;
		}

		if (animation.getByName(AnimName) == null) {
			trace(AnimName + " doesn't exist on character " + curCharacter);
			return;
		}
		if (isPlayer && AnimName == "singLEFT" && flipX)
			AnimName = "singRIGHT";
		else if (isPlayer && AnimName == "singRIGHT" && flipX)
			AnimName = "singLEFT";
		animation.play(AnimName, Force, Reversed, Frame);

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
// import LoadSettings.Settings;
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
