package mod_support_stuff;

import flixel.FlxBasic;
import flixel.FlxG;
import EngineSettings.Settings;
import Script.HScript;

class ModState extends MusicBeatState {
    public var _mod:String = Settings.engineSettings.data.selectedMod;
    public var _scriptName:String = "main";
    public var script:Script = null;
    public var args:Array<Any> = [];

    // WILL NEED TO BE IN "Your Mod/states/"
    public override function new(name:String, mod:String, ?args:Array<Any>) {
        super();
        if (args == null) args = [];
        if (name != null) _scriptName = name;
        if (mod != null) _mod = mod;

        var path = '${Paths.modsPath}/$_mod/states/$_scriptName';

        script = Script.create(path);
        if (script != null) script = new HScript();

        
        script.setVariable("new", function(args) {});
        script.setVariable("create", function(args) {});
        script.setVariable("beatHit", function(curBeat:Int) {});
        script.setVariable("stepHit", function(curStep:Int) {});
        script.setVariable("destroy", function() {});
        script.setVariable("add", function(obj:FlxBasic) {add(obj);});
        script.setVariable("remove", function(obj:FlxBasic) {remove(obj);});
        script.setVariable("insert", function(i:Int, obj:FlxBasic) {insert(i, obj);});

        ModSupport.setScriptDefaultVars(script, _mod, {});
        script.loadFile(path);

        script.executeFunc("new", args);

        this.args = args;
    }

    public override function create() {
        super.create();
        script.executeFunc("create", args);
    }

    public override function beatHit() {
        script.executeFunc("beatHit", [curBeat]);
        super.beatHit();
    }

    public override function stepHit() {
        script.executeFunc("stepHit", [curStep]);
        super.stepHit();
    }

    public override function update(elapsed:Float) {
        if (CoolUtil.isDevMode()) {
            if (FlxG.keys.justPressed.F5) {
                // F5 to reload in dev mode
                FlxG.switchState(new ModState(_scriptName, _mod));
            }
        }
        script.executeFunc("update", [elapsed]);
        super.update(elapsed);
    }

    public override function destroy() {
        script.executeFunc("destroy");
        super.destroy();
    }
}