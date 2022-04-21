enableRating = true;
// enableMiss(true);

function create() {
    if (EngineSettings.customArrowColors) {
        note.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels-colored'), true, 17, 17);
    } else {
        note.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
    }
    note.colored = EngineSettings.customArrowColors;

    note.animation.add('greenScroll', [6]);
    note.animation.add('redScroll', [7]);
    note.animation.add('blueScroll', [5]);
    note.animation.add('purpleScroll', [4]);

    note.splash = Paths.splashes('weeb/splash');
    
    if (note.isSustainNote)
    {
        note.noteOffset.x += 30;
        if (EngineSettings.customArrowColors) {
            note.loadGraphic(Paths.image('weeb/pixelUI/arrowEnds-colored'), true, 7, 6);
        } else {
            note.loadGraphic(Paths.image('weeb/pixelUI/arrowEnds'), true, 7, 6);
        }
        note.animation.add('purpleholdend', [4]);
        note.animation.add('greenholdend', [6]);
        note.animation.add('redholdend', [7]);
        note.animation.add('blueholdend', [5]);

        note.animation.add('purplehold', [0]);
        note.animation.add('greenhold', [2]);
        note.animation.add('redhold', [3]);
        note.animation.add('bluehold', [1]);
    }

    if (note.isSustainNote) {
        var anims = ['purpleholdend', 'blueholdend', 'greenholdend', 'redholdend'];
        var anims2 = ['purplehold', 'bluehold', 'greenhold', 'redhold'];
        note.animation.play(anims[note.noteData % 4]);
        note.setGraphicSize(Std.int(note.width * PlayState_.daPixelZoom));
        note.updateHitbox();
        if (note.prevNote != null) {
            if (anims.contains(note.animation.curAnim.name)) {
                note.prevNote.animation.play(anims2[note.noteData % 4]);
            }
        }
    } else {
        var anims = ['purpleScroll', 'blueScroll', 'greenScroll', 'redScroll'];
        note.animation.play(anims[note.noteData % 4]);
        note.setGraphicSize(Std.int(note.width * PlayState_.daPixelZoom));
        note.updateHitbox();
    }
}


function generateStaticArrow(babyArrow:FlxSprite, i:Int) {
    babyArrow.loadGraphic(Paths.image(EngineSettings.customArrowColors ? 'weeb/pixelUI/arrows-pixels-colored' : 'weeb/pixelUI/arrows-pixels'), true, 17, 17);
    babyArrow.animation.add('green', [6]);
    babyArrow.animation.add('red', [7]);
    babyArrow.animation.add('blue', [5]);
    babyArrow.animation.add('purplel', [4]);

    babyArrow.setGraphicSize(Std.int(babyArrow.width * PlayState_.daPixelZoom));
    babyArrow.updateHitbox();
    babyArrow.antialiasing = false;
    
    babyArrow.colored = EngineSettings.customArrowColors;
    
    var noteNumberScheme:Array<NoteDirection> = Note.noteNumberSchemes[PlayState.song.keyNumber];
    if (noteNumberScheme == null) noteNumberScheme = Note.noteNumberSchemes[4];
    switch (noteNumberScheme[i % noteNumberScheme.length])
    {
        case 0:
            babyArrow.animation.add('static', [0]);
            babyArrow.animation.add('pressed', [4, 8], 12, false);
            babyArrow.animation.add('confirm', [12, 16], 24, false);
        case 1:
            babyArrow.animation.add('static', [1]);
            babyArrow.animation.add('pressed', [5, 9], 12, false);
            babyArrow.animation.add('confirm', [13, 17], 24, false);
        case 2:
            babyArrow.animation.add('static', [2]);
            babyArrow.animation.add('pressed', [6, 10], 12, false);
            babyArrow.animation.add('confirm', [14, 18], 12, false);
        case 3:
            babyArrow.animation.add('static', [3]);
            babyArrow.animation.add('pressed', [7, 11], 12, false);
            babyArrow.animation.add('confirm', [15, 19], 24, false);
    }
}