package;

import lime.app.Application;
import EngineSettings.Settings;
import flixel.util.FlxColor;
import openfl.display.BitmapData;
import lime.ui.FileDialogType;
import lime.ui.FileDialog;
import flixel.FlxState;
import flixel.FlxSprite;
import sys.FileSystem;
import flixel.FlxG;
import haxe.DynamicAccess;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	/**
	* Array for difficulty names
	*/
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	
	public static function isDevMode() {
		return Settings.engineSettings != null && Settings.engineSettings.data.developerMode && ModSupport.modConfig[Settings.engineSettings.data.selectedMod] != null && !ModSupport.modConfig[Settings.engineSettings.data.selectedMod].locked;
	}
	public static function getSizeLabel(num:UInt):String{
        var size:Float = num;
        var data = 0;
        var dataTexts = ["B", "KB", "MB", "GB", "TB", "PB"]; // IS THAT A QT MOD REFERENCE!!!??!!111!!11???
        while(size > 1024 && data < dataTexts.length - 1) {
          data++;
          size = size / 1024;
        }
        
        size = Math.round(size * 100) / 100;
        return size + " " + dataTexts[data];
    }

	public static function loadUIStuff(sprite:FlxSprite, ?anim:String) {
		sprite.loadGraphic(Paths.image("uiIcons", "preload"), true, 16, 16);
		var anims = ["up", "refresh", "delete", "copy", "paste", "x", "swap", "folder", "play"];
		
		for(k=>a in anims) {
			sprite.animation.add(a, [k], 0, false);
		}
		if (anim != null) sprite.animation.play(anim);
	}

	public static function loadSong(mod:String, song:String, ?difficulty:String):haxe.Exception {
		if (difficulty == null) difficulty = "normal";


		// 
		// 
		try {
			PlayState._SONG = Song.loadModFromJson(Highscore.formatSong(song, difficulty), mod, song);
		} catch(e) {
			return e;
		}
		PlayState._SONG.validScore = true;
		PlayState.isStoryMode = false;
		PlayState.startTime = 0;
		PlayState.songMod = mod;
		PlayState.jsonSongName = song;
		PlayState.storyDifficulty = difficulty;
		PlayState.fromCharter = false;
		return null;
	}

	public static function loadWeek(mod:String, week:String, ?difficulty:String) {
		
	}

	public static function calculateAverageColorLight(icon:BitmapData) {
		var r:Float = 0;
		var g:Float = 0;
		var b:Float = 0;
		var t:Float = 0;
		for (x in 0...icon.width) {
			for (y in 0...icon.height) {
				var c:FlxColor = icon.getPixel32(x, y);
				r += c.redFloat * c.lightness * c.alpha;
				g += c.greenFloat * c.lightness * c.alpha;
				b += c.blueFloat * c.lightness * c.alpha;
				t += c.lightness * c.alpha;
			}
		}
		if (t == 0) {
			return 0xFF000000;
		} else {
			return FlxColor.fromRGBFloat(r / t, g / t, b / t);
		}
	}
	public static function calculateAverageColor(icon:BitmapData) {
		var r:Float = 0;
		var g:Float = 0;
		var b:Float = 0;
		var t:Float = 0;
		for (x in 0...icon.width) {
			for (y in 0...icon.height) {
				var c:FlxColor = icon.getPixel32(x, y);
				r += c.redFloat * c.alpha;
				g += c.greenFloat * c.alpha;
				b += c.blueFloat * c.alpha;
				t += c.alpha;
			}
		}
		if (t == 0) {
			return 0xFF000000;
		} else {
			return FlxColor.fromRGBFloat(r / t, g / t, b / t);
		}
	}

	public static function getMostPresentColor(icon:BitmapData) {
		var colors:Map<FlxColor, Float> = [];
		for (x in 0...icon.width) {
			for (y in 0...icon.height) {
				var alphaC:FlxColor = icon.getPixel32(x, y);
				var c:FlxColor = alphaC.to24Bit();
				if (colors[c] == null) {
					colors[c] = 1 * alphaC.alphaFloat;
				} else {
					colors[c] += 1 * alphaC.alphaFloat;
				}
			}
		}

		var maxColor:Int = 0xFF000000;
		var maxColorAmount:Float = 0;
		for (color=>amount in colors) {
			if (amount > maxColorAmount) {
				maxColor = color;
				maxColorAmount = amount;
			}
		}

		return maxColor;
	}

	public static function getMostPresentColor2(icon:BitmapData) {
		var colors:Map<FlxColor, Int> = [];
		for (x in 0...icon.width) {
			for (y in 0...icon.height) {
				var c:FlxColor = cast(icon.getPixel32(x, y), FlxColor).to24Bit();
				if (c.redFloat == 0 && c.greenFloat == 0 && c.blueFloat == 0) continue;
				if (colors[c] == null) {
					colors[c] = 1;
				} else {
					colors[c]++;
				}
			}
		}

		var maxColor:FlxColor = 0xFF000000;
		var maxColorAmount:Int = 0;
		for (color=>amount in colors) {
			if (amount > maxColorAmount && color.to24Bit() != FlxColor.BLACK) {
				maxColor = color;
				maxColorAmount = amount;
			}
		}

		return maxColor;
	}



	public static function addBG(f:FlxState) {
		var p = Paths.image("menuBGYoshiCrafter", 'mods/${Settings.engineSettings.data.selectedMod}');
		if (!Assets.exists(p)) p = Paths.image("menuBGYoshiCrafter", "preload");
		var bg = new FlxSprite(0,0).loadGraphic(p);
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.screenCenter();
		bg.antialiasing = true;
		f.add(bg);
		return bg;
	}


	public static function addUpdateBG(f:FlxState) {
		// siivkoi i love your art thanks again
		var p = Paths.image("YoshiCrafter_Engine_download_screen", "preload");
		var bg = new FlxSprite(0,0).loadGraphic(p);
		bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		bg.antialiasing = true;
		f.add(bg);
		return bg;
	}

	public static function playMenuMusic(fade:Bool = false, force:Bool = false) {
		if (force || FlxG.sound.music == null || !FlxG.sound.music.playing) {
			var daFunkyMusicPath = Paths.music('freakyMenu');
			if (Assets.exists(Paths.music('freakyMenu', 'mods/${Settings.engineSettings.data.selectedMod}')))
				daFunkyMusicPath = Paths.music('freakyMenu', 'mods/${Settings.engineSettings.data.selectedMod}');
			FlxG.sound.playMusic(daFunkyMusicPath, fade ? 0 : 1);
			if (fade) FlxG.sound.music.fadeIn(4, 0, 0.7);
		}
	}

	public static function addWhiteBG(f:FlxState) {
		var p = Paths.image("menuDesat", 'mods/${Settings.engineSettings.data.selectedMod}');
		if (!Assets.exists(p)) p = Paths.image("menuDesat", "preload");
		var bg = new FlxSprite(0,0).loadGraphic(p);
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.antialiasing = true;
		f.add(bg);
		return bg;
	}

	public static function openDialogue(t:FileDialogType, name:String, callback:String->Void) {
		var fDial = new FileDialog();
		fDial.onSelect.add(callback);
		
		fDial.browse(t, null, null, name);
	}
	/**
	* Copies folder. Used to copy default skins to prevent crashes
	* 
	* @param path Path of the original folder
	* @param path Path of the new folder
	*/
	public static function deleteFolder(delete:String) {
		#if sys
		if (!sys.FileSystem.exists(delete)) return;
		var files:Array<String> = sys.FileSystem.readDirectory(delete);
		for(file in files) {
			if (sys.FileSystem.isDirectory(delete + "/" + file)) {
				deleteFolder(delete + "/" + file);
				FileSystem.deleteDirectory(delete + "/" + file);
			} else {
				try {
					FileSystem.deleteFile(delete + "/" + file);
				} catch(e) {
					Application.current.window.alert("Could not delete " + delete + "/" + file + ", click OK to skip.");
				}
			}
		}
		#end
	}
	
	public static function copyFolder(path:String, copyTo:String) {
		#if sys
		if (!sys.FileSystem.exists(copyTo)) {
			sys.FileSystem.createDirectory(copyTo);
		}
		var files:Array<String> = sys.FileSystem.readDirectory(path);
		for(file in files) {
			if (sys.FileSystem.isDirectory(path + "/" + file)) {
				copyFolder(path + "/" + file, copyTo + "/" + file);
			} else {
				sys.io.File.copy(path + "/" + file, copyTo + "/" + file);
			}
		}
		#end
	}

	/**
	* Get the difficulty name based on the actual song
	*/
	public static function difficultyString():String
	{
		// return difficultyArray[PlayState.storyDifficulty];
		return PlayState.storyDifficulty.toUpperCase();
	}

	public static function prettySong(song:String):String {
		var split = song.replace("-", " ").split(" ");
		for(i in 0...split.length) {
			if (split[i].length > 0) split[i] = split[i].charAt(0).toUpperCase() + split[i].substr(1).toLowerCase();
		}
		return split.join(" ");
	}

	/**
	* Get text, then convert it to a array of trimmed strings. Used for lists.
	* @param path Path of the text
	*/
	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	/**
	* Creates an array of numbers. Equivalent of `[for (i in min...max) i]`.
	* @param max Maximum amount
	* @param min Number to start with
	*/
	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	public static function getAllChartKeys() {
		var controlKeys:Array<Int> = [];
		var it = ModSupport.modConfig.keys();
		while(it.hasNext()) {
			var e = it.next();
			var config = ModSupport.modConfig[e];
			if (config.keyNumbers != null) {
				for (k in config.keyNumbers) {
					if (!controlKeys.contains(k)) controlKeys.push(k);
				}
			}
		}
		haxe.ds.ArraySort.sort(controlKeys, function(x, y) {
			return x - y;
		});
		return controlKeys;
	}
	public static function playMenuSFX(id:Int) {
		var soundId:String = 'scrollMenu';
		switch(id) {
			case 1:
				soundId = 'confirmMenu';
			case 2:
				soundId = 'cancelMenu';
			case 3:
				soundId = 'disabledMenu';
		}
		var mPath = Paths.sound(soundId, 'mods/${Settings.engineSettings.data.selectedMod}');
		if (Assets.exists(mPath))
			FlxG.sound.play(mPath);
		else
			FlxG.sound.play(Paths.sound(soundId), 1);
	}
	
	public static function wrapFloat(value:Float, min:Float, max:Float) {
		if (value < min)
			return min;
		if (value > max)
			return max;
		return value;
	}
	
	public static function addZeros(v:String, length:Int, end:Bool = false) {
		var r = v;
		while(r.length < length) {
			r = end ? r + '0': '0$r';
		}
		return r;
	}

	public static function getCharacterFullString(char:String, mod:String):String {
		return getCharacterFull(char, mod).join(":");
	}
	public static function getCharacterFull(char:String, mod:String):Array<String> {
		var splitChar = char.split(":");
		if (splitChar.length == 1) {
			for (fileExt in Main.supportedFileTypes) {
				if (FileSystem.exists('${Paths.modsPath}/$mod/characters/${splitChar[0]}/Character.$fileExt')) {
					splitChar.insert(0, mod);
					break;
				}
			}
			if (splitChar.length == 1) {
				for (fileExt in Main.supportedFileTypes) {
					if (FileSystem.exists('${Paths.modsPath}/Friday Night Funkin\'/characters/${splitChar[0]}/Character.$fileExt')) {
						splitChar.insert(0, "Friday Night Funkin'");
						break;
					}
				}
			}
		}
        if (splitChar.length == 1) splitChar = ["Friday Night Funkin'", "unknown"];

		
		return splitChar;
	}
	public static function getNoteTypeFullString(char:String, mod:String):String {
		return getNoteTypeFull(char, mod).join(":");
	}
	public static function getNoteTypeFull(char:String, mod:String):Array<String> {
		var splitChar = char.split(":");
		if (splitChar.length == 1) {
			for (fileExt in Main.supportedFileTypes) {
				if (FileSystem.exists('${Paths.modsPath}/$mod/notes/${splitChar[0]}.$fileExt')) {
					splitChar.insert(0, mod);
					break;
				}
			}
			if (splitChar.length == 1) {
				for (fileExt in Main.supportedFileTypes) {
					if (FileSystem.exists('${Paths.modsPath}/Friday Night Funkin\'/notes/${splitChar[0]}.$fileExt')) {
						splitChar.insert(0, "Friday Night Funkin'");
						break;
					}
				}
			}
		}
        if (splitChar.length == 1) splitChar = ["Friday Night Funkin'", "Default Note"];
		return splitChar;
	}
}
