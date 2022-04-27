package options;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class OptionSprite extends FlxSpriteGroup {
    public var name:String = "";
    public var desc:String = "";
    public var value:String = "";
    public var _nameAlphabet:AlphabetOptimized;
    public var _descAlphabet:AlphabetOptimized;
    public var _valueAlphabet:AlphabetOptimized;
    public var _icon:FlxSprite;
    public var optionWidth:Int = FlxG.width - 200;
    public var onCreate:OptionSprite->Void = null;
    public var onUpdate:Float->Void = null;
    public var onSelect:OptionSprite->Void = null;
    public function new(option:FunkinOption) {
        super();
        name = option.name;
        desc = option.desc;
        value = option.value;
        _nameAlphabet = new AlphabetOptimized(150, 0, option.name, true);
        _nameAlphabet.textSize = 0.75;
        add(_nameAlphabet);
        _descAlphabet = new AlphabetOptimized(155, 60, option.desc, false);
        _descAlphabet.textSize = 1 / 3;
        add(_descAlphabet);
        _icon = new FlxSprite(40, 0).loadGraphic(option.img);
        _icon.setGraphicSize(100, 100);
        _icon.updateHitbox();
        _icon.antialiasing = true;
        add(_icon);
        _valueAlphabet = new AlphabetOptimized(100, 20, option.value, false);
        _valueAlphabet.textSize = 0.6;
        add(_valueAlphabet);
        onSelect = option.onSelect;
        onUpdate = option.onUpdate;
        if (onCreate != null) onCreate(this);
    }

    public function check(bool:Bool) {
        if (bool) {
            value = "Enabled";
            _valueAlphabet.textColor = 0xFF44FF44;
        } else {
            value = "Disabled";
            _valueAlphabet.textColor = 0xFFFF4444;
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        _nameAlphabet.text = name;
        _descAlphabet.text = desc;
        _valueAlphabet.text = value;
        _valueAlphabet.x = x + (optionWidth) - _valueAlphabet.width;
    }
}