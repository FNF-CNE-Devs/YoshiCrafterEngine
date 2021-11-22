function beatHit(curBeat) {
    
}
function create()
{
    bg = new FlxSprite(-100).loadGraphic(Paths.stageImage('sky.png'));
    bg.scrollFactor.set(0.1, 0.1);
    PlayState.add(bg);
}