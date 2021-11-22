var halloweenBG:FlxSprite = null;

var lightningStrikeBeat:Int = 0;
var lightningOffset:Int = 8;

function create()
{
    var hallowTex = Paths.getSparrowAtlas_Stage('halloween_bg');

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
}
function lightningStrikeShit()
{
    var random = Std.string(FlxG.random.int(1, 2));
    FlxG.sound.play(Paths.stageSound('thunder_$random'));
    halloweenBG.animation.play('lightning');

    lightningStrikeBeat = PlayState.curBeat;
    lightningOffset = FlxG.random.int(8, 24);

    PlayState.boyfriend.playAnim('scared', true);
    PlayState.gf.playAnim('scared', true);
}