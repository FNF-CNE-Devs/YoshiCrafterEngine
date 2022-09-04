import flixel.input.keyboard.FlxKey;
import flixel.input.actions.FlxAction.FlxActionDigital;

class KeybindControls {
    public static var controls:Map<Int, Map<Int, ActionControl>> = [];

    public static function getPressedState(keyNum:Int, id:Int) {
        return checkKey(keyNum, id).pressed.check();
    }

    public static function getJustPressedState(keyNum:Int, id:Int) {
        return checkKey(keyNum, id).justPressed.check();
    }

    public static function getJustReleasedState(keyNum:Int, id:Int) {
        return checkKey(keyNum, id).justReleased.check();
    }

    public static function checkKey(keyNum:Int, id:Int) {
        if (controls[keyNum] == null)
            loadControls(keyNum);
        if (controls[keyNum][id] == null)
            loadControlFromKey(keyNum, id);
        return controls[keyNum][id];
    }

    public static function loadControls(keyNum:Int) {
        var controlSet:Map<Int, ActionControl> = [];
        controls[keyNum] = controlSet;
        for(i in 0...keyNum)
            loadControlFromKey(keyNum, i);
    }

    public static function loadControlFromKey(keyNum:Int, i:Int) {
        var key:Null<FlxKey> = Reflect.field(Settings.engineSettings.data, 'control_${keyNum}_${i}');
        var altKey:Null<FlxKey> = Reflect.field(Settings.engineSettings.data, 'control_${keyNum}_${i}_alt');
        var action = new ActionControl();
        for(key in [key, altKey]) {
            action.pressed.addKey(key, PRESSED);
            action.justPressed.addKey(key, JUST_PRESSED);
            action.justReleased.addKey(key, JUST_RELEASED);
        }
        controls[keyNum][i] = action;
    }
}

class ActionControl {
    public var pressed:FlxActionDigital = new FlxActionDigital();
    public var justPressed:FlxActionDigital = new FlxActionDigital();
    public var justReleased:FlxActionDigital = new FlxActionDigital();

    public function new() {}
}