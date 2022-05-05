package options.screens;

import flixel.FlxG;
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
        return ControlsSettingsSubState.getKeyName(key, true);
    }
    public override function create() {
        options = [];
        for(k in keys) {
            
            options.push({
                name: '$k keys',
                desc: 'Current keybinds: ${[for(i in 0...k) getKeyLabel(Reflect.field(Settings.engineSettings.data, 'control_${k}_$i'))].join(" ")}',
                img: null,
                value: "",
                onUpdate: null,
                onSelect: function(e) {
                    persistentUpdate = false;
                    openSubState(new ControlsSettingsSubState(k, FlxG.camera, function() {
                        e.desc = 'Current keybinds: ${[for(i in 0...k) getKeyLabel(Reflect.field(Settings.engineSettings.data, 'control_${k}_$i'))].join(" ")}';
                    }));
                }
            });
        }
        super.create();
    }
}