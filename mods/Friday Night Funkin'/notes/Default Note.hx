enableRating = true;

var noteSchemes:Array<Array<Array<String>>> = [
    [
    ],
    [
        // ["Static arrow sprite", "Pressed arrow sprite", "Confirmed arrow sprite", "Scroll arrow sprite", "Character animation", "Hold end piece animation", "Hold piece animation"]
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"]
    ],
    [
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"]
    ],
    [
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"]
    ],
    [
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowDOWN", "down press", "down confirm", "blue0", "singDOWN", "blue hold end", "blue hold piece"],
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
    ],
    [
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
    ],
    [
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowDOWN", "down press", "down confirm", "blue0", "singDOWN", "blue hold end", "blue hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
    ],
    [
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowDOWN", "down press", "down confirm", "blue0", "singDOWN", "blue hold end", "blue hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
    ],
    [
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowDOWN", "down press", "down confirm", "blue0", "singDOWN", "blue hold end", "blue hold piece"],
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
        
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowDOWN", "down press", "down confirm", "blue0", "singDOWN", "blue hold end", "blue hold piece"],
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
    ],
    [
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowDOWN", "down press", "down confirm", "blue0", "singDOWN", "blue hold end", "blue hold piece"],
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
        
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowDOWN", "down press", "down confirm", "blue0", "singDOWN", "blue hold end", "blue hold piece"],
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
    ],
    [
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowDOWN", "down press", "down confirm", "blue0", "singDOWN", "blue hold end", "blue hold piece"],
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
        
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
        
        ["arrowLEFT", "left press", "left confirm", "purple0", "singLEFT", "pruple end hold", "purple hold piece"],
        ["arrowDOWN", "down press", "down confirm", "blue0", "singDOWN", "blue hold end", "blue hold piece"],
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"],
        ["arrowRIGHT", "right press", "right confirm", "red0", "singRIGHT", "red hold end", "red hold piece"],
    ]
];
// enableMiss(true);

var schemeShit:Array<String> = null;

function generateStaticArrow(babyArrow:FlxSprite, i:Int) {
    var s = noteSchemes[PlayState.song.keyNumber][i % PlayState.song.keyNumber % noteSchemes.length];
    babyArrow.frames = (EngineSettings.customArrowSkin == "default") ? Paths.getSparrowAtlas(EngineSettings.customArrowColors ? 'NOTE_assets_colored' : 'NOTE_assets') : Paths_.getSparrowAtlas_Custom(Paths_.getSkinsPath() + "/notes/" + EngineSettings.customArrowSkin.toLowerCase());
    babyArrow.antialiasing = true;
    babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
    
    if (s == null) s = ["arrowUP", "up press", "up confirm"];

    babyArrow.animation.addByPrefix('static', s[0]);
    babyArrow.animation.addByPrefix('pressed', s[1], 24, false);
    babyArrow.animation.addByPrefix('confirm', s[2], 24, false);
    babyArrow.colored = EngineSettings.customArrowColors;
}

function create() {
    if (EngineSettings.customArrowColors) {
        // var colors:Array<Int> = (note.mustPress || EngineSettings.customArrowColors_allChars) ? PlayState.boyfriend.getColors(note.altAnim) : PlayState.dad.getColors(note.altAnim);
        note.frames = (EngineSettings.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets_colored') : Paths_.getSparrowAtlas_Custom(StringTools.replace(StringTools.replace(Paths_.getSkinsPath() + "notes/" + EngineSettings.customArrowSkin.toLowerCase(), "/", "\\"), "\r", ""));
        note.colored = true;
		// note.color = colors[(note.noteData % 4) + 1];
    } else {
        note.frames = (EngineSettings.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets') : Paths_.getSparrowAtlas_Custom(StringTools.replace(StringTools.replace(Paths_.getSkinsPath() + "notes/" + EngineSettings.customArrowSkin.toLowerCase(), "/", "\\"), "\r", ""));
    }

    schemeShit = noteSchemes[PlayState.song.keyNumber][note.noteData % PlayState.song.keyNumber % noteSchemes.length];

    note.animation.addByPrefix('scroll', schemeShit[3]);
    note.animation.addByPrefix('holdend', schemeShit[5]);
    note.animation.addByPrefix('holdpiece', schemeShit[6]);

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