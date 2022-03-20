package charter;

import flixel.math.FlxMath;
import EngineSettings.Settings;
import flixel.text.FlxText;
import Section.SwagSection;
import openfl.geom.Rectangle;
import flixel.addons.display.FlxGridOverlay;
import flixel.system.FlxSound;
import Song.SwagSong;
import flixel.*;
import flixel.addons.ui.*;

class YoshiCharter extends MusicBeatState {
    public var notes:Array<CharterNote> = [];
    public static var _song:SwagSong;

    public var vocals:FlxSound;

    var grid:FlxSprite;
    var gridLightUp:FlxSprite;
	public static var GRID_SIZE:Int = 40;

    var hitsound:FlxSound;

    var section(get, null):SwagSection;

    function get_section() {
        return _song.notes[Math.floor(Conductor.songPosition / (Conductor.crochet * 4))];
    };

    var followThing:FlxSprite;

    var playing = false;

    var iconP1:HealthIcon;
    var iconP2:HealthIcon;

    var strums:Array<CharterStrum> = [];

    var statusText:FlxText;

    var topView:Bool = Settings.engineSettings.data.charter_topView;
    var showStrums:Bool = Settings.engineSettings.data.charter_showStrums;
    var hitsoundsEnabled:Bool = Settings.engineSettings.data.charter_hitsoundsEnabled;
    var topViewCheckbox:FlxUICheckBox = null;
    var showStrumsCheckbox:FlxUICheckBox = null;
    var hitsoundsEnabledCheckbox:FlxUICheckBox = null;

    var pageSwitchLerpRemaining:Float = 0;

    public function new() {
        super();
        if (PlayState._SONG == null) {
            PlayState.songMod = "Friday Night Funkin'";
            PlayState.storyDifficulty = "hard";
            CoolUtil.loadSong("Friday Night Funkin'", "MILF", "Hard");
        }
        PlayState.checkSong();
        _song = PlayState._SONG;
        ChartingState_New._song = _song;
        Conductor.changeBPM(_song.bpm);
    }

    public function compile() { // out of ideas for a func name
        for (s in _song.notes) {
            s.sectionNotes = []; // resets
        }
        for(s in notes) {
            if (s.noteData >= 0) {
                // normal note
                var noteType = Math.floor(s.noteData / (_song.keyNumber * 2));
                var strum = s.noteData;
                var section = _song.notes[Math.floor((Math.ceil(s.strumTime / 10) * 10) / (Conductor.crochet * 4))];
                if (section == null) {
                    _song.notes[Math.floor((Math.ceil(s.strumTime / 10) * 10) / (Conductor.crochet * 4))] = (section = {
                        mustHitSection: true,
                        typeOfSection: 1,
                        sectionNotes: [],
                        lengthInSteps: 16,
                        bpm: 0,
                        changeBPM: false,
                        altAnim: false
                    });
                }
                // if (!section.mustHitSection) strum += _song.keyNumber;
                var noteData = (noteType * _song.keyNumber * 2) + (strum % (_song.keyNumber * 2));
                section.sectionNotes.push([s.strumTime, noteData, s.sustainLength]);
            } else {
                // event note, TODO
            }
        }
    }

    public override function create() {
        var bg = CoolUtil.addBG(this);
        bg.scrollFactor.set(0, 0);

        FlxG.sound.playMusic(Paths.modInst(_song.song, PlayState.songMod, PlayState.storyDifficulty));
        FlxG.sound.music.pause();
        vocals = new FlxSound().loadEmbedded(Paths.modVoices(_song.song, PlayState.songMod, PlayState.storyDifficulty));

        updateGrid();
        generateNotes();

        followThing = new FlxSprite(0, 0).makeGraphic(GRID_SIZE * 8, 5, 0xFFFFFFFF);
        FlxG.camera.follow(followThing);
        FlxG.camera.targetOffset.y += topView ? ((FlxG.height * 0.25) + GRID_SIZE) : GRID_SIZE;
        FlxG.camera.targetOffset.x += 150;
        insert(members.indexOf(strums[0]), followThing);

        iconP1 = new HealthIcon(CoolUtil.getCharacterFull(_song.player1, PlayState.songMod).join(":"));
        iconP2 = new HealthIcon(CoolUtil.getCharacterFull(_song.player2, PlayState.songMod).join(":"));
        iconP1.x = ((grid.width - GRID_SIZE) * 0.75) - 75;
        iconP2.x = ((grid.width - GRID_SIZE) * 0.25) - 75;
        iconP1.scrollFactor.x = 1;
        iconP1.scrollFactor.y = 0;
        iconP2.scrollFactor.x = 1;
        iconP2.scrollFactor.y = 0;
        add(iconP1);
        add(iconP2);

        iconP1.flipX = true;

        create_ui();

        hitsound = new FlxSound().loadEmbedded(Paths.sound('hitsound', 'shared')); // it's the osu hitsound in case you're wondering
        //hitsound.persist = true;
        hitsound.autoDestroy = false;

        super.create();
        Conductor.songPosition = 0;
        Conductor.songPositionOld = 0;
    }

    public function create_ui() {
        statusText = new FlxText(10, 55, 0, "Section:\nBeat:\nStep:", 16); // 55 cause fps thing
        statusText.scrollFactor.set(0, 0);
		statusText.setBorderStyle(FlxTextBorderStyle.OUTLINE, 0xFF000000, 1, 1);
        add(statusText);

        topViewCheckbox = new FlxUICheckBox(10, 0, null, null, "Vertically center charter", 250, null, function() {
            topView = Settings.engineSettings.data.charter_topView = !topViewCheckbox.checked;
        });
        topViewCheckbox.y = FlxG.height - topViewCheckbox.height - 10;
        topViewCheckbox.scrollFactor.set(0, 0);
        topViewCheckbox.checked = !topView;
        add(topViewCheckbox);

        showStrumsCheckbox = new FlxUICheckBox(10, 0, null, null, "Show strums", 250, null, function() {
            for(s in strums) s.visible = Settings.engineSettings.data.charter_showStrums = showStrumsCheckbox.checked;
        });
        showStrumsCheckbox.y = FlxG.height - topViewCheckbox.height - 20 - showStrumsCheckbox.height;
        showStrumsCheckbox.scrollFactor.set(0, 0);
        showStrumsCheckbox.checked = showStrums;
        add(showStrumsCheckbox);

        hitsoundsEnabledCheckbox = new FlxUICheckBox(10, 0, null, null, "Enable hitsounds", 250, null, function() {
            hitsoundsEnabled = Settings.engineSettings.data.charter_showStrums = hitsoundsEnabledCheckbox.checked;
        });
        hitsoundsEnabledCheckbox.y = FlxG.height - topViewCheckbox.height - 30 - showStrumsCheckbox.height - hitsoundsEnabledCheckbox.height;
        hitsoundsEnabledCheckbox.scrollFactor.set(0, 0);
        hitsoundsEnabledCheckbox.checked = hitsoundsEnabled;
        add(hitsoundsEnabledCheckbox);
    }

    public function generateNotes() {
        for (s in _song.notes) {
            for(n in s.sectionNotes) {
                addNote(n[0], n[1], s.mustHitSection);
            }
        }
    }

    public function addNote(strumTime:Float, noteData:Int, mustHitSection:Bool = false) {
        var note = new CharterNote(strumTime, noteData, null, false, mustHitSection);
        note.y = strumTime / Conductor.stepCrochet * GRID_SIZE;
        var xPos = noteData;
        if (mustHitSection) xPos += _song.keyNumber;
        xPos %= (_song.keyNumber * 2);
        note.x = xPos * GRID_SIZE;
        add(note);
        notes.push(note);
        note.setGraphicSize(GRID_SIZE, GRID_SIZE);
        note.updateHitbox();
    }

    public function removeNote(note:CharterNote) {
        notes.remove(note);
        remove(note);
        note.destroy();
    }

    public function updateGrid() {
        grid = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * (_song.keyNumber * 2 + 1), Math.ceil(FlxG.height / (GRID_SIZE * 16)) * 2 * (GRID_SIZE * 16), true, 0x88888888, 0x88444444);
        grid.x = -GRID_SIZE;
        grid.pixels.lock();
        grid.pixels.fillRect(new Rectangle(GRID_SIZE - 1, 0, 2, grid.pixels.height), 0x88FFFFFF);
        grid.pixels.fillRect(new Rectangle(GRID_SIZE + (GRID_SIZE * _song.keyNumber) - 1, 0, 2, grid.pixels.height), 0x88FFFFFF);
        for(i in 0...Math.floor(grid.pixels.height / (GRID_SIZE * 16))) {
            grid.pixels.fillRect(new Rectangle(0, (GRID_SIZE * 16 * (i + 1)) - 2, grid.pixels.width, 4), 0xAAFFFFFF);
        }
        grid.pixels.unlock();
        add(grid);

        gridLightUp = new FlxSprite(0, 0).makeGraphic(GRID_SIZE * _song.keyNumber, FlxG.height, 0xFFFFFFFF);
        gridLightUp.alpha = 0.3;
        gridLightUp.scrollFactor.set(1, 0);
        add(gridLightUp);

        // add strums
        for (e in strums) {
            remove(e);
            e.destroy();
        }
        strums = [];
        for(i in 0...(_song.keyNumber * 2)) {
            var s = new CharterStrum(i * GRID_SIZE, 0, i);
            add(s);
            strums.push(s);
        }

        if (followThing != null) {
            remove(followThing);
            insert(members.indexOf(strums[0]), followThing);
        }
    }

    public function switchToPlayState() {
        compile();
        
        PlayState._SONG = _song;
        PlayState._SONG.validScore = false;
        PlayState.fromCharter = true;
        FlxG.sound.music.stop();
        vocals.stop();
        FlxG.switchState(new PlayState());
    }
    public function moveCursor(steps:Float) {
        if (playing) {
            playing = false;
            FlxG.sound.music.pause();
            vocals.pause();
        }
        FlxG.sound.music.time = vocals.time = (Conductor.songPosition += steps * Conductor.stepCrochet);
    }
    public override function update(elapsed:Float) {
        if (playing) {
            pageSwitchLerpRemaining = 0;
        } else {
            var val = CoolUtil.wrapFloat(pageSwitchLerpRemaining * 0.40 * 60 * elapsed, pageSwitchLerpRemaining < 0 ? pageSwitchLerpRemaining : 0, pageSwitchLerpRemaining > 0 ? pageSwitchLerpRemaining : 0);
            vocals.time = FlxG.sound.music.time = (Conductor.songPosition += val);
            pageSwitchLerpRemaining -= val;
            if (Conductor.songPosition < 0) {
                pageSwitchLerpRemaining = 0;
                Conductor.songPosition = 0;
            }
        }
        FlxG.camera.targetOffset.y = FlxMath.lerp(FlxG.camera.targetOffset.y, topView ? ((FlxG.height * 0.25) + GRID_SIZE) : GRID_SIZE, 0.45 * 60 * elapsed);
        if (FlxG.mouse.justPressed) {
            
            var overlaps = false;
            for(n in notes) {
                if (FlxG.mouse.overlaps(n)) {
                    overlaps = true;
                    removeNote(n);
                }
            }
            if (!overlaps && FlxG.mouse.overlaps(grid)) {
                var strumT = FlxG.mouse.y / GRID_SIZE;
                if (!FlxG.keys.pressed.SHIFT) {
                    strumT = Math.floor(strumT);
                }
                addNote(strumT * Conductor.stepCrochet, Math.floor(FlxG.mouse.x / GRID_SIZE));
            }
        }
        if (FlxG.keys.justPressed.LEFT) pageSwitchLerpRemaining -= Conductor.crochet * 4;
        if (FlxG.keys.justPressed.RIGHT) pageSwitchLerpRemaining += Conductor.crochet * 4;
        pageSwitchLerpRemaining -= FlxG.mouse.wheel * Conductor.stepCrochet * 2;
        if (FlxG.keys.pressed.UP) moveCursor(-8 * elapsed);
        if (FlxG.keys.pressed.DOWN) moveCursor(8 * elapsed);

        if (FlxG.keys.justPressed.ENTER) {
            switchToPlayState();
        }

        if (section != null) {
            var s = (Conductor.songPosition / Conductor.crochet) % 1;
            if (section.mustHitSection) {
                iconP1.alpha = 1;
                iconP1.scale.set(1.25 - (s * 0.25), 1.25 - (s * 0.25));
                iconP2.alpha = 0.33;
                iconP2.scale.set(1, 1);
                gridLightUp.x = FlxMath.lerp(gridLightUp.x, GRID_SIZE * _song.keyNumber, 0.40 * 60 * elapsed);
            } else {
                iconP2.alpha = 1;
                iconP2.scale.set(1.25 - (s * 0.25), 1.25 - (s * 0.25));
                iconP1.alpha = 0.33;
                iconP1.scale.set(1, 1);
                gridLightUp.x = FlxMath.lerp(gridLightUp.x, 0, 0.40 * 60 * elapsed);
            }
            var multiplicator = 0.60;
            iconP1.scale.x *= multiplicator;
            iconP1.scale.y *= multiplicator;
            iconP2.scale.x *= multiplicator;
            iconP2.scale.y *= multiplicator;
        } else {
            iconP1.scale.set(0.66, 0.66);
            iconP2.scale.set(0.66, 0.66);
            iconP1.alpha = iconP2.alpha = 0.33;
        }
        if (Conductor.songPositionOld != FlxG.sound.music.time) {
            Conductor.songPosition = Conductor.songPositionOld = FlxG.sound.music.time;
        } else {
            if (FlxG.sound.music.playing) Conductor.songPosition += elapsed * 1000;
        }
        // grid.y = -((Conductor.songPosition % (Conductor.crochet * 4)) / (Conductor.crochet * 4) * (GRID_SIZE * 16));
        grid.y = Math.max(0, Math.floor(Conductor.songPosition / (Conductor.crochet * 4)) * GRID_SIZE * 16) + ((Conductor.songPosition < Conductor.crochet * 4) ? 0 : -GRID_SIZE * 16);
        followThing.y = Conductor.songPosition / (Conductor.crochet * 4) * (GRID_SIZE * 16);
        for(s in strums) {
            s.y = followThing.y;
        }
        
        for (n in notes) {
            if (n.strumTime < Conductor.songPosition) {
                if (n.alpha == 1) {
                    var str = strums[Math.floor(n.x / GRID_SIZE) % (_song.keyNumber * 2)];
                    if (str != null) str.lastHit = Conductor.stepCrochet / 500;
                    n.alpha = 1 / 3;
                    if (hitsoundsEnabled) {
                        hitsound.stop();
                        hitsound.volume = FlxG.sound.music.volume;
                        hitsound.play();
                    }
                }
            } else {
                n.alpha = 1;
            }
        }

        super.update(elapsed);

        if (FlxG.keys.justPressed.SPACE) {
            playing = !playing;
            if (playing) {
                FlxG.sound.music.play();
                vocals.play();
                vocals.time = FlxG.sound.music.time;
            } else {
                FlxG.sound.music.pause();
                vocals.pause();
            }
        }
        vocals.volume = FlxG.sound.music.volume;

        var m = Math.floor(Conductor.songPosition / 1000 / 60);
        var s = CoolUtil.addZeros(Std.string(Math.floor(Conductor.songPosition / 1000) % 60), 2);

        var mt = Math.floor(FlxG.sound.music.length / 1000 / 60);
        var st = CoolUtil.addZeros(Std.string(Math.floor(FlxG.sound.music.length / 1000) % 60), 2);
        statusText.text = '${m}:${s} - ${mt}:${st}\nSection: ${Math.floor(curBeat / 4)}\nBeat: ${curBeat}\nStep: ${curStep}';
    }

    public override function onFocusLost() {
        super.onFocusLost();
        if (FlxG.autoPause) {
            vocals.pause();
        }
    }

    public override function onFocus() {
        if (playing) {
            vocals.play();
        }
    }
}