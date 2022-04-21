import flixel.math.FlxMath;
import flixel.input.keyboard.FlxKey;
import flixel.FlxState;

class AndroidInputTest extends FlxState {
    var androidSprite:FlxClickableSprite;
    public override function create() {
        super.create();
        androidSprite = new FlxClickableSprite(0, 0);
        var sprAtlas = Paths.getSparrowAtlas("ui_buttons", "preload");
        // trace(sprAtlas);
        androidSprite.frames = sprAtlas;
        androidSprite.animation.addByPrefix("select button", "select button");
        androidSprite.animation.play("select button");
        androidSprite.key = FlxKey.SPACE;
        androidSprite.screenCenter();
        androidSprite.antialiasing = true;
        // trace(androidSprite.pixels);
        add(androidSprite);
    }

    public override function update(elapsed) {
        super.update(elapsed);
        // try {
        // } catch(e) {
        //     trace(e);
        // }
        androidSprite.color = FlxControls.pressed.SPACE ? 0xFF008888 : 0xFFFFFFFF;
        if (FlxControls.justPressed.SPACE) {
            androidSprite.scale.x = androidSprite.scale.y = 1.25;
        }
        androidSprite.scale.x = androidSprite.scale.y = FlxMath.lerp(androidSprite.scale.x, 1, 0.025);
    }
}