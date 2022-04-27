import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

using StringTools;
class AlphabetOptimized extends FlxSpriteGroup {
    public var frameOffset:Float = 0;
    public static inline var letters:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    public var textColor:FlxColor = 0xFFFFFFFF;
    public var textColorSequences:Map<Int, FlxColor> = null;

    public static var nonBoldLetters:Map<String, String> = [
        "_" => "_",
        "#" => "#",
        "$" => "$",
        "%" => "%",
        "&" => "&",
        "(" => "(",
        ")" => ")",
        "*" => "*",
        "+" => "+",
        "-" => "-",
        "0" => "0",
        "1" => "1",
        "2" => "2",
        "3" => "3",
        "4" => "4",
        "5" => "5",
        "6" => "6",
        "7" => "7",
        "8" => "8",
        "9" => "9",
        ":" => ":",
        ";" => ";",
        "<" => "<",
        ">" => ">",
        "@" => "@",
        "]" => "]",
        "[" => "[",
        "\\" => "\\",
        "`" => "apostraphie",
        "'" => "apostraphie",
        "," => "comma",
        "↓" => "down arrow",
        "\"" => "start parentheses",
        "!" => "exclamation point",
        "/" => "forward slash",
        "❤️" => "heart",
        "←" => "left arrow",
        "×" => "multiply x",
        "?" => "question mark",
        "→" => "right arrow",
        "↑" => "up arrow",
        "|" => "|",
        "~" => "~",

        "😡" => "angry faic", // so that ng emoticon can be used

        "A" => "A capital",
        "B" => "B capital",
        "C" => "C capital",
        "D" => "D capital",
        "E" => "E capital",
        "F" => "F capital",
        "G" => "G capital",
        "H" => "H capital",
        "I" => "I capital",
        "J" => "J capital",
        "K" => "K capital",
        "L" => "L capital",
        "M" => "M capital",
        "N" => "N capital",
        "O" => "O capital",
        "P" => "P capital",
        "Q" => "Q capital",
        "R" => "R capital",
        "S" => "S capital",
        "T" => "T capital",
        "U" => "U capital",
        "V" => "V capital",
        "W" => "W capital",
        "X" => "X capital",
        "Y" => "Y capital",
        "Z" => "Z capital",

        "a" => "a lowercase",
        "b" => "b lowercase",
        "c" => "c lowercase",
        "d" => "d lowercase",
        "e" => "e lowercase",
        "f" => "f lowercase",
        "g" => "g lowercase",
        "h" => "h lowercase",
        "i" => "i lowercase",
        "j" => "j lowercase",
        "k" => "k lowercase",
        "l" => "l lowercase",
        "m" => "m lowercase",
        "n" => "n lowercase",
        "o" => "o lowercase",
        "p" => "p lowercase",
        "q" => "q lowercase",
        "r" => "r lowercase",
        "s" => "s lowercase",
        "t" => "t lowercase",
        "u" => "u lowercase",
        "v" => "v lowercase",
        "w" => "w lowercase",
        "x" => "x lowercase",
        "y" => "y lowercase",
        "z" => "z lowercase"
    ];
    public var text(default, set):String = "";

    private var __ready:Bool = false;
    public function set_text(t:String) {
        if (!__ready) return text = t;
        text = t;
        calculateShit(false);
        return text;
    }
    public var letterSprite:FlxSprite;

    public var isMenuItem:Bool = false;
    public var targetY:Int = 0;

    public var textSize:Float = 1;

    public var bold:Bool = false;

    public var __cacheWidth:Float = 0;
	/**
	 * If false, the Alphabet will go to the target Y without any lerp and set this to true.
	**/
	public var wentToTargetY:Bool = false;

    public override function get_width():Float {
        return __cacheWidth * textSize;
    }
    public function new(x:Float, y:Float, text:String, bold:Bool = true) {
        super();
        this.x = x;
        this.y = y;
        this.text = text;
        this.bold = bold;

        letterSprite = new FlxSprite(0, 0);
        letterSprite.frames = Paths.getCustomizableSparrowAtlas('alphabet');
        letterSprite.antialiasing = true;

        for(i in 0...letters.length) {
            var char = letters.charAt(i);
            letterSprite.animation.addByPrefix('$char bold', '$char bold', 24, true);
        }
        for(k=>e in nonBoldLetters) {
            letterSprite.animation.addByPrefix(e, e, 24, true);
        }

        add(letterSprite);
        __ready = true;
        calculateShit(false);
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
        calculateShit(true);
    }

    public function calculateShit(draw:Bool) {
        if (text == null || text.length <= 0) {
            __cacheWidth = 0;
            return;
        }
        var t = text;
        var w:Float = 0;
        for(i in 0...t.length) {
            var char = t.charAt(i);
            var animName:String = null;

            var color = textColor;
            if (textColorSequences != null) {
                var lastK = -1;
                for(k=>e in textColorSequences) {
                    if (k > lastK && k <= i) {
                        lastK = k;
                        color = e;
                    }
                }
            }
            if (bold) {
                char = char.toUpperCase();
                if (letters.indexOf(char) > -1) animName = '$char bold';
            }
            if (animName == null) animName = nonBoldLetters[char];

            if (animName != null && animName.trim() != "" && char.trim() != "") {
                letterSprite.animation.play(animName);
                if (letterSprite.animation.curAnim != null) {
                    letterSprite.animation.curAnim.curFrame = Std.int(time * letterSprite.animation.curAnim.frameRate) % letterSprite.animation.curAnim.frames.length;
                }
                if (bold) {
                    letterSprite.colorTransform.redMultiplier = 1;
                    letterSprite.colorTransform.greenMultiplier = 1;
                    letterSprite.colorTransform.blueMultiplier = 1;
                    letterSprite.colorTransform.redOffset = 0;
                    letterSprite.colorTransform.greenOffset = 0;
                    letterSprite.colorTransform.blueOffset = 0;
                } else {
                    letterSprite.colorTransform.redMultiplier = 0;
                    letterSprite.colorTransform.greenMultiplier = 0;
                    letterSprite.colorTransform.blueMultiplier = 0;
                    letterSprite.colorTransform.redOffset = color.red;
                    letterSprite.colorTransform.greenOffset = color.green;
                    letterSprite.colorTransform.blueOffset = color.blue;
                }
                letterSprite.scale.set(textSize, textSize);
                letterSprite.updateHitbox();
                letterSprite.alpha = alpha;
                letterSprite.x = x + w;
                letterSprite.y = y + ((70 * textSize) - letterSprite.height);
                if (draw) letterSprite.draw();
                w += letterSprite.width;
                if (letterSprite.animation.curAnim != null) w += letterSprite.frames.frames[letterSprite.animation.curAnim.frames[0]].offset.x;
            } else {
                w += 48 * textSize;
            }
            
        }
        __cacheWidth = letterSprite.x + letterSprite.width - x;
    }
}