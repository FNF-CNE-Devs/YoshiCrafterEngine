package options.screens;

import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Assets;
import flixel.addons.transition.FlxTransitionableState;
import dev_toolbox.ToolboxMain;
import options.OptionScreen;
import flixel.FlxG;

using StringTools;

class DebugMenu extends OptionScreen {
    public var selectThing:FlxSprite;
    public var selectThingShader:MenuItemShader;
    public function new() {
        super("Options > Debug Menu");
    }
    public override function create() {
        options = [
            {
                name: "flashingLightsDoNotShow",
                desc: "Do not show flashing lights.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.flashingLightsDoNotShow);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.flashingLightsDoNotShow = !Settings.engineSettings.data.flashingLightsDoNotShow);}
            },
            {
                name: "reset flashing lights mods",
                desc: "Do not show flashing lights.",
                value: "",
                onSelect: function(e) {
                    Settings.engineSettings.data.approvedFlashingLightsMods = [];
                    e.value = ("mods reset");
                }
            },
            {
                name: "rainbow notes",
                desc: "Hidden option!?!?!?",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.rainbowNotes);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.rainbowNotes = !Settings.engineSettings.data.rainbowNotes);}
            },
            {
                name: "Force debug mode",
                desc: "Force debug mode on locked mods",
                value: "",
                onCreate: function(e) {@:privateAccess e.check(ModSupport.forceDevMode);},
                onSelect: function(e) {@:privateAccess e.check(ModSupport.forceDevMode = !ModSupport.forceDevMode);}
            },
            {
                name: "loading screen (unfinished)",
                desc: "adds an unfinished loading screen.\nscrapped cause it has a 1/1000 chance to break a flxsprite with a sparrow atlas",
                value: "",
                onCreate: function(e) {@:privateAccess e.check(Settings.engineSettings.data.secretLoadingScreen);},
                onSelect: function(e) {@:privateAccess e.check(Settings.engineSettings.data.secretLoadingScreen = !Settings.engineSettings.data.secretLoadingScreen);}
            },
            {
                name: "widescreen sweep",
                desc: "cool stuff hehe, hidden cause not every mods are compatible with it",
                value: "",
                onCreate: function(e) {@:privateAccess e.check(Settings.engineSettings.data.secretWidescreenSweep);},
                onSelect: function(e) {@:privateAccess e.check(Settings.engineSettings.data.secretWidescreenSweep = !Settings.engineSettings.data.secretWidescreenSweep);}
            },
            {
                name: "Crash the engine",
                desc: "Select this to crash the engine.",
                value: "",
                onSelect: function(e) {
                    var i:Int = -1;
                    var messages = [
                        "Are you sure?",
                        "Are you really sure?",
                        "fr??",
                        "this is a one way go, are you really really sure?",
                        "i cant believe you. are you REALLY sure about that?",
                        "select no if you're sure about it.",
                        "are you really really sure?",
                        "there may be something left unsaved. Are you really really really sure?",
                        "i think they want me to stfu",
                        "yeah they do.",
                        "really really really sure????",
                        "really sure? last warning",
                        "i lied MUAHAHHAHAHAHAHAA",
                        "are you really really really sure?",
                        "last warning (fr this time)",
                        "are you sure?",
                        "Fredbear's Family Diner William Afton and Henry opened in 1967 the family friendly Fredbear's Family Diner, featuring a brown furry suit of a bear as a mascot. Henry would usually wear the suit, as they didn't have enough money to hire someone to do the job for a long time and they were studying at the time. William studied engineering and Henry business adminstration and communication. William met an unnamed woman, with whom he married and three years later had a boy challed Michael. They met in the court; William was being charged for murdering a child that allegedly was crying outside the Diner for being scared of Fredbear, the bear, and she was working selling hot-dogs in from of the building.",
                        "im not funny",
                        "mfw",
                        "how did you even find this option",
                        "what have you done to get here",
                        "anyways",
                        "are you sure?"
                    ];
                    var nextMessage:Void->Void = null;
                    nextMessage = function() {
                        i++;
                        if (i >= messages.length) {
                            var e:MusicBeatState = null;
                            @:privateAccess
                            e.update(0);
                        } else {
                            openSubState(new MenuMessage(messages[i], [
                                {
                                    label: "Yes",
                                    callback: function() {
                                        nextMessage();
                                    }
                                },
                                {
                                    label: "No",
                                    callback: function() {}
                                }
                            ], 1));
                        }
                    }
                    nextMessage();
                }
            },
            {
                name: "2.0.0 update screen",
                desc: "Test the 2.0.0 update screen",
                value: "",
                onSelect: function(e) {
                    FlxG.switchState(new OutdatedSubState([], "2.0.0", Assets.getText(Paths.txt('testChangelog', 'preload')).replace("\r\n", "\n")));
                }
            }
        ];
        createBG = false;
        canSelect = false;
        selectThing = new FlxSprite(0, 0, Paths.image("options/layout"));
        selectThing.shader = (selectThingShader = new MenuItemShader());
        selectThing.antialiasing = true;
        add(selectThing);
        super.create();
        var label = new AlphabetOptimized(0, 0, "YoshiCrafter Engine debug settings menu\nThis menu contains some useful options used during YoshiCrafter Engine development along with some UI changes that didnt made it through the normal settings (mainly because people thinks shaders are gpu burners)", false, 0.25);
        label.alpha = 0.5;
        add(label);
        FlxG.camera.zoom = 10;
        FlxG.camera.alpha = 0;
        FlxTween.tween(FlxG.camera, {zoom: 1, alpha: 1}, 2, {ease: FlxEase.quartOut, onComplete:function(t) {
            canSelect = true;
        }});
    }

    var specialTime:Float = 0;
    public override function update(elapsed:Float) {
        super.update(elapsed);
        selectThing.setPosition(FlxMath.lerp(selectThing.x, spawnedOptions[curSelected].x + ((spawnedOptions[curSelected].width - selectThing.width) / 2) + 100, 0.25 * elapsed * 60), FlxMath.lerp(selectThing.y, spawnedOptions[curSelected].y + ((spawnedOptions[curSelected].height - selectThing.height) / 2), 0.25 * elapsed * 60));

        specialTime += elapsed;
        selectThingShader.setTime(specialTime);
        FlxG.camera.scroll.y = Math.sin(specialTime / 3) * 15;
    }
}

class MenuItemShader extends FlxFixedShader {
    @:glFragmentSource('#pragma header

    uniform float time = 0;

    float bound(float v1, float v2, float v3) {
        if (v1 < v2) return v2;
        if (v1 > v3) return v3;
        return v1;
    }
    void main() {
        gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);

        float mul = 3.5 / openfl_TextureSize.x * openfl_TextureSize.y;
        float d = pow(mod(abs(time - (openfl_TextureCoordv.x + ((openfl_TextureCoordv.y) * mul))), 1.0), 2.0);
        if (d > 0.5)
            d = 1.0 - d;
        float dist = bound(d, 0.0, mul) / mul;
        // float dist = 0;
        gl_FragColor *= dist;
    }')

    public function new() {
        super();
        setTime(0);
    }

    public function setTime(time:Float) {
        this.time.value = [time];
    }
}