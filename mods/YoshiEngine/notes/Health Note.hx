enableRating = true;

var noteSchemes:Array<Array<Array<String>>> = [
    [
        ["arrowUP", "up press", "up confirm", "green0", "singUP", "green hold end", "green hold piece"]
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

function create() {
    note.frames = Paths.getSparrowAtlas("NOTE_assets_health");
    note.animation.addByPrefix('scroll', noteSchemes[PlayState.song.keyNumber % noteSchemes.length][note.noteData % PlayState.song.keyNumber][3], 0);
    note.animation.addByPrefix('holdend', "hold end");
    note.animation.addByPrefix('holdpiece', "hold piece");
    
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
    note.colored = false;
    note.splashColor = 0xFF880000;
}

function onPlayerHit() {
    for (bf in PlayState.boyfriends) bf.playAnim("preAttack", true);
    PlayState.health += PlayState.maxHealth / 4;
}

function onMiss() {
    
}