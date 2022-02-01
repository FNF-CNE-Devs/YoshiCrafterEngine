package dev_toolbox.toolbox_tabs;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

class ToolboxTab extends FlxSpriteGroup {
    var state:ToolboxHome;
    public function new(x:Float, y:Float) {
        super(x, y);
        state = cast(FlxG.state, ToolboxHome);
    }

    public function onTabExit() {

    }

    public function tabUpdate(elapsed:Float) {

    }

    public function onTabEnter() {

    }
}