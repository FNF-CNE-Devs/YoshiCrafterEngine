function beatHit(curBeat) {
    if (curBeat % 16 == 15 && PlayState.dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
    {
        PlayState.boyfriend.playAnim('hey', true);
        PlayState.dad.playAnim('cheer', true);
    }
    if (curBeat == 128 || curBeat == 129 || curBeat == 130)
        PlayState.vocals.volume = 0;
}