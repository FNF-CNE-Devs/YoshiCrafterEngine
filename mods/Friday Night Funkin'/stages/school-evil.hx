function create() {
    gfVersion = "gf-pixel";

    var bg:FlxSprite = new FlxSprite(400, 200);
    bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
    bg.animation.addByPrefix('idle', 'background 2', 24);
    bg.animation.play('idle');
    bg.scrollFactor.set(0.8, 0.9);
    bg.scale.set(6, 6);
    PlayState.add(bg);
}