package options.screens;

import EngineSettings.Settings;
import options.OptionScreen;

class GameplayMenu extends OptionScreen {
    public override function create() {
        options = [
            {
                name: "Downscroll",
                desc: "If enabled, Notes will scroll from up to down, instead of from down to up.",
                value: "Enabled"
            }
        ];
        super.create();
        spawnedOptions[0]._valueAlphabet.textColor = 0xFF44FF44;
    }

    public override function onSelect(id:Int) {
        switch(id) {
            case 0:
                Settings.engineSettings.data.downscroll = !Settings.engineSettings.data.downscroll;
                if (Settings.engineSettings.data.downscroll) {
                    spawnedOptions[0].value = "Disabled";
                    spawnedOptions[0]._valueAlphabet.textColor = 0xFFFF4444;
                } else {
                    spawnedOptions[0].value = "Enabled";
                    spawnedOptions[0]._valueAlphabet.textColor = 0xFF44FF44;
                }
        }
    }
}