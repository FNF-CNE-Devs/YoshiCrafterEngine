import cpp.vm.Gc;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.rtti.Meta;
import haxe.Unserializer;
import flixel.FlxG;
import flixel.FlxSprite;
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

/**
    BASE CLASSES
**/
class Script implements IFlxDestroyable {
    public var fileName:String = "";
    public var mod:String = null;
    public var filePath:String = null;
    public var metadata:Dynamic = {};

    public function new() {

    }

    public static function fromPath(path:String):Script {
        var script = create(path);
        if (script != null) {
            script.loadFile();
            return script;
        } else {
            return null;
        }
    }

    public static function create(path:String):Script {
        var p = path.toLowerCase();
        var ext = Path.extension(p);

        var scriptExts = Main.supportedFileTypes;
        if (ext.trim() == "") {
            for (e in scriptExts) {
                if (FileSystem.exists('$p.$e')) {
                    p = '$p.$e';
                    ext = e;
                    break;
                }
            }
        }
        var script = switch(ext.toLowerCase()) {
            case 'hhx':                     new HardcodedHScript();
            case 'hx' | 'hscript' | 'hsc':  new HScript();
            #if ENABLE_LUA case 'lua':      new LuaScript(); #end
            default:                        null;
            
        }
        if (script == null) return null;
        script.filePath = p;
        script.fileName = CoolUtil.getLastOfArray(path.replace("\\", "/").split("/"));
        return script;
    }


    public function executeFunc(funcName:String, ?args:Array<Any>):Dynamic {
        var ret = _executeFunc(funcName, args);
        executeFuncPost();
        return ret;
    }

    public function _executeFunc(funcName:String, ?args:Array<Any>):Dynamic {
        Paths.curSelectedMod = 'mods/${mod}';
        return null;
    }

    public function executeFuncPost() {
        Paths.curSelectedMod = null;
    }

    public function setVariable(name:String, val:Dynamic) {}

    public function getVariable(name:String):Dynamic {return null;}

    public function trace(text:String, error:Bool = false) {
        trace(text);
        if (CoolUtil.isDevMode()) {
            LogsOverlay.trace(text);
        }
    }

    public function loadFile() {
        Paths.curSelectedMod = 'mods/${mod}';
    }

    public function destroy() {

    }

    public function setScriptObject(obj:Dynamic) {}
}

class DummyScript extends Script {
    var variables:Map<String, Dynamic> = [];

    public function new() {super();}

    public override function _executeFunc(funcName:String, ?args:Array<Any>) {
        var f = variables[funcName];
        if (f != null) {
            try {
                if (args == null) {
                    var result = null;
                    try {
                        result = f();
                    } catch(e) {
                        this.trace('$e', true);
                    }
                    return result;
                } else {
                    var result = null;
                    try {
                        result = Reflect.callMethod(null, f, args);
                    } catch(e) {
                        this.trace('$e', true);
                    }
                    return result;
                }
            } catch(e) {
                this.trace('${e.toString()}');
            }
        }
        return null;
    }

    public override function setVariable(name:String, val:Dynamic) {variables.set(name, val);}
    public override function getVariable(name:String) {return variables.get(name);}
}

/**
    SCRIPT PACK
**/
class ScriptPack {
    public var ogScripts:Array<Script> = [];
    public var scripts:Array<Script> = [];
    public var scriptModScripts:Array<ModScript> = [];
    public var __curScript:Script;
    public function new(scripts:Array<ModScript>) {
        for (s in scripts) {
            addScript(s.path, s.mod);
            scriptModScripts.push(s);
        }
        for(e in this.scripts) ogScripts.push(e);
    }

    public function addScript(path:String, ?mod:String) {
        if (mod == null) mod = Settings.engineSettings.data.selectedMod;

        var sc = Script.create('${Paths.modsPath}/${path}');
        if (sc == null) return;
        ModSupport.setScriptDefaultVars(sc, mod, {});
        sc.setVariable("scriptPack", this);
        sc.setVariable("setGlobal", function(name:String, value:Dynamic, alsoAffectThis:Bool = false) {
            for(e in scripts) {
                if (alsoAffectThis || e != __curScript) {
                    e.setVariable(name, value);
                }
            }
        });
        sc.setVariable("importScript", function(p:String) {
            if (p == null) return;
            var scriptPath = SongConf.getModScriptFromValue(sc.mod, p);
            addScript(scriptPath.path, scriptPath.mod);
            scriptModScripts.push(scriptPath);
        });
        this.scripts.push(sc);
    }

    public function loadFiles() {
        for (k=>sc in scripts) {
            var s = scriptModScripts[k];
            __curScript = sc;
            sc.loadFile();
        }
    }

    public function executeFunc(funcName:String, ?args:Array<Any>, ?defaultReturnVal:Any) {
        var a = args;
        if (a == null) a = [];
        for (script in scripts) {
            __curScript = script;
            var returnVal = script.executeFunc(funcName, a);
            if (returnVal != defaultReturnVal && defaultReturnVal != null) {
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
            __curScript = script;
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
        for (script in ogScripts) { // for gfVersion and shit like that
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

/**
    HSCRIPT
**/
class HScript extends Script {
    public var hscript:Interp;
    public function new() {
        hscript = new Interp();
        hscript.errorHandler = function(e) {
            this.trace('$e', true);
            if (Settings.engineSettings != null && Settings.engineSettings.data.showErrorsInMessageBoxes && !FlxG.keys.pressed.SHIFT) {
                var posInfo = hscript.posInfos();

                var lineNumber = Std.string(posInfo.lineNumber);
                var methodName = posInfo.methodName;
                var className = posInfo.className;

                Application.current.window.alert('Exception occured at line $lineNumber ${methodName == null ? "" : 'in $methodName'}\n\n${e}\n\nIf the message boxes blocks the engine, hold down SHIFT to bypass.', 'HScript error! - ${fileName}');
            }
        };
        super();
    }
    public override function setScriptObject(obj:Dynamic) {
        hscript.scriptObject = obj;
    }

    public override function _executeFunc(funcName:String, ?args:Array<Any>):Dynamic {
        super._executeFunc(funcName, args);
        if (hscript == null)
            return null;
		if (hscript.variables.exists(funcName)) {
            var f = hscript.variables.get(funcName);
            if (Reflect.isFunction(f)) {
                if (args == null || args.length < 1)
                    return f();
                else
                    return Reflect.callMethod(null, f, args);
            }
		}
        executeFuncPost();
        return null;
    }

    public override function loadFile() {
        super.loadFile();
        if (filePath == null || filePath.trim() == "") return;
        try {
            hscript.execute(ModSupport.getExpressionFromPath(filePath, true));
        } catch(e) {
            this.trace('${e.message}', true);
        }
    }
    public function bruh() {
        super.loadFile();
    }

    public override function trace(text:String, error:Bool = false) {
        var posInfo = hscript.posInfos();

        var lineNumber = Std.string(posInfo.lineNumber);
        var methodName = posInfo.methodName;
        var className = posInfo.className;

        if (!Settings.engineSettings.data.developerMode) return;
        
        (error ? LogsOverlay.error : LogsOverlay.trace)(('$fileName:${methodName == null ? "" : '$methodName:'}$lineNumber: $text').trim());
    }

    public override function setVariable(name:String, val:Dynamic) {
        hscript.variables.set(name, val);
        @:privateAccess
        hscript.locals.set(name, {r: val, depth: 0});
    }

    public override function getVariable(name:String):Dynamic {
        if (@:privateAccess hscript.locals.exists(name) && @:privateAccess hscript.locals[name] != null) {
            @:privateAccess
            return hscript.locals.get(name).r;
        } else if (hscript.variables.exists(name))
            return hscript.variables.get(name);

        return null;
    }
}

class HardcodedHScript extends HScript {
    public override function loadFile() {
        bruh();

        var code:String = null;
        var expr = null;
        var unserializer = null;
        try {
            code = sys.io.File.getContent(filePath);
            // {code: expr}
            unserializer = new Unserializer(code);
            expr = unserializer.unserialize();
        } catch(e) {
            this.trace('${e.message}', true);
            return;
        }

        if (expr == null)
            return;

        if (!Reflect.hasField(expr, "code")) {
            this.trace('Serialized code does not have "code" variable.', true);
            return;
        }
        try {
            this.hscript.execute(expr.code);
        } catch(e) {
            this.trace('${e.message}', true);
            return;
        }
    }
}

/**
    LUA
**/
#if ENABLE_LUA
class LuaScript extends Script {
    public var state:llua.State;
    public var variables:Map<String, Dynamic> = [];
    public final zws = "​​";
    public var scriptObject:Dynamic = null;
    public var scriptObjectInstFields:Array<String> = [];
    public var luaFuncs:LuaFuncs;
    public var hscript:Interp;

    public var luaCallbacks:Map<String, Dynamic> = [];

    public static var currentExecutingScript:LuaScript = null;

    public function setLuaVar(name:String, value:Dynamic) {
        switch(Type.typeof(value)) {
            case Type.ValueType.TNull | Type.ValueType.TBool | Type.ValueType.TInt | Type.ValueType.TFloat | Type.ValueType.TClass(String) | Type.ValueType.TObject:
                Convert.toLua(state, value);
                Lua.setglobal(state, name);
            case value:
                throw new Exception('Variable of type $value is not supported.');
        }
    }

    function getVar(v:String) {
        var splittedVar = v.split(".");
        if (splittedVar.length == 0) return null;
        var currentObj = variables[splittedVar[0]];
        for (i in 1...splittedVar.length) {
            var property = Reflect.getProperty(currentObj, splittedVar[i]);
            if (property != null) {
                currentObj = property;
            } else {
                try {
                    // try running getter
                    currentObj = Reflect.getProperty(currentObj, 'get_${splittedVar[i]}')();
                } catch(e) {
                    this.trace('Variable ${splittedVar[i]} in $v doesn\'t exist or is equal to null. Parent variable is of type ${Type.typeof(currentObj)}.', true);
                    return null;
                }
            }
        }
        return currentObj;
    }

    public function getClass(path:String, forceClass:Bool = false):Dynamic {
        if (path.startsWith(zws)) path = path.substr(zws.length);
        var cl = Type.resolveClass(path);
        if (cl == null) {
            if (CoolUtil.isClass(variables[path])) {
                cl = variables[path];
            }
            if (cl == null) {
                if (forceClass) {
                    this.trace('Class ${path} not found.', true);
                    return null;
                } else {
                    var v = variables[path];
                    if (v == null)
                        this.trace('Class/Variable ${path} not found.', true);
                    return v;
                }
            }
        }
        return cl;
    }

    public static var callbackReturnVariables = [];
    /**
     * og code had too many flaws, redoing it
     */
    public static inline function callback_handler(l:State, fname:String):Int {

		var cbf = currentExecutingScript.luaCallbacks.get(fname);
        callbackReturnVariables = [];
        
		if(cbf == null) {
			return 0;
		}

		var nparams:Int = Lua.gettop(l);
		var args:Array<Dynamic> = [];

		for (i in 0...nparams) {
			args[i] = Convert.fromLua(l, i + 1);
		}

		var ret:Dynamic = null;

        try {
            ret = (nparams > 0) ? Reflect.callMethod(null, cbf, args) : cbf();
        } catch(e) {
            currentExecutingScript.trace(e.details(), true); // for super cool mega logging!!!
            throw e;
        }
        Lua.settop(l, 0);

        if (callbackReturnVariables.length <= 0)
            callbackReturnVariables.push(ret);
        for(e in callbackReturnVariables) {
            Convert.toLua(l, e);
        }

		/* return the number of results */
		return callbackReturnVariables.length;

	} //callback_handler

    public function addLuaCallback(callbackName:String, func:Dynamic) {
        luaCallbacks.set(callbackName, func);
		Lua.add_callback_function(state, callbackName);
        return true;
    }

    static inline function print_function(s:String) : Int { // you can use custom
		if (currentExecutingScript != null)
            currentExecutingScript.trace(s);
		return 0;
	}

    public function addLuaCallbacks(callbackNames:Array<String>, func:Dynamic) {
        for(e in callbackNames)
            addLuaCallback(e, func);
        return true;
    }
    public function new() {
        super();
        state = LuaL.newstate();
        Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(callback_handler));
        LuaL.openlibs(state);
		Lua.register_hxtrace_func(cpp.Callable.fromStaticFunction(print_function));
		Lua.register_hxtrace_lib(state);

        hscript = new Interp();
        hscript.errorHandler = function(error) {
            executeFunc("onHaxeError", [error.toString(), error.line, error.origin]);
        };
        variables = hscript.variables; // for syncing
        
        function doReturn(val:Dynamic, varName:String, path:String, warn:Bool = true):Dynamic {
            switch(Type.typeof(val)) {
                case Type.ValueType.TNull | Type.ValueType.TBool | Type.ValueType.TInt | Type.ValueType.TFloat | Type.ValueType.TClass(String) | Type.ValueType.TObject:
                    return val;
                default:
                    if (varName != null) {
                        variables.set(varName, val);
                        return '${zws}${varName}';
                    }
                    if (warn) this.trace('The variable type of ${path} is not supported by lua. Please add a 3rd parameter to specify the return variable name. (nil, path, varName) or (class, path, varName)', true);
                    return null;
            }
        }
        /**
            BASIC LUA FUNCTIONS
        **/
        addLuaCallback("refVar", function(val:String) {
            if (val.startsWith(zws)) {
                return val;
            }
            return zws + val;
        });
        addLuaCallback("createInstance", function(varName:String, classPath:String, parameters:Array<Dynamic>) {
                if (classPath == null || varName == null) {
                    this.trace("Class or variable name cannot be nil.", true);
                    return null;
                }
                trace(varName);
                trace(classPath);
                trace(parameters);
                var args = parseLuaVars(parameters);
                var correctClassName = [for(e in classPath.split(".")) e.trim()].join(".");
                var cl = getClass(correctClassName, true);
                try {
                    variables.set(varName, Type.createInstance(cl, args));
                    return '${zws}${varName}';
                } catch(e) {
                    trace(e.details());
                }
                // trace(variables);
                return null;
        });
        var getField = function(cl:String, path:String, varName:String):Dynamic {
            if (path == null && varName == null) {
                path = cl;
                cl = varName;
                varName = null;
            }
            
            var split = [for(e in path.split(".")) e.trim()];
            if (cl != null) {
                var cla = getClass(cl);
                if (cla == null) {
                    return null;
                }

                if (split.length < 2) {
                    return doReturn(getProperty(cla, split[0]), varName, path);
                } else {
                    var o = getProperty(cla, split[0]);
                    for(i in 1...split.length-1) {
                        o = getProperty(o, split[i]);
                        if (o == null) {
                            this.trace('Variable ${split[i]} is null.', true);
                            return null;
                        }
                    }
                    return doReturn(getProperty(o, split[split.length - 1]), varName, path);
                }
            } else {
                if (split.length < 2) {
                    if (variables.exists(split[0])) {
                        return variables[split[0]];
                    } else if (scriptObject != null && (scriptObjectInstFields.contains(split[0]) || scriptObject is Dynamic)) {
                        return doReturn(getProperty(scriptObject, split[0]), varName, path);
                    }
                    this.trace('Could not get variable.', true);
                    return null;
                } else {
                    var va = variables[split[0]];
                    if (va == null && scriptObject != null) va = getProperty(scriptObject, split[0]);
                    if (va == null) {
                        this.trace('Variable ${split[0]} is null.', true);
                        return null;
                    }
                    for(i in 1...split.length-1) {
                        va = getProperty(va, split[i]);
                        if (va == null) {
                            this.trace('Variable ${split[i]} is null.', true);
                            return null;
                        }
                    }
                    
                    return doReturn(getProperty(va, split[split.length - 1]), varName, path);
                }
            }
        };
        for(name in ["getField", "getProperty", "get", "getValue", "getVariable", "getFieldFromClass", "getFromClass", "getGBZEUIGBZIOG", "getVariableAkaFieldFromObjectOrClassUsingHaxesReflectApiWhileMakingSureGettersAreAlsoCalled"]) addLuaCallback(name, getField);

        var setField = function(cl:String, _path:Dynamic, val:Dynamic) {
            if (val == null) {
                val = _path;
                _path = cl;
                cl = null;
            }
            var path:String = _path;
            var v = parseLuaVar(val);
            var split = [for(e in path.split(".")) e.trim()];
            if (cl != null) {
                var cla = getClass(cl);
                if (cla == null) {
                    return false;
                }

                if (split.length < 2) {
                    Reflect.setProperty(cla, split[0], v);
                } else {
                    var o = getProperty(cla, split[0]);
                    for(i in 1...split.length-1) {
                        o = getProperty(o, split[i]);
                        if (o == null) {
                            this.trace('Variable ${split[i]} is null.', true);
                            return false;
                        }
                    }
                    Reflect.setProperty(o, split[split.length - 1], v);
                    return true;
                }
                
                return true;
            } else {
                if (split.length < 2) {
                    if (variables.exists(split[0])) {
                        variables[split[0]] = v;
                        return true;
                    } else if (scriptObject != null && (scriptObjectInstFields.contains(split[0]) || scriptObject is Dynamic)) {
                        Reflect.setProperty(scriptObject, split[0], v);
                        return true;
                    }
                    this.trace('Could not set variable.', true);
                    return false;
                } else {
                    var va = variables[split[0]];
                    if (va == null && scriptObject != null) va = Reflect.getProperty(scriptObject, split[0]);
                    if (va == null) {
                        this.trace('Variable ${split[0]} is null.', true);
                        return false;
                    }
                    for(i in 1...split.length-1) {
                        va = Reflect.getProperty(va, split[i]);
                        if (va == null) {
                            this.trace('Variable ${split[i]} is null.', true);
                            return false;
                        }
                    }
                    
                    Reflect.setProperty(va, split[split.length - 1], v);
                    return true;
                }
            }
        };
        for(name in ["setField", "setProperty", "set", "setValue", "setVariable", "setFieldFromClass", "setFromClass", "setGBZEUIGBZIOG", "setVariableAkaFieldFromObjectOrClassUsingHaxesReflectApiWhileMakingSureSettersAreAlsoCalled"]) addLuaCallback(name, setField);
        addLuaCallback("clearVariable", function(name:String) {
            if (variables.exists(name)) {
                variables.remove(name);
                return true;
            } else {
                return false;
            }
        });
        // better
        addLuaCallback("call", function(_cl:Dynamic, _path:Dynamic, _args:Dynamic, _resultVar:Dynamic) {
            var cl:String;
            var path:String;
            var args:Array<Dynamic>;
            var resultVar:String;
            if (_path is Array || _path == null || _args is String) { // by the power of haxe, this is possible
                resultVar = cast _args;
                args = cast _path;
                path = cast _cl;
                cl = null;
            } else {
                cl = cast _cl;
                path = cast _path;
                args = cast _args;
                resultVar = cast _resultVar;
            }
            if (args is Array) {
                args = parseLuaVars(args);
            } else {
                args = [];
            }
            var splitPath = [for(e in path.split(".")) e.trim()];
            var baseObj:Dynamic = null;
            if (cl != null) {
                var cla = getClass(cl);
                if (cl == null) {
                    return null;
                }
                baseObj = cla;
            } else {
                var v = splitPath.shift();
                baseObj = variables[v];
                if (baseObj == null) {
                    if (scriptObject != null && scriptObjectInstFields.contains(v)) {
                        baseObj = getProperty(scriptObject, v);
                        if (baseObj == null) {
                            this.trace('Variable ${v} is null.', true);
                            return null;
                        }
                    } else {
                        this.trace('Variable ${v} is null.', true);
                        return null;
                    }
                }
            }
            for(i in 0...splitPath.length) {
                baseObj = getProperty(baseObj, splitPath[i]);
                if (baseObj == null) {
                    this.trace('Variable ${splitPath[i]} is null.', true);
                    return null;
                }
            }
            switch(Type.typeof(baseObj)) {
                case TFunction:
                    var retValue = null;
                    try {
                        if (args is Array && args != null && args.length > 0)
                            retValue = Reflect.callMethod(null, baseObj, args);
                        else
                            retValue = baseObj();
                    } catch(e) {
                        this.trace('Error while calling ${path}:\n${e.details()}', true);
                    }
                    return doReturn(retValue, resultVar, path, false);
                default:
                    this.trace('Variable at ${path} is not a function.', true);
                    return null;
            }
        });
        // saul

        /**
            ARRAY HELPERS
        **/

        function getAssetThen(doStuff:Dynamic->Void, cl:String, path:String) {
            var split = [for(e in path.split(".")) e.trim()];
            if (cl != null) {
                var cla = getClass(cl);
                if (cla == null) {
                    return;
                }

                if (split.length < 2) {
                    doStuff(getProperty(cla, split[0]));
                    return;
                } else {
                    var o = getProperty(cla, split[0]);
                    for(i in 1...split.length-1) {
                        o = getProperty(o, split[i]);
                        if (o == null) {
                            this.trace('Variable ${split[i]} is null.', true);
                            return;
                        }
                    }
                    doStuff(getProperty(o, split[split.length - 1]));
                    return;
                }
            } else {
                if (split.length < 2) {
                    if (variables.exists(split[0])) {
                        doStuff(variables[split[0]]);
                        return;
                    } else if (scriptObject != null && (scriptObjectInstFields.contains(split[0]) || scriptObject is Dynamic)) {
                        doStuff(getProperty(scriptObject, split[0]));
                        return;
                    }
                    this.trace('Could not get variable.', true);
                    return;
                } else {
                    var va = variables[split[0]];
                    if (va == null && scriptObject != null) va = getProperty(scriptObject, split[0]);
                    if (va == null) {
                        this.trace('Variable ${split[0]} is null.', true);
                        return;
                    }
                    for(i in 1...split.length-1) {
                        va = getProperty(va, split[i]);
                        if (va == null) {
                            this.trace('Variable ${split[i]} is null.', true);
                            return;
                        }
                    }
                    
                    doStuff(getProperty(va, split[split.length - 1]));
                    return;
                }
            }

        }
        addLuaCallback("addToArray", function(_cl:Dynamic, _path:Dynamic, _val:Dynamic) {
            var cl:String;
            var path:String;
            var val:Dynamic;

            if (_val == null) {
                cl = null;
                path = cast _cl;
                val = cast _path;
            } else {
                cl = _cl;
                path = _path;
                val = _val;
            }
            if (path == null) {
                this.trace('Path cannot be nil.', true);
                return false;
            }

            var retValue = false;
            getAssetThen(function(obj:Dynamic) {
                if (obj == null) {
                    this.trace('Array at ${path} is null.', true);
                    return;
                }
                if (obj is Array) {
                    var arr:Array<Dynamic> = cast obj;
                    arr.push(parseLuaVar(val));
                    retValue = true;
                    return;
                } else {
                    this.trace('Object at ${path} is not an array.', true);
                    return;
                }
            }, cl, path);
            
            return retValue;
        });
        addLuaCallback("removeFromArray", function(_cl:Dynamic, _path:Dynamic, _val:Dynamic) {
            var cl:String;
            var path:String;
            var val:Dynamic;

            if (_val == null) {
                cl = null;
                path = cast _cl;
                val = cast _path;
            } else {
                cl = _cl;
                path = _path;
                val = _val;
            }
            if (path == null) {
                this.trace('Path cannot be nil.', true);
                return false;
            }

            var retValue = false;
            getAssetThen(function(obj:Dynamic) {
                if (obj == null) {
                    this.trace('Array at ${path} is null.', true);
                    return;
                }
                if (obj is Array) {
                    var arr:Array<Dynamic> = cast obj;
                    arr.remove(parseLuaVar(val));
                    retValue = true;
                    return;
                } else {
                    this.trace('Object at ${path} is not an array.', true);
                    return;
                }
            }, cl, path);
            
            return retValue;
        });
        addLuaCallback("setFromArray", function(_cl:Dynamic, _path:Dynamic, _id:Null<Int>, _val:Dynamic) {
            var cl:String;
            var path:String;
            var id:Int;
            var val:Dynamic;

            if (_val == null) {
                cl = null;
                path = cast _cl;
                id = cast _path;
                val = cast _id;
            } else {
                cl = _cl;
                path = _path;
                id = _id;
                val = _val;
            }
            if (path == null) {
                this.trace('Path cannot be nil.', true);
                return false;
            }

            var retValue = false;
            getAssetThen(function(obj:Dynamic) {
                if (obj == null) {
                    this.trace('Array at ${path} is null.', true);
                    return;
                }
                if (obj is Array) {
                    var arr:Array<Dynamic> = cast obj;
                    arr[id] = parseLuaVar(val);
                    retValue = true;
                    return;
                } else {
                    this.trace('Object at ${path} is not an array.', true);
                    return;
                }
            }, cl, path);
            
            return retValue;
        });
        addLuaCallback("getFromArray", function(_cl:Dynamic, _path:Dynamic, _index:Null<Int>) {
            var cl:String;
            var path:String;
            var index:Int;

            if (_index == null) {
                cl = null;
                path = cast _cl;
                index = cast _path;
            } else {
                cl = _cl;
                path = _path;
                index = _index;
            }
            if (path == null) {
                this.trace('Path cannot be nil.', true);
                return null;
            }

            var retValue = null;
            getAssetThen(function(obj:Dynamic) {
                if (obj == null) {
                    this.trace('Array at ${path} is null.', true);
                    return;
                }
                if (obj is Array) {
                    var arr:Array<Dynamic> = cast obj;
                    retValue = arr[index];
                    return;
                } else {
                    this.trace('Object at ${path} is not an array.', true);
                    return;
                }
            }, cl, path);
            
            return retValue;
        });

        /**
            HAXE HELPERS
        **/
        addLuaCallback("executeHaxe", function(haxeCode:String, returnValueName:String) {
                
            var parsedShit = ModSupport.getExpressionFromString(haxeCode);
            if (parsedShit == null) return null;

            @:privateAccess
            for(k=>e in hscript.locals) if (e == null || e.depth <= 0) hscript.locals.remove(k);
            @:privateAccess
            var retValue = hscript.exprReturn(parsedShit);
            return doReturn(retValue, returnValueName, "your HScript code's returned value", false);
            return null;
        });
        addLuaCallbacks(["addCallbackFromHaxe", "addHaxeCallback"], function(haxeCallbackName:String, luaCallbackName:String) {
            if (luaCallbackName == null) luaCallbackName = haxeCallbackName;
            if (haxeCallbackName == null) {
                this.trace('Callback name cannot be null.');
                return false;
            }
            if (luaCallbackName.trim() == "" || haxeCallbackName.trim() == "") {
                this.trace('Callback names cannot be empty strings.');
                return false;
            }
            var haxeCallback = variables.get(haxeCallbackName);
            if (haxeCallback == null) {
                this.trace('Could not find haxe callback ${haxeCallbackName}.');
                return false;
            }
            if (!Reflect.isFunction(haxeCallback)) {
                this.trace('Variable named ${haxeCallbackName} is not a function.');
                return false;
            }
            addLuaCallback(luaCallbackName, function(?p1:Dynamic, ?p2:Dynamic, ?p3:Dynamic, ?p4:Dynamic, ?p5:Dynamic, ?p6:Dynamic, ?p7:Dynamic, ?p8:Dynamic, ?p9:Dynamic, ?p10:Dynamic) {
                try {
                    var realArgs:Array<Dynamic> = parseLuaVars([p1, p2, p3, p4, p5, p6, p7, p8, p9, p10]);
                    return doReturn(Reflect.callMethod(null, haxeCallback, realArgs), haxeCallbackName, '(Custom HScript function) $haxeCallbackName', true);
                } catch(e) {
                    this.trace('Failed to run ${haxeCallbackName} - ${e.details()}', true);
                    throw e;
                }
            });
            return false;
        });
        /**
            ADDING FLIXEL SUPPORT
        **/
        LuaFuncs.addCallbacks(this);
        
    }

    public function getProperty(obj:Dynamic, property:String):Dynamic {
        var prop = Reflect.getProperty(obj, property);
        if (prop == null) {
            prop = Reflect.getProperty(obj, 'get_${property}');
            if (prop == null || !Reflect.isFunction(prop)) return null;
            return prop();
        }
        return prop;
    }

    public function parseLuaVars(v:Array<Dynamic>) {
        var f:Array<Dynamic> = [];
        for(e in v) {
            f.push(parseLuaVar(e));
        }
        return f;
    }
    public function parseLuaVar(v:Dynamic) {
        if (v != null)
            if (v is String)
                if (cast(v, String).startsWith(zws)) 
                    return variables[cast(v, String).substr(1)];
        return v;
    }

    public override function setScriptObject(obj:Dynamic) {
        var cl = Type.getClass(obj);
        scriptObject = obj;
        scriptObjectInstFields = Type.getInstanceFields(cl);
        hscript.scriptObject = obj;

        // BE AWARE! WILL NOT BE CLEANED UP!!
        if (obj is ILuaScriptable && !(obj is MusicBeatState)) {
            obj.addLuaCallbacks(this);
        }
    }

    public override function loadFile() {
        super.loadFile();
        var oldExec = currentExecutingScript;
        currentExecutingScript = this;
        
        if (FileSystem.exists(filePath)) {
            if (LuaL.dostring(state, File.getContent(filePath)) != 0) {
                var err = Lua.tostring(state, -1);
                this.trace('$err');
            }
        } else {
            this.trace("Lua script does not exist.", true);
        }
        currentExecutingScript = oldExec;
    }

    public override function trace(text:String, error:Bool = false)
    {
        var lua_debug:Lua_Debug = {

        }
        Lua.getinfo(state, "nSl", lua_debug);

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

        (error ? LogsOverlay.error : LogsOverlay.trace)(bText + text);
        trace(bText + text);
    }

    public override function getVariable(name:String) {
        return variables[name];
    }

    public override function setVariable(name:String, v:Dynamic) {
        variables[name] = v;
    }

    public override function _executeFunc(funcName:String, ?args:Array<Any>) {
        super._executeFunc(funcName, args);
        var oldExec = currentExecutingScript;
        currentExecutingScript = this;
        
        Lua.settop(state, 0);
        if (args == null) args = [];
        Lua.getglobal(state, funcName);

        var type:Int = Lua.type(state, -1);
        if (type != Lua.LUA_TFUNCTION) {
            if (variables[funcName] != null) //mayhaps
                if (Reflect.isFunction(variables[funcName]))
                    return Reflect.callMethod(null, variables[funcName], args);
            return null; // not a function, not executing, fuck off
        }
            
        
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
                    variables["p" + Std.string(k + 1)] = val;
                    Lua.pushstring(state, '${zws}p${Std.string(k+1)}');
            }
        }

        // SYNCING SHARED VALUES (@shareWithLuas)
        if (scriptObject != null && scriptObject is ILuaScriptable) {
            cast(scriptObject, ILuaScriptable).setSharedLuaVariables(this);
        }
        if (FlxG.state is ILuaScriptable && scriptObject != FlxG.state) {
            cast(FlxG.state, ILuaScriptable).setSharedLuaVariables(this);
        }
        
        if (Lua.pcall(state, args.length, 1, 0) != 0) {
            var err = Lua.tostring(state, -1);
            this.trace('$err', true);
            return null;
        }

        var value = Convert.fromLua(state, Lua.gettop(state));
        currentExecutingScript = oldExec;
        return value;
    }

    public override function destroy() {
        Lua.close(state);
    }
}
#end

interface ILuaScriptable {
    #if ENABLE_LUA
    public function setSharedLuaVariables(script:LuaScript):Void;
    public function addLuaCallbacks(script:LuaScript):Void;
    #end
}