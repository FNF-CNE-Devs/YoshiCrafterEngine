function onPlayerHit(direction:Int) {
    switch(direction) {
        case 0:
            PlayState.gf.playAnim("singLEFT", true);
        case 1:
            PlayState.gf.playAnim("singDOWN", true);
        case 2:
            PlayState.gf.playAnim("singUP", true);
        case 3:
            PlayState.gf.playAnim("singRIGHT", true);
    }
}

function onDadHit(direction:Int) {
    onPlayerHit(direction);
}

function onMiss(direction:Int) {
    switch(direction) {
        case 0:
            PlayState.gf.playAnim("singLEFTmiss", true);
        case 1:
            PlayState.gf.playAnim("singDOWNmiss", true);
        case 2:
            PlayState.gf.playAnim("singUPmiss", true);
        case 03:
            PlayState.gf.playAnim("singRIGHTmiss", true);
    }
}