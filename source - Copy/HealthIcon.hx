package;

import flixel.FlxG;
import lime.utils.Assets;
import flixel.FlxSprite;
import LoadSettings.Settings;

class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public static var redirects:Map<String, String> = null;
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();

		// loadGraphic(Paths.image('iconGrid'), true, 150, 150);
		
		// animation.add('bf', [0, 1], 0, false, isPlayer);
		// animation.add('bf-car', [0, 1], 0, false, isPlayer);
		// animation.add('bf-christmas', [0, 1], 0, false, isPlayer);
		// animation.add('bf-pixel', [21, 21], 0, false, isPlayer);
		// animation.add('spooky', [2, 3], 0, false, isPlayer);
		// animation.add('pico', [4, 5], 0, false, isPlayer);
		// animation.add('mom', [6, 7], 0, false, isPlayer);
		// animation.add('mom-car', [6, 7], 0, false, isPlayer);
		// animation.add('tankman', [8, 9], 0, false, isPlayer);
		// animation.add('face', [10, 11], 0, false, isPlayer);
		// animation.add('dad', [12, 13], 0, false, isPlayer);
		// animation.add('senpai', [22, 22], 0, false, isPlayer);
		// animation.add('senpai-angry', [22, 22], 0, false, isPlayer);
		// animation.add('spirit', [23, 23], 0, false, isPlayer);
		// animation.add('bf-old', [14, 15], 0, false, isPlayer);
		// animation.add('gf', [16], 0, false, isPlayer);
		// animation.add('parents-christmas', [17], 0, false, isPlayer);
		// animation.add('monster', [19, 20], 0, false, isPlayer);
		// animation.add('monster-christmas', [19, 20], 0, false, isPlayer);
		// animation.play(char);
		

		// if (animation.curAnim == null) {
		// 	animation.play('face');
		// }
		
		if (HealthIcon.redirects == null) {
			var ir = CoolUtil.coolTextFile("characters:assets/characters/icons/iconRedirects.txt");
			var redirects:Map<String, String> = [];
			for (icon in ir) {
				var split = icon.split(":");
				redirects[split[0]] = split[1];
			}
			HealthIcon.redirects = redirects;
		}

		antialiasing = true;
		scrollFactor.set();

		var character = char;
		if (HealthIcon.redirects[character] != null) {
			character = HealthIcon.redirects[character];
		}
		
		#if sys
		var cBF:String = Settings.engineSettings.data.customBFSkin;
		var cGF:String = Settings.engineSettings.data.customGFSkin;
		if (character == "bf" && cBF != "default") {
			loadGraphic(Paths.getBitmapOutsideAssets('skins/bf/$cBF/icon.png'), true, 150, 150);
		} else if (character == "gf" && cGF != "default") {
			loadGraphic(Paths.getBitmapOutsideAssets('skins/gf/$cGF/icon.png'), true, 150, 150);
		} else {
			loadGraphic(Assets.exists('characters:assets/characters/icons/$character.png') ? Paths.getCharacterIcon(character) : Paths.getCharacterIcon('unknown'), true, 150, 150);
		}
		#else
			loadGraphic(Assets.exists('characters:assets/characters/icons/$character.png') ? Paths.getCharacterIcon(character) : Paths.getCharacterIcon('unknown'), true, 150, 150);
		#end
		animation.add('char', [0, 1], 0, false, isPlayer);
		animation.play('char');
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
