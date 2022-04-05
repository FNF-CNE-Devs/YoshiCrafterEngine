package charter;

import flixel.addons.ui.*;
import flixel.group.FlxSpriteGroup;

class ChooseCharacterScreen extends MusicBeatSubstate {
    public var modsScroll:FlxSpriteGroup;
    public override function create() {
        super.create();
        modsScroll = new FlxSpriteGroup(-300, 0);
        
        var i:Int = 0;
        for(k=>m in ModSupport.modConfig) {
            i++;
            var button = new FlxUIButton(0, 0 + (i * 20), ModSupport.getModName(k));
            button.scrollFactor.set();
            modsScroll.add(button);
        }
        add(modsScroll);

    }

    public function changeSecondMenu(mod:String) {
        trace(mod);
    }
}