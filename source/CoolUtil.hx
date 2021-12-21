package;

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

	/**
	* Copies folder. Used to copy default skins to prevent crashes
	* 
	* @param path Path of the original folder
	* @param path Path of the new folder
	*/
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

	public static function playMenuSFX(id:Int) {
		switch(id) {
			case 0:
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
			case 1:
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
			case 2:
				FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
		}
	}
	
	public static function wrapFloat(value:Float, min:Float, max:Float) {
		if (value < min)
			return min;
		if (value > max)
			return max;
		return value;
	}
	
	public static function addZeros(v:String, length:Int) {
		var r = v;
		while(r.length < length) {
			r = '0$r';
		}
		return r;
	}
}
