function create() {
    var videoSprite:FlxSprite = null;
    videoSprite = MP4Video.playMP4(Paths.video(PlayState_.SONG.song.toLowerCase() + "Cutscene"),
        function() {
            PlayState.remove(videoSprite);
            trace(FlxG.camera.color);
            PlayState.camGame.flash(0x00000000, 0);
            startCountdown();
        }, false);
    videoSprite.cameras = [PlayState.camHUD];
    videoSprite.scrollFactor.set();
    PlayState.camGame.flash(0xFF000000, 0);
    PlayState.add(videoSprite);
}