import NoteShader.ColoredNoteShader;
import flixel.FlxSprite;

class StrumNote extends FlxSprite {
    public var notes_angle:Null<Float> = null;
    public var notes_alpha:Null<Float> = null; // Ranges from 0 to 1
    public var colored:Bool = false;
    public var cpuRemainingGlowTime:Float = 0;
    public var isCpu:Bool = false;
    public var scrollSpeed:Null<Float> = null;

    public function getAnimName() {
        return animation.curAnim == null ? "" : animation.curAnim.name;
    }

    public function getScrollSpeed() {
        return PlayState.current.engineSettings.customScrollSpeed ? PlayState.current.engineSettings.scrollSpeed : (scrollSpeed == null ? PlayState.SONG.speed : scrollSpeed);
    }

    public function getAlpha() {
        return (notes_alpha == null ? alpha : notes_alpha);
    }

    public function getAngle() {
        return (notes_angle == null ? angle : notes_angle);
    }

    public override function update(elapsed:Float) {
        var animName = getAnimName();
        if (isCpu) {
            cpuRemainingGlowTime -= elapsed;
            if (cpuRemainingGlowTime <= 0 && animName != "static") {
                animation.play("static");
                centerOffsets();
                centerOrigin();
            }
            toggleColor(animName != "static" && colored);
            
        }
        super.update(elapsed);
    }

    public function toggleColor(toggle:Bool) {
        if (Std.isOfType(this.shader, ColoredNoteShader))
            cast(this.shader, ColoredNoteShader).enabled.value = [toggle];
    }
}