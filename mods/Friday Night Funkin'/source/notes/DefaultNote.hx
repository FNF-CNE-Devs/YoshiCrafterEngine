enableRating(true);
// enableMiss(true);

function create() {
    if (EngineSettings.customArrowColors) {
        var colors:Array<Int> = (note.mustPress || EngineSettings.customArrowColors_allChars) ? PlayState.boyfriend.getColors(false) : PlayState.dad.getColors(false);
        note.frames = (EngineSettings.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets_colored') : Paths.getSparrowAtlas_Custom((Paths.getSkinsPath() + "notes/" + EngineSettings.customArrowSkin.toLowerCase()).replace("/", "\\").replace("\r", ""));
		note.color = colors[(note.noteData % 4) + 1];
    } else {
        note.frames = (EngineSettings.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets') : Paths.getSparrowAtlas_Custom((Paths.getSkinsPath() + "notes/" + EngineSettings.customArrowSkin.toLowerCase()).replace("/", "\\").replace("\r", ""));
    }

    note.animation.addByPrefix('greenScroll', 'green0');
    note.animation.addByPrefix('redScroll', 'red0');
    note.animation.addByPrefix('blueScroll', 'blue0');
    note.animation.addByPrefix('purpleScroll', 'purple0');

    note.animation.addByPrefix('purpleholdend', 'pruple end hold');
    note.animation.addByPrefix('greenholdend', 'green hold end');
    note.animation.addByPrefix('redholdend', 'red hold end');
    note.animation.addByPrefix('blueholdend', 'blue hold end');

    note.animation.addByPrefix('purplehold', 'purple hold piece');
    note.animation.addByPrefix('greenhold', 'green hold piece');
    note.animation.addByPrefix('redhold', 'red hold piece');
    note.animation.addByPrefix('bluehold', 'blue hold piece');

    note.setGraphicSize(Std.int(note.width * 0.7));
    note.updateHitbox();
    note.antialiasing = true;
}

function update(elapsed) {
    if (note.isSustainNote) {
        note.canBeHit = (note.strumTime - (Conductor.stepCrochet * 0.6) < Conductor.songPosition) && (note.strumTime + (Conductor.stepCrochet) > Conductor.songPosition);
    } else {
        note.canBeHit = (note.strumTime > Conductor.songPosition - Conductor.safeZoneOffset && note.strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5));
    }
    if (note.strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !note.wasGoodHit)
        note.tooLate = true;
}

function onPlayerHit(direction) {
    switch(direction) {
        case 0: //SING LEFT
            PlayState.boyfriend.playAnim("singLEFT", true);
        case 1: //SING DOWN
            PlayState.boyfriend.playAnim("singDOWN", true);
        case 2: //SING UP
            PlayState.boyfriend.playAnim("singUP", true);
        case 3: //SING RIGHT
            PlayState.boyfriend.playAnim("singRIGHT", true);
    }
}

function onMiss(direction) {
    switch(direction) {
        case 0: //SING LEFT
            PlayState.boyfriend.playAnim("singLEFTmiss", true);
        case 1: //SING DOWN
            PlayState.boyfriend.playAnim("singDOWNmiss", true);
        case 2: //SING UP
            PlayState.boyfriend.playAnim("singUPmiss", true);
        case 3: //SING RIGHT
            PlayState.boyfriend.playAnim("singRIGHTmiss", true);
    }
    PlayState.noteMiss(note.noteData);
    PlayState.health -= note.isSustainNote ? 0.03125 : 0.125;
}

// function onDadHit(direction) {
//     switch(direction) {
//         case 0: //SING LEFT
//             PlayState.dad.playAnim("singLEFT");
//         case 1: //SING DOWN
//             PlayState.dad.playAnim("singDOWN");
//         case 2: //SING UP
//             PlayState.dad.playAnim("singUP");
//         case 3: //SING RIGHT
//             PlayState.dad.playAnim("singRIGHT");
//     }
// }