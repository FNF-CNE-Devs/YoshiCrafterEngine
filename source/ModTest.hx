import haxe.macro.Compiler;
#if desktop
import cpp.Lib;
#end
import flixel.FlxState;

class ModTest extends FlxState {
    public override function create() {
        super.create();
        var func:Dynamic;
        #if desktop
        func = Lib.load(Paths.modsPath + "/Friday Night Funkin'/mod.ndll", "template_mod_main", 0);
        #end
        func();
    }
    public override function update(elapsed:Float) {

    }
}