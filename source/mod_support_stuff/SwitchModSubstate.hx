package mod_support_stuff;

import EngineSettings.Settings;
import flixel.FlxSprite;
import flixel.FlxG;
import openfl.utils.Assets;
import flixel.math.FlxMath;

class SwitchModSubstate extends MusicBeatSubstate {
    var mods:Array<SwitchMod> = [];
    var selected:Int = 0;
    public override function new() {
        super();
    }

    public override function create() {
        super.create();
        cast(add(new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xAA222222)), FlxSprite).scrollFactor.set(0, 0);

        var i:Int = 0;
        for(mod=>config in ModSupport.modConfig) {
            var mIcon = Paths.getPath('modIcon.png', IMAGE, 'mods/$mod');
            if (!Assets.exists(mIcon)) mIcon = Paths.image("modEmptyIcon", "preload");
            
            var m = new SwitchMod(0, 0, mod, config.name != null ? config.name : mod, mIcon);
            m.alpha = 0.4; // not selected
            mods.push(m);
            add(m);

            i++;
        }
    }

    public override function update(elapsed) {
        super.update(elapsed);
        for(k=>m in mods) {
            m.x = FlxMath.lerp(m.x, 175 + (k - selected) * 25, CoolUtil.wrapFloat(0.16 * 60 * elapsed, 0, 1));
            m.y = FlxMath.lerp(m.y, ((FlxG.height / 2) + (k - selected) * 185) - 75, CoolUtil.wrapFloat(0.16 * 60 * elapsed, 0, 1));
            m.alpha = FlxMath.lerp(m.alpha, ((k == selected) ? 1 : 0.4), CoolUtil.wrapFloat(0.16 * 60 * elapsed, 0, 1));
            
        }
        if (controls.UP_P) changeSelection(-1);
        if (controls.DOWN_P) changeSelection(1);
        if (controls.ACCEPT) {
            if (Std.isOfType(FlxG.state, TitleState)) TitleState.initialized = false;
            if (FlxG.sound.music != null) {
                FlxG.sound.music.fadeOut(0.25, 0);
                FlxG.sound.music.persist = false;
            }
            CoolUtil.playMenuSFX(1);
            Settings.engineSettings.data.selectedMod = mods[selected].modDataName;
            close();
            FlxG.resetState();
            return;
        }
        if (controls.BACK) {
            CoolUtil.playMenuSFX(2);
            close();
        }
    }

    public function changeSelection(am:Int) {
        selected += am;
        if (selected < 0) selected = mods.length - 1;
        if (selected >= mods.length) selected = 0;
        if (am != 0) CoolUtil.playMenuSFX(0);
    }
}