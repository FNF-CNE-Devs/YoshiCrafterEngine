function create() {
    PlayState.defaultCamZoom = 0.9;

    var bg = new FlxSprite(-600, -200).loadGraphic(Paths.image('default_stage/stageback'));
    bg.antialiasing = true;
    bg.scrollFactor.set(0.9, 0.9);
    bg.active = false;
    PlayState.add(bg);

    var stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('default_stage/stagefront'));
    stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
    stageFront.updateHitbox();
    stageFront.antialiasing = true;
    stageFront.scrollFactor.set(0.9, 0.9);
    stageFront.active = false;
    PlayState.add(stageFront);

    var stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('default_stage/stagecurtains'));
    stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
    stageCurtains.updateHitbox();
    stageCurtains.antialiasing = true;
    stageCurtains.scrollFactor.set(1.3, 1.3);
    stageCurtains.active = false;

    PlayState.add(stageCurtains);
}

//   TEST CODE
// var rot = 0;
// function update(elapsed) {
//     rot += 180 * elapsed;
//     // trace(rot);
//     PlayState.health = 1 + (Math.sin(rot / 180 * Math.pi) * 0.75);
// }