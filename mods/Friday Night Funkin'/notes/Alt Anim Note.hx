enableRating = true;

var noteSchemes:Array<Array<Array<String>>> = [
    [
    ],
    [
        ["arrowUP", "green0", "singUP", "green hold end", "green hold piece"]
    ],
    [
        ["arrowLEFT", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowRIGHT", "red0", "singRIGHT", "red hold end", "red hold piece"]
    ],
    [
        ["arrowLEFT", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowUP", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowRIGHT", "red0", "singRIGHT", "red hold end", "red hold piece"]
    ],
    [
        ["arrowLEFT", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowDOWN", "blue0", "singDOWN", "blue hold end", "blue hold piece"],
        ["arrowUP", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowRIGHT", "red0", "singRIGHT", "red hold end", "red hold piece"],
    ]
];
// enableMiss(true);

var schemeShit:Array<String> = null;

function create() {
    if (EngineSettings.customArrowColors) {
        var colors:Array<Int> = (note.mustPress || EngineSettings.customArrowColors_allChars) ? PlayState.boyfriend.getColors(false) : PlayState.dad.getColors(false);
        note.frames = (EngineSettings.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets_colored') : Paths_.getSparrowAtlas_Custom(StringTools.replace(StringTools.replace(Paths_.getSkinsPath() + "notes/" + EngineSettings.customArrowSkin.toLowerCase(), "/", "\\"), "\r", ""));
		note.color = colors[(note.noteData % 4) + 1];
    } else {
        note.frames = (EngineSettings.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets') : Paths_.getSparrowAtlas_Custom(StringTools.replace(StringTools.replace(Paths_.getSkinsPath() + "notes/" + EngineSettings.customArrowSkin.toLowerCase(), "/", "\\"), "\r", ""));
    }

    schemeShit = noteSchemes[PlayState.song.keyNumber][note.noteData % PlayState.song.keyNumber];

    // note.animation.addByPrefix('greenScroll', 'green0');
    // note.animation.addByPrefix('redScroll', 'red0');
    // note.animation.addByPrefix('blueScroll', 'blue0');
    // note.animation.addByPrefix('purpleScroll', 'purple0');

    // note.animation.addByPrefix('purpleholdend', 'pruple end hold');
    // note.animation.addByPrefix('greenholdend', 'green hold end');
    // note.animation.addByPrefix('redholdend', 'red hold end');
    // note.animation.addByPrefix('blueholdend', 'blue hold end');

    // note.animation.addByPrefix('purplehold', 'purple hold piece');
    // note.animation.addByPrefix('greenhold', 'green hold piece');
    // note.animation.addByPrefix('redhold', 'red hold piece');
    // note.animation.addByPrefix('bluehold', 'blue hold piece');

    note.animation.addByPrefix('scroll', schemeShit[1]);
    note.animation.addByPrefix('holdend', schemeShit[3]);
    note.animation.addByPrefix('holdpiece', schemeShit[4]);

    note.setGraphicSize(Std.int(note.width * 0.7));
    note.updateHitbox();
    note.antialiasing = true;

    note.animation.play("scroll");
    if (note.isSustainNote) {
        if (note.prevNote != null)
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
}

function onPlayerHit(noteData) {
    PlayState.boyfriend.playAnim(schemeShit[2] + "-alt", true);
}

function onMiss(noteData) {
    PlayState.boyfriend.playAnim(schemeShit[2] + "miss", true);
    PlayState.noteMiss(note.noteData);
    PlayState.health -= note.isSustainNote ? 0.03125 : 0.125;
}

function onDadHit(noteData) {
    PlayState.dad.playAnim(schemeShit[2] + "-alt", true);
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