function onDadHit(noteData) {
    switch(noteData) {
        case 0:
            PlayState.dad.playAnim("singLEFT-alt");
        case 1:
            PlayState.dad.playAnim("singDOWN-alt");
        case 2:
            PlayState.dad.playAnim("singUP-alt");
        case 3:
            PlayState.dad.playAnim("singRIGHT-alt");
    }
}