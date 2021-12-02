var danced = false;
var chart = null;

function create() {
    character.frames = Paths.getCharacter("Week 7:pico-speakers");

    character.animation.addByPrefix("shoot1", "Pico shoot 1", 24, false);
    character.animation.addByPrefix("shoot2", "Pico shoot 2", 24, false);
    character.animation.addByPrefix("shoot3", "Pico shoot 3", 24, false);
    character.animation.addByPrefix("shoot4", "Pico shoot 4", 24, false);
    character.animation.addByIndices("idle", "Pico shoot 1", [for (i in 4...25) i], "", 24, true);

    character.addOffset("shoot1", 0, 0);
    character.addOffset("shoot2", -1, -128);
    character.addOffset("shoot3", 412, -64);
    character.addOffset("shoot4", 439, -19);

    character.playAnim("shoot1");

    chart = Paths.parseJson("stress/picospeaker");
}

var h = -1;
var e = -1;
function update(elapsed) {
    var e = Math.floor(Conductor.songPosition / (Conductor.crochet * 4));
    if (e < 0) return;
    for (note in chart.song.notes[e].sectionNotes) {
        if (note[0] < Conductor.songPosition && !(note[0] <= h || note[1] == e)) {
            switch(note[1]) {
                case 0:
                    var r = FlxG.random.int(1, 2);
                    character.playAnim("shoot" + Std.string(r), true);
                case 3:
                    var r = FlxG.random.int(3, 4);
                    character.playAnim("shoot" + Std.string(r), true);
            }
            character.lastNoteHitTime = Conductor.songPosition;
            h = Conductor.songPosition;
            e = note[1];
        }
    }
}

function dance() {
    character.playAnim("idle");
}

function onAnim(animName) {
}

function getColors(altAnim) {
    return [
        new FlxColor(0xFFA5004D),
        new FlxColor(0xFFA5004D),
        new FlxColor(0xFFA5004D),
        new FlxColor(0xFFA5004D),
        new FlxColor(0xFFA5004D)
    ];
}