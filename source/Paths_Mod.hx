import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.media.Sound;
import flixel.FlxG;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

class Paths_Mod {
    private var mod:String;
    public var copyBitmap:Bool = false;
    public function new(mod:String, settings:Dynamic) {
        this.mod = mod;
        trace(settings);
        if (settings.cloneBitmap != null) {
            if (Std.isOfType(settings.cloneBitmap, Bool)) {
                copyBitmap = settings.cloneBitmap;
            }
        }
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
        var mFolder = Paths.modsPath;
        var path = '$mFolder/$mod/$file';
        if (!FileSystem.exists(path)) {
            PlayState.log.push('Paths : File at "$path" does not exist');
        }
    }

    public function txt(file:String):String {
        var mFolder = Paths.modsPath;
        return readTextFile('$mFolder/$mod/data/$file.txt');
    }

    public function xml(file:String):String {
        var mFolder = Paths.modsPath;
        return readTextFile('$mFolder/$mod/data/$file.xml');
    }

    public function json(file:String):String {
        var mFolder = Paths.modsPath;
        return readTextFile('$mFolder/$mod/data/$file.json');
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
        return Json.parse(json(file));
    }

    public function video(key:String) {
        return '${Paths.modsPath}/$mod/videos/$key.mp4';
    }

    public function soundRandom(file:String, min:Int, max:Int):Sound {
        var r = FlxG.random.int(min, max);
        return sound('$file$r');
    }
    public function sound(file:String):Sound {
        var mFolder = Paths.modsPath;
        #if web
            return Sound.fromFile('$mFolder/$mod/sounds/$file.mp3');
        #else
            return Sound.fromFile('$mFolder/$mod/sounds/$file.ogg');
        #end
    }

    public function music(file:String):Sound {
        var mFolder = Paths.modsPath;
        #if web
            return Sound.fromFile('$mFolder/$mod/music/$file.mp3');
        #else
            return Sound.fromFile('$mFolder/$mod/music/$file.ogg');
        #end
    }

    public function image(key:String):BitmapData {
        var mFolder = Paths.modsPath;
        var p = '$mFolder/$mod/images/$key.png';
        if (FileSystem.exists(p)) {
            if (copyBitmap) {
                return Paths.getBitmapOutsideAssets(p).clone();
            } else {
                return Paths.getBitmapOutsideAssets(p);
            }
        } else {
            PlayState.log.push('Paths : Image at "$p" does not exist');
            return null;
        }
    }

    public function getSparrowAtlas(key:String):FlxAtlasFrames {
        var mFolder = Paths.modsPath;
        var png = '$mFolder/$mod/images/$key.png';
        var xml = '$mFolder/$mod/images/$key.xml';
        if (FileSystem.exists(png) && FileSystem.exists(xml)) {
            var b:BitmapData;
            if (copyBitmap) {
                b = Paths.getBitmapOutsideAssets(png).clone();
            } else {
                b = Paths.getBitmapOutsideAssets(png);
            }
            return FlxAtlasFrames.fromSparrow(b, Paths.getTextOutsideAssets(xml));
        } else {
            PlayState.log.push('Paths : Sparrow Atlas at "$mFolder/$mod/images/$key" does not exist. Make sure there is an XML and a PNG file');
            return null;
        }
    }

    public function getCharacterPacker(char:String):FlxAtlasFrames {
        var splitChar = CoolUtil.getCharacterFull(char, mod);
        var path = '${Paths.modsPath}/${splitChar[0]}/characters/${splitChar[1]}';
        if (splitChar[0] == "~") {
			// YOOOOO SKIN SUPPORT
			path = '${Paths.getSkinsPath()}/${splitChar[1]}/';
		}
        var png = '$path/spritesheet.png';
        var txt = '$path/spritesheet.txt';
        if (FileSystem.exists(png) && FileSystem.exists(txt)) {
            var b = Paths.getBitmapOutsideAssets(png);
            if (copyBitmap) b = b.clone();
            return FlxAtlasFrames.fromSpriteSheetPacker(b, Paths.getTextOutsideAssets(txt));
        } else {
            PlayState.log.push('Paths : Sprite Sheet Packer at "$path/spritesheet" does not exist. Make sure there is an TXT and a PNG file');
            return null;
        }
    }

    public function getCharacter(char:String) {
        var splitChar = CoolUtil.getCharacterFull(char, mod);
        return Paths.getModCharacter(splitChar.join(":"));
    }

    public function getPackerAtlas(key:String) {
        var mFolder = Paths.modsPath;
        var png = '$mFolder/$mod/images/$key.png';
        var txt = '$mFolder/$mod/images/$key.txt';
        if (FileSystem.exists(png) && FileSystem.exists(txt)) {
            var b = Paths.getBitmapOutsideAssets(png);
            if (copyBitmap) b = b.clone();
            return FlxAtlasFrames.fromSpriteSheetPacker(b, Paths.getTextOutsideAssets(txt));
        } else {
            PlayState.log.push('Paths : Packer Atlas at "$mFolder/$mod/images/$key" does not exist. Make sure there is an XML and a PNG file');
            return null;
        }
    }
}