import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class FlxClickableSprite extends FlxSprite {
    public var onClick:Void->Void = null;
    public var hoverColor:FlxColor = 0xFF2384E4;
    public var hovering:Bool = false;

    public override function new(x:Float, y:Float, ?onClick:Void->Void) {
        super(x, y);
        this.onClick = onClick;
    }
    
    public override function update(elapsed) {
        super.update(elapsed);
        if (FlxG.mouse.overlaps(this, this.camera)) {
            color = hoverColor;
            hovering = true;
            if (FlxG.mouse.justPressed) {
                if (onClick != null) onClick();
            }
        } else {
            color = FlxColor.WHITE;
            hovering = false;
        }
    }
}