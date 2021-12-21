enableRating = true;
// enableMiss(true);

function create() {
    if (EngineSettings.customArrowColors) {
        var colors:Array<FlxColor> = (mustPress || EngineSettings.customArrowColors_allChars) ? PlayState.current.boyfriend.getColors(false) : PlayState.current.boyfriend.getColors(false);
        note.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels-colored'), true, 17, 17);
        #if secret
            var c:FlxColor = new FlxColor(0xFFFF0000);
            c.hue = (strumTime / 100) % 359;
            note.color = c;
        #else
            note.color = colors[(noteData % 4) + 1];
        #end
    } else {
        note.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
    }

    note.animation.add('greenScroll', [6]);
    note.animation.add('redScroll', [7]);
    note.animation.add('blueScroll', [5]);
    note.animation.add('purpleScroll', [4]);

    if (note.isSustainNote)
    {
        note.noteOffset.x += 30;
        if (EngineSettings.customArrowColors) {
            var colors:Array<FlxColor> = (mustPress || EngineSettings.customArrowColors_allChars) ? PlayState.current.boyfriend.getColors(false) : PlayState.current.boyfriend.getColors(false);
            // loadGraphic(Paths.image('weeb/pixelUI/arrowEnds-colored', 'week6'), true, 17, 17);
            note.loadGraphic(Paths.image('weeb/pixelUI/arrowEnds-colored'), true, 7, 6);
            note.color = colors[noteData % 4];
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

function onDadHit(direction) {
    switch(direction) {
        case 0: //SING LEFT
            PlayState.dad.playAnim("singLEFT", true);
        case 1: //SING DOWN
            PlayState.dad.playAnim("singDOWN", true);
        case 2: //SING UP
            PlayState.dad.playAnim("singUP", true);
        case 3: //SING RIGHT
            PlayState.dad.playAnim("singRIGHT", true);
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

function generateStaticArrow(babyArrow:FlxSprite, i:Int) {
    babyArrow.loadGraphic(Paths.image(EngineSettings.customArrowColors ? 'weeb/pixelUI/arrows-pixels-colored' : 'weeb/pixelUI/arrows-pixels'), true, 17, 17);
    babyArrow.animation.add('green', [6]);
    babyArrow.animation.add('red', [7]);
    babyArrow.animation.add('blue', [5]);
    babyArrow.animation.add('purplel', [4]);

    babyArrow.setGraphicSize(Std.int(babyArrow.width * PlayState_.daPixelZoom));
    babyArrow.updateHitbox();
    babyArrow.antialiasing = false;
    
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