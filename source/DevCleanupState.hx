import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import Type.ValueType;
import flixel.FlxState;

class DevCleanupState extends FlxState {
    var args:Array<Any> = [];
    var newState:Class<FlxState>;
    public override function new(newState:Class<FlxState>, ?args:Array<Any>)  {
        this.newState = newState;
        FlxTransitionableState.skipNextTransIn = true;
        if (args != null) this.args = args;
        super();
    }
    public override function create() {
        super.create();
        FlxTransitionableState.skipNextTransOut = true;
        FlxG.switchState(Type.createInstance(newState, args));
        FlxTransitionableState.skipNextTransIn = false;
    }
}