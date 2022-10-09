package;

import haxe.Json;
import haxe.io.Path;
import openfl.system.ApplicationDomain;
import lime.app.Application;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.frames.FlxFramesCollection;
import haxe.io.Bytes;
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

import sys.thread.Thread;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	public static var curSelectedMod:String = null;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static var modsPath(get, null):String;
	
	public static function get_modsPath() {
		
		#if sourceCode
			return './../../../../mods';
		#elseif android
			return '${System.userDirectory}/YoshiCrafter Engine/mods';
		#else
			return './mods';
		#end
	}
	public static function getModsPath() {return modsPath;};
	
	public static function getPath(file:String, type:AssetType, ?library:Null<String>, forceLibrary:Bool = false)
	{
		if (!forceLibrary) {
			try {
				var p = "";
				if (!library.toLowerCase().startsWith("mods")
		         && library != "mods/~"
		         && library != "~"
				 && library != "skins"
				 && Settings.engineSettings != null
				 &&   (
					   (PlayState.current != null && OpenFlAssets.exists(p = getLibraryPathForce('songs/${PlayState.current.curSong}/$file', 'mods/${Settings.engineSettings.data.selectedMod}')))
					|| OpenFlAssets.exists(p = getLibraryPathForce(file, 'mods/${Settings.engineSettings.data.selectedMod}'))
					|| OpenFlAssets.exists(p = getLibraryPathForce(file, curSelectedMod))
					|| OpenFlAssets.exists(p = getLibraryPathForce(file, "mods/Friday Night Funkin'")))) { // can use assets from the fnf mod itself
					return p;
				}
			} catch(e) {

			}
		}
		
		
		file = file.replace("\\", "/");
		while(file.contains("//")) {
			file = file.replace("//", "/");
		}
		while(file.startsWith("/")) file = file.substr(1);
		if (library == "~") library = "skins";
		if (library == "mods/~") library = "skins";
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

	inline static function parseJson(path:String, ?library:String) {
		return Json.parse(OpenFlAssets.getText(Paths.json(path, library)));
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
		if (Assets.exists(p)) {
			voices = p;
		}
		return voices.toLowerCase();
	}
	
	inline static public function getSkinsPath() {
		#if android
			return '${System.userDirectory}/YoshiCrafter Engine/skins/';
		#else
			return "./skins/";
		#end
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}


	inline static public function font(key:String, ?library:String)
	{
		key = Path.withoutExtension(key);
		var path = getPath('fonts/$key', FONT, library);
		var p = "";
		if (Assets.exists(path)) {
			p = Assets.getPath(path);
		} else {
			p = path;
		}
		if (Path.extension(p).trim() == "") p = '$p.ttf';
		return p;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, useImagesFolder:Bool = true)
	{
		if (useImagesFolder)
			return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		else
			return FlxAtlasFrames.fromSparrow(file('$key.png', library), file('$key.xml', library));
	}

	public static function fromSparrow(imageKey:String, xmlKey:String) {
		// return FlxAtlasFrames.fromSparrow(imageKey, xmlKey);
	}

	
	inline static public function getCharacterAssetsPath(char:String):CharAssetPath {

		var split = char.split(":");

		var mod = "Friday Night Funkin'";
		var char = split[split.length - 1];
		if (split.length > 1)
			mod = split[0];

		var p:CharAssetPath = {
			imagePath: getPath('characters/${split[split.length - 1]}/spritesheet.png', IMAGE, 'mods/$mod'),
			dataPath: file('characters/${split[split.length - 1]}/spritesheet.xml', TEXT, 'mods/$mod'),
			type: SPARROW
		}
		var jsonPath = file('characters/${split[split.length - 1]}/spritesheet.json', TEXT, 'mods/$mod');
		var txtPath = file('characters/${split[split.length - 1]}/spritesheet.txt', TEXT, 'mods/$mod');
		if (Assets.exists(txtPath)) {
			p.dataPath = txtPath;
			p.type = SPRITESHEET_PACKER;
		} else if (Assets.exists(jsonPath)) {
			p.dataPath = jsonPath;
			p.type = TEXTURE_PACKER;
		}
		return p;
	}
	inline static public function getCharacter(char:String)
	{
		var data = getCharacterAssetsPath(char);
		return switch(data.type) {
			case SPRITESHEET_PACKER:
				return FlxAtlasFrames.fromSpriteSheetPacker(data.imagePath, data.dataPath);
			case TEXTURE_PACKER:
				return FlxAtlasFrames.fromTexturePackerJson(data.imagePath, data.dataPath);
			case _:
				return FlxAtlasFrames.fromSparrow(data.imagePath, data.dataPath);
		};
	}

	public inline static function unloadCharacter(char:String, mod:String) {
		if (mod == null) mod = curSelectedMod;
		if (mod == null) mod = Settings.engineSettings.data.selectedMod;

		// literally clears every asset loaded from that folder
		Assets.cache.clear('mods/${mod}:assets/mods/${mod}/characters/${char}/');
	}

	inline static public function getCharacterPacker(char:String) {
		return getCharacter(char);
	}

	inline static public function video(key:String, ?library:String)
	{
		key = key.trim().replace("/", "/").replace("\\", "/");
		return getPath('videos/$key.mp4', BINARY, library);
	}

	inline static public function getCharacterFolderPath(characterId:String):String {
		var splittedCharacterID = characterId.split(":");
		var charName = "";
		var charMod = "";
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

	inline static public function splashes(path:String, ?library:String) {
		return Path.withoutExtension(getPath('images/$path.png', IMAGE, library));
	}

	inline static public function shader(name:String, ?mod:String) {
		if (mod == null) {
			mod = "Friday Night Funkin'";
			if (curSelectedMod.startsWith("mods/")) {
				mod = curSelectedMod.substr(5);
			}
		}
		return '$mod:$name';
	}

	inline static public function shaderFrag(key:String, ?library:String) {
		return getPath('shaders/$key.frag', TEXT, library);
	}

	inline static public function shaderVert(key:String, ?library:String) {
		return getPath('shaders/$key.vert', TEXT, library);
	}

	public static function characterExists(character:String, mod:String):Bool {
		return (FileSystem.exists('${Paths.modsPath}/$mod/characters/$character/spritesheet.png') && (FileSystem.exists('${Paths.modsPath}/$mod/characters/$character/spritesheet.xml') || FileSystem.exists('${Paths.modsPath}/$mod/characters/$character/spritesheet.json')));
	}

	inline static public function getCharacterIcon(key:String, library:String)
	{
		return getPath('characters/$key/icon.png', IMAGE, library);
	}

	inline static public function getCharacterIconXml(key:String, library:String)
	{
		return getPath('characters/$key/icon.xml', IMAGE, library);
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}

typedef CharAssetPath = {
	var imagePath:String;
	var dataPath:String;
	var type:CharAssetType;
}

@:enum
abstract CharAssetType(Int) {
	var SPARROW = 0;
	var TEXTURE_PACKER = 1;
	var SPRITESHEET_PACKER = 2;
}