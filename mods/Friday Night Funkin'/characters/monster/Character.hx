function create() {
    // GOTTA FIX OFFSET PROBLEMS
    var tex = Paths.getCharacter(textureOverride != "" ? textureOverride : "monster");
    character.frames = tex;
    character.animation.addByPrefix('idle', 'monster idle', 24, false);
    character.animation.addByPrefix('singUP', 'monster up note', 24, false);
    character.animation.addByPrefix('singDOWN', 'monster down', 24, false);
    character.animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
    character.animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

    character.addOffset('idle');
    character.addOffset("singUP", -20, 50);
    character.addOffset("singRIGHT", -51);
    character.addOffset("singLEFT", -30);
    character.addOffset("singDOWN", -30, -40);
    character.charGlobalOffset.y = 100;
    character.playAnim('idle');
}

function getColors(altAnim) {
    return [
        new FlxColor(0xFFF3FF6E),
        new FlxColor(0xFFF3FF6E),
        new FlxColor(0xFFF3FF6E),
        new FlxColor(0xFFF3FF6E),
        new FlxColor(0xFFF3FF6E)
    ];
}

danced = true;
function dance() {
    if (!danced)
        character.playAnim("idle");
    danced = !danced;
}