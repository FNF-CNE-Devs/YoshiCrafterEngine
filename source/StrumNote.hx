import flixel.math.FlxPoint;
import flixel.FlxG;
import NoteShader.ColoredNoteShader;
import flixel.FlxSprite;

@:allow(PlayState)
class StrumNote extends FlxSprite {

    public var notes_angle:Null<Float> = null;
    public var notes_alpha:Null<Float> = null; // Ranges from 0 to 1
    public var notes_scale:Float = 1; // Ranges from 0 to 1

    public var notesAlpha(get, set):Null<Float>;    function get_notesAlpha() {return notes_alpha;}     function set_notesAlpha(v:Float) {return notes_alpha = v;}
    public var notesAngle(get, set):Null<Float>;    function get_notesAngle() {return notes_angle;}     function set_notesAngle(v:Float) {return notes_angle = v;}
    public var notesScale(get, set):Float;          function get_notesScale() {return notes_scale;}     function set_notesScale(v:Float) {return notes_scale = v;}


    public var colored:Bool = false;
    public var cpuRemainingGlowTime:Float = 0;
    public var isCpu:Bool = false;
    public var scrollSpeed:Null<Float> = null;

    private var _defaultPosition:FlxPoint;

    private var __animationEnabled:Bool = false;
    private var __animationAlpha:Float = 1;
    private var __animationY:Float = 0;

    public var defaultPosition(get, null):FlxPoint;
    public function get_defaultPosition() {
        return new FlxPoint(_defaultPosition.x, _defaultPosition.y);
    }

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
        doCpuStuff(elapsed);
        super.update(elapsed);
    }
    public override function draw() {
        doCpuStuff(0);

        var oldScale = [scale.x, scale.y];
        scale.x *= notesScale;
        scale.y *= notesScale;

        if (__animationEnabled) {
            var oldY = y;
            var oldAlpha = alpha;
            alpha *= __animationAlpha;
            y += __animationY;
            super.draw();
            y = oldY;
            alpha = oldAlpha;
        } else
            super.draw();
        scale.set(oldScale[0], oldScale[1]);
    }

    public function doCpuStuff(elapsed:Float) {
        var animName = getAnimName();
        if (isCpu) {
            cpuRemainingGlowTime -= elapsed;
            if (cpuRemainingGlowTime <= 0 && animName != "static") {
                animation.play("static");
                animName = "static";
                centerOffsets();
                centerOrigin();
            }
        }
        toggleColor(animName != "static" && colored);
    }

    public function toggleColor(toggle:Bool) {
        if (Std.isOfType(this.shader, ColoredNoteShader))
            cast(this.shader, ColoredNoteShader).enabled.value = [toggle];
    }
}