package dev_toolbox;

import cpp.abi.Abi;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIPopup;

typedef Button = {
    var label:String;
    var onClick:ToolboxMessage->Void;
};
class ToolboxMessage extends FlxUIPopup {
    var buttons:Array<Button> = [];
    public override function new(title:String, text:String, buttons:Array<Button>, ?bgColor:FlxColor) {
        super(bgColor);
        quickSetup(title, text, [for(b in buttons) b.label]);
        this.buttons = buttons;
    }

    public override function getEvent(id:String, target:Dynamic, data:Dynamic, ?params:Array<Dynamic>):Void
    {
        if (params != null)
        {
            if (id == "click_button")
            {
                buttons[params[0]].onClick(this);
                close();
            }
        }
    }

    public static function showMessage(title:String, text:String, ?callback:Void->Void) {
        return new ToolboxMessage(title, text, [
            {
                label : "OK",
                onClick: function(toolboxMessage) {
                    if (callback != null) callback();
                }
            }
        ]);
    }
}