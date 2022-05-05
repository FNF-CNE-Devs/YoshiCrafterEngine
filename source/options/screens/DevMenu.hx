package options.screens;

import flixel.addons.transition.FlxTransitionableState;
import dev_toolbox.ToolboxMain;
import EngineSettings.Settings;
import options.OptionScreen;
import flixel.FlxG;

class DevMenu extends OptionScreen {
    public override function create() {
        options = [
            {
                name: "Developer Mode",
                desc: "When checked, enables Developer Mode, which allows you to access the Toolbox to create\nand edit mods.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.developerMode);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.developerMode = !Settings.engineSettings.data.developerMode);}
            },
            {
                name: "Open the Toolbox",
                desc: "Select this option to open the Toolbox (dev mode only).",
                value: "Open",
                onSelect: function(e) {
                    if (Settings.engineSettings.data.developerMode) {
                        doFlickerAnim(1, function() {
                            FlxG.switchState(new ToolboxMain());
                        });
                    } else {
                        CoolUtil.playMenuSFX(3);
                    }
                }
            }
        ];
        super.create();
    }
    
    public override function update(elapsed:Float) {
        super.update(elapsed);
        spawnedOptions[1]._nameAlphabet.textColor = Settings.engineSettings.data.developerMode ? 0xFFFFFFFF : 0xFF888888;
    }
}