import haxe.macro.Compiler;
#if cpp
import cpp.Lib;
#end
import flixel.FlxState;

class ModTest extends FlxState {
    public override function create() {
        super.create();
        var func:Dynamic;
        #if cpp
        func = Lib.load(Paths.getModsFolder() + "/Friday Night Funkin'/mod.ndll", "template_mod_main", 0);
        #end
        func();
    }
    public override function update(elapsed:Float) {

    }
}