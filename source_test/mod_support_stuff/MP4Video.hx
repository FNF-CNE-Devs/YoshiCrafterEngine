package mod_support_stuff;

import EngineSettings.Settings;
import flixel.FlxSprite;

class MP4Video {
    // public var video:MP4Handler = new MP4Handler();
    // public var sprite:FlxSprite;
    // public var finishCallback:Void->Void = function() {
    //     PlayState.current.startCountdown();
    // };
    // public function new() {
    //     sprite = new FlxSprite(0, 0);
    // }

    public static function playMP4(path:String, callback:Void->Void, repeat:Bool = false):FlxSprite {
        
		#if X64_BITS
            #if windows
            var video = new MP4Handler();
            video.finishCallback = callback;
            var sprite = new FlxSprite(0,0);
            sprite.antialiasing = Settings.engineSettings.data.videoAntialiasing;
            video.playMP4(path, repeat, sprite, null, null, true);
            return sprite;
            #else
            callback();
            return new FlxSprite(0,0);
            #end
        #else
            callback();
            return new FlxSprite(0,0);
        #end
    }
}