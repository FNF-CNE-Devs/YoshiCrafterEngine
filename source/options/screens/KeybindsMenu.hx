package options.screens;

import flixel.input.keyboard.FlxKey;
import EngineSettings.Settings;
import options.*;

class KeybindsMenu extends OptionScreen {
    
    var keys = CoolUtil.getAllChartKeys();
    var map = FlxKey.toStringMap;
    
    public function new() {
        super();
    }

    function getKeyLabel(key) {
        var label:String = null;
        if ((label = map[key]) == null) label = key;
        return label;
    }
    public override function create() {
        options = [];
        for(k in keys) {
            
            options.push({
                name: "4 keys",
                desc: 'Current keybinds: ${[for(i in 0...k) getKeyLabel(Reflect.field(Settings.engineSettings.data, 'control_${k}_$i'))].join(" ")}',
                img: null,
                value: "",
                onUpdate: null
            });
        }
        super.create();
    }
}