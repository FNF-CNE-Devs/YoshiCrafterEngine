function create() {
    var videoSprite:FlxSprite = null;
    videoSprite = MP4Video.playMP4(Paths.video(PlayState_.SONG.song.toLowerCase() + "Cutscene"),
        function() {
            PlayState.remove(videoSprite);
            trace(FlxG.camera.color);
            startCountdown();
        }, false);
    videoSprite.cameras = [PlayState.camHUD];
    videoSprite.scrollFactor.set();
    PlayState.add(videoSprite);
}