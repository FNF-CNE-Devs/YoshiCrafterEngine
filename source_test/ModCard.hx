
import lime.utils.Assets;
import openfl.display.BitmapData;
import sys.FileSystem;
import flixel.addons.ui.*;

class ModCard extends FlxUITabMenu {
    var m:ModConfig;

    var mod_name:FlxUIText;
    var mod_desc:FlxUIText;
    var mod_icon:FlxUISprite;

    public var mod:String;
    public override function new(modFolder:String, mod:ModConfig) {
        this.mod = modFolder;
        super(
            null,
            [
                {name: "mod", label: 'Mod Card'}
            ]
        );
        this.resize(640, 222);
		var tab = new FlxUI(null, this);
		tab.name = "mod";

        mod_name = new FlxUIText(10, 10, 620, "Mod Name", 16);
        mod_desc = new FlxUIText(170, mod_name.y + mod_name.height + 10, 460, "Mod Description");
        mod_icon = new FlxUISprite(10, mod_name.y + mod_name.height + 10);
        mod_icon.makeGraphic(150, 150, 0xFF000000);
        tab.add(mod_name);
        tab.add(mod_desc);
        tab.add(mod_icon);
        this.addGroup(tab);
        updateMod(mod);
    }

    public function updateMod(mod:ModConfig) {
        m = mod;
        mod_name.text = mod.name != null ? mod.name : this.mod;
        mod_desc.text = mod.description != null ? mod.description : "(No description)";
        // var iconPath = '${Paths.modsPath}/${this.mod}/modIcon.png';
		var asset = Paths.getPath('modIcon.png', IMAGE, 'mods/${this.mod}');
        mod_icon.loadGraphic(Assets.exists(asset) ? asset : Paths.image("modEmptyIcon", "preload"));
        mod_icon.setGraphicSize(150, 150);
        mod_icon.updateHitbox();
    }

}