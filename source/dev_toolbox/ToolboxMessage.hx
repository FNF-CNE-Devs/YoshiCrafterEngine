package dev_toolbox;

import flixel.addons.ui.*;
import flixel.FlxCamera;
import flixel.util.FlxColor;

typedef Button = {
    var label:String;
    var onClick:ToolboxMessage->Void;
};
class ToolboxMessage extends MusicBeatSubstate {
    var buttons:Array<Button> = [];
    public override function new(title:String, text:String, buttons:Array<Button>, ?bgColor:FlxColor, ?camera:FlxCamera) {
        super();
        if (camera != null) this.camera = camera;

        var bg = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
        bg.alpha = 0.5;
        bg.scale.set(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.scrollFactor.set();
        add(bg);

        var UI_Tabs = new FlxUITabMenu(null, 
            [
                {
                    name: 'name',
                    label: title
                }
            ], true );
        var tab = new FlxUI(null, UI_Tabs);
        tab.name = "name";

        var text = new FlxUIText(10, 10, Std.int(FlxG.width / 3) - 20, text);

        var y = text.y + text.height + 10;
        var maxButtonWidth = Std.int((Std.int(FlxG.width / 3) - 20 - (Math.max(0, buttons.length - 1) * 10)) / buttons.length);
        for(i=>button in buttons) {
            // HAHAHAHAHAHAHAH butt
            var butt = new FlxUIButton(0, y, button.label, function() {
                close();
                button.onClick(this);
            });
            butt.x = Std.int(10 + (maxButtonWidth * (i + 0.5))) + (i * 10);
            butt.resize(Std.int(maxButtonWidth), 20);
            butt.x -= butt.width / 2;
            tab.add(butt);
        }

        tab.add(text);

        UI_Tabs.addGroup(tab);
        UI_Tabs.resize(FlxG.width / 3, 50 + y); // TODO
        UI_Tabs.scrollFactor.set();
        UI_Tabs.screenCenter();
        add(UI_Tabs);

        this.buttons = buttons;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
    }

    public static function showMessage(title:String, text:String, ?callback:Void->Void, ?camera:FlxCamera) {
        return new ToolboxMessage(title, text, [
            {
                label : "OK",
                onClick: function(toolboxMessage) {
                    if (callback != null) callback();
                }
            }
        ], null, camera);
    }
}