

import flixel.input.keyboard.FlxKeyList;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

using haxe.EnumTools;

class FlxControls {
    public static var pressed(get, null):Dynamic;
    private static function get_pressed() {
        var list = {};
		for (f in Type.getEnum(FlxKey.A.toString())) {
			// xFlxKey.A.toString("f");
		}
        return list;
        
    }
    public static function anyPressed(keys:Array<FlxKey>) {
		#if android
			
		#else
			FlxG.keys.anyPressed(keys);
		#end
    }
}