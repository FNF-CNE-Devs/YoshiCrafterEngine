package;

import openfl.system.ApplicationDomain;
import lime.app.Application;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxFramesCollection;
import haxe.io.Bytes;
import EngineSettings.Settings;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;
import lime.system.System;
import lime.utils.AssetLibrary;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	public static var currentLibrary:String = ""; // FOR SCRIPTS!!!

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static var modsPath(get, null):String;
	public static var savesPath(get, null):String;

	public static function getSoundExtern(path:String) {
		var cPath = getCachePath(path);
		if (cacheSound[cPath] == null) {
			cacheSound[cPath] = Sound.fromFile(path);
		}
		return cacheSound[cPath];
	}
	public static function get_modsPath() {
		
		#if sourceCode
			return './../../../../mods';
		#elseif android
			return '${System.userDirectory}/YoshiCrafter Engine/mods';
		#else
			return './mods';
		#end
	}
	public static function get_savesPath() {
		#if android
			return FileSystem.absolutePath('${System.userDirectory}/YoshiCrafter Engine/saves/');
		#else
			return FileSystem.absolutePath('./saves/');
		#end
	}

	public static function getModsPath() {return modsPath;};
	
	public static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		file = file.replace("\\", "/");
		while(file.contains("//")) {
			file = file.replace("//", "/");
		}
		while(file.startsWith("/")) file = file.substr(1);
		if (library == "~") library = "skins";
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

	public static function clearModCache() {
		if (!Settings.engineSettings.data.memoryOptimization) return;
		Assets.cache.clear('mods/');
		Assets.cache.clear('skins');
		Assets.cache.clear('shared');
		Assets.cache.clear('preload');
	}
	public static function clearOtherModCache(currentMod:String) {
		if (!Settings.engineSettings.data.memoryOptimization) return;
		for (k=>m in ModSupport.modConfig) {
			trace(k);
			if (k.toLowerCase() != currentMod.toLowerCase()) {
				Assets.cache.clear('mods/${k.toLowerCase()}');
			}
		}
		Assets.cache.clear('skins');
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		var finalPath = '$library:assets/$library/$file';
		if (library.startsWith("mods/") || library.toLowerCase() == "skins")
			finalPath = finalPath.toLowerCase();
		return finalPath;
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

	inline static public function stage(key:String, ?library:String, ?ext:String = "json")
	{
		return getPath('stages/$key.$ext', TEXT, library);
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

	inline static public function modInst(song:String, mod:String, ?difficulty:String = "")
	{
		
		return getInstPath(song, mod, difficulty);
	}
	inline static public function getInstPath(song:String, mod:String, ?difficulty:String = "")
	{
		var inst = 'mods/$mod:assets/mods/$mod/songs/${song.toLowerCase()}/inst.ogg';
		if (Assets.exists('mods/$mod:assets/mods/$mod/songs/${song.toLowerCase()}/inst-${difficulty.toLowerCase()}.ogg'.toLowerCase())) {
			inst = 'mods/$mod:assets/mods/$mod/songs/${song.toLowerCase()}/inst-${difficulty.toLowerCase()}.ogg'.toLowerCase();
		}
		return inst.toLowerCase();
	}

	inline static public function modVoices(song:String, mod:String, ?difficulty:String = "")
	{
		difficulty = difficulty.trim();
		var voices = 'mods/$mod:assets/mods/$mod/songs/${song.toLowerCase()}/voices.ogg';
		var p = 'mods/$mod:assets/mods/$mod/songs/${song.toLowerCase()}/voices-${difficulty.toLowerCase()}.ogg'.toLowerCase();
		trace(p);
		if (Assets.exists(p)) {
			voices = p;
		}
		return voices.toLowerCase();
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
		#if android
			return '${System.userDirectory}/YoshiCrafter Engine/skins/';
		#else
			return "./skins/";
		#end
	}
	inline static public function getOldSkinsPath() {
		return System.applicationStorageDirectory + "../../YoshiCrafter29/YoshiCrafter Engine/skins/";
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function customizableImage(key:String, ?library:String)
	{
		var mPath = image(key, 'mods/${Settings.engineSettings.data.selectedMod}');
		if (!OpenFlAssets.exists(mPath))
			mPath = image(key, library);
		return mPath;
	}

	// inline static public function stageImage(key:String)
	// {
	// 	var p = ModSupport.song_stage_path;
	// 	return getBitmapOutsideAssets('$p/$key');
	// }

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getCustomizableSparrowAtlas(key:String, ?library:String)
	{
		var lib = 'mods/${Settings.engineSettings.data.selectedMod}';
		if (!OpenFlAssets.exists(image(key, lib)) || !OpenFlAssets.exists(file('images/$key.xml', lib))) {
			lib = library;
		}
		return FlxAtlasFrames.fromSparrow(image(key, lib), file('images/$key.xml', lib));
	}

	public static var cacheText:Map<String, String> = new Map<String, String>();
	public static var cacheBitmap:Map<String, BitmapData> = new Map<String, BitmapData>();
	public static var cacheBytes:Map<String, Bytes> = new Map<String, Bytes>();
	public static var cacheSparrow:Map<String, FlxAtlasFrames> = new Map<String, FlxAtlasFrames>();
	public static var cacheSound:Map<String, Sound> = new Map<String, Sound>();
	#if sys	
	
	public static function clearForMod(mod:String) {
		clearCache('${modsPath}/$mod');
	}

	inline static public function clearCache(?startsWith:String) {
		if (startsWith == null) startsWith = "";
		cacheText.clear();
		for (k=>bData in cacheBitmap) {
			if (k.startsWith(startsWith) && bData != null) {
				bData.dispose();
				bData.disposeImage();
				cacheBitmap[k] = null;
			}
		}
		if (startsWith.trim() == "") {
			cacheBitmap.clear();
			cacheBytes.clear();
			// for (c in cacheSparrow) 
			// 	FlxDestroyUtil.destroy(c);
			cacheSparrow.clear();	
		} else {
			for (k => b in cacheBytes) {
				if (k.startsWith(startsWith)) {
					cacheBytes[k] = null;
				}
			}
			for (k => b in cacheSparrow) {
				if (k.startsWith(startsWith)) {
					cacheSparrow[k].destroy();
					cacheSparrow[k] = null;
				}
			}
			for (k => b in cacheText) {
				if (k.startsWith(startsWith)) {
					cacheText[k] = null;
				}
			}
			for (k => b in cacheSound) {
				if (k.startsWith(startsWith)) {
					cacheSound[k].close();
					cacheSound[k] = null;
				}
			}
		}
	}

	public static function getCachePath(path:String) {
		return path.replace("\\", "/").trim().toLowerCase();
	}
	inline static public function getTextOutsideAssets(path:String, log:Bool = false) {
		
		var cachePath = getCachePath(path);
		if (Settings.engineSettings.data.developerMode) {
			if (!FileSystem.exists(path)) {
				PlayState.log.push('Paths : Text file at "$path" does not exist.');
			}
		}

		if (cacheText[cachePath] == null) cacheText[cachePath] = sys.io.File.getContent(path);
		// if (Paths.cacheText[path] == null) {
		// 	if (log) trace('Getting file content at "$path"');
		// 	Paths.cacheText[path] = sys.io.File.getContent(path);
		// }

		// THIS is causing some PROBLEMS.
		// return sys.io.File.getContent(path);

		return cacheText[cachePath];
	}

	#end
	inline static public function getBitmapOutsideAssets(path:String) {
		// trace(path);
		
		var cachePath = getCachePath(path);
		if (Settings.engineSettings.data.developerMode) {
			if (!FileSystem.exists(cachePath)) {
				PlayState.log.push('Paths : Bitmap at "$path" does not exist.');
			}
		}
		if (Paths.cacheBitmap[cachePath] == null) {
			#if trace_everything trace('BitmapData not existent for $path.'); #end
			var bData = BitmapData.fromFile(path);
			// bData.dis
			Paths.cacheBitmap[cachePath] = bData;
		} else if (!Paths.cacheBitmap[cachePath].readable) {
			#if trace_everything trace('BitmapData not readable for $path.'); #end
			Paths.cacheBitmap[cachePath] = BitmapData.fromFile(path);
		}
		
		var b = Paths.cacheBitmap[cachePath];
		// if (copyBitmap) {
		// 	b = b.clone();
		// 	for(i in 0...0x7FFFFFFF) {
		// 		if (Paths.cacheBitmap[cachePath + "/" + Std.string(i)] == null) {
		// 			Paths.cacheBitmap[cachePath + "/" + Std.string(i)] = b;
		// 			break;
		// 		}
		// 	}
		// }
		return (Paths.cacheBitmap[cachePath]);
	}
	inline static public function getBytesOutsideAssets(path:String) {
		// trace(path);
		var cachePath = getCachePath(path);
		if (Settings.engineSettings.data.developerMode) {
			if (!FileSystem.exists(cachePath)) {
				PlayState.log.push('Paths : Byte file at "$path" does not exist.');
			}
		}
		if (Paths.cacheBytes[cachePath] == null) {
			Paths.cacheBytes[cachePath] = File.getBytes(path);
		}
		return Paths.cacheBytes[cachePath];
	}
	public static function getExternSparrow(key:String) {
		#if trace_everything trace("Getting bitmap"); #end
		var png = Paths.getBitmapOutsideAssets(key + ".png");

		#if trace_everything trace("Getting XML content"); #end
		var xml = Paths.getTextOutsideAssets(key + ".xml");
		var nFrames = FlxAtlasFrames.fromSparrow(png, xml);
		cacheSparrow[key] = nFrames;
		return nFrames;
	}
	inline static public function getSparrowAtlas_Custom(key:String, forceReload:Bool = false)
	{
		// Assets.registerLibrary("custom", AssetLibrary.(key + ".png"));
		// Assets.registerLibrary("custom", AssetLibrary.fromFile(key + ".xml"));
		#if sys
		key = key.trim().replace("/", "/").replace("\\", "/");
		if (cacheSparrow[key] != null) {
			if (cacheSparrow[key].frames != null && !forceReload) {
				if (cacheSparrow[key].parent.bitmap != null) {
					if (cacheSparrow[key].parent.bitmap.readable) {
						return cacheSparrow[key];
					} else {
						return getExternSparrow(key);
					}
				} else {
					return getExternSparrow(key);
				}
			} else {
				#if trace_everything trace('$key is dead, returning a new one'); #end
				return getExternSparrow(key);
			}
		} else {
			#if trace_everything trace('$key exists, returning from cache'); #end
			return getExternSparrow(key);
		}
		#else
		return null;
		#end
	}
	// inline static public function getSparrowAtlas_Stage(key:String)
	// {
	// 	key = key.trim().replace("/", "/").replace("\\", "/");
	// 	#if sys
	// 	return FlxAtlasFrames.fromSparrow(Paths.getLibraryPath(ModSupport.song_stage_path), Paths.getTextOutsideAssets(ModSupport.song_stage_path + '/$key.xml'));
	// 	// return FlxAtlasFrames.fromSparrow(Paths.getBitmapOutsideAssets(ModSupport.song_stage_path + '/$key.png'), Paths.getTextOutsideAssets(ModSupport.song_stage_path + '/$key.xml'));
	// 	#else
	// 	return null;
	// 	#end
	// }

	inline static public function getCharacter(key:String, library:String)
	{
		var jsonPath = file('characters/$key/spritesheet.json', TEXT, library);
		if (Assets.exists(jsonPath)) {
			// json (packer)
			return FlxAtlasFrames.fromTexturePackerJson(getPath('characters/$key/spritesheet.png', IMAGE, library), jsonPath);
		} else {
			// xml (sparrow)
			return FlxAtlasFrames.fromSparrow(getPath('characters/$key/spritesheet.png', IMAGE, library), file('characters/$key/spritesheet.xml', TEXT, library));
		}
	}

	inline static public function video(key:String, ?library:String)
	{
		key = key.trim().replace("/", "/").replace("\\", "/");
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
		if(charMod.toLowerCase() == "yoshiengine") charMod = "YoshiCrafterEngine";
		var folder = Paths.modsPath + '/$charMod/characters/$charName';
		if (charMod == "~") {
			// You have unlocked secret skin menu !
			folder = '${Paths.getSkinsPath()}/$charName';
		}
		trace(folder);
		
		var exists = false;
		for (e in Main.supportedFileTypes) {
			exists = FileSystem.exists('$folder/Character.$e');
			if (exists) break;
		}
		if (!exists) {
			folder = Paths.modsPath + '/Friday Night Funkin\'/characters/unknown';
		}
		return folder;
	}
	inline static public function getCharacterFolderPath_Array(character:Array<String>):String {
		return '${Paths.modsPath}/${character[0]}/characters/${character[1]}';
	}

	inline static public function splashes(path:String, ?library:String = "shared") {
		return getPath('images/$path', IMAGE, library);
	}
	inline static public function getModCharacter(characterId:String)
	{
		var folder = getCharacterFolderPath(characterId);
		#if debug
			trace(folder);
		#end
		var b = Paths.getBitmapOutsideAssets('$folder/spritesheet.png');
		
		return FlxAtlasFrames.fromSparrow(b, Paths.getTextOutsideAssets('$folder/spritesheet.xml'));
	}

	public static function characterExists(character:String, mod:String):Bool {
		return (FileSystem.exists('${Paths.modsPath}/$mod/characters/$character/spritesheet.png') && (FileSystem.exists('${Paths.modsPath}/$mod/characters/$character/spritesheet.xml') || FileSystem.exists('${Paths.modsPath}/$mod/characters/$character/spritesheet.json')));
	}

	inline static public function getCharacterIcon(key:String, library:String)
	{
		if (library == "mods/~" || library.endsWith("~")) library = "skins";
		return getPath('characters/$key/icon.png', IMAGE, library);
	}

	inline static public function getCharacterIconXml(key:String, library:String)
	{
		if (library == "mods/~" || library.endsWith("~")) library = "skins";
		return getPath('characters/$key/icon.xml', IMAGE, library);
	}

	// inline static public function getCharacterPacker(key:String)
	// {
	// 	return FlxAtlasFrames.fromSpriteSheetPacker(getPath('$key.png', IMAGE, "characters"), file('$key.txt', "characters"));
	// }

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
