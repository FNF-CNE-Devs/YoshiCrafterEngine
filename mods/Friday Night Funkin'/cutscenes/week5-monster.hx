var blackScreen:FlxSprite = null;
var t:Float = 0;
var phase = 0;
function create() {
    blackScreen = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), 0xFF000000);
    PlayState.add(blackScreen);
    blackScreen.scrollFactor.set();
    PlayState.camFollow.y = -2050;
    PlayState.camFollow.x = 200;
    FlxG.camera.focusOn(PlayState.camFollow.getPosition());
    FlxG.camera.zoom = 1.5;
    FlxG.sound.play(Paths.sound('Lights_Turn_On'));
}
function update(elapsed) {
    t += elapsed;

    if (phase == 0 && t > 0.8) {
        PlayState.remove(blackScreen);
        phase = 1;
    }
    if (phase == 1 && t > 0.8 + 2.5) {
        startCountdown();
    }
}