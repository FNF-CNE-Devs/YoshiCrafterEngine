package options.screens;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import flixel.FlxG;
import EngineSettings.Settings;
import options.OptionScreen;
import flixel.group.FlxSpriteGroup;

class GUIMenu extends OptionScreen {

    var camHUD:FlxCamera;
    var healthBarBG:FlxSprite;
    var scoreTxt:FlxText;
    var strums:FlxSpriteGroup = new FlxSpriteGroup();
    var msScoreLabel:FlxText;

    public function getNoteScaleValue() {
        return '${Std.string(Settings.engineSettings.data.noteScale)} (${Std.int(FlxG.width / Settings.engineSettings.data.noteScale)}x${Std.int(FlxG.height / Settings.engineSettings.data.noteScale)})';
    }
    public override function create() {
        options = [
            {
                name: "GUI Scale",
                desc: "Changes the GUI Scale. The smaller the value is, the smaller the elements will appear on \nthe in game UI.",
                value: getNoteScaleValue(),
                onUpdate: function(v) {
                    if (controls.LEFT_P) Settings.engineSettings.data.noteScale -= 0.05;
                    if (controls.RIGHT_P) Settings.engineSettings.data.noteScale += 0.05;
                    Settings.engineSettings.data.noteScale = FlxMath.bound(FlxMath.roundDecimal(Settings.engineSettings.data.noteScale, 2), 0.1, 2);
                    v.value = '< ${getNoteScaleValue()} >';
                },
                onLeft: function(v) {
                    v.value = getNoteScaleValue();
                }
            },
            {
                name: "Show timer",
                desc: "If enabled, will show a timer with the song name, time elapsed and song length.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showTimer);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showTimer = !Settings.engineSettings.data.showTimer);}
            },
            {
                name: "Show press delay",
                desc: "If enabled, will show the delay above the strums everytime a note is hit.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showPressDelay);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showPressDelay = !Settings.engineSettings.data.showPressDelay);}
            },
            {
                name: "Bump press delay",
                desc: "If enabled, will show the delay above the strums everytime a note is hit.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.animateMsLabel);},
                onEnter: function(e) {if (e.check(Settings.engineSettings.data.animateMsLabel)) msScoreLabel.offset.y = msScoreLabel.height / 3;},
                onSelect: function(e) {
                    if (e.check(Settings.engineSettings.data.animateMsLabel = !Settings.engineSettings.data.animateMsLabel)) {
                        msScoreLabel.offset.y = msScoreLabel.height / 3;
                    } else {
                        msScoreLabel.offset.y = 0;
                    }}
            },
            {
                name: "Show accuracy",
                desc: "If enabled, show your accuracy in percent on the Score Bar.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showAccuracy);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showAccuracy = !Settings.engineSettings.data.showAccuracy);}
            },
            {
                name: "Show accuracy mode",
                desc: "If enabled, will show the accuracy mode you're using (Simple or Complex).",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showAccuracyMode);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showAccuracyMode = !Settings.engineSettings.data.showAccuracyMode);}
            },
            {
                name: "Show number of misses",
                desc: "If enabled, will show the number of misses.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showMisses);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showMisses = !Settings.engineSettings.data.showMisses);}
            },
            {
                name: "Show ratings amount",
                desc: "If enabled, will show the number of hits for each rating at the right of the screen.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showRatingTotal);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showRatingTotal = !Settings.engineSettings.data.showRatingTotal);}
            },
            {
                name: "Show average hit delay",
                desc: "If enabled, will add your average delay in milliseconds next to the score.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showAverageDelay);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showAverageDelay = !Settings.engineSettings.data.showAverageDelay);}
            },
            {
                name: "Show rating",
                desc: "If enabled, will show your rating next to the score (ex : FC).",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.showRating);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.showRating = !Settings.engineSettings.data.showRating);}
            },
            {
                name: "Animate the Score Bar",
                desc: "If enabled, the Score bar will do a pop animation every time you hit a note.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.animateInfoBar);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.animateInfoBar = !Settings.engineSettings.data.animateInfoBar);}
            },
            {
                name: "Show watermark",
                desc: "If enabled, will show a watermark with the engine's name, the mod's name and the song\nname.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.watermark);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.watermark = !Settings.engineSettings.data.watermark);}
            },
            {
                name: "Minimal mode",
                desc: "When checked, will minimize the Score Text width.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.minimizedMode);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.minimizedMode = !Settings.engineSettings.data.minimizedMode);}
            },
            {
                name: "Score Text Size",
                desc: "Sets the score text size. 16 is base game size, 20 is Psych size. Defaults to 18.",
                value: '${Settings.engineSettings.data.scoreTextSize}',
                onUpdate: function(v) {
                    if (controls.LEFT_P) Settings.engineSettings.data.scoreTextSize -= 1;
                    if (controls.RIGHT_P) Settings.engineSettings.data.scoreTextSize += 1;
                    v.value = '< ${Settings.engineSettings.data.scoreTextSize} >';
                },
                onLeft: function(v) {
                    v.value = '${Settings.engineSettings.data.scoreTextSize}';
                }
            }
        ];

        super.create();

        camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        FlxG.cameras.add(camHUD, false);
        camHUD.bgColor = 0;
        camHUD.zoom = Settings.engineSettings.data.noteScale;

        var h = FlxG.height / Settings.engineSettings.data.noteScale;
        healthBarBG = new FlxSprite(0, h * (Settings.engineSettings.data.downscroll ? 0.075 : 0.9)).loadGraphic(Paths.image('healthBar', 'shared'));
		healthBarBG.cameras = [camHUD];
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.antialiasing = true;

        scoreTxt = new FlxText(0, healthBarBG.y + 30, FlxG.width, "Score: 123456 | Misses: 0 | Accuracy: 100% (Simple) | Average: 5ms | S (MFC)", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), Std.int(Settings.engineSettings.data.scoreTextSize), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scale.x = 1;
		scoreTxt.scale.y = 1;
		scoreTxt.antialiasing = true;
		scoreTxt.cameras = [camHUD];
		scoreTxt.screenCenter(X);
		scoreTxt.scrollFactor.set();

        for(i in 0...4) {
            var babyArrow = new FlxSprite(Note._swagWidth * i, 0);
            
            babyArrow.frames = (Settings.engineSettings.data.customArrowSkin == "default") ? Paths.getCustomizableSparrowAtlas('NOTE_assets', 'shared') : Paths.getSparrowAtlas(Settings.engineSettings.data.customArrowSkin.toLowerCase(), 'skins');
					
					
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
        strums.screenCenter(X);
        strums.y = 50;

        msScoreLabel = new FlxText(
			strums.x,
			strums.y - 25,
			strums.width,
			"25ms", 20);
		msScoreLabel.setFormat(Paths.font("vcr.ttf"), Std.int(30), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		msScoreLabel.antialiasing = true;
		msScoreLabel.visible = false;
		msScoreLabel.scale.x = 1;
		msScoreLabel.scale.y = 1;
		msScoreLabel.scrollFactor.set();
        msScoreLabel.color = 0xFF24DEFF;
		msScoreLabel.alpha = 0;

		add(msScoreLabel);

        add(healthBarBG);
        add(scoreTxt);
    }

    public function uiCenter(spr:FlxSprite) {
        spr.x = ((FlxG.width / Settings.engineSettings.data.noteScale) - spr.width) / 2;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        var l = 0.125 * elapsed * 60;
        // camHUD.y = FlxG.camera.y;
        @:privateAccess
        camHUD.initialZoom = FlxMath.lerp(camHUD.initialZoom, Settings.engineSettings.data.noteScale, l);
        camHUD.zoom = camHUD.initialZoom;
        
		camHUD.setSize(Std.int(FlxG.width / camHUD.initialZoom), Std.int(FlxG.height / camHUD.initialZoom));
        @:privateAccess
        camHUD.updateScrollRect();
        @:privateAccess
		camHUD.updateFlashOffset();
        @:privateAccess
		camHUD.updateFlashSpritePosition();
        @:privateAccess
		camHUD.updateInternalSpritePositions();
        var h = FlxG.height / camHUD.initialZoom;

        var showStrums = [2, 3];
        var showScoreLabel = [2, 3];
        var showScore:Array<Int> = [for(i in 4...14) i];
        showScore.insert(0, 0);

        
        healthBarBG.alpha = FlxMath.lerp(healthBarBG.alpha, curSelected == 0 ? 1 : 0, l);
        healthBarBG.y = h * (Settings.engineSettings.data.downscroll ? 0.075 : 0.9);
        healthBarBG.x = ((FlxG.width / camHUD.initialZoom) - healthBarBG.width) / 2; 
        scoreTxt.y = healthBarBG.y + 30;
        scoreTxt.x = ((FlxG.width / camHUD.initialZoom) - scoreTxt.width) / 2; 
        scoreTxt.alpha = FlxMath.lerp(scoreTxt.alpha, showScore.contains(curSelected) ? 1 : 0, l);
        scoreTxt.size = Settings.engineSettings.data.scoreTextSize;
        var t = "";
        var accText = ScoreText.accuracyTypesText[Settings.engineSettings.data.accuracyMode];
        if (Settings.engineSettings.data.minimizedMode) {
            accText = accText.charAt(0);
            var e = ["Score: 12345"];
            if (Settings.engineSettings.data.showMisses) e.push("0 Misses");
            if (Settings.engineSettings.data.showAccuracy) e.push("100%" + (Settings.engineSettings.data.showAccuracyMode ? ' ($accText)' : ""));
            if (Settings.engineSettings.data.showAverageDelay) e.push("~ 25ms");
            if (Settings.engineSettings.data.showRating) e.push("S (MFC)");
            t = e.join(Settings.engineSettings.data.scoreJoinString);
        } else {
            var e = ["Score: 12345"];
            if (Settings.engineSettings.data.showMisses) e.push("Misses:0");
            if (Settings.engineSettings.data.showAccuracy) e.push("Accuracy:100%" + (Settings.engineSettings.data.showAccuracyMode ? ' ($accText)' : ""));
            if (Settings.engineSettings.data.showAverageDelay) e.push("Average:25ms");
            if (Settings.engineSettings.data.showRating) e.push("S (MFC)");
            t = e.join(Settings.engineSettings.data.scoreJoinString);
        }
        scoreTxt.text = t;

        if (msScoreLabel.visible != (msScoreLabel.visible = Settings.engineSettings.data.showPressDelay)) {
            if (Settings.engineSettings.data.animateMsLabel) {
                msScoreLabel.offset.y = msScoreLabel.height / 3;
            }
        }
        msScoreLabel.offset.y = FlxMath.lerp(msScoreLabel.offset.y, 0, CoolUtil.wrapFloat(0.25 * 60 * elapsed, 0, 1));


        strums.alpha = FlxMath.lerp(strums.alpha, showStrums.contains(curSelected) ? 1 : 0, l * 2);
        msScoreLabel.alpha = FlxMath.lerp(msScoreLabel.alpha, showScoreLabel.contains(curSelected) ? 1 : 0, l * 2);
        // 13
    }
}