import flixel.addons.ui.FlxUINumericStepper;

class FlxUINumericStepperPlus extends FlxUINumericStepper {
    public var onChange:Float->Void;
    public override function _onPlus() {
        @:privateAccess
        super._onPlus();
        if (onChange != null) onChange(value);
    }
    public override function _onMinus() {
        @:privateAccess
        super._onMinus();
        if (onChange != null) onChange(value);
    }
}