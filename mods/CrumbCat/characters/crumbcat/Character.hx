function create() {
    character.loadGraphic(Paths.image("crumbcat"), true, 498, 498);
	character.animation.add('danceLeft', [0, 1, 2, 3, 4, 5, 6], 20, false);
	character.animation.add('danceRight', [7, 8, 9, 10, 11, 12, 13], 20, false);
    character.playAnim('danceRight');
    character.charGlobalOffset.x = 200;
    character.charGlobalOffset.y = 200;
    character.scale.x = 0.5;
    character.scale.y = 0.5;
}

danced = false;
function dance() {
    if (danced)
        character.playAnim("danceLeft");
    else
        character.playAnim("danceRight");
    danced = !danced;
}