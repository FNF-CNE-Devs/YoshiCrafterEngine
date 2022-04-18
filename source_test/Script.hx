import linc.Linc;
import mod_support_stuff.ModScript;
import cpp.Reference;
import cpp.Lib;
import cpp.Pointer;
import cpp.RawPointer;
import cpp.Callable;

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
#if ENABLE_LUA
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end

class Script {
    public var fileName:String = "";
    public var mod:String = null;
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

        var scriptExts = Main.supportedFileTypes;
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
            case 'hx' | 'hscript' | 'hsc':
                trace("HScript");
                return new HScript();
            #if ENABLE_LUA
            case 'lua':
                trace("Lua");
                return new LuaScript();
            #end
        }
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
            var sc = Script.create('${Paths.modsPath}/${s.path}');
            if (sc == null) continue;
            ModSupport.setScriptDefaultVars(sc, s.mod, {});
            this.scripts.push(sc);
            scriptModScripts.push(s);
        }
    }

    public function loadFiles() {
        for (k=>sc in scripts) {
            var s = scriptModScripts[k];
            sc.loadFile('${Paths.modsPath}/${s.path}');
        }
    }

    public function executeFunc(funcName:String, ?args:Array<Any>, ?defaultReturnVal:Any) {
        
        var a = args;
        if (a == null) a = [];
        for (script in scripts) {
            var returnVal = script.executeFunc(funcName, a);
            if (returnVal != defaultReturnVal && defaultReturnVal != null) {
                trace("found");
                return returnVal;
            }
        }
        return defaultReturnVal;
    }

    public function executeFuncMultiple(funcName:String, ?args:Array<Any>, ?defaultReturnVal:Array<Any>) {
        var a = args;
        if (a == null) a = [];
        if (defaultReturnVal == null) defaultReturnVal = [null];
        for (script in scripts) {
            var returnVal = script.executeFunc(funcName, a);
            if (!defaultReturnVal.contains(returnVal)) {
                #if messTest trace("found"); #end
                return returnVal;
            }
        }
        return defaultReturnVal[0];
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
        Paths.currentLibrary = 'mods/${mod}';
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
                    this.trace('$e');
                }
                Paths.currentLibrary = null;
                return result;
            } else {
                var result = null;
                try {
                    result = Reflect.callMethod(null, f, args);
                } catch(e) {
                    this.trace('$e');
                }
                Paths.currentLibrary = null;
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
            var exts = ["hx", "hsc", "hscript"];
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
            this.trace('${e.message}');
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

#if ENABLE_LUA
typedef LuaObject = {
    var varPath:String;
    var set:(String,String)->Void;
    var get:(String)->LuaObject;
    // var toLua
}


/*
class LuaScript extends Script {
    public var state:llua.State;
    public var variables:Map<String, Dynamic> = [];

    function getVar(v:String) {
        var splittedVar = v.split(".");
        if (splittedVar.length == 0) return null;
        var currentObj = variables[splittedVar[0]];
        for (i in 1...splittedVar.length) {
            var property = Reflect.getProperty(currentObj, splittedVar[i]);
            if (property != null) {
                currentObj = property;
            } else {
                this.trace('Variable $v doesn\'t exist or is equal to null.');
                return null;
            }
        }
        return currentObj;
    }


    
    
    public override function new() {
        super();
        state = LuaL.newstate();
        Lua.init_callbacks(state);
        LuaL.openlibs(state);
        Lua_helper.register_hxtrace(state);
        Lua_helper.add_callback(state, "print", function(toPtr:Dynamic) {
            this.trace(Std.string(toPtr));
        });

		function get(pointer):Int {
			var text:String = Lua.tostring(state, -1); // ayyy
			Lua.pushstring(state, "good");
			return 0; // lua error code
		}
		
        //Lua.pushcfunction(state, Callable.fromFunction(new cpp.Function(get)));
		Lua_helper.add_callback(state, "__get", get);
		LuaL.dostring(state, "function get(value)
			__get(value);
		end");
    }

    public override function loadFile(path:String) {
        // LuaL.loadfile(state, path);
        // LuaL.dostring(state, Paths.getTextOutsideAssets(path));
        var p = path;
        if (Path.extension(p) == "") {
            p = p + ".lua";
        }
        fileName = Path.withoutDirectory(p);
        if (FileSystem.exists(p)) {
            if (LuaL.dostring(state, File.getContent(p)) != 0) {
                var err = Lua.tostring(state, -1);
                this.trace('$err');
            }
        } else {
            this.trace("Lua script does not exist.");
        }
    }

    public override function trace(text:String)
    {
        // LuaL.error(state, "%s");
        
        var lua_debug:Lua_Debug = {

        }
        Lua.getinfo(state, "S", lua_debug);
        Lua.getinfo(state, "n", lua_debug);
        Lua.getinfo(state, "l", lua_debug);

        // Lua.getinfo
        var bText = '$fileName: ';
        if (lua_debug.name != null)  bText += '${lua_debug.name}()';
        if (lua_debug.currentline == -1)  {
            if (lua_debug.linedefined != -1) {
                bText += 'at line ${lua_debug.linedefined}: ';
            }
        } else {
            bText += 'at line ${lua_debug.currentline}: ';
        }

        for(t in text.split("\n")) PlayState.log.push(bText + t);
        trace(text);
    }

    public override function getVariable(name:String) {
        // Lua.getglobal()
        return variables[name];
    }

    // public override function executeFunc(name:String) {
    //     // Lua.getglobal()
    //     return variables[name];
    // }

    public override function setVariable(name:String, v:Dynamic) {
        // Lua.getglobal()
        variables[name] = v;
    }

    public override function executeFunc(funcName:String, ?args:Array<Any>) {
        // Gets func
        // Lua.
        
        if (args == null) args = [];
        Lua.getglobal(state, funcName);

        
        for (k=>val in args) {
            switch (Type.typeof(val)) {
                case Type.ValueType.TNull:
                    Lua.pushnil(state);
                case Type.ValueType.TBool:
                    Lua.pushboolean(state, val);
                case Type.ValueType.TInt:
                    Lua.pushinteger(state, cast(val, Int));
                case Type.ValueType.TFloat:
                    Lua.pushnumber(state, val);
                case Type.ValueType.TClass(String):
                    Lua.pushstring(state, cast(val, String));
                case Type.ValueType.TClass(Array):
                    Convert.arrayToLua(state, val);
                case Type.ValueType.TObject:
                    @:privateAccess
                    Convert.objectToLua(state, val); // {}
                default:
                    variables["parameter" + Std.string(k + 1)] = val;
                    Lua.pushnil(state);
            }
        }
        if (Lua.pcall(state, args.length, 1, 0) != 0) {
            var err = Lua.tostring(state, -1);
            if (err != "attempt to call a nil value") {

                // Lua.getinfo
                this.trace('$err');
            }
        }
        return Convert.fromLua(state, Lua.gettop(state));
    }
}
*/

class LuaScript extends Script {
    public var state:llua.State;
    public var variables:Map<String, Dynamic> = [];

    function getVar(v:String) {
        var splittedVar = v.split(".");
        if (splittedVar.length == 0) return null;
        var currentObj = variables[splittedVar[0]];
        for (i in 1...splittedVar.length) {
            var property = Reflect.getProperty(currentObj, splittedVar[i]);
            if (property != null) {
                currentObj = property;
            } else {
                this.trace('Variable $v doesn\'t exist or is equal to null.');
                return null;
            }
        }
        return currentObj;
    }
    public function new() {
        super();
        state = LuaL.newstate();
        Lua.init_callbacks(state);
        LuaL.openlibs(state);
        Lua_helper.register_hxtrace(state);
        
        Lua_helper.add_callback(state, "set", function(v:String, value:Dynamic) {
            var splittedVar = v.split(".");
            if (splittedVar.length == 0) return false;
            if (splittedVar.length == 1) {
                variables[v] = value;
                return true;
            }
            var currentObj = variables[splittedVar[0]];
            for (i in 1...splittedVar.length - 1) {
                var property = Reflect.getProperty(currentObj, splittedVar[i]);
                if (property != null) {
                    currentObj = property;
                } else {
                    this.trace('Variable $v doesn\'t exist or is equal to null.');
                    return false;
                }
            }
            // var property = Reflect.getProperty(currentObj, splittedVar[splittedVar.length - 1]);
            // if (property != null) {
            var finalVal = value;
            if (Std.isOfType(finalVal, String)) {
                var str = cast(finalVal, String);
                if (str.startsWith("${") && str.endsWith("}")) {
                    var v = getVar(str.substr(2, str.length - 3));
                    if (v != null) {
                        finalVal = v;
                    }
                }
            }
            try {
                Reflect.setProperty(currentObj, splittedVar[splittedVar.length - 1], finalVal);
                return true;
            } catch(e) {
                this.trace('Variable $v doesn\'t exist.');
                return false;
            }
        });
        Lua_helper.add_callback(state, "get", function(v:String, ?globalName:String) {
            var r = getVar(v);
            if (globalName != null && globalName != "") {
                variables[globalName] = r;
                return '$' + '{$globalName}';
            } else {
                return r;
            }
        });
        Lua_helper.add_callback(state, "getArray", function(array:String, key:Int, ?globalVar:String):Dynamic {
            if (array == null || array == "") {
                this.trace("getArray(): You need to type a variable name");
                return null;
            } else {
                var obj = getVar(array);
                switch(Type.typeof(obj)) {
                    case Type.ValueType.TClass(Array):
                        var arr:Array<Any> = obj;
                        var elem = arr[key];
    
                        if (globalVar == null || globalVar == "") {
                            return elem;
                        } else {
                            variables[globalVar] = elem;
                            return null;
                        }
                    default:
                        this.trace('getArray(): Variable is an ${Type.typeof(obj)} instead of an array');
                        return null;
                }
            }
        });
        Lua_helper.add_callback(state, "setArray", function(array:String, key:Int, newVar:Dynamic):Bool {
            if (array == null || array == "") {
                this.trace("setArray(): You need to type a variable name");
                return false;
            } else {
                var obj = getVar(array);
                switch(Type.typeof(obj)) {
                    case Type.ValueType.TClass(Array):
                        var arr:Array<Any> = obj;
                        arr[key] = newVar;
                        return true;
                    default:
                        this.trace('setArray(): Variable is an ${Type.typeof(obj)} instead of an array');
                        return false;
                }
            }
        });
        Lua_helper.add_callback(state, "v", function(c:String) {return '$' + '{$c}';});
        Lua_helper.add_callback(state, "call", function(v:String, ?resultName:String, ?args:Array<Dynamic>):Dynamic {
            if (args == null) args = [];
            var splittedVar = v.split(".");
            if (splittedVar.length == 0) return false;
            var currentObj = variables[splittedVar[0]];
            for (i in 1...splittedVar.length - 1) {
                var property = Reflect.getProperty(currentObj, splittedVar[i]);
                if (property != null) {
                    currentObj = property;
                } else {
                    this.trace('Variable $v doesn\'t exist or is equal to null.');
                    return false;
                }
            }
            var func = Reflect.getProperty(currentObj, splittedVar[splittedVar.length - 1]);

            var finalArgs = [];
            for (a in args) {
                if (Std.isOfType(a, String)) {
                    var str = cast(a, String);
                    if (str.startsWith("${") && str.endsWith("}")) {
                        var st = str.substr(2, str.length - 3);
                        trace(st);
                        var v = getVar(st);
                        if (v != null) {
                            finalArgs.push(v);
                        } else {
                            finalArgs.push(a);
                        }
                    } else {
                        finalArgs.push(a);
                    }
                } else {
                    finalArgs.push(a);
                }
            }
            if (func != null) {
                var result = null;
                try {
                    result = Reflect.callMethod(null, func, finalArgs);
                } catch(e) {
                    this.trace('$e');
                }
                if (resultName == null) {
                    return result;
                } else {
                    variables[resultName] = result;
                    return '$' + resultName;
                }
            } else {
                this.trace('Function $v doesn\'t exist or is equal to null.');
                return false;
            }
        });
        Lua_helper.add_callback(state, "createClass", function(name:String, className:String, params:Array<Dynamic>) {
            var cl = Type.resolveClass(className);
            if (cl == null) {
                if (variables[className] != null) {
                    if (Type.typeof(variables[className]) == Type.typeof(Class)) {
                        cl = cast(variables[className], Class<Dynamic>);
                    }
                }
            }
            variables[name] = Type.createInstance(cl, params);
        });
        Lua_helper.add_callback(state, "print", function(toPtr:Dynamic) {
            this.trace(Std.string(toPtr));
        });
        // Lua_helper.add_callback(state, "trace", function(text:String) {
        //     trace(text);
        // });
    }

    public override function loadFile(path:String) {
        // LuaL.loadfile(state, path);
        // LuaL.dostring(state, Paths.getTextOutsideAssets(path));
        var p = path;
        if (Path.extension(p) == "") {
            p = p + ".lua";
        }
        fileName = Path.withoutDirectory(p);
        if (FileSystem.exists(p)) {
            if (LuaL.dostring(state, File.getContent(p)) != 0) {
                var err = Lua.tostring(state, -1);
                this.trace('$err');
            }
        } else {
            this.trace("Lua script does not exist.");
        }
    }

    public override function trace(text:String)
    {
        // LuaL.error(state, "%s");
        
        var lua_debug:Lua_Debug = {

        }
        Lua.getinfo(state, "S", lua_debug);
        Lua.getinfo(state, "n", lua_debug);
        Lua.getinfo(state, "l", lua_debug);

        // Lua.getinfo
        var bText = '$fileName: ';
        if (lua_debug.name != null)  bText += '${lua_debug.name}()';
        if (lua_debug.currentline == -1)  {
            if (lua_debug.linedefined != -1) {
                bText += 'at line ${lua_debug.linedefined}: ';
            }
        } else {
            bText += 'at line ${lua_debug.currentline}: ';
        }

        for(t in text.split("\n")) PlayState.log.push(bText + t);
        trace(text);
        Lua.settop(state, 0);
    }

    public override function getVariable(name:String) {
        // Lua.getglobal()
        return variables[name];
    }

    // public override function executeFunc(name:String) {
    //     // Lua.getglobal()
    //     return variables[name];
    // }

    public override function setVariable(name:String, v:Dynamic) {
        // Lua.getglobal()
        variables[name] = v;
    }

    public override function executeFunc(funcName:String, ?args:Array<Any>) {
        // Gets func
        // Lua.
        
        if (args == null) args = [];
        Lua.getglobal(state, funcName);

        
        for (k=>val in args) {
            switch (Type.typeof(val)) {
                case Type.ValueType.TNull:
                    Lua.pushnil(state);
                case Type.ValueType.TBool:
                    Lua.pushboolean(state, val);
                case Type.ValueType.TInt:
                    Lua.pushinteger(state, cast(val, Int));
                case Type.ValueType.TFloat:
                    Lua.pushnumber(state, val);
                case Type.ValueType.TClass(String):
                    Lua.pushstring(state, cast(val, String));
                case Type.ValueType.TClass(Array):
                    Convert.arrayToLua(state, val);
                case Type.ValueType.TObject:
                    @:privateAccess
                    Convert.objectToLua(state, val); // {}
                default:
                    variables["parameter" + Std.string(k + 1)] = val;
                    Lua.pushnil(state);
            }
        }
        if (Lua.pcall(state, args.length, 1, 0) != 0) {
            var err = Lua.tostring(state, -1);
            if (err != "attempt to call a nil value") {

                // Lua.getinfo
                this.trace('$err');
            }
        }
        return Convert.fromLua(state, Lua.gettop(state));
        Lua.settop(state, 0);
    }
}
#end