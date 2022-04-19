import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.addons.ui.*;
import flixel.tweens.FlxEase;
import EngineSettings.Settings;
import flixel.*;
import flixel.math.FlxMath;

class OffsetConfigState extends MusicBeatState {

    var chars:Array<Character> = [];
    public function new() {
        super();
    }

    public override function create() {
        var gf = new Character(100, 100, "Friday Night Funkin':gf");
        chars.push(gf);
        add(gf);

        var bf = new Character(770, 100, "Friday Night Funkin':bf", true);
        chars.push(bf);
        add(bf);

        FlxG.sound.playMusic(Paths.modInst('tutorial', "Friday Night Funkin'", "hard"));
        Conductor.changeBPM(100);
        Conductor.songPosition = -5000;
        Conductor.songPositionOld = -5000;

        FlxG.camera.scroll.set(gf.getMidpoint().x - (FlxG.width / 2), gf.getMidpoint().y - (FlxG.height / 2));
        super.create();

        var hud = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        FlxG.cameras.add(hud, false);
        hud.bgColor = 0;

        var bar1 = new FlxBar(100, (FlxG.height * 0.95) - 17, LEFT_TO_RIGHT, Std.int(FlxG.width / 2) - 100 + 1, 17, Settings.engineSettings.data, "noteOffset", -150, 0, true);
        bar1.cameras = [hud];
        bar1.createGradientBar([0xFF7163F1, 0xFFD15CF8], [0x88222222], 1, 90, true, 0xFF000000);
        add(bar1);

        var bar2 = new FlxBar(Std.int(FlxG.width * 0.5), (FlxG.height * 0.95) - 17, LEFT_TO_RIGHT, Std.int(FlxG.width / 2) - 100, 17, Settings.engineSettings.data, "noteOffset", 0, 150, true);
        bar2.cameras = [hud];
        bar2.createGradientBar([0x88222222], [0xFF7163F1, 0xFFD15CF8], 1, 90, true, 0xFF000000);
        add(bar2);

        var bar1label = new FlxUIText(bar1.x, bar1.y + bar1.height + 10, 0, "-150ms");
        bar1label.setFormat(null, 16, 0xFFFFFFFF, LEFT, 0xFF000000);
        bar1label.x -= bar1label.width / 2;
        bar1label.cameras = [hud];
        add(bar1label);

        var bar2label = new FlxUIText(bar2.x + bar2.width, bar2.y + bar2.height + 10, 0, "150ms");
        bar2label.setFormat(null, 16, 0xFFFFFFFF, LEFT, 0xFF000000);
        bar2label.x -= bar2label.width / 2;
        bar2label.cameras = [hud];
        add(bar2label);

        bar1label.y -= bar1label.height;
        bar1.y -= bar1label.height;
        bar2label.y -= bar1label.height;
        bar2.y -= bar1label.height;
    }

    public override function beatHit() {
        super.beatHit();
        for(c in chars) {
            c.dance();
        }
    }
    public override function update(elapsed:Float) {
        if (controls.RIGHT_P) {
            Settings.engineSettings.data.noteOffset += 2;
        }
        if (controls.LEFT_P) {
            Settings.engineSettings.data.noteOffset -= 2;
        }
        if (controls.RIGHT && FlxControls.pressed.SHIFT) {
            Settings.engineSettings.data.noteOffset += 25 * elapsed;
        }
        if (controls.LEFT && FlxControls.pressed.SHIFT) {
            Settings.engineSettings.data.noteOffset -= 25 * elapsed;
        }
        Settings.engineSettings.data.noteOffset -= Settings.engineSettings.data.noteOffset % 1;
		Conductor.songPosition += Settings.engineSettings.data.noteOffset;
        if (FlxG.sound.music.time == Conductor.songPositionOld) {
            Conductor.songPosition += FlxG.elapsed * 1000;
        } else {
            Conductor.songPosition = Conductor.songPositionOld = FlxG.sound.music.time;
        }
		Conductor.songPosition -= Settings.engineSettings.data.noteOffset;

        super.update(elapsed);

        FlxG.camera.zoom = FlxMath.lerp(1.025 * 0.8, 0.8, FlxEase.quartOut((Conductor.songPosition % (Conductor.crochet * 2)) / (2 * Conductor.crochet)));
    }
}