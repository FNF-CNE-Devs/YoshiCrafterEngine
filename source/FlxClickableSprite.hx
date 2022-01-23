import flixel.FlxG;
import flixel.FlxSprite;

class FlxClickableSprite extends FlxSprite {
    public var onClick:Void->Void = null;
    
    public override function update(elapsed) {
        super.update(elapsed);
        if (FlxG.mouse.overlaps(this, this.camera)) {
            if (FlxG.mouse.justPressed) {
                if (onClick != null) onClick();
            }
        }
    }
}