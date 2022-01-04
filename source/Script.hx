import vm.lua.Lua;
import vm.lua.State;
import llua.LuaL;
import llua.State;
import llua.State.Lua_State;
import sys.FileSystem;
import sys.io.File;
using StringTools;

import haxe.io.Path;
import LoadSettings.Settings;
import hscript.Interp;
import haxe.Exception;

class Script {
    public var fileName:String = "";
    public function new() {

    }

    public static function fromPath(path:String):Script {
        var script = create(path);
        if (script != null) {
            script.loadFile(path);
            return script;
        } else {
            return null;
        }
    }

    public static function create(path:String):Script {
        var p = path.toLowerCase();
        var ext = Path.extension(p);
        trace('ext :');
        trace(ext);

        var scriptExts = ["lua", "hscript", "hx"];
        if (ext == "") {
            for (e in scriptExts) {
                if (FileSystem.exists('$p.$e')) {
                    p = '$p.$e';
                    ext = e;
                    break;
                }
            }
        }
        trace(ext);
        switch(ext.toLowerCase()) {
            case 'hx' | 'hscript':
                trace("HScript");
                return new HScript();
            case 'lua':
                trace("Lua");
                return new LuaScript();
        }
        trace('ext not found : $ext for $path');
        return null;
    }

    public function executeFunc(funcName:String, ?args:Array<Dynamic>):Dynamic {
        throw new Exception("NOT IMPLEMENTED !");
        return null;
    }

    public function setVariable(name:String, val:Dynamic) {
        throw new Exception("NOT IMPLEMENTED !");
    }

    public function getVariable(name:String):Dynamic {
        throw new Exception("NOT IMPLEMENTED !");
        return null;
    }

    public function trace(text:String) {
        trace(text);
        if (Settings.engineSettings.data.developerMode) {
            for (t in text.split("\n")) PlayState.log.push(t);
        }
    }

    public function loadFile(path:String) {
        throw new Exception("NOT IMPLEMENTED !");
    }
}

class HScript extends Script {
    public var hscript:Interp;
    public function new() {
        hscript = new Interp();
        super();
    }

    public override function executeFunc(funcName:String, ?args:Array<Dynamic>):Dynamic {
        if (hscript == null) {
            trace("hscript is null");
            return null;
        }
		if (hscript.variables.exists(funcName)) {
            var f = hscript.variables.get(funcName);
            if (args == null) {
                var result = null;
                try {
                    result = f();
                } catch(e) {
                    var s = e.stack;
                    var details = e.details();
                    
                    trace('$e at $s\r\n$details');
                }
                Paths.copyBitmap = false;
                return result;
            } else {
                var result = null;
                try {
                    result = Reflect.callMethod(null, f, args);
                } catch(e) {
                    var s = e.stack;
                    var details = e.details();

                    trace('$e at $s\r\n$details');
                }
                Paths.copyBitmap = false;
                return result;
            }
			// f();
		}
        return null;
    }

    public override function loadFile(path:String) {
        fileName = Path.withoutDirectory(path);
        var p = path;
        if (Path.extension(p) == "") {
            var exts = ["hx", "hscript"];
            for (e in exts) {
                if (FileSystem.exists('$p.$e')) {
                    p = '$p.$e';
                    break;
                }
            }
        }
        try {
            hscript.execute(ModSupport.getExpressionFromPath(p, false));
        } catch(e) {

        }
    }

    public override function trace(text:String) {
        var posInfo = hscript.posInfos();

        // var fileName = posInfo.fileName;
        var lineNumber = Std.string(posInfo.lineNumber);
        var methodName = posInfo.methodName;
        var className = posInfo.className;
        trace('$fileName:$methodName:$lineNumber: $text');

        if (!Settings.engineSettings.data.developerMode) return;
        for (e in ('$fileName:$methodName:$lineNumber: $text').split("\n")) PlayState.log.push(e.trim());
    }

    public override function setVariable(name:String, val:Dynamic) {
        hscript.variables.set(name, val);
    }

    public override function getVariable(name:String):Dynamic {
        return hscript.variables.get(name);
    }
}

class LuaScript extends Script {
    public var lua:vm.lua.Lua;

    public function new() {
        // lua = Luaplugin;
        lua = new Lua();
        super();
    }

    public override function loadFile(path:String) {

        
    }
}