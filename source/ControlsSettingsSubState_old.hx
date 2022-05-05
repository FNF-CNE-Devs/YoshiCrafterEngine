import NoteShader.ColoredNoteShader;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxBasic;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import Note.NoteDirection;
import flixel.input.keyboard.FlxKey;
import EngineSettings.Settings;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;

class ControlsSettingsSub extends MusicBeatSubstate {
    public var arrows:Array<FlxSprite> = [];
    public var currentControls:Array<FlxKey> = [];
    public var size:Float = 0;
    public var saveButton:FlxSprite;
    public var exitButton:FlxSprite;
    public var selectedColor:FlxColor = new FlxColor(0xFF2384E4);
    public var saveButtonEnabled:Bool = false;
    public var arrowsText:Array<FlxText> = [];
    public var isSettingKeybind = false;

    public var arrowNumber:Int = 4;

    public var keybindSettingBackground:FlxSprite;
    public var keybindSettingBackground2:FlxSprite;
    public var keybindSettingText:FlxText;
    public var keybindSettingInstructions:FlxText;
    public var keybindSettingCancel:FlxSprite;
    public var keybindSettingKey:Int = 0;

    public static var customKeybindsNameOverride:Map<String, String> = [
        "numpadone" => "Numpad 1",
        "numpadtwo" => "Numpad 2",
        "numpadthree" => "Numpad 3",
        "numpadfour" => "Numpad 4",
        "numpadfive" => "Numpad 5",
        "numpadsix" => "Numpad 6",
        "numpadseven" => "Numpad 7",
        "numpadeight" => "Numpad 8",
        "numpadnine" => "Numpad 9",
        "numpadzero" => "Numpad 0",
        "one" => "1",
        "two" => "2",
        "three" => "3",
        "four" => "4",
        "five" => "5",
        "six" => "6",
        "seven" => "7",
        "eight" => "8",
        "nine" => "9",
        "zero" => "0",
        "numpadplus" => "Numpad +",
        "numpadminus" => "Numpad -",
        "numpadmultiply" => "Numpad *"
    ];
    public static var customKeybindsNameOverrideSimple:Map<String, String> = [
        "numpadone" => "#1",
        "numpadtwo" => "#2",
        "numpadthree" => "#3",
        "numpadfour" => "#4",
        "numpadfive" => "#5",
        "numpadsix" => "#6",
        "numpadseven" => "#7",
        "numpadeight" => "#8",
        "numpadnine" => "#9",
        "numpadzero" => "#0",
        "one" => "1",
        "two" => "2",
        "three" => "3",
        "four" => "4",
        "five" => "5",
        "six" => "6",
        "seven" => "7",
        "eight" => "8",
        "nine" => "9",
        "zero" => "0",
        "numpadplus" => "#+",
        "numpadminus" => "#-",
        "numpadmultiply" => "#*"
    ];

    public function mouseOverlaps(f:FlxSprite):Bool {
        // var pos = new FlxPoint(FlxG.game.mouseX / FlxG.scaleMode.gameSize.x * 1280, FlxG.game.mouseY / FlxG.scaleMode.gameSize.y * 720);
        var pos = FlxG.mouse.getScreenPosition(PlayState.current != null ? PlayState.current.camHUD : FlxG.camera);
        // if (PlayState.current != null) {
        // }
        
        // trace(pos);
        return (pos.x > f.x + f.offset.x && pos.x < f.x + f.width) && (pos.y > f.y && pos.y < f.y + f.height);
    }
    public function switchKeybindSetting(enable:Bool, key:Int = 0) {
        isSettingKeybind = enable;
        var list:Array<FlxBasic> = [keybindSettingBackground, keybindSettingBackground2, keybindSettingCancel, keybindSettingInstructions, keybindSettingText];
        if (enable) {
            keybindSettingKey = key;
            for (index => value in list) {
                add(value);
                FlxTween.tween(value, {alpha : 1}, 0.2, {ease : FlxEase.smoothStepInOut});
            }
        } else {
            keybindSettingKey = key;
            for (index => value in list) {
                FlxTween.tween(value, {alpha : 0}, 0.2, {ease : FlxEase.smoothStepInOut, onComplete: function(e) {
                    remove(value);
                }});
            }
        }
    }
    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (isSettingKeybind) {
            if (mouseOverlaps(keybindSettingCancel)) {
                keybindSettingCancel.color = selectedColor;
                if (FlxG.mouse.justReleased) {
                    CoolUtil.playMenuSFX(2);
                    switchKeybindSetting(false);
                    return;
                }
            } else {
                keybindSettingCancel.color = FlxColor.WHITE;
            }
            if (FlxControls.firstJustPressed() != -1) {
                var key:FlxKey = cast(FlxControls.firstJustPressed(), FlxKey);
                currentControls[keybindSettingKey] = key;
                arrowsText[keybindSettingKey].text = getKeyName(key);
                saveButtonEnabled = true;
                switchKeybindSetting(false);
            }
        } else {
            if (controls.BACK) {
                trace("closed");
                close();
                return;
            }
            for (i => value in currentControls) {
                try {

                    var isPressed:Bool = FlxControls.anyPressed([value]);
                    if (isPressed && arrows[i].animation.curAnim.name != "pressed") {
                        arrows[i].animation.play("pressed");
                        arrows[i].centerOffsets();
                        arrows[i].centerOrigin();
                        cast(arrows[i].shader, ColoredNoteShader).enabled.value = [true];
                    }
                    if (!isPressed && arrows[i].animation.curAnim.name != "static") {
                        arrows[i].animation.play("static");
                        arrows[i].centerOffsets();
                        arrows[i].centerOrigin();
                        cast(arrows[i].shader, ColoredNoteShader).enabled.value = [false];
                    }
                } catch(e) {

                }
            }
            for (index => value in arrows) {
                if (mouseOverlaps(value) && FlxG.mouse.justReleased) {
                    switchKeybindSetting(true, index);
                }
            }
            saveButton.alpha = saveButtonEnabled ? 1 : 0.5;
            // if (FlxG.mouse.overlaps(saveButton, saveButton.camera) && saveButtonEnabled) {
            if (mouseOverlaps(saveButton) && saveButtonEnabled) {
                saveButton.color = selectedColor;
                if (FlxG.mouse.justReleased) {
                    for(i in 0...arrowNumber) {
                        Reflect.setField(Settings.engineSettings.data, 'control_' + arrowNumber + '_$i', currentControls[i]);
                        if (PlayState.current != null) Reflect.setField(PlayState.current.engineSettings, 'control_' + arrowNumber + '_$i', currentControls[i]);
                    }
                    CoolUtil.playMenuSFX(1);
                    saveButtonEnabled = false;
                }
            } else {
                saveButton.color = FlxColor.WHITE;
            }
            // if (FlxG.mouse.overlaps(exitButton, exitButton.camera)) {
            if (mouseOverlaps(exitButton)) {
                exitButton.color = selectedColor;
                if (FlxG.mouse.justReleased) {
                    CoolUtil.playMenuSFX(2);
                    trace("closed");
                    close();
                }
            } else {
                exitButton.color = FlxColor.WHITE;
            }
        }
    }

    public function new(arrowNumber:Int, camera:FlxCamera) {
        super();
        this.arrowNumber = arrowNumber;
        FlxG.mouse.visible = true;

        var menuBG:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0x88000000);
        menuBG.camera = camera;
		menuBG.updateHitbox();
		menuBG.screenCenter();
        add(menuBG);

        var infoText = new FlxText(0, 10, 1280 * 2, "Click on an arrow to configure the keybind.");
        infoText.scale.x = 0.5;
        infoText.scale.y = 0.5;
        infoText.camera = camera;
        infoText.antialiasing = true;
        infoText.setFormat(Paths.font("vcr.ttf"), 45, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        infoText.screenCenter(X);
        add(infoText);

        saveButton = new FlxSprite(0, 0);
        saveButton.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
        saveButton.animation.addByPrefix("button", "save button", 1, true);
        saveButton.animation.play("button");
        saveButton.scale.x = 0.75;
        saveButton.scale.y = 0.75;
        saveButton.antialiasing = true;
        saveButton.updateHitbox();
        saveButton.x = 1280 - saveButton.width - 25;
        saveButton.y = 720 - saveButton.height - 25;
        saveButton.camera = camera;
        add(saveButton);

        exitButton = new FlxSprite(0, 0);
        exitButton.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
        exitButton.animation.addByPrefix("button", "exit button", 1, true);
        exitButton.animation.play("button");
        exitButton.scale.x = 0.75;
        exitButton.scale.y = 0.75;
        exitButton.antialiasing = true;
        exitButton.updateHitbox();
        exitButton.x = 1280 - saveButton.width - 25 - exitButton.width - 25;
        exitButton.y = 720 - exitButton.height - 25;
        exitButton.camera = camera;
        add(exitButton);

        size = Math.min(1, 10 / arrowNumber) * 160 * 0.7;

        for(i in 0...arrowNumber) {
            var babyArrow = new FlxSprite((1280 / 2) + size * (-(arrowNumber / 2) + i - 0.5), 50);
            
            babyArrow.frames = (Settings.engineSettings.data.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets_colored', 'shared') : Paths.getSparrowAtlas_Custom("skins/notes/" + Settings.engineSettings.data.customArrowSkin.toLowerCase());
					
            babyArrow.animation.addByPrefix('up', 'arrowUP');
            babyArrow.animation.addByPrefix('down', 'arrowDOWN');
            babyArrow.animation.addByPrefix('left', 'arrowLEFT');
            babyArrow.animation.addByPrefix('right', 'arrowRIGHT');
            var color = [
                new FlxColor(Settings.engineSettings.data.arrowColor0),
                new FlxColor(Settings.engineSettings.data.arrowColor1),
                new FlxColor(Settings.engineSettings.data.arrowColor2),
                new FlxColor(Settings.engineSettings.data.arrowColor3)
            ][i % 4];
            babyArrow.shader = new ColoredNoteShader(color.red, color.green, color.blue, false);
            cast(babyArrow.shader, ColoredNoteShader).enabled.value = [false];

            var noteNumberScheme:Array<NoteDirection> = Note.noteNumberSchemes[arrowNumber];
            if (noteNumberScheme == null) noteNumberScheme = Note.noteNumberSchemes[4];
            switch (noteNumberScheme[i % noteNumberScheme.length])
            {
                case Left:
                    babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                    babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
                    babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
                case Down:
                    babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                    babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
                    babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
                case Up:
                    babyArrow.animation.addByPrefix('static', 'arrowUP');
                    babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
                    babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
                case Right:
                    babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                    babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
                    babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
            }

            babyArrow.animation.play("static");
            babyArrow.antialiasing = true;
            babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

            babyArrow.scale.x *= Math.min(1, 10 / arrowNumber);
			babyArrow.scale.y *= Math.min(1, 10 / arrowNumber);
            babyArrow.camera = camera;

            
            babyArrow.centerOffsets();
            babyArrow.centerOrigin();

            arrows.push(babyArrow);
            add(babyArrow);
            var key:FlxKey = cast(Reflect.field(Settings.engineSettings.data, 'control_' + arrowNumber + '_$i'), FlxKey);
            currentControls.push(key);

            var text:FlxText = new FlxText(babyArrow.x, babyArrow.y + babyArrow.height, babyArrow.width, getKeyName(key));
            text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.antialiasing = true;
            text.camera = camera;
            arrowsText.push(text);
            add(text);
        }

        keybindSettingBackground = new FlxSprite(0, 0).makeGraphic(1280, 720, 0x88000000);
        keybindSettingBackground.camera = camera;

        keybindSettingBackground2 = new FlxSprite(0, 0).makeGraphic(Std.int(1280 / 1.5), Std.int(720 / 1.5), 0x44000000);
        keybindSettingBackground2.screenCenter();
        keybindSettingBackground2.camera = camera;

        keybindSettingInstructions = new FlxText(keybindSettingBackground2.x, keybindSettingBackground2.y, keybindSettingBackground.width * 2, "Press any key to continue or click on [Cancel] to cancel.");
        keybindSettingInstructions.setFormat(Paths.font("vcr.ttf"), 45, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        keybindSettingInstructions.scale.x = keybindSettingInstructions.scale.y = 0.5;
        keybindSettingInstructions.antialiasing = true;
        keybindSettingInstructions.updateHitbox();
        keybindSettingInstructions.screenCenter(X);
        keybindSettingInstructions.camera = camera;

        keybindSettingText = new FlxText(keybindSettingBackground2.x, keybindSettingBackground2.y, keybindSettingBackground2.width * 2, "(blank)");
        keybindSettingText.setFormat(Paths.font("vcr.ttf"), 75, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        keybindSettingText.scale.x = keybindSettingText.scale.y = 0.5;
        keybindSettingText.antialiasing = true;
        keybindSettingText.updateHitbox();
        keybindSettingText.screenCenter();
        keybindSettingText.camera = camera;

        keybindSettingCancel = new FlxSprite(0, 0);
        keybindSettingCancel.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
        keybindSettingCancel.animation.addByPrefix("button", "exit button", 1, true);
        keybindSettingCancel.animation.play("button");
        keybindSettingCancel.scale.x = 0.75;
        keybindSettingCancel.scale.y = 0.75;
        keybindSettingCancel.antialiasing = true;
        keybindSettingCancel.updateHitbox();
        keybindSettingCancel.x = (keybindSettingBackground2.x + keybindSettingBackground2.width) - keybindSettingCancel.width - 25;
        keybindSettingCancel.y = (keybindSettingBackground2.x + keybindSettingBackground2.width) - keybindSettingCancel.height - 25;
        keybindSettingCancel.camera = camera;
    }

    public static function getKeyName(key:FlxKey, simple:Bool = false) {
        if (customKeybindsNameOverrideSimple[Std.string(key).toLowerCase()] != null && simple) {
            return customKeybindsNameOverrideSimple[Std.string(key).toLowerCase()];
        } else if (customKeybindsNameOverride[Std.string(key).toLowerCase()] != null) {
            return customKeybindsNameOverride[Std.string(key).toLowerCase()];
        } else {
            return Std.string(key);
        }
    }
}