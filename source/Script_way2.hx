/*
    DOESNT WORK !!!!
*/

import cpp.Reference;
import cpp.Lib;
import cpp.Pointer;
import cpp.RawPointer;
import cpp.Callable;
#if ENABLE_LUA
import llua.State;
import llua.Convert;
#end
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
import llua.Lua;
import llua.LuaL;

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
                    this.trace('$e');
                }
                Paths.copyBitmap = false;
                return result;
            } else {
                var result = null;
                try {
                    result = Reflect.callMethod(null, f, args);
                } catch(e) {
                    this.trace('$e');
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

    var currentID = 0;

    function addToVariables(obj:Dynamic):String {
        while(variables["{" + Std.string(currentID) + "}"] != null) {
            currentID++;
        }
        variables['{$currentID}'] = obj;
        return "$" + '{$currentID}';
    }
    public function new() {
        super();
        state = LuaL.newstate();
        Lua.init_callbacks(state);
        LuaL.openlibs(state);
        Lua_helper.register_hxtrace(state);
        
        Lua_helper.add_callback(state, "set", function(obj:String, name:String, val:String) {
            try {
                if (!obj.startsWith("$")) {
                    this.trace("set() : obj is not a valid object.");
                    return false;
                }
                if (!val.startsWith("$")) {
                    this.trace("set() : given value is not a valid object.");
                    return false;
                }
                
                var o = variables[obj.substr(1)];
                if (o == null) return false;
                if (Type.getInstanceFields(o).contains(name)) {
                    var nV = variables[val.substr(1)];
                    Reflect.setProperty(o, name, nV);
                    return true;
                } else {
                    return false;
                }
            } catch(e) {
                this.trace(Std.string(e));
                return false;
            }
        });
        Lua_helper.add_callback(state, "get", function(obj:String, ?val:String):String {
            if (val == null) {
                return '$' + obj;
            } else {
                if (obj.startsWith("$")) {
                    var v = variables[obj.substr(1)];
                    var p = Reflect.getProperty(v, val);
                    return addToVariables(p);
                } else {
                    this.trace("get() : obj is not a valid object.");
                    return null;
                }
            }
        });
        Lua_helper.add_callback(state, "call", function(obj:String, func:String, ?args:Array<Dynamic>):String {
            if (!obj.startsWith("$")) {
                this.trace("call() : obj is not a valid object.");
                return null;
            }
            var o = variables[obj.substr(1)];
            if (o == null) {
                this.trace("call() : obj does not exist.");
                return null;
            }

            var func = Reflect.getProperty(o, func);

            var finalArgs = [];
            for (a in args) {
                if (Std.isOfType(a, String)) {
                    var str = cast(a, String);
                    if (str.startsWith("$")) {
                        var v = getVar(str.substr(1));
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
                Paths.copyBitmap = false;
                return addToVariables(result);
                
            } else {
                this.trace('Function $func doesn\'t exist or is equal to null.');
                return null;
            }

        });
        Lua_helper.add_callback(state, "createClass", function(className:String, params:Array<Dynamic>) {
            var cl = Type.resolveClass(className);
            if (cl == null) {
                if (variables[className] != null) {
                    if (Type.typeof(variables[className]) == Type.typeof(Class)) {
                        cl = cast(variables[className], Class<Dynamic>);
                    }
                }
            }
            var r = null;
            try {
                r = Type.createInstance(cl, params);
            } catch(e) {
                trace('createClass(): $e');
            }
            return addToVariables(r);
        });
        Lua_helper.add_callback(state, "toLuaValue", function(obj:String):Dynamic {
            if (Std.isOfType(obj, String)) {
                if (obj.startsWith("$")) {
                    var v = variables[obj.substr(1)];
                    switch (Type.typeof(v)) {
                        case Type.ValueType.TNull | Type.ValueType.TBool | Type.ValueType.TInt | Type.ValueType.TFloat | Type.ValueType.TClass(String) | Type.ValueType.TClass(Array) | Type.ValueType.TObject:
                            return v;
                        default:
                            this.trace("toLuaValue(): haxe value not supported\n"+obj+" - "+Type.typeof(obj) );
                            return null;
                    }
                } else {
                    return obj;
                }
            } else {
                return obj;
            }
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
        if (FileSystem.exists(p)) {
            if (LuaL.dostring(state, File.getContent(p)) != 0) {
                var err = Lua.tostring(state, -1);
                this.trace('$fileName: $err');
            }
        } else {
            this.trace("Lua script does not exist.");
        }
        fileName = Path.withoutDirectory(p);
    }

    public override function trace(text:String)
    {
        // LuaL.error(state, "%s");
        for(t in text.split("\n")) PlayState.log.push(t);
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
        
        for (a in args) {
            Convert.toLua(state, a);
        }
        if (Lua.pcall(state, args.length, 1, 0) != 0) {
            var err = Lua.tostring(state, -1);
            if (err != "attempt to call a nil value") {
                this.trace('$fileName:$funcName():$err');
            }
        }
        return Convert.fromLua(state, Lua.gettop(state));
    }
}

// class LuaScript extends Script {
//     // public var lua:State;
//     public var lua:vm.lua.Lua;
//     public var vars:Map<String, Dynamic> = [];
//     public function new() {
//         lua = new vm.lua.Lua();
//         lua.setGlobalVar("get", function(v:String):Dynamic {
//             var splittedVar = v.split(".");
//             if (splittedVar.length == 0) return null;
//             var currentObj = vars[splittedVar[0]];
//             for (i in 1...splittedVar.length) {
//                 if (Reflect.hasField(currentObj, splittedVar[i])) {
//                     currentObj = Reflect.field(currentObj, splittedVar[i]);
//                 } else {
//                     this.trace('Variable $v doesn\'t exist.');
//                     return null;
//                 }
//             }
//             return currentObj;
//         });
//         lua.setGlobalVar("set", function(v:String, value:Dynamic):Bool {
//             var splittedVar = v.split(".");
//             if (splittedVar.length == 0) return false;
//             if (splittedVar.length == 1) {
//                 vars[v] = value;
//                 return true;
//             }
//             var currentObj = vars[splittedVar[0]];
//             for (i in 1...splittedVar.length - 1) {
//                 if (Reflect.hasField(currentObj, splittedVar[i])) {
//                     currentObj = Reflect.field(currentObj, splittedVar[i]);
//                 } else {
//                     this.trace('Variable $v doesn\'t exist.');
//                     return false;
//                 }
//             }
//             if (Reflect.hasField(currentObj, splittedVar[splittedVar.length - 1])) {
//                 Reflect.setField(currentObj, splittedVar[splittedVar.length - 1], value);
//                 return true;
//             } else {
//                 this.trace('Variable $v doesn\'t exist.');
//                 return false;
//             }
//         });
//         lua.setGlobalVar("createClass", function(name:String, className:String, params:Array<Dynamic>) {
//             var cl = Type.resolveClass(className);
//             if (cl == null) {
//                 if (vars[className] != null) {
//                     if (Type.typeof(vars[className]) == Type.typeof(Class)) {
//                         cl = cast(vars[className], Class<Dynamic>);
//                     }
//                 }
//             }
//             vars[name] = Type.createInstance(cl, params);
//         });


//         // lua = LuaL.newstate();
//         // Lua.(lua);

//         // lua = Luaplugin;
//         // lua = new llua.LuaL();
        
//         super();
//     }

//     public override function loadFile(path:String) {
//         var p = path;
//         if (Path.extension(p) == "") {
//             if (FileSystem.exists('$p.lua')) {
//                 p = '$p.lua';
//             }
//         }
//         fileName = Path.withoutDirectory(p);
//         if (FileSystem.exists(p)) {
//             try {
//                 lua.run(Paths.getTextOutsideAssets(p));
//             } catch(e) {
//                 var t = 'Failed to run lua file at "$p".\r\n$e';
//                 trace(t);
//                 openfl.Lib.application.window.alert(t);
//             }
//         } else {
//             trace('Lua script at "$p" doesn\'t exist.');
//             openfl.Lib.application.window.alert('Lua script at "$p" doesn\'t exist.');
//         }
//     }

//     public override function trace(text:String) {
//         trace('$fileName: $text');

//         if (!Settings.engineSettings.data.developerMode) return;
//         for (e in ('$fileName: $text').split("\n")) PlayState.log.push(e.trim());
//     }

//     public override function setVariable(name:String, val:Dynamic) {
//         if (Type.typeof(val) == TFunction) {
//             #if debug trace('$name is a function.'); #end
//             lua.setGlobalVar(name, val);
//         }
        
//         vars[name] = val;
//         // lua.setGlobalVar(name, val);
//     }

//     public override function getVariable(name:String):Dynamic {
//         return vars[name];

//     }

//     public override function executeFunc(funcName:String, ?args:Array<Any>) {

//         #if debug trace('calling $funcName'); #end
//         var result = null;
//         try {
//             if (args == null) {
//                 result =  lua.call(funcName, []);
//             } else {
//                 result =  lua.call(funcName, args);
//             }
//             #if debug trace('called'); #end
//         } catch(e) {
//             this.trace(e.toString() + '\r' + e.stack);
//             return null;
//         }
//         return result;
//     }

//     public override function destroy() {
//         lua.destroy();
//     }

//     // public override function setVariable()
//     // public override function getVariable(name:String):Dynamic {
//     //     return Lua.getglobal(lua, name);
//     // }
// }