function create() {
    var tex = Paths.getCharacter(textureOverride != "" ? textureOverride : "Friday Night Funkin':senpai");
    character.frames = tex;
    character.animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
	character.animation.addByPrefix('singUP', 'Angry Senpai UP NOTE instance 1', 24, false);
	character.animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
	character.animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
    character.animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

    character.addOffset('idle');
    character.addOffset("singUP", 5, 37);
    character.addOffset("singRIGHT");
    character.addOffset("singLEFT", 40);
    character.addOffset("singDOWN", 14);


    character.setGraphicSize(Std.int(character.width * 6));
    character.updateHitbox();
    character.charGlobalOffset.x = 150;
    character.charGlobalOffset.y = 360;
    // character.charGlobalOffset.y = 180;
    character.camOffset.x = -150;
    character.camOffset.y = -character.height / 3.5;

    character.antialiasing = false;
    character.playAnim('idle');
}