import flixel.util.FlxColor;
import NoteShader.ColoredNoteShader;
import EngineSettings.Settings;
import flixel.FlxG;
import flixel.FlxSprite;

class Splash extends FlxSprite {
    public static inline var splashCounts:Int = 2;
    public function new() {
        super();
        frames = Paths.getCustomizableSparrowAtlas("splashes");
        for(i in 1...splashCounts+1) {
            animation.addByPrefix(Std.string(i), "splash" + Std.string(i), 30, false);
        }
        visible = false;
        alpha = (PlayState.current == null ? Settings.engineSettings.data : PlayState.current.engineSettings).splashesAlpha;
        scale.set(0.65, 0.65);

        antialiasing = true;
        
        shader = new ColoredNoteShader(255, 255, 255, false);
        updateHitbox();
    }

    public function pop(color:FlxColor) {
        visible = true;
        cast(shader, ColoredNoteShader).setColors(color.red, color.green, color.blue);
        animation.play(Std.string(FlxG.random.int(1, splashCounts)), true);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        visible = animation.curAnim != null && !animation.curAnim.finished;
    }
}