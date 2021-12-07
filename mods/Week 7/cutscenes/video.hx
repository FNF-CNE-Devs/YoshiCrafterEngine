function create() {
    var wasWidescreen = PlayState.isWidescreen;
    var videoSprite:FlxSprite = null;
    videoSprite = MP4Video.playMP4(Paths.video(PlayState_.SONG.song.toLowerCase() + "Cutscene"),
        function() {
            PlayState.remove(videoSprite);
            PlayState.isWidescreen = wasWidescreen;
            trace(FlxG.camera.color);
            PlayState.camGame.flash(0x00000000, 0);
            startCountdown();
        }, false);
    videoSprite.cameras = [PlayState.camHUD];
    videoSprite.scrollFactor.set();
    PlayState.isWidescreen = false;
    PlayState.add(videoSprite);
}