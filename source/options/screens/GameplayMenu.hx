package options.screens;

import flixel.math.FlxMath;
import EngineSettings.Settings;
import options.OptionScreen;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import Note.NoteDirection;
import NoteShader.ColoredNoteShader;

class GameplayMenu extends OptionScreen {
    var strums:FlxSpriteGroup = new FlxSpriteGroup();
    var arrow:FlxSprite;
    public override function create() {
        options = [
            {
                name: "Downscroll",
                desc: "If enabled, Notes will scroll from up to down, instead of from down to up.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.downscroll = !Settings.engineSettings.data.downscroll);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.downscroll = !Settings.engineSettings.data.downscroll);}
            },
            {
                name: "Middlescroll",
                desc: "If enabled, Strums will be centered, and opponent strums will be hidden.",
                value: "Enabled",
                onCreate: function(e) {e.check(Settings.engineSettings.data.middleScroll = !Settings.engineSettings.data.middleScroll);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.middleScroll = !Settings.engineSettings.data.middleScroll);}
            }
        ];
        super.create();
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

        arrow = new FlxSprite(0, 0);
            
        arrow.frames = (Settings.engineSettings.data.customArrowSkin == "default") ? Paths.getCustomizableSparrowAtlas(Settings.engineSettings.data.customArrowColors ? 'NOTE_assets_colored' : 'NOTE_assets', 'shared') : Paths.getSparrowAtlas(Settings.engineSettings.data.customArrowSkin.toLowerCase(), 'skins');
        arrow.animation.addByPrefix('green', 'green0');
        arrow.antialiasing = true;
        arrow.setGraphicSize(Std.int(arrow.width * 0.7));
        arrow.animation.play('green');
        var shader:ColoredNoteShader;
        var color:FlxColor = Settings.engineSettings.data.arrowColor2;
        arrow.shader = shader = new ColoredNoteShader(color.red, color.green, color.blue, false);

        add(arrow);
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

    public override function update(elapsed:Float) {
        super.update(elapsed);
        var pointX:Float = 0;
        var pointY:Float = 0;

        if (Settings.engineSettings.data.downscroll && curSelected < 3) {
            pointY = FlxG.height - Note._swagWidth - 50;
        } else {
            pointY = 50;
        }
        if (Settings.engineSettings.data.middleScroll && curSelected < 3) {
            pointX = FlxG.width / 2;
            pointX -= strums.width / 2;
        } else {
            pointX = FlxG.width / 4 * 3;
            pointX -= strums.width / 2;
        }
        var l = FlxMath.bound(0.125 * 60 * elapsed, 0, 1);
        strums.x = FlxMath.lerp(strums.x, pointX, l);
        strums.y = FlxMath.lerp(strums.y, pointY, l);
        
        Conductor.songPosition += Settings.engineSettings.data.noteOffset;
        if (FlxG.sound.music.time == Conductor.songPositionOld) {
            Conductor.songPosition += FlxG.elapsed * 1000;
        } else {
            Conductor.songPosition = Conductor.songPositionOld = FlxG.sound.music.time;
        }
        Conductor.songPosition -= Settings.engineSettings.data.noteOffset;

        if (arrow.visible = (curSelected == 2)) {
            var notePos = FlxG.height - (((time * 1000) * (0.45 * FlxMath.roundDecimal(Settings.engineSettings.data.scrollSpeed, 2))) % FlxG.height);
            if (Settings.engineSettings.data.downscroll) notePos = -notePos;
            arrow.x = strums.members[2].x;
            arrow.y = strums.members[2].y + notePos;
            arrow.visible = true;
        }
    }
}