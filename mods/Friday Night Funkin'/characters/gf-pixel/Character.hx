function create() {
    tex = Paths.getCharacter(textureOverride != "" ? textureOverride : 'gf-pixel');
    character.frames = tex;
    character.animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
    character.animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
    character.animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);



    character.setGraphicSize(Std.int(character.width * 6));
    character.updateHitbox();
    

    character.addOffset('danceLeft', -character.width / 2, -character.height / 2);
    character.addOffset('danceRight', -character.width / 2, -character.height / 2);
    
    character.antialiasing = false;
    character.playAnim('danceRight');
    character.charGlobalOffset.x -= 150;
}

danced = false;
function dance() {
    if (danced)
        character.playAnim("danceLeft");
    else
        character.playAnim("danceRight");
    danced = !danced;
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