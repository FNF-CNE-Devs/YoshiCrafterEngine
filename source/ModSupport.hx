import haxe.io.Bytes;
// import zip.Zip;
// import zip.ZipEntry;
// import zip.ZipReader;
import Shaders.ColorShader;
#if desktop
import cpp.Lib;
#end
import flixel.util.FlxSave;
import lime.app.Application;
import haxe.PosInfos;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import flixel.util.FlxAxes;
import flixel.addons.text.FlxTypeText;
import openfl.display.PNGEncoderOptions;
import flixel.tweens.FlxEase;
import haxe.Json;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;
import sys.FileSystem;
import haxe.display.JsonModuleTypes.JsonTypeParameters;
import flixel.addons.effects.chainable.FlxShakeEffect;
import flixel.FlxBasic;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import sys.io.File;
import lime.utils.Assets;
import flixel.system.FlxAssets;
import EngineSettings.Settings;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.input.keyboard.FlxKey;
using StringTools;

#if windows
@:headerCode("#include <windows.h>")
@:headerCode("#undef RegisterClass")
#end

class ExceptionState extends FlxState {
    var text:String;
    var resumeTo = 0;
    public function new<T>(text:String, resumeTo:Int) {
        super();
        this.text = text;
        this.resumeTo = resumeTo;
    }
    public override function create() {
        super.create();
        var exceptionText = new FlxText(0,0,FlxG.width,text +"\r\n\r\nPress enter to retry.",8);
        exceptionText.setFormat(Paths.font("vcr.ttf"), Std.int(16), FlxColor.WHITE, LEFT);
        add(exceptionText);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (FlxControls.pressed.ENTER) {
            switch(resumeTo) {
                case 0:
                    FlxG.switchState(new PlayState());
            }
        }
    }
}

class MP4Video {
    // public var video:MP4Handler = new MP4Handler();
    // public var sprite:FlxSprite;
    // public var finishCallback:Void->Void = function() {
    //     PlayState.current.startCountdown();
    // };
    // public function new() {
    //     sprite = new FlxSprite(0, 0);
    // }

    public static function playMP4(path:String, callback:Void->Void, repeat:Bool = false):FlxSprite {
        
		#if X64_BITS
            var video = new MP4Handler();
            video.finishCallback = callback;
            var sprite = new FlxSprite(0,0);
            sprite.antialiasing = Settings.engineSettings.data.videoAntialiasing;
            video.playMP4(path, repeat, sprite, null, null, true);
            return sprite;
        #else
            callback();
            return new FlxSprite(0,0);
        #end
    }
}


class FlxColor_Helper {
    var fc:FlxColor;

    
    public var color(get, null):Int;
    public function get_color():Int {
        return fc;
    }

    public var alpha(get, set):Int;
    public function get_alpha():Int {return fc.alpha;}
    public function set_alpha(obj:Int):Int {fc.alpha = obj; return obj;}

    public var alphaFloat(get, set):Float;
    public function get_alphaFloat():Float {return fc.alphaFloat;}
    public function set_alphaFloat(obj:Float):Float {fc.alphaFloat = obj; return obj;}

    public var black(get, set):Float;
    public function get_black():Float {return fc.black;}
    public function set_black(obj:Float):Float {fc.black = obj; return obj;}

    public var blue(get, set):Int;
    public function get_blue():Int {return fc.blue;}
    public function set_blue(obj:Int):Int {fc.blue = obj; return obj;}

    public var blueFloat(get, set):Float;
    public function get_blueFloat():Float {return fc.blueFloat;}
    public function set_blueFloat(obj:Float):Float {fc.blueFloat = obj; return obj;}

    public var brightness(get, set):Float;
    public function get_brightness():Float {return fc.brightness;}
    public function set_brightness(obj:Float):Float {fc.brightness = obj; return obj;}

    public var cyan(get, set):Float;
    public function get_cyan():Float {return fc.cyan;}
    public function set_cyan(obj:Float):Float {fc.cyan = obj; return obj;}

    public var green(get, set):Int;
    public function get_green():Int {return fc.green;}
    public function set_green(obj:Int):Int {fc.green = obj; return obj;}

    public var greenFloat(get, set):Float;
    public function get_greenFloat():Float {return fc.greenFloat;}
    public function set_greenFloat(obj:Float):Float {fc.greenFloat = obj; return obj;}

    public var hue(get, set):Float;
    public function get_hue():Float {return fc.hue;}
    public function set_hue(obj:Float):Float {fc.hue = obj; return obj;}

    public var lightness(get, set):Float;
    public function get_lightness():Float {return fc.lightness;}
    public function set_lightness(obj:Float):Float {fc.lightness = obj; return obj;}

    public var magenta(get, set):Float;
    public function get_magenta():Float {return fc.magenta;}
    public function set_magenta(obj:Float):Float {fc.magenta = obj; return obj;}

    public var red(get, set):Int;
    public function get_red():Int {return fc.red;}
    public function set_red(obj:Int):Int {fc.red = obj; return obj;}

    public var redFloat(get, set):Float;
    public function get_redFloat():Float {return fc.redFloat;}
    public function set_redFloat(obj:Float):Float {fc.redFloat = obj; return obj;}

    public var saturation(get, set):Float;
    public function get_saturation():Float {return fc.saturation;}
    public function set_saturation(obj:Float):Float {fc.saturation = obj; return obj;}

    public var yellow(get, set):Float;
    public function get_yellow():Float {return fc.yellow;}
    public function set_yellow(obj:Float):Float {fc.yellow = obj; return obj;}

    public static function add(lhs:Int, rhs:Int):Int {return FlxColor.add(lhs, rhs);}
    public static function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float):FlxColor_Helper {return new FlxColor_Helper(FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha));}
    public static function fromHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float = 1):FlxColor_Helper {return new FlxColor_Helper(FlxColor.fromHSB(Hue, Saturation, Brightness, Alpha));}
    public static function fromHSL(Hue:Float, Saturation:Float, Lightness:Float, Alpha:Float = 1):FlxColor_Helper {return new FlxColor_Helper(FlxColor.fromHSL(Hue, Saturation, Lightness, Alpha));}
    public static function fromInt(Value:Int):FlxColor_Helper {return new FlxColor_Helper(Value);}
    public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):FlxColor_Helper {return new FlxColor_Helper(FlxColor.fromRGB(Red, Blue, Green, Alpha));}
    public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):FlxColor_Helper {return new FlxColor_Helper(FlxColor.fromRGBFloat(Red, Blue, Green, Alpha));}
    public static function fromString(str:String):Null<FlxColor_Helper> {
        var color = FlxColor.fromString(str);
        if (color == null)
            return null;
        else
            return new FlxColor_Helper(color);
    }
    public function getAnalogousHarmony(Threshold:Int = 30) {return fc.getAnalogousHarmony(Threshold);}
    public function getColorInfo() {return fc.getColorInfo();}
    public function getComplementHarmony() {return fc.getComplementHarmony();}
    public function getDarkened(Factor:Float = 0.2) {return fc.getDarkened(Factor);}
    public function getInverted() {return fc.getInverted();}
    public function getLightened(Factor:Float = 0.2) {return fc.getLightened(Factor);}
    public function getSplitComplementHarmony(Threshold:Int = 30) {return fc.getSplitComplementHarmony(Threshold);}
    public function getTriadicHarmony() {return fc.getTriadicHarmony();}
    public static function gradient(color1:Int, color2:Int, steps:Int, ?ease:Float -> Float) {return FlxColor.gradient(color1, color2, steps, ease);}
    public static function interpolate(color1:Int, color2:Int, Factor:Float = 0.5) {return FlxColor.interpolate(color1, color2, Factor);}
    public static function multiply(color1:Int, color2:Int) {return FlxColor.multiply(color1, color2);}
    public function setCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1) {return fc.setCMYK(Cyan, Magenta, Yellow, Black, Alpha);}
    public function setHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float) {return fc.setHSB(Hue, Saturation, Brightness, Alpha);}
    public function setHSL(Hue:Float, Saturation:Float, Lightness:Float, Alpha:Float) {return fc.setHSL(Hue, Saturation, Lightness, Alpha);}
    public function setRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int) {return fc.setRGB(Red, Green, Blue, Alpha);}
    public function setRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float) {return fc.setRGBFloat(Red, Green, Blue, Alpha);}
    public static function substract(color1:Int, color2:Int) {return FlxColor.subtract(color1, color2);}
    public function toHexString(Alpha:Bool = true, Prefix:Bool = true) {return fc.toHexString(Alpha, Prefix);}
    public function toWebString() {return fc.toWebString();}

    public function new(color:Int) {
        fc = new FlxColor(color);
    }
}

typedef CharacterSkin = {
    var name:String;
    var char:String;
}
typedef ModConfig = {
    var name:String;
    var locked:Null<Bool>;
    var description:String;
    var titleBarName:String;
    var skinnableBFs:Array<String>;
    var skinnableGFs:Array<String>;
    var BFskins:Array<CharacterSkin>;
    var GFskins:Array<CharacterSkin>;
    var keyNumbers:Array<Int>;
}
typedef ModScript = {
    var path:String;
    var mod:String;
}

// typedef ZipProgress = {
//     var progress:Float;
//     var zipReader:ZipReader;
// }
class ModSupport {
    public static var song_config_parser:hscript.Interp;
    public static var song_modchart_path:String = "";
    public static var song_stage_path:String = "";
    public static var song_cutscene_path:String = "";

    public static var song_cutscene:ModScript = null;
    public static var song_end_cutscene:ModScript = null;
    public static var currentMod:String = "Friday Night Funkin'";

    public static var scripts:Array<ModScript> = [];

    public static var modConfig:Map<String, ModConfig> = null;

    public static var modSaves:Map<String, FlxSave> = [];
    public static var mFolder = Paths.modsPath;

    public static function getMods():Array<String> {
        var modFolder = Paths.modsPath;
        var a = FileSystem.readDirectory(modFolder);
        var finalArray = [];
        for (e in a) {
            if (FileSystem.isDirectory('$modFolder/$e')) finalArray.push(e);
        }
        return finalArray;
    }
    public static function reloadModsConfig() {
        modConfig = [];
        for(mod in getMods()) {
            var json:ModConfig = null;
            if (FileSystem.exists('$mFolder/$mod/config.json')) {
                try {
                    json = Json.parse(Paths.getTextOutsideAssets('$mFolder/$mod/config.json'));
                } catch(e) {
                    for (e in ('Failed to parse mod config for $mod.').split('\n')) PlayState.log.push(e);
                }
            }
            if (json == null) json = {
                name: null,
                description: null,
                titleBarName: null,
                skinnableGFs: null,
                skinnableBFs: null,
                BFskins: null,
                GFskins: null,
                keyNumbers: null,
                locked: false
            };
            modConfig[mod] = json;
        }
    }
    #if windows
    public static function changeWindowIcon(iconPath:String) {
        
    }
    #end
    public static function getExpressionFromPath(path:String, critical:Bool = false):hscript.Expr {
        var parser = new hscript.Parser();
		parser.allowTypes = true;
        var ast = null;
		try {
			#if sys
			ast = parser.parseString(sys.io.File.getContent(path));
			#else
            trace("no sys support");
            #end
		} catch(ex) {
			trace(ex);
            var exThingy = Std.string(ex);
            var line = parser.line;
            if (!openfl.Lib.application.window.fullscreen) openfl.Lib.application.window.alert('Failed to parse the file located at "$path".\r\n$exThingy at $line');
            // if (critical) {
            //     FlxG.switchState(new ExceptionState('Failed to parse the file located at "$path".\r\n$exThingy at $line', 0));
            // }
            trace('Failed to parse the file located at "$path".\r\n$exThingy at $line');
		}
        return ast;
    }

    public static function hTrace(text:String, hscript:hscript.Interp) {
        var posInfo = hscript.posInfos();

        var fileName = posInfo.fileName;
        var lineNumber = Std.string(posInfo.lineNumber);
        var methodName = posInfo.methodName;
        var className = posInfo.className;
        trace('$fileName:$methodName:$lineNumber: $text');

        if (!Settings.engineSettings.data.developerMode) return;
        for (e in ('$fileName:$methodName:$lineNumber: $text').split("\n")) PlayState.log.push(e.trim());
    }

    public static function setHaxeFileDefaultVars(hscript:hscript.Interp, mod:String, settings:Dynamic) {
		hscript.variables.set("mod", mod);
		hscript.variables.set("PlayState", PlayState.current);
		hscript.variables.set("EngineSettings", PlayState.current.engineSettings);
        hscript.variables.set("include", function(path:String) {
            var splittedPath = path.split(":");
            if (splittedPath.length < 2) splittedPath.insert(0, mod);
            var joinedPath = splittedPath.join("/");
            var mFolder = Paths.modsPath;
            var expr = getExpressionFromPath('$mFolder/$joinedPath.hx');
            if (expr != null) {
                hscript.execute(expr);
            }
        });

        if (PlayState.current != null) {
            hscript.variables.set("global", PlayState.current.vars);
        }
        hscript.variables.set("trace", function(text) {
            try {
                hTrace(text, hscript);
            } catch(e) {
                trace(e);
            }
            
        });
		hscript.variables.set("PlayState_", PlayState);
		hscript.variables.set("FlxSprite", FlxSprite);
		hscript.variables.set("BitmapData", BitmapData);
		hscript.variables.set("FlxG", FlxG);
		hscript.variables.set("Paths", new Paths_Mod(mod, settings));
		hscript.variables.set("Paths_", Paths);
		hscript.variables.set("Std", Std);
		hscript.variables.set("Math", Math);
		hscript.variables.set("FlxMath", FlxMath);
		hscript.variables.set("FlxAssets", FlxAssets);
        hscript.variables.set("Assets", Assets);
		hscript.variables.set("ModSupport", ModSupport);
		hscript.variables.set("Note", Note);
		hscript.variables.set("Character", Character);
		hscript.variables.set("Conductor", Conductor);
		hscript.variables.set("StringTools", StringTools);
		hscript.variables.set("FlxSound", FlxSound);
		hscript.variables.set("FlxEase", FlxEase);
		hscript.variables.set("FlxTween", FlxTween);
		// hscript.setVariable("File", File);
		// hscript.setVariable("FileSystem", FileSystem);
		hscript.variables.set("FlxColor", FlxColor_Helper);
		hscript.variables.set("Boyfriend", Boyfriend);
		hscript.variables.set("FlxTypedGroup", FlxTypedGroup);
		hscript.variables.set("BackgroundDancer", BackgroundDancer);
		hscript.variables.set("BackgroundGirls", BackgroundGirls);
		hscript.variables.set("FlxTimer", FlxTimer);
		hscript.variables.set("Json", Json);
		hscript.variables.set("MP4Video", MP4Video);
		// hscript.setVariable("PNGEncoderOptions", PNGEncoderOptions);
		hscript.variables.set("CoolUtil", CoolUtil);
		hscript.variables.set("FlxTypeText", FlxTypeText);
		hscript.variables.set("FlxText", FlxText);
		hscript.variables.set("FlxAxes", FlxAxes);
		hscript.variables.set("BitmapDataPlus", BitmapDataPlus);
		hscript.variables.set("Rectangle", Rectangle);
		hscript.variables.set("Point", Point);
		hscript.variables.set("Window", Application.current.window);
		hscript.variables.set("ColorShader", Shaders.ColorShader);
		hscript.variables.set("BlammedShader", Shaders.BlammedShader);
		hscript.variables.set("GameOverSubstate", GameOverSubstate);
		hscript.variables.set("ModSupport", null);

        // SHADERS

		hscript.variables.set("CustomShader", CustomShader);
		// hscript.setVariable("FlxColor", Int);
    }

    public static function saveModData(mod:String):Bool {
        if (FileSystem.exists('${Paths.modsPath}/$mod/')) {
            if (modConfig[mod] != null) {
                File.saveContent('${Paths.modsPath}/$mod/config.json', Json.stringify(modConfig[mod], "\t"));
                return true;
            }
        }
        return false;
    }
    public static function getModName(mod:String):String {
        var name = mod;
        if (modConfig[mod] != null) {
            if (modConfig[mod].name != null) {
                name = modConfig[mod].name.trim();
            }
        }
        return name;
    }
    public static function setScriptDefaultVars(script:Script, mod:String, settings:Dynamic) {
		script.setVariable("mod", mod);
		script.setVariable("PlayState", PlayState.current);
        // script.setVariable("include", function(path:String) {
        //     var splittedPath = path.split(":");
        //     if (splittedPath.length < 2) splittedPath.insert(0, mod);
        //     var joinedPath = splittedPath.join("/");
        //     var mFolder = Paths.modsPath;
        //     var expr = getExpressionFromPath('$mFolder/$joinedPath.hx');
        //     if (expr != null) {
        //         hscript.execute(expr);
        //     }
        // });

        if (PlayState.current != null) {
            script.setVariable("EngineSettings", PlayState.current.engineSettings);
            script.setVariable("global", PlayState.current.vars);
            script.setVariable("loadStage", function(stagePath) {
                return new Stage(stagePath, mod);
            });

        } else {
            script.setVariable("EngineSettings", {});
            script.setVariable("global", {});
            script.setVariable("loadStage", function(stagePath) {
                return null;
            });
        }
        script.setVariable("trace", function(text) {
            try {
                script.trace(text);
            } catch(e) {
                trace(e);
            } 
        });
		script.setVariable("PlayState_", PlayState);
		script.setVariable("FlxSprite", FlxSprite);
		script.setVariable("BitmapData", BitmapData);
		script.setVariable("FlxG", FlxG);
		script.setVariable("Paths", new Paths_Mod(mod, settings));
		script.setVariable("Paths_", Paths);
		script.setVariable("Std", Std);
		script.setVariable("Math", Math);
		script.setVariable("FlxMath", FlxMath);
		script.setVariable("FlxAssets", FlxAssets);
        script.setVariable("Assets", Assets);
		script.setVariable("ModSupport", ModSupport);
		script.setVariable("Note", Note);
		script.setVariable("Character", Character);
		script.setVariable("Conductor", Conductor);
		script.setVariable("StringTools", StringTools);
		script.setVariable("FlxSound", FlxSound);
		script.setVariable("FlxEase", FlxEase);
		script.setVariable("FlxTween", FlxTween);
		script.setVariable("FlxColor", FlxColor_Helper);
		script.setVariable("Boyfriend", Boyfriend);
		script.setVariable("FlxTypedGroup", FlxTypedGroup);
		script.setVariable("BackgroundDancer", BackgroundDancer);
		script.setVariable("BackgroundGirls", BackgroundGirls);
		script.setVariable("FlxTimer", FlxTimer);
		script.setVariable("Json", Json);
		script.setVariable("MP4Video", MP4Video);
		script.setVariable("CoolUtil", CoolUtil);
		script.setVariable("FlxTypeText", FlxTypeText);
		script.setVariable("FlxText", FlxText);
		script.setVariable("FlxAxes", FlxAxes);
		script.setVariable("BitmapDataPlus", BitmapDataPlus);
		script.setVariable("Rectangle", Rectangle);
		script.setVariable("Point", Point);
		script.setVariable("Window", Application.current.window);

		script.setVariable("ColorShader", Shaders.ColorShader);
		script.setVariable("BlammedShader", Shaders.BlammedShader);
		script.setVariable("GameOverSubstate", GameOverSubstate);
		script.setVariable("ModSupport", null);
		script.setVariable("CustomShader", CustomShader);
		// script.setVariable("FlxKey", FlxKey);


    }
    public static function parseSongConfig() {
        var songName = PlayState._SONG.song.toLowerCase();
        var songCodePath = Paths.modsPath + '/$currentMod/song_conf';

        var songConf = SongConf.parse(PlayState.songMod, PlayState.SONG.song);

        scripts = songConf.scripts;
        song_cutscene = songConf.cutscene;
        song_end_cutscene = songConf.end_cutscene;
        // var parser = new hscript.Parser();
        // parser.allowTypes = true;
        // var ast = null;
        #if sys
        // ast = parser.parseString(sys.io.File.getContent(songCodePath));
        #end
        
        // scripts = [];
        // scripts.push(getModScriptFromValue('stages/$stage'));
        // for (s in sc) {
        //     scripts.push(getModScriptFromValue(s));
        // }

        // OUTDATED CODE, HOW TF DID I WROTE THIS IN RELEASE
        // if (stage == "default_stage")
        //     song_stage_path = Paths.modsPath + '/Friday Night Funkin\'/stages/$stage'; // fallback
        // else
        //     song_stage_path = Paths.modsPath + '/$currentMod/stages/$stage';

        // if (modchart != "")
        //     song_modchart_path = Paths.modsPath + '/$currentMod/modcharts/$modchart';
        // else
        //     song_modchart_path = "";

        

        // trace(scripts);
        // trace(song_stage_path);
        // trace(song_modchart_path);
    }

    

    // UNUSED
    public static function getFreeplaySongs():Array<String> {
        var folders:Array<String> = [];
        var songs:Array<String> = [];
        #if sys
            var folders:Array<String> = sys.FileSystem.readDirectory(Paths.modsPath + "/");
        #end

        for (mod in folders) {
            trace(mod);
            var freeplayList:String = "";
            #if sys
                try {
                    freeplayList = sys.io.File.getContent(Paths.modsPath + "/" + mod + "/data/freeplaySonglist.txt");
                } catch(e) {
                    freeplayList = "";
                }
            #end
            for(s in freeplayList.trim().replace("\r", "").split("\n")) if (s != "") songs.push('$mod:$s');
        }
        return songs;
    }

    /*
    public static function installModFromZip(zipPath:String, callback:Void->Void):ZipProgress {
        var fileContent = File.getBytes(zipPath);
        var zip = new ZipReader(fileContent);

        var thingy:ZipProgress = {
            progress: 0,
            zipReader: zip
        };
        #if (target.threaded)
        sys.thread.Thread.create(function() {
        #end
            var entries:Map<String, ZipEntry> = [];
            while(true) {
                var entry = zip.getNextEntry();
                if (entry == null) break;
                entries[entry.fileName] = entry;
                thingy.progress = zip.progress() / 2;
            }
            var p = 0;
            var keys = entries.keys();
            var am = [while (keys.hasNext()) keys.next()];
            for(k=>e in entries) {
                // wtf
                var bytes:Bytes = cast(Zip.getBytes(entries.get(k)), Bytes);
                File.saveBytes('${Paths.modsPath}/$k', bytes);
                p++;
                thingy.progress = 0.5 + (p / am.length / 2);
            }
            callback();
        #if (target.threaded)
        });
        #end
        return thingy;
    }
    */
}