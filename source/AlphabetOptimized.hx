import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class AlphabetOptimized extends FlxSpriteGroup {
    public var frameOffset:Float = 0;
    public static inline var letters:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    public var text:String = "";
    public var letterSprite:FlxSprite;

    public var isMenuItem:Bool = false;
    public var targetY:Int = 0;
	/**
	 * If false, the Alphabet will go to the target Y without any lerp and set this to true.
	**/
	public var wentToTargetY:Bool = false;

    public override function get_width():Float {
        return text.length * 48;
    }
    public function new(x:Float, y:Float, text:String) {
        super();
        this.x = x;
        this.y = y;
        this.text = text;

        letterSprite = new FlxSprite(0, 0);
        letterSprite.frames = Paths.getCustomizableSparrowAtlas('alphabet');
        letterSprite.antialiasing = true;

        for(i in 0...letters.length) {
            var char = letters.charAt(i);
            letterSprite.animation.addByPrefix(char, '$char bold', 24, true);
        }

        add(letterSprite);
    }

    var time:Float = 0;
    public override function update(elapsed:Float) {
        super.update(elapsed);
        time += elapsed;
        if (isMenuItem) {
            var scaledY = FlxMath.remapToRange(targetY, 0, 1, 0, 1.3);

			var h:Float = FlxG.height;
			if (Std.isOfType(FlxG.state, PlayState))
				if (isMenuItem)
					h = PlayState.current.guiSize.y;
			var w:Float = FlxG.width;
			if (Std.isOfType(FlxG.state, PlayState))
				if (isMenuItem)
					w = PlayState.current.guiSize.x;

			if (wentToTargetY) {
				y = FlxMath.lerp(y, (scaledY * 120) + (h * 0.48), 0.16 * 60 * elapsed);
				x = FlxMath.lerp(x, (targetY * 20) + 90, 0.16 * 60 * elapsed);
			} else {
				x = (targetY * 20) + 90 - w;
				// y = (targetY * 20) + 90;
				y = (scaledY * 120) + (h * 0.48);
				wentToTargetY = true;
			}
        }
    }
    public override function draw() {
        var t = text.toUpperCase();
        for(i in 0...t.length) {
            var char = t.charAt(i);
            if (letters.indexOf(char) > -1) {
                letterSprite.animation.play(char);
                if (letterSprite.animation.curAnim != null) letterSprite.animation.curAnim.curFrame = Std.int(time * letterSprite.animation.curAnim.frameRate) % letterSprite.animation.curAnim.frames.length;
                letterSprite.updateHitbox();
                letterSprite.alpha = alpha;
                letterSprite.x = x + (48 * i) + ((48 - letterSprite.width) / 2);
                letterSprite.y = y;
                letterSprite.draw();
            }
        }
    }
}