function beatHit(curBeat) {
    if (curBeat % 8 == 7)
    {
        PlayState.boyfriend.playAnim('hey', true);
    }
}