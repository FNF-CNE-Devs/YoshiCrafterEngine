function create() {
    var gfSprite = "gf-car";

    if (EngineSettings.customGFSkin == "default") {
        var tex = Paths.getCharacter(textureOverride != "" ? textureOverride : gfSprite);
        character.frames = tex;
        character.animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
        character.animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

        character.addOffset('danceLeft', 0, -9);
        character.addOffset('danceRight', 0, -9);
    } else {
        // Loads the custom default GF skin
        var cGF = EngineSettings.customGFSkin;
        var tex =  Paths_.getSparrowAtlas_Custom(textureOverride != "" ? Paths_.getSkinsPath() + '/gf/' + cGF + '/' + textureOverride + '' : Paths_.getSkinsPath() + '/gf/' + cGF + '/spritesheet');
        character.frames = tex;
        Character.customGFOffsets = StringTools.ltrim(Paths_.getTextOutsideAssets(Paths_.getSkinsPath() + '/gf/' + cGF + '/offsets.txt')).split("\n");
        Character.customGFAnims = StringTools.ltrim(Paths_.getTextOutsideAssets(Paths_.getSkinsPath() + '/gf/' + cGF + '/anim_names.txt')).split("\n");
        // var color:Array<String> = Paths_.getTextOutsideAssets(Paths_.getSkinsPath() + '/gf/' + cGF + '/color.txt').trim().split("\r");	//May come in use later
        character.configureAnims();
        for(offset in Character.customGFOffsets) {
            var data:Array<String> = StringTools.ltrim(offset).split(" ");
            if (data[0] == "dance") {
                character.addOffset("danceLeft", Std.parseInt(data[1]), Std.parseInt(data[2]));
                character.addOffset("danceRight", Std.parseInt(data[1]), Std.parseInt(data[2]));
            } else {
                character.addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
            }
        }
    }
    character.playAnim('danceRight');
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