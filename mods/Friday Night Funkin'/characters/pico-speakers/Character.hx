var danced = false;
var chart = null;

function create() {
    character.frames = Paths.getCharacter("pico-speakers");

    character.animation.addByPrefix("shoot1", "Pico shoot 1", 24, false);
    character.animation.addByPrefix("shoot2", "Pico shoot 2", 24, false);
    character.animation.addByPrefix("shoot3", "Pico shoot 3", 24, false);
    character.animation.addByPrefix("shoot4", "Pico shoot 4", 24, false);

    character.addOffset("shoot1", 0, 0);
    character.addOffset("shoot2", 0, 0);
    character.addOffset("shoot3", 0, 0);
    character.addOffset("shoot4", 0, 0);
    character.animation.addByIndices();

    var chart = Json.parse(Paths.json("stress/picospeaker"));
}

function update(elapsed) {
    for (note in chart.song.notes[Math.floor(Conductor.songPosition / Conductor.crochet)].sectionNotes) {
        if (note[0] - (elapsed / 1000) < Conductor.songPosition && note[0] > Conductor.songPosition) {
            switch(note[1]) {
                case 0:
                    var r = FlxG.random.int(0, 1);
                    character.playAnim("shoot" + Std.string(r));
                case 3:
                    var r = FlxG.random.int(2, 3);
                    character.playAnim("shoot" + Std.string(r));
            }
            lastNoteHitTime = Conductor.songPosition;
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