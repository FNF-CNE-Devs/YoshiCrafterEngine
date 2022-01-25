import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxG;

class MenuMessage extends MusicBeatSubstate {
    var wasUnpressed = false;
    public override function new(message:String) {
        super();
        add(new FlxSprite(0, 0).makeGraphic(1280, 720, 0x88000000));
        add(new FlxSprite(1280 / 4, 720 / 4).makeGraphic(640, 360, 0x88000000));

        var message = new FlxText(1280 / 4 + 10, 720 / 4 + 10, 620, message);
		message.setFormat(Paths.font("vcr.ttf"), Std.int(16), 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        add(message);

        var okButton = new FlxSprite(0, 0);
        okButton.loadGraphic(Paths.image("enterToClose", "preload"));
        okButton.scale.x = okButton.scale.y = 0.6;
        okButton.updateHitbox();
        okButton.setPosition(1280 * 0.75 - 10 - okButton.width, 720 * 0.75 - 10 - okButton.height);
        add(okButton);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (!FlxG.keys.pressed.BACKSPACE) {
            wasUnpressed = true;
        }
        if (FlxG.keys.justPressed.BACKSPACE && wasUnpressed) {
            close();
        }
    }
}