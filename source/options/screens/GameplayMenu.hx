package options.screens;

import EngineSettings.Settings;
import options.OptionScreen;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import Note.NoteDirection;

class GameplayMenu extends OptionScreen {
    var strums:FlxSpriteGroup = new FlxSpriteGroup();
    public override function create() {
        options = [
            {
                name: "Downscroll",
                desc: "If enabled, Notes will scroll from up to down, instead of from down to up.",
                value: "Enabled"
            },
            {
                name: "Middlescroll",
                desc: "If enabled, Strums will be centered, and opponent strums will be hidden.",
                value: "Enabled"
            }
        ];
        super.create();
        updateSettings(-1);
        var w:Float = 0;
        for(i in 0...4) {
            var babyArrow = new FlxSprite(Note._swagWidth * i, 0);
            
            babyArrow.frames = (Settings.engineSettings.data.customArrowSkin == "default") ? Paths.getCustomizableSparrowAtlas(Settings.engineSettings.data.customArrowColors ? 'NOTE_assets_colored' : 'NOTE_assets', 'shared') : Paths.getSparrowAtlas(Settings.engineSettings.data.customArrowSkin.toLowerCase(), 'skins');
					
					
            babyArrow.animation.addByPrefix('green', 'arrowUP');
            babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
            babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
            babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
            //babyArrow.colored = Settings.engineSettings.data.customArrowColors;

            babyArrow.antialiasing = true;
            babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
            
            switch (i)
            {
                case 0:
                    babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                case 1:
                    babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                case 2:
                    babyArrow.animation.addByPrefix('static', 'arrowUP');
                case 3:
                    babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
            }
            babyArrow.animation.play('static');
            strums.add(babyArrow);
        }
        add(strums);
        if (Settings.engineSettings.data.downscroll) {
            strums.y = FlxG.height - Note._swagWidth - 50;
        } else {
            strums.y = 50;
        }
        if (Settings.engineSettings.data.middleScroll) {
            strums.x = FlxG.width / 2;
            strums.x -= strums.width / 2;
        } else {
            strums.x = FlxG.width / 4 * 3;
            strums.x -= strums.width / 2;
        }
    }

    public override function onSelect(id:Int) {
        switch(id) {
            case 0:
                Settings.engineSettings.data.downscroll = !Settings.engineSettings.data.downscroll;
                updateSettings(0);
        }
    }

    public function updateSettings(id:Int) {
        if (id == 0 || id == -1) {
            if (Settings.engineSettings.data.downscroll) {
                spawnedOptions[0].value = "Disabled";
                spawnedOptions[0]._valueAlphabet.textColor = 0xFFFF4444;
            } else {
                spawnedOptions[0].value = "Enabled";
                spawnedOptions[0]._valueAlphabet.textColor = 0xFF44FF44;
            }
        }
        if (id == 1 || id == -1) {
            if (Settings.engineSettings.data.middleScroll) {
                spawnedOptions[1].value = "Disabled";
                spawnedOptions[1]._valueAlphabet.textColor = 0xFFFF4444;
            } else {
                spawnedOptions[1].value = "Enabled";
                spawnedOptions[1]._valueAlphabet.textColor = 0xFF44FF44;
            }
        }
    }
}