import flixel.text.FlxText;
import flixel.FlxSprite;

interface TaggedElement {
    public var tag:String;
}

class FlxTagSprite extends FlxSprite implements TaggedElement { public var tag:String; }
class FlxTagText extends FlxText implements TaggedElement { public var tag:String; }