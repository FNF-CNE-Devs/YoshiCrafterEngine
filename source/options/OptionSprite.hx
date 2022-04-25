package options;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class OptionSprite extends FlxSpriteGroup {
    public var name:String = "";
    public var desc:String = "";
    public var _nameAlphabet:AlphabetOptimized;
    public var _descAlphabet:AlphabetOptimized;
    public var _icon:FlxSprite;
    public function new(option:FunkinOption) {
        super();
        name = option.name;
        desc = option.desc;
        _nameAlphabet = new AlphabetOptimized(150, 0, option.name, true);
        _nameAlphabet.textSize = 0.75;
        add(_nameAlphabet);
        _descAlphabet = new AlphabetOptimized(155, 60, option.desc, false);
        _descAlphabet.textSize = 1 / 3;
        add(_descAlphabet);
        _icon = new FlxSprite(40, 0).makeGraphic(100, 100, 0xFFFFFFFF);
        _icon.setGraphicSize(100, 100);
        _icon.updateHitbox();
        _icon.antialiasing = true;
        add(_icon);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        _nameAlphabet.text = name;
        _descAlphabet.text = desc;
    }
}