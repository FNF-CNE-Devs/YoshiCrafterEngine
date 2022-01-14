enableRating = true;

// enableMiss(true);

var blammed:Bool = false;
var light:FlxSprite = null;
function create() {

    if (EngineSettings.customArrowColors && EngineSettings.customArrowSkin != "default") {
        var colors:Array<Int> = (note.mustPress || EngineSettings.customArrowColors_allChars) ? PlayState.boyfriend.getColors(false) : PlayState.dad.getColors(false);
        note.frames = Paths_.getSparrowAtlas_Custom(StringTools.replace(StringTools.replace(Paths_.getSkinsPath() + "notes/" + EngineSettings.customArrowSkin.toLowerCase(), "/", "\\"), "\r", ""));
		note.color = colors[(note.noteData % 4) + 1];
    } else {
        note.frames = (EngineSettings.customArrowSkin == "default") ? Paths.getSparrowAtlas("NOTE_assets_blammed_colored") : Paths_.getSparrowAtlas_Custom(StringTools.replace(StringTools.replace(Paths_.getSkinsPath() + "notes/" + EngineSettings.customArrowSkin.toLowerCase(), "/", "\\"), "\r", ""));
    }

    switch(note.noteData % PlayState.song.keyNumber) {
        case 0:
            note.animation.addByPrefix('scroll', "purple0");
            note.animation.addByPrefix('holdend', "pruple end hold");
            note.animation.addByPrefix('holdpiece', "purple hold piece");
        case 1:
            note.animation.addByPrefix('scroll', "blue0");
            note.animation.addByPrefix('holdend', "blue end hold");
            note.animation.addByPrefix('holdpiece', "blue hold piece");
        case 2:
            note.animation.addByPrefix('scroll', "green0");
            note.animation.addByPrefix('holdend', "green hold end");
            note.animation.addByPrefix('holdpiece', "green hold piece");
        case 3:
            note.animation.addByPrefix('scroll', "red0");
            note.animation.addByPrefix('holdend', "red hold end");
            note.animation.addByPrefix('holdpiece', "red hold piece");
    }

    note.setGraphicSize(Std.int(note.width * 0.7));
    note.updateHitbox();
    note.antialiasing = true;

    note.animation.play("scroll");
    if (note.isSustainNote) {
        if (note.prevNote != null)
            if (note.prevNote.animation.curAnim.name == "holdend")
                note.prevNote.animation.play("holdpiece");
        note.animation.play("holdend");
    }
}

function update(elapsed) {
    if (note.isSustainNote) {
        note.canBeHit = (note.strumTime - (Conductor.stepCrochet * 0.6) < Conductor.songPosition) && (note.strumTime + (Conductor.stepCrochet) > Conductor.songPosition);
    } else {
        note.canBeHit = (note.strumTime > Conductor.songPosition - Conductor.safeZoneOffset && note.strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5));
    }
    if (note.strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !note.wasGoodHit)
        note.tooLate = true;
    if (global["light"] != null) {
        if (EngineSettings.customArrowSkin == "default") {
            note.color = global["light"].color;
        }
    }
}

function onPlayerHit(noteData) {
    for (bf in PlayState.boyfriends) {
        switch(note.noteData % PlayState.song.keyNumber) {
            case 0:
                bf.playAnim("singLEFT", true);
            case 1:
                bf.playAnim("singDOWN", true);
            case 2:
                bf.playAnim("singUP", true);
            case 3:
                bf.playAnim("singRIGHT", true);
        }
    }
}

function onMiss(noteData) {
    for (bf in PlayState.boyfriends) {
        switch(note.noteData % PlayState.song.keyNumber) {
            case 0:
                bf.playAnim("singLEFTmiss", true);
            case 1:
                bf.playAnim("singDOWNmiss", true);
            case 2:
                bf.playAnim("singUPmiss", true);
            case 3:
                bf.playAnim("singRIGHTmiss", true);
        }
    }
    PlayState.noteMiss(note.noteData);
    PlayState.health -= note.isSustainNote ? 0.03125 : 0.125;
}

function onDadHit(noteData) {
    for (dad in PlayState.dads) {
        switch(note.noteData % PlayState.song.keyNumber) {
            case 0:
                dad.playAnim("singLEFT", true);
            case 1:
                dad.playAnim("singDOWN", true);
            case 2:
                dad.playAnim("singUP", true);
            case 3:
                dad.playAnim("singRIGHT", true);
        }
    }
}