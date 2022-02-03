

import flixel.input.keyboard.FlxKeyList;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

using haxe.EnumTools;

enum FlxControlType {
	JustPressed;
	JustReleased;
	Pressed;
}
class FlxControls {
    public static var pressed(get, null):Dynamic;
    private static function get_pressed() {
        var list = {};
		var map = FlxKey.toStringMap;
        var keys = map.keys();
        while(keys.hasNext()) {
            var id = keys.next();
            var name = map[id];
            Reflect.setField(pressed, name, FlxG.keys.any);
        }
        return list;
        
    }
    public static function anyPressed(keys:Array<FlxKey>) {
		#if android
			
		#else
			FlxG.keys.anyPressed(keys);
		#end
    }

    public static function getAndroidInput(type:FlxControlType):Dynamic {
		#if MOBILE_UI
			var result = {};
			var currentState = FlxG.state;
			var map = FlxKey.toStringMap;
			for(c in currentState.members) {
				if (Std.isOfType(c, FlxClickableSprite)) {
					var sprite = cast(c, FlxClickableSprite);
					if (sprite.key != null) {
						switch (type) {
							case Pressed:
								if (sprite.pressed) {
									result[map[sprite.key]] = true;
								}
							case JustPressed:
								if (sprite.justPressed) {
									result[map[sprite.key]] = true;
								}
							case JustReleased:
								if (sprite.justReleased) {
									result[map[sprite.key]] = true;
								}
						}
					}
				}
			}
		#else
			return {};
		#end
    }
}