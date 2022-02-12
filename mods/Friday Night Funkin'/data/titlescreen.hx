var yoshiEngineLogo:FlxSprite = null;
var gfDancing:FlxSprite = null;

function create() {
    gfDancing = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
    gfDancing.frames = Paths.getSparrowAtlas('titlescreen/gfDanceTitle');
    gfDancing.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
    gfDancing.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
    gfDancing.antialiasing = true;
    add(gfDancing);

    yoshiEngineLogo = new FlxSprite(-50, -35);
    yoshiEngineLogo.frames = Paths.getSparrowAtlas('titlescreen/logoBumpin');
    yoshiEngineLogo.antialiasing = true;
    yoshiEngineLogo.animation.addByPrefix('bump', 'logo bumpin', 24);
    yoshiEngineLogo.animation.play('bump');
    yoshiEngineLogo.updateHitbox();
    yoshiEngineLogo.scale.x = yoshiEngineLogo.scale.y = 0.95;
    add(yoshiEngineLogo);
}

var danced = false;
function beatHit() {
    gfDancing.animation.play(danced ? "danceLeft" : "danceRight");
    danced = !danced;
}