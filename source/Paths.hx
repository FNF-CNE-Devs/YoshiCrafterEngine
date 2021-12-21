package;

import haxe.io.Bytes;
import LoadSettings.Settings;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;
import lime.system.System;
import lime.utils.AssetLibrary;
import openfl.display.BitmapData;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static public function getModsFolder() {
		#if sourceCode
			return './../../../../mods';
		#else
			return './mods';
		#end
		
	}
	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function modInst(song:String, mod:String)
	{
		var path = Paths.getModsFolder() + '/$mod/songs/$song/Inst.ogg';
		if (Settings.engineSettings.data.developerMode) {
			if (!FileSystem.exists(path)) {
				PlayState.log.push('Paths : Inst for song $song at "$path" does not exist.');
			}
		}
		return Sound.fromFile(path);
	}

	inline static public function modVoices(song:String, mod:String)
	{
		var path = Paths.getModsFolder() + '/$mod/songs/$song/Voices.ogg';
		if (Settings.engineSettings.data.developerMode) {
			if (!FileSystem.exists(path)) {
				PlayState.log.push('Paths : Voices for song $song at "$path" does not exist.');
			}
		}
		return Sound.fromFile(path);
	}

	inline static public function stageSound(file:String)
	{
		var p = ModSupport.song_stage_path + #if web '/$file.mp3' #else '/$file.ogg' #end;
		if (Settings.engineSettings.data.developerMode) {
			if (!FileSystem.exists(p)) {
				PlayState.log.push('Paths : Sound at "$p" does not exist.');
			}
		}
		return Sound.fromFile(p);
	}
	
	inline static public function getSkinsPath() {
		return System.applicationStorageDirectory + "../../YoshiCrafter29/Yoshi Engine/skins/";
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function stageImage(key:String)
	{
		var p = ModSupport.song_stage_path;
		return getBitmapOutsideAssets('$p/$key');
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	public static var cacheText:Map<String, String> = new Map<String, String>();
	public static var cacheBitmap:Map<String, BitmapData> = new Map<String, BitmapData>();
	public static var cacheBytes:Map<String, Bytes> = new Map<String, Bytes>();
	#if sys	

	inline static public function clearCache() {
		cacheText.clear();
		for (bData in cacheBitmap) {
			bData.dispose();
			bData.disposeImage();
		}
		cacheBitmap.clear();
	}

	inline static public function getTextOutsideAssets(path:String, log:Bool = false) {
		
		if (Settings.engineSettings.data.developerMode) {
			if (!FileSystem.exists(path)) {
				PlayState.log.push('Paths : Text file at "$path" does not exist.');
			}
		}
		if (Paths.cacheText[path] == null) {
			if (log) trace('Getting file content at "$path"');
			Paths.cacheText[path] = sys.io.File.getContent(path);
		}
		return Paths.cacheText[path];
	}

	#end
	inline static public function getBitmapOutsideAssets(path:String) {
		// trace(path);
		
		if (Settings.engineSettings.data.developerMode) {
			if (!FileSystem.exists(path)) {
				PlayState.log.push('Paths : Bitmap at "$path" does not exist.');
			}
		}
		if (Paths.cacheBitmap[path] == null) {
			Paths.cacheBitmap[path] = BitmapData.fromFile(path);
		} else if (!Paths.cacheBitmap[path].readable) {
			Paths.cacheBitmap[path] = BitmapData.fromFile(path);
		}
		return Paths.cacheBitmap[path];
	}
	inline static public function getBytesOutsideAssets(path:String) {
		// trace(path);
		
		if (Settings.engineSettings.data.developerMode) {
			if (!FileSystem.exists(path)) {
				PlayState.log.push('Paths : Byte file at "$path" does not exist.');
			}
		}
		if (Paths.cacheBytes[path] == null) {
			Paths.cacheBytes[path] = File.getBytes(path);
		}
		return Paths.cacheBytes[path];
	}
	inline static public function getSparrowAtlas_Custom(key:String)
	{
		// Assets.registerLibrary("custom", AssetLibrary.(key + ".png"));
		// Assets.registerLibrary("custom", AssetLibrary.fromFile(key + ".xml"));
		#if sys
		return FlxAtlasFrames.fromSparrow(Paths.getBitmapOutsideAssets(key + ".png"), Paths.getTextOutsideAssets(key + ".xml"));
		#else
		return null;
		#end
	}
	inline static public function getSparrowAtlas_Stage(key:String)
	{
		#if sys
		return FlxAtlasFrames.fromSparrow(Paths.getLibraryPath(ModSupport.song_stage_path), Paths.getTextOutsideAssets(ModSupport.song_stage_path + '/$key.xml'));
		// return FlxAtlasFrames.fromSparrow(Paths.getBitmapOutsideAssets(ModSupport.song_stage_path + '/$key.png'), Paths.getTextOutsideAssets(ModSupport.song_stage_path + '/$key.xml'));
		#else
		return null;
		#end
	}

	inline static public function getCharacter(key:String)
	{
		return FlxAtlasFrames.fromSparrow(getPath('$key.png', IMAGE, "characters"), file('$key.xml', "characters"));
	}

	inline static public function video(key:String, ?library:String)
	{
		trace('assets/videos/$key.mp4');
		return getPath('videos/$key.mp4', BINARY, library);
	}

	inline static public function getCharacterFolderPath(characterId:String):String {
		var splittedCharacterID = characterId.split(":");
		var charName = "";
		var charMod = "";
		trace(splittedCharacterID);
		if (splittedCharacterID.length < 2) {
			 // For default FNF characters
			charName = splittedCharacterID[0];
			charMod = "Friday Night Funkin'";
		} else {
			 // For YOUR characters
			charName = splittedCharacterID[1];
			charMod = splittedCharacterID[0];
		}
		var folder = Paths.getModsFolder() + '/$charMod/characters/$charName';
		trace(folder);
		if (!FileSystem.exists(folder + "/Character.hx")) {
			folder = Paths.getModsFolder() + '/Friday Night Funkin\'/characters/unknown';
		}
		return folder;
	}
	inline static public function getModCharacter(characterId:String)
	{
		var folder = getCharacterFolderPath(characterId);
		#if debug
			trace(folder);
		#end
		return FlxAtlasFrames.fromSparrow(Paths.getBitmapOutsideAssets('$folder/spritesheet.png'), Paths.getTextOutsideAssets('$folder/spritesheet.xml'));
	}

	inline static public function getCharacterIcon(key:String)
	{
		return getPath('icons/$key.png', IMAGE, "characters");
	}

	inline static public function getCharacterPacker(key:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(getPath('$key.png', IMAGE, "characters"), file('$key.txt', "characters"));
	}

	inline static public function getModCharacterPacker(characterId:String)
	{
		var folder = getCharacterFolderPath(characterId);
		return FlxAtlasFrames.fromSpriteSheetPacker(Paths.getBitmapOutsideAssets('$folder/spritesheet.png'), Paths.getTextOutsideAssets('$folder/spritesheet.txt'));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}
