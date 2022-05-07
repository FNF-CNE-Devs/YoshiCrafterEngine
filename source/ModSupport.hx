import animateatlas.AtlasFrameMaker;
import Script.HScript;
import haxe.EnumTools;
import mod_support_stuff.ModState;
import hscript.Expr;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetManifest;
import haxe.io.Path;
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
import mod_support_stuff.*;
import stage.Stage;

using StringTools;

#if windows
@:headerCode("#include <windows.h>")
@:headerCode("#undef RegisterClass")
#end

typedef CacheExpr = {
	var code:Expr;
	var time:Null<Float>;
}

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

    public static function getAssetFiles(assets:Array<Dynamic>, rootPath:String, path:String, libraryName:String, prefix:String = "", addRoot:Bool = false) {
        for(f in FileSystem.readDirectory('$rootPath$path')) {
            if (FileSystem.isDirectory('$rootPath$path$f')) {
                getAssetFiles(assets, rootPath, '$path$f/', libraryName);
            } else {
                var type = "BINARY";
                switch(Path.extension(f).toLowerCase()) {
                    case "txt" | "xml" | "json" | "hx" | "hscript" | "hsc" | "lua":
                        type = "TEXT";
                    case "png":
                        type = "IMAGE";
                    case "ogg":
                        type = path.toLowerCase().startsWith("music") ? "MUSIC" : "SOUND";
                    case "ttf":
                        type = "FONT";

                }
                assets.push({
                    type: type,
                    id: ('assets/$libraryName/$prefix$path$f').toLowerCase(), // for case sensitive shit & correct linux support
                    path: (addRoot ? rootPath : '') + '$path$f',
                    size: FileSystem.stat('$rootPath$path$f').size
                });
            }
        }
    }
    public static function reloadModsConfig(reloadAll:Bool = false, reloadSkins:Bool = true):Bool {
        switch(Settings.engineSettings.data.optimizationType) {
            default:
                Assets.cache.clear('');
                openfl.utils.Assets.cache.clear('');
            case 1:
                Assets.cache.clear('mods');
                openfl.utils.Assets.cache.clear('mods');
            case 2:
                Assets.cache.clear('mods/${Settings.engineSettings.data.selectedMod}');
                openfl.utils.Assets.cache.clear('mods/${Settings.engineSettings.data.selectedMod}');
            case 3:
                // no clearing

        }
        modConfig = [];

        if (reloadSkins) {
            // skins shit
            
            var assets:AssetManifest = new AssetManifest();
            assets.name = "skins";// for case sensitive shit & correct linux support
            assets.libraryType = null;
            assets.version = 2;
            assets.libraryArgs = [];
            // assets.rootPath = '${Paths.getSkinsPath()}';
            assets.assets = [];
            FileSystem.createDirectory('${Paths.getSkinsPath()}/bf/');
            FileSystem.createDirectory('${Paths.getSkinsPath()}/gf/');
            FileSystem.createDirectory('${Paths.getSkinsPath()}/notes/');
            for (char in ["bf", "gf"]) {
                for(skin in [for (e in FileSystem.readDirectory('${Paths.getSkinsPath()}$char/')) if (FileSystem.isDirectory('${Paths.getSkinsPath()}$char/$e')) e]) {
                    var path = '${Paths.getSkinsPath()}$char/$skin/';
                    for (f in FileSystem.readDirectory(path)) {
                        var type = "TEXT";
                        if (Path.extension(f).toLowerCase() == "png") {
                            type = "IMAGE";
                        }
                        assets.assets.push({
                            type: type,
                            id: ('assets/skins/characters/$char/$skin/$f').toLowerCase(), // for case sensitive shit & correct linux support
                            path: '$path$f',
                            size: FileSystem.stat('$path$f').size
                        });
                    }
                }
            }
            try {
                getAssetFiles(assets.assets, '${Paths.getSkinsPath()}notes/', '', 'skins', 'images/', true);
            } catch(e) {
                trace(e.details());
            }
            // trace(assets.assets);
            // getAssetFiles(assets.assets, '${Paths.modsPath}/$mod/', '', libName);

            if (openfl.utils.Assets.hasLibrary("skins"))
                openfl.utils.Assets.unloadLibrary("skins");
            openfl.utils.Assets.registerLibrary("skins", AssetLibrary.fromManifest(assets));
        }
        var mods = getMods();
        var newMod = false;
        for(mod in mods)
            if (reloadAll || modConfig[mod] == null)
                newMod = newMod || loadMod(mod);
        Settings.engineSettings.data.lastInstalledMods = mods;
        return newMod;
    }

    public static function loadMod(mod:String) {
        try {
            var s = new FlxSave();
            s.bind(mod.replace(" ", "_").replace("'", "_"));
            s.data.mod = mod;
            // s.flush();
            modSaves[mod] = s;
        } catch(e) {
            trace(e.details());
        }

        // imma do assets lol
        var libName = 'mods/$mod'.toLowerCase();
        var assets:AssetManifest = new AssetManifest();
        assets.name = libName;// for case sensitive shit & correct linux support
        assets.libraryType = null;
        assets.version = 2;
        assets.libraryArgs = [];
        assets.rootPath = '${Paths.modsPath}/$mod/';
        assets.assets = [];
        getAssetFiles(assets.assets, '${Paths.modsPath}/$mod/', '', libName);

        if (openfl.utils.Assets.hasLibrary(libName))
            openfl.utils.Assets.unloadLibrary(libName);
        openfl.utils.Assets.registerLibrary(libName, AssetLibrary.fromManifest(assets));

        

        var json:ModConfig = null;
        var path = Paths.getPath('config.json', TEXT, libName);
        if (Assets.exists(path)) {
            try {
                json = Json.parse(Assets.getText(path));
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
            locked: false,
            intro: {
                bpm: 102,
                authors: ['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er'],
                present: 'present',
                assoc: ['In association', 'with'],
                newgrounds: 'newgrounds',
                gameName: ['Friday Night Funkin\'', 'YoshiCrafter', 'Engine']
            }
        };
        modConfig[mod] = json;

        if (!Settings.engineSettings.data.lastInstalledMods.contains(mod)) {
            trace("NEW MOD INSTALLED: " + mod);
            if (Settings.engineSettings.data.autoSwitchToLastInstalledMod) {
                Settings.engineSettings.data.selectedMod = mod;
                return true;
            }
        }
        return false;
    }
    #if windows
    public static function changeWindowIcon(iconPath:String) {
        
    }
    #end
    public static function getExpressionFromPath(path:String, critical:Bool = false):hscript.Expr {
        var parser = new hscript.Parser();
		parser.allowTypes = true;
        var ast:Expr = null;
		try {
			var cachePath = path.toLowerCase();
			var fileData = FileSystem.stat(path);
			var cachePath = Paths.getCachePath(path);
			
			// if (Reflect.hasField(Settings.hscriptCache.data, cachePath)) {
			// 	var thing = Reflect.field(Settings.hscriptCache.data, cachePath);
			// 	if (Std.isOfType(thing, Dynamic)) {
			// 		var cache:CacheExpr = thing;
			// 		if (cache.time != null && cache.code != null) {
			// 			if (cache.time >= fileData.mtime.getTime()) {
			// 				ast = cache.code;
			// 				trace("Using cache.");
			// 				return ast;
			// 			} else {
							// trace("Cache is outdated!");
						// }
					// } else {
						// trace("Cache is invalid!");
					// }
				// } else {
					// trace("Cache is not of the right type!");
				// }
			// } else {
				// trace("Cache not found!");
			// }
			#if sys
			ast = parser.parseString(sys.io.File.getContent(path));
			#else
			trace("no sys support");
			#end
			// Reflect.setField(Settings.hscriptCache.data, cachePath, {
			// 	time: fileData.mtime.getTime(),
			// 	code: ast
			// });
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
        var superVar = {};
        if (Std.isOfType(script, HScript)) {
            var hscript:HScript = cast script;
            for(k=>v in hscript.hscript.variables) {
                Reflect.setField(superVar, k, v);
            }
        }
		script.setVariable("super", superVar);
		script.setVariable("mod", mod);
		script.setVariable("PlayState", PlayState.current);
        script.setVariable("import", function(className:String) {
            var splitClassName = [for (e in className.split(".")) e.trim()];
            var realClassName = splitClassName.join(".");
            var cl = Type.resolveClass(realClassName);
            var en = Type.resolveEnum(realClassName);
            if (cl == null && en == null) {
                PlayState.trace('Class / Enum at $realClassName does not exist.');
            } else {
                if (en != null) {
                    // ENUM!!!!
                    var enumThingy = {};
                    for(c in en.getConstructors()) {
                        Reflect.setField(enumThingy, c, en.createByName(c));
                    }
                    script.setVariable(splitClassName[splitClassName.length - 1], enumThingy);
                } else {
                    // CLASS!!!!
                    script.setVariable(splitClassName[splitClassName.length - 1], cl);
                }
            }
        });
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
		script.setVariable("CustomShader", CustomShader_Helper);
		script.setVariable("FlxControls", FlxControls);
		script.setVariable("save", modSaves[mod]);
		script.setVariable("ModState", ModState);
		script.setVariable("AtlasFrameMaker", AtlasFrameMaker);
		// script.setVariable("FlxKey", FlxKey);

        script.mod = mod;
    }
    public static function parseSongConfig() {
        var songName = PlayState._SONG.song.toLowerCase();
        var songCodePath = Paths.modsPath + '/$currentMod/song_conf';

        var songConf = SongConf.parse(PlayState.songMod, PlayState.SONG.song, PlayState.SONG);

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