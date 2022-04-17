package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;
import lime.tools.IOSHelper;
import openfl.utils.Assets;
import sys.FileSystem;
import flixel.FlxG;
import lime.utils.Assets;
import flixel.FlxSprite;
import EngineSettings.Settings;

using StringTools;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;
	public var isAnimated:Bool = false;
	public var frameIndexes(default, set):Array<Array<Int>> = [[20, 0], [0, 1]];
	public var frameIndexesAnimated:Array<Array<Dynamic>> = [[80, "winning"], [20, "normal"], [0, "losing"]];
	// public var health:Float = 0.5;
	public var curCharacter:String = "";
	public var isPlayer:Bool = false;
	/**
		Whenever the icon should be automatically managed by PlayState.
	**/
	public var auto:Bool = true;
	private function set_frameIndexes(f:Array<Array<Int>>):Array<Array<Int>> {
		frameIndexes = f;
		animation.curAnim.reset();
		if (PlayState.current != null) {
			for(i in frameIndexes) {
				if ((i[0] >= PlayState.current.healthBar.percent && animation.curAnim.flipX) || (i[0] >= (100 - PlayState.current.healthBar.percent) && !animation.curAnim.flipX)) {
					animation.curAnim.curFrame = i[1];
					break;
				}
			}
		}
		return frameIndexes;
	}

	public static var redirects:Map<String, String> = null;
	public function new(char:String = 'bf', isPlayer:Bool = false, ?mod:String)
	{
		super();
		this.isPlayer = isPlayer;
		// if (char.indexOf(":") == -1 && mod != null) {
		// 	if (FileSystem.exists(Paths.modsPath + '/$mod/characters/$char/icon.png'))
		// 		char = '$mod:$char';
		// }
		// if (HealthIcon.redirects == null) {
		// 	var ir = CoolUtil.coolTextFile("characters:assets/characters/icons/iconRedirects.txt");
		// 	var redirects:Map<String, String> = [];
		// 	for (icon in ir) {
		// 		var split = icon.split(":");
		// 		redirects[split[0]] = split[1];
		// 	}
		// 	HealthIcon.redirects = redirects;
		// }


		antialiasing = true;
		scrollFactor.set();

		changeCharacter(char, mod);

		
		// if (HealthIcon.redirects[character] != null) {
		// 	character = HealthIcon.redirects[character];
		// }
		
		// var cBF:String = Settings.engineSettings.data.customBFSkin;
		// if (PlayState.current != null) cBF = PlayState.current.engineSettings.customBFSkin;
		// var cGF:String = Settings.engineSettings.data.customGFSkin;
		// if (PlayState.current != null) cGF = PlayState.current.engineSettings.customGFSkin;
		
		// loadGraphic(FileSystem.exists(path) ? Paths.getBitmapOutsideAssets(path) : Paths.getBitmapOutsideAssets(Paths.modsPath + "/Friday Night Funkin'/characters/unknown/icon.png"), true, 150, 150);
		
	}

	override function update(elapsed:Float)
	{
		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
			
		if (isAnimated) {
			var name:String = "normal";
			for (frameIndex in frameIndexesAnimated) {
				if (frameIndex.length == 2) {
					if (health * 100 >= frameIndex[0]) {
						name = frameIndex[1];
						break;
					}
				}
			}
			var anim = "";
			if (animation.curAnim != null) anim = animation.curAnim.name;
			if (anim != name) {
				animation.play(name);
			}
		} else {
			if (animation.curAnim != null) {
				for (frameIndex in frameIndexes) {
					if (frameIndex.length == 2) {
						if (health * 100 >= frameIndex[0]) {
							animation.curAnim.curFrame = frameIndex[1];
							break;
						}
					}
				}
			}
		}
		super.update(elapsed);

	}

	public function changeCharacter(char:String, mod:String) {
		var character = CoolUtil.getCharacterFull(char, mod);
		var tex = Paths.getCharacterIcon(character[1], 'mods/${character[0]}');
		var xml = Paths.getCharacterIconXml(character[1], 'mods/${character[0]}');
		if (openfl.utils.Assets.exists(tex)) {
			if (openfl.utils.Assets.exists(xml)) {
				isAnimated = true;
				frames = FlxAtlasFrames.fromSparrow(tex, xml);
				
				var addedAnims:Array<String> = [];
				var numbers = "0123456789";
				for(f in frames.frames) {
					if (f == null) continue;
					var name = f.name;
					while(numbers.contains(name.charAt(name.length - 1))) {
						name = name.substr(0, name.length - 1);
					}
					if (!addedAnims.contains(name) && name.trim() != "") {
						animation.addByPrefix(name, name, 24, true, isPlayer);
						addedAnims.push(name);
					}
				}
				animation.play('normal');
			} else {
				loadGraphic(tex, true, 150, 150);
				animation.add('char', [for (i in 0...frames.frames.length) i], 0, true, isPlayer);
				animation.play('char');	
				
				if (frames.frames.length > 2) {
					// winning icon pog
					frameIndexes = [[80, 2], [20, 0], [0, 1]];
				}
			}
		} else {
			loadGraphic(Paths.image('icons/face', 'shared'), true, 150, 150);
			animation.add('char', [for (i in 0...frames.frames.length) i], 0, true, isPlayer);
			animation.play('char');
		}

		
		this.curCharacter = character.join(":");
	}
}
