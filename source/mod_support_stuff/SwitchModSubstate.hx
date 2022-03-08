package mod_support_stuff;

import flixel.FlxSprite;
import flixel.FlxG;

class SwitchModSubstate extends MusicBeatSubstate {
    public override function new() {
        super();
    }

    public override function create() {
        super.create();
        cast(add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000)), FlxSprite).scrollFactor.set(0, 0);
    }
}