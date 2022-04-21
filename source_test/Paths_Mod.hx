import EngineSettings.Settings;
import lime.utils.Assets;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.media.Sound;
import flixel.FlxG;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

class Paths_Mod {
    private var mod:String;
    public function new(mod:String, settings:Dynamic) {
        this.mod = mod;
        trace(settings);
        // if (settings.cloneBitmap != null) {
        //     if (Std.isOfType(settings.cloneBitmap, Bool)) {
        //         copyBitmap = settings.cloneBitmap;
        //     }
        // }
    }

    public function getModsFolder() {
        return Paths.modsPath;
    }

    private function readTextFile(path:String) {
        if (FileSystem.exists(path)) {
            return File.getContent(path);
        } else {
            PlayState.log.push('Paths : File at "$path" does not exist');
            return "";
        }
    }

    public function file(file:String) {
        // var mFolder = Paths.modsPath;
        // var path = '$mFolder/$mod/$file';
        // if (!FileSystem.exists(path)) {
        //     PlayState.log.push('Paths : File at "$path" does not exist');
        // }
        // return path;
        
        return Paths.file(file, TEXT, 'mods/$mod');
    }

    public function font(font:String) {
        return FileSystem.absolutePath('${Paths.modsPath}/$mod/fonts/$font.ttf');
    }

    public function txt(file:String):String {
        var mFolder = Paths.modsPath;
        return Paths.txt(file, 'mods/$mod');
    }

    public function xml(file:String):String {
        var mFolder = Paths.modsPath;
        return Paths.xml(file, 'mods/$mod');
    }

    public function json(file:String):String {
        var mFolder = Paths.modsPath;
        return Paths.json(file, 'mods/$mod');
    }

    // No support for it yet, sorry
    // public function getAnimateManager(path:String, onFinish:AssetManager->Void) {
    //     var mFolder = Paths.modsPath;
    //     var path = '$mFolder/$mod/images/$path/';
    //     var assets:AssetManager = new AssetManager();
    //     assets.enqueue(path);
    //     assets.loadQueue(onFinish);
    // }

    public function parseJson(file:String) {
        return Json.parse(Assets.getText(json(file)));
    }

    public function video(key:String) {
        return '${Paths.modsPath}/$mod/videos/$key.mp4';
    }

    public function soundRandom(file:String, min:Int, max:Int) {
        var r = FlxG.random.int(min, max);
        return sound('$file$r');
    }
    public function sound(file:String) {
        return Paths.sound(file, 'mods/$mod');
        // return Paths.getSoundExtern('${Paths.modsPath}/$mod/sounds/$file.ogg');
    }

    public function music(file:String) {
        return Paths.music(file, 'mods/$mod');
        // return Paths.getSoundExtern('${Paths.modsPath}/$mod/music/$file.ogg');
    }

    public function image(key:String) {
        // var mFolder = Paths.modsPath;
        // var p = '$mFolder/$mod/images/$key.png';
        // if (FileSystem.exists(p)) {
        //     return Paths.getBitmapOutsideAssets(p);
        // } else {
        //     PlayState.log.push('Paths : Image at "$p" does not exist');
        //     return null;
        // }
        return Paths.image(key, 'mods/$mod');
    }

    public function getSparrowAtlas(key:String):FlxAtlasFrames {
        return Paths.getSparrowAtlas(key, 'mods/$mod');
    }

    public function getCharacterPacker(char:String) {
        var splitChar = CoolUtil.getCharacterFull(char, mod);
        // TODO
        // return Paths.getModCharacterPacker(key, 'mods/$mod');
        return FlxAtlasFrames.fromSpriteSheetPacker(Paths.getPath('characters/${splitChar[1]}/spritesheet.png', IMAGE, splitChar[0] == "~" ? 'skins' : 'mods/${splitChar[0]}'), Paths.getPath('characters/${splitChar[1]}/spritesheet.txt', TEXT, splitChar[0] == "~" ? "skins" : 'mods/${splitChar[0]}'));
    }

    public function getCharacter(char:String) {
        var splitChar = CoolUtil.getCharacterFull(char, mod);
        
        // if (!Paths.characterExists(splitChar[0], splitChar[1])) splitChar = ["Friday Night Funkin'", "unknown"];
        if (splitChar[0] == "~") {
            return Paths.getCharacter(splitChar[1], 'skins');
        } else {
            return Paths.getCharacter(splitChar[1], 'mods/${splitChar[0]}');
        }
    }

    public function getPackerAtlas(key:String) {
        // var mFolder = Paths.modsPath;
        // var png = '$mFolder/$mod/images/$key.png';
        // var txt = '$mFolder/$mod/images/$key.txt';
        // if (FileSystem.exists(png) && FileSystem.exists(txt)) {
        //     var b = Paths.getBitmapOutsideAssets(png);
        //     // if (copyBitmap) b = b.clone();
        //     return FlxAtlasFrames.fromSpriteSheetPacker(b, Paths.getTextOutsideAssets(txt));
        // } else {
        //     PlayState.log.push('Paths : Packer Atlas at "$mFolder/$mod/images/$key" does not exist. Make sure there is an XML and a PNG file');
        //     return null;
        // }
        return Paths.getPackerAtlas(key, 'mods/$mod');
    }
}