package options;

import options.OptionSprite;

typedef FunkinOption = {
    var name:String;
    var desc:String;
    var value:String;
    @:optional var onUpdate:Float->Void;
    @:optional var onCreate:OptionSprite->Void;
    @:optional var img:String;
    @:optional var onSelect:OptionSprite->Void;
}