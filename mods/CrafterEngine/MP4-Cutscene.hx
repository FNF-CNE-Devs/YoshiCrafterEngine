// TO USE, ADD :
// cutscene = "CrafterEngine:MP4-Cutscene";
// In your song_conf.hx file for the song you want and
// go to your mod folder, create a "videos" folder and
// add a video with this title "(your song) cutscene.mp4"
// for example : "philly cutscene.mp4" or "satin-panties cutscene.mp4"
// PLEASE RESPECT THE CASE FOR LINUX USERS.
// THE VIDEO MUST BE 1280x720

function create() {
    var mFolder = Paths_.modsPath;
    
    // To get video path in your custom cutscene, type Paths.video("(video file name)");
    var path = mFolder + "\\" + PlayState_.songMod + "\\videos\\" + PlayState.song.song.toLowerCase() + " cutscene.mp4";

    var wasWidescreen = PlayState.isWidescreen;
    // Video sprite to be added in game.
    var videoSprite:FlxSprite = null;
    // Assigns the video sprite
    videoSprite = MP4Video.playMP4(path,
        // WILL TRIGGER ONCE THE VIDEO ENDS
        function() {
            // Removes the video sprite from the PlayState
            PlayState.remove(videoSprite);
            // Enables widescreen back (or disable it if it was disabled)
            PlayState.isWidescreen = wasWidescreen;
            // Starts the countdown and ends the cutscene.
            startCountdown();
        },
        // If midsong.
        false);
    // Sets the video sprite camera to camHUD, putting it above the HUD.
    videoSprite.cameras = [PlayState.camHUD];
    // Sets the scroll factor to 0
    videoSprite.scrollFactor.set();
    // Disables widescreen
    PlayState.isWidescreen = false;
    // Adds the video sprite.
    PlayState.add(videoSprite);
}