package;

import sys.FileSystem;
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
	public function new(char:String = 'bf', isPlayer:Bool = false, ?mod:String)
	{
		super();
		
		if (char.indexOf(":") == -1 && mod != null) {
			if (FileSystem.exists(Paths.getModsFolder() + '/$mod/characters/$char/icon.png'))
				char = '$mod:$char';
		}
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

		var character = char;
		// if (HealthIcon.redirects[character] != null) {
		// 	character = HealthIcon.redirects[character];
		// }
		
		var cBF:String = Settings.engineSettings.data.customBFSkin;
		if (PlayState.current != null) cBF = PlayState.current.engineSettings.customBFSkin;
		var cGF:String = Settings.engineSettings.data.customGFSkin;
		if (PlayState.current != null) cGF = PlayState.current.engineSettings.customGFSkin;
		
		if (character == "bf" && cBF != "default") {
			loadGraphic(Paths.getBitmapOutsideAssets(Paths.getSkinsPath() + '/bf/$cBF/icon.png'), true, 150, 150);
		} else if (character == "gf" && cGF != "default") {
			loadGraphic(Paths.getBitmapOutsideAssets(Paths.getSkinsPath() + '/gf/$cGF/icon.png'), true, 150, 150);
		} else {
			var path = Paths.getCharacterFolderPath(character) + "/icon.png";
			loadGraphic(FileSystem.exists(path) ? Paths.getBitmapOutsideAssets(path) : Paths.getBitmapOutsideAssets(Paths.getModsFolder() + "/Friday Night Funkin'/characters/unknown/icon.png"), true, 150, 150);
		}
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
