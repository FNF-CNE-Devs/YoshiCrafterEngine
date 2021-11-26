function create() {

    // Loads the custom default GF skin
    var cGF = EngineSettings.customGFSkin;
    var tex =  Paths_.getSparrowAtlas_Custom(textureOverride != "" ? Paths_.getSkinsPath() + '/gf/' + cGF + '/' + textureOverride + '' : Paths_.getSkinsPath() + '/gf/' + cGF + '/blammed');
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

    character.playAnim('danceRight');
}

danced = false;
function dance() {
    if (character.animation.name == "hairBlow" || (character.animation.name == "hairFall" && !character.animation.finished)) {
        danced = false;
        return;
    }
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