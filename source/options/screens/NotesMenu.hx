package options.screens;

import flixel.FlxG;
import flixel.math.FlxMath;
import EngineSettings.Settings;

class NotesMenu extends OptionScreen {
    public override function create() {
        options = [
            {
                name: "Glow CPU strums",
                desc: "If enabled, CPU strums will glow when they hit a note, like the player ones.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.glowCPUStrums);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.glowCPUStrums = !Settings.engineSettings.data.glowCPUStrums);}
            },
            {
                name: "Apply colors on everyone",
                desc: "If enabled, your note colors will be applied on every characters. Defaults to off.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.customArrowColors_allChars);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.customArrowColors_allChars = !Settings.engineSettings.data.customArrowColors_allChars);}
            },
            {
                name: "Customize Note Colors",
                desc: "Select this to open the Color Customisation Menu.",
                value: "",
                onSelect: function(e) {
                    doFlickerAnim(curSelected, function() {
                        FlxG.switchState(new OptionsNotesColors());
                    });
                }
            },
            {
                name: "Enable Note Motion Blur",
                desc: "If enabled, a blur effect will be applied to scrolling notes, making them seem smoother, at\ncost of performance.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.noteMotionBlurEnabled);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.noteMotionBlurEnabled = !Settings.engineSettings.data.noteMotionBlurEnabled);}
            },
            {
                name: "Blur Multiplier",
                desc: "How blurry the notes should be. Defaults to 1.",
                value: "",
                onCreate: function(e) {e.value = '${Settings.engineSettings.data.noteMotionBlurMultiplier}';},
                onLeft: function(e) {e.value = '${Settings.engineSettings.data.noteMotionBlurMultiplier}';},
                onUpdate: function(e) {
                    if (controls.LEFT_P) Settings.engineSettings.data.noteMotionBlurMultiplier -= 0.1;
                    if (controls.RIGHT_P) Settings.engineSettings.data.noteMotionBlurMultiplier += 0.1;
                    Settings.engineSettings.data.noteMotionBlurMultiplier = FlxMath.bound(FlxMath.roundDecimal(Settings.engineSettings.data.noteMotionBlurMultiplier, 1), 0.1, 10);
                    e.value = '< ${Settings.engineSettings.data.noteMotionBlurMultiplier} >';
                }
            },
            {
                name: "Transparent sustains",
                desc: "If enabled, will make note sustains (tails) semi transparent, like in the original game.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.transparentSubstains);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.transparentSubstains = !Settings.engineSettings.data.transparentSubstains);}
            },
            {
                name: "Enable Splashes",
                desc: "If enabled, will show splashes everytime you hit a Sick! rating, like in Week 7.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.splashesEnabled);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.splashesEnabled = !Settings.engineSettings.data.splashesEnabled);}
            },
            {
                name: "Splashes Opacity",
                desc: "How opaque the splashes should be. 0% means invisible and 100% means fully opaque. Defaults\nto 80%",
                value: "",
                onCreate: function(e) {e.value = '${Settings.engineSettings.data.splashesAlpha * 100}%';},
                onLeft: function(e) {e.value = '${Settings.engineSettings.data.splashesAlpha * 100}%';},
                onUpdate: function(e) {
                    if (controls.LEFT_P) Settings.engineSettings.data.splashesAlpha -= 0.1;
                    if (controls.RIGHT_P) Settings.engineSettings.data.splashesAlpha += 0.1;
                    Settings.engineSettings.data.splashesAlpha = FlxMath.bound(FlxMath.roundDecimal(Settings.engineSettings.data.splashesAlpha, 1), 0.1, 1);
                    e.value = '< ${Settings.engineSettings.data.splashesAlpha * 100}% >';
                }
            }
        ];
        super.create();
    }
}