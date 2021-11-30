import ModSupport.Paths_Mod;
import flixel.FlxState;

class AnimateTest extends FlxState {
    public override function create() {
        new Paths_Mod("Friday Night Funkin'").getAnimateManager("cutscenes/tightBars/", function(f) {
            add(f.("TANK TALK 2").child);
        });

    }
}