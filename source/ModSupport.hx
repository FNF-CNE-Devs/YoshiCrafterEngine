import flixel.system.FlxSound;
import flixel.util.FlxColor;
import sys.io.File;
import lime.utils.Assets;
import flixel.system.FlxAssets;
import LoadSettings.Settings;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.math.FlxMath;
using StringTools;


class ModSupport {
    public static var song_config_parser:hscript.Interp;
    public static var song_modchart_path:String = "";
    public static var song_stage_path:String = "";
    public static var currentMod:String = "Friday Night Funkin'";

    public static function getExpressionFromPath(path:String):hscript.Expr {
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
		}
        return ast;
    }

    public static function setHaxeFileDefaultVars(hscript:hscript.Interp) {
		hscript.variables.set("PlayState", PlayState.current);
		hscript.variables.set("EngineSettings", Settings.engineSettings.data);

		hscript.variables.set("PlayStateClass", PlayState);
		hscript.variables.set("FlxSprite", FlxSprite);
		hscript.variables.set("BitmapData", BitmapData);
		hscript.variables.set("FlxG", FlxG);
		hscript.variables.set("Paths", Paths);
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
		// hscript.variables.set("FlxColor", Int);
    }
    public static function executeFunc(hscript:hscript.Interp, funcName:String, ?args:Array<Dynamic>):Dynamic {
        
		if (hscript.variables.exists(funcName)) {
            var f = hscript.variables.get(funcName);
            if (args == null) {
                var result = null;
                try {
                    result = f();
                } catch(e) {
                    trace(e);
                }
                return result;
            } else {
                var result = null;
                try {
                    result = Reflect.callMethod(null, f, args);
                } catch(e) {
                    trace(e);
                }
                return result;
            }
			// f();
		}
        return null;
    }
    public static function parseSongConfig() {
        var songName = PlayState.SONG.song.toLowerCase();
        var songCodePath = Paths.getModsFolder() + '/$currentMod/source/song_conf.hx';
        var parser = new hscript.Parser();
        parser.allowTypes = true;
        var ast = null;
        #if sys
        ast = parser.parseString(sys.io.File.getContent(songCodePath));
        #end
        var interp = new hscript.Interp();
        interp.variables.set("song", songName);
        interp.variables.set("difficulty", PlayState.storyDifficulty);
        interp.variables.set("stage", "default_stage");
        interp.variables.set("cutscene", "");
        interp.variables.set("modchart", "");
        interp.execute(ast);

        var stage = interp.variables.get("stage");
        var modchart = interp.variables.get("modchart");
        trace(stage);
        if (stage == "default_stage")
            song_stage_path = Paths.getModsFolder() + '/Friday Night Funkin\'/source/stages/$stage/'; // fallback
        else
            song_stage_path = Paths.getModsFolder() + '/$currentMod/source/stages/$stage/';

        if (modchart != "")
            song_modchart_path = Paths.getModsFolder() + '/$currentMod/source/modcharts/$modchart.hx';
        else
            song_modchart_path = "";
        trace(song_stage_path);
        trace(song_modchart_path);
    }

    public static function getFreeplaySongs():Array<String> {
        var folders:Array<String> = [];
        var songs:Array<String> = [];
        #if sys
            var folders:Array<String> = sys.FileSystem.readDirectory(Paths.getModsFolder() + "/");
        #end

        for (mod in folders) {
            trace(mod);
            var freeplayList:String = "";
            #if sys
                try {
                    freeplayList = sys.io.File.getContent(Paths.getModsFolder() + "/" + mod + "/assets/data/freeplaySonglist.txt");
                } catch(e) {
                    freeplayList = "";
                }
            #end
            for(s in freeplayList.trim().replace("\r", "").split("\n")) if (s != "") songs.push('$mod:$s');
        }
        return songs;
    }
}