import NoteShader.ColoredNoteShader;
import flixel.FlxSprite;

class StrumNote extends FlxSprite {
    public var notes_angle:Float = 0;
    public var notes_alpha:Float = 1; // Ranges from 0 to 1
    public var colored:Bool = false;
    public var cpuRemainingGlowTime:Float = 0;
    public var isCpu:Bool = false;
    public var scrollSpeed:Null<Float> = null;

    public function getScrollSpeed() {
        return PlayState.current.engineSettings.customScrollSpeed ? PlayState.current.engineSettings.scrollSpeed : (scrollSpeed == null ? PlayState.SONG.speed : scrollSpeed);
    }

    public override function update(elapsed:Float) {
        if (isCpu) {
            cpuRemainingGlowTime -= elapsed;
            if (cpuRemainingGlowTime <= 0 && animation.curAnim.name != "static") {
                animation.play("static");
                centerOffsets();
                centerOrigin();
            }
            toggleColor(animation.curAnim.name != "static" && colored);
            
        }
        super.update(elapsed);
    }

    public function toggleColor(toggle:Bool) {
        cast(this.shader, ColoredNoteShader).enabled.value = [toggle];
    }
}