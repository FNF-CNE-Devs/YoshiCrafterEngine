var halloweenBG:FlxSprite = null;

var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;
var lightningStrike:Float = -5;

function create()
{
    var hallowTex = Paths.getSparrowAtlas('halloween/halloween_bg');

    halloweenBG = new FlxSprite(-200, -100);
    halloweenBG.frames = hallowTex;
    halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
    halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
    halloweenBG.animation.play('idle');
    halloweenBG.antialiasing = true;
    PlayState.add(halloweenBG);
}
function beatHit(curBeat)
{
    if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
    {
        lightningStrikeShit();
    }
    if (curBeat > lightningStrikeBeat + 2) {
        if (PlayState.gf.animation.curAnim.name == "scared") PlayState.gf.dance(true);
        if (PlayState.boyfriend.animation.curAnim.name == "scared") PlayState.boyfriend.dance(true);
    }
}
function lightningStrikeShit()
{
    FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
    halloweenBG.animation.play('lightning');

    lightningStrikeBeat = PlayState.curBeat;
    lightningOffset = FlxG.random.int(8, 24);

    PlayState.boyfriend.playAnim('scared', true);
    PlayState.boyfriend.lastNoteHitTime = Conductor.songPosition;
    PlayState.gf.playAnim('scared', true);
    PlayState.gf.lastNoteHitTime = Conductor.songPosition;
}