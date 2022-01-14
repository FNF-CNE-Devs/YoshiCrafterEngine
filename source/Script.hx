import ModSupport.ModScript;
import haxe.Constraints.Function;
import haxe.DynamicAccess;
import lime.app.Application;
using StringTools;

import sys.FileSystem;
import sys.io.File;
import haxe.io.Path;
import EngineSettings.Settings;
import haxe.Exception;

// HSCRIPT
import hscript.Interp;

// LUA
import vm.lua.Lua;
import vm.lua.Api;

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
        trace('path : "$path"');
        trace('ext :');

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

    public function executeFunc(funcName:String, ?args:Array<Any>):Dynamic {
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

    public function destroy() {

    }
}

class ScriptPack {
    public var scripts:Array<Script> = [];
    public var scriptModScripts:Array<ModScript> = [];
    public function new(scripts:Array<ModScript>) {
        for (s in scripts) {
            var sc = Script.create('${Paths.getModsFolder()}\\${s.path}');
            if (sc == null) continue;
            ModSupport.setScriptDefaultVars(sc, s.mod, {});
            this.scripts.push(sc);
            scriptModScripts.push(s);
        }
    }

    public function loadFiles() {
        for (k=>sc in scripts) {
            var s = scriptModScripts[k];
            sc.loadFile('${Paths.getModsFolder()}\\${s.path}');
        }
    }

    public function executeFunc(funcName:String, ?args:Array<Any>, ?defaultReturnVal:Any) {
        var a = args;
        if (a == null) a = [];
        for (script in scripts) {
            var returnVal = script.executeFunc(funcName, a);
            if (returnVal != defaultReturnVal && defaultReturnVal != null) {
                #if messTest trace("found"); #end
                return returnVal;
            }
        }
        return defaultReturnVal;
    }

    public function setVariable(name:String, val:Dynamic) {
        for (script in scripts) script.setVariable(name, val);
    }

    public function getVariable(name:String, defaultReturnVal:Any) {
        for (script in scripts) {
            var variable = script.getVariable(name);
            if (variable != defaultReturnVal) {
                return variable;
            }
        }
        return defaultReturnVal;
    }

    public function destroy() {
        for(script in scripts) script.destroy();
        scripts = null;
    }
}

class HScript extends Script {
    public var hscript:Interp;
    public function new() {
        hscript = new Interp();
        super();
    }

    public override function executeFunc(funcName:String, ?args:Array<Any>):Dynamic {
        if (hscript == null) {
            this.trace("hscript is null");
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
                    
                    this.trace('$e at $s\r\n$details');
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

                    this.trace('$e at $s\r\n$details');
                }
                Paths.copyBitmap = false;
                return result;
            }
			// f();
		}
        return null;
    }

    public override function loadFile(path:String) {
        if (path.trim() == "") return;
        fileName = Path.withoutDirectory(path);
        var p = path;
        if (Path.extension(p) == "") {
            var exts = ["hx", "hscript"];
            for (e in exts) {
                if (FileSystem.exists('$p.$e')) {
                    p = '$p.$e';
                    fileName += '.$e';
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
    // public var lua:State;
    public var lua:vm.lua.Lua;
    public var vars:Map<String, Dynamic> = [];
    public function new() {
        lua = new vm.lua.Lua();
        lua.setGlobalVar("get", function(v:String):Dynamic {
            var splittedVar = v.split(".");
            if (splittedVar.length == 0) return null;
            var currentObj = vars[splittedVar[0]];
            for (i in 1...splittedVar.length) {
                if (Reflect.hasField(currentObj, splittedVar[i])) {
                    currentObj = Reflect.field(currentObj, splittedVar[i]);
                } else {
                    this.trace('Variable $v doesn\'t exist.');
                    return null;
                }
            }
            return currentObj;
        });
        lua.setGlobalVar("set", function(v:String, value:Dynamic):Bool {
            var splittedVar = v.split(".");
            if (splittedVar.length == 0) return false;
            if (splittedVar.length == 1) {
                vars[v] = value;
                return true;
            }
            var currentObj = vars[splittedVar[0]];
            for (i in 1...splittedVar.length - 1) {
                if (Reflect.hasField(currentObj, splittedVar[i])) {
                    currentObj = Reflect.field(currentObj, splittedVar[i]);
                } else {
                    this.trace('Variable $v doesn\'t exist.');
                    return false;
                }
            }
            if (Reflect.hasField(currentObj, splittedVar[splittedVar.length - 1])) {
                Reflect.setField(currentObj, splittedVar[splittedVar.length - 1], value);
                return true;
            } else {
                this.trace('Variable $v doesn\'t exist.');
                return false;
            }
        });
        lua.setGlobalVar("createClass", function(name:String, className:String, params:Array<Dynamic>) {
            var cl = Type.resolveClass(className);
            if (cl == null) {
                if (vars[className] != null) {
                    if (Type.typeof(vars[className]) == Type.typeof(Class)) {
                        cl = cast(vars[className], Class<Dynamic>);
                    }
                }
            }
            vars[name] = Type.createInstance(cl, params);
        });


        // lua = LuaL.newstate();
        // Lua.(lua);

        // lua = Luaplugin;
        // lua = new llua.LuaL();
        
        super();
    }

    public override function loadFile(path:String) {
        var p = path;
        if (Path.extension(p) == "") {
            if (FileSystem.exists('$p.lua')) {
                p = '$p.lua';
            }
        }
        fileName = Path.withoutDirectory(p);
        if (FileSystem.exists(p)) {
            try {
                lua.run(Paths.getTextOutsideAssets(p));
            } catch(e) {
                var t = 'Failed to run lua file at "$p".\r\n$e';
                trace(t);
                openfl.Lib.application.window.alert(t);
            }
        } else {
            trace('Lua script at "$p" doesn\'t exist.');
            openfl.Lib.application.window.alert('Lua script at "$p" doesn\'t exist.');
        }
    }

    public override function trace(text:String) {
        trace('$fileName: $text');

        if (!Settings.engineSettings.data.developerMode) return;
        for (e in ('$fileName: $text').split("\n")) PlayState.log.push(e.trim());
    }

    public override function setVariable(name:String, val:Dynamic) {
        if (Type.typeof(val) == TFunction) {
            #if debug trace('$name is a function.'); #end
            lua.setGlobalVar(name, val);
        }
        
        vars[name] = val;
        // lua.setGlobalVar(name, val);
    }

    public override function getVariable(name:String):Dynamic {
        return vars[name];

    }

    public override function executeFunc(funcName:String, ?args:Array<Any>) {

        #if debug trace('calling $funcName'); #end
        var result = null;
        try {
            if (args == null) {
                result =  lua.call(funcName, []);
            } else {
                result =  lua.call(funcName, args);
            }
            #if debug trace('called'); #end
        } catch(e) {
            this.trace(e.toString() + '\r' + e.stack);
            return null;
        }
        return result;
    }

    public override function destroy() {
        lua.destroy();
    }

    // public override function setVariable()
    // public override function getVariable(name:String):Dynamic {
    //     return Lua.getglobal(lua, name);
    // }
}
