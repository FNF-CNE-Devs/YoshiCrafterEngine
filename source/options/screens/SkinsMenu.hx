package options.screens;

import EngineSettings.Settings;
import sys.FileSystem;

using StringTools;

class SkinsMenu extends OptionScreen {
    public override function create() {

        options = [];

        if (sys.FileSystem.exists(Paths.getSkinsPath() + "/notes/")) {
            var skins:Array<String> = [];
            skins.insert(0, "default");
            var sPath = Paths.getSkinsPath();
            for (f in FileSystem.readDirectory('$sPath/notes/')) {
                if (f.endsWith(".png") && !FileSystem.isDirectory('$sPath/notes/$f')) {
                    var skinName = f.substr(0, f.length - 4);
                    if (FileSystem.exists('$sPath/notes/$skinName.xml')) {
                        skins.push(skinName);
                    }
                }
            }

            if (skins.indexOf(Settings.engineSettings.data.customArrowSkin) == -1) Settings.engineSettings.data.customArrowSkin = "default";
            var pos:Int = skins.indexOf(Settings.engineSettings.data.customArrowSkin);

            options.push({
                name : "Note skin",
                desc : "Select a Note skin from your skins folder.",
                onLeft: function(o) {o.value = Settings.engineSettings.data.customArrowSkin;},
                onUpdate: function(o) {
                    if (controls.RIGHT_P) pos++;
                    if (controls.LEFT_P) pos++;
                    pos %= skins.length;
                    if (pos < 0) pos = skins.length + pos;

                    Settings.engineSettings.data.customArrowSkin = skins[pos];
                    o.value = '< ${Settings.engineSettings.data.customArrowSkin} >';
                },
                value: Settings.engineSettings.data.customArrowSkin
            });
        }
        
        var bfSkins:Array<String> = [for (s in sys.FileSystem.readDirectory(Paths.getSkinsPath() + "/bf/")) if (FileSystem.isDirectory('${Paths.getSkinsPath()}/bf/$s')) s];
        bfSkins.insert(0, "default");
        bfSkins.remove("template");

        if (bfSkins.indexOf(Settings.engineSettings.data.customBFSkin) == -1) Settings.engineSettings.data.customBFSkin = "default";
        var posBF:Int = bfSkins.indexOf(Settings.engineSettings.data.customBFSkin);

        options.push({
            name : "Boyfriend skin",
            desc : "Select a Boyfriend skin from a mod, or from your skins folder.",
            onLeft: function(o) {o.value = Settings.engineSettings.data.customBFSkin;},
            onUpdate: function(o) {
                if (controls.RIGHT_P) posBF++;
                if (controls.LEFT_P) posBF++;
                posBF %= bfSkins.length;
                if (posBF < 0) posBF = bfSkins.length + posBF;

                Settings.engineSettings.data.customBFSkin = bfSkins[posBF];
                o.value = '< ${Settings.engineSettings.data.customBFSkin} >';
            },
            value: Settings.engineSettings.data.customBFSkin
        });
    

        var gfSkins:Array<String> = [for (s in sys.FileSystem.readDirectory(Paths.getSkinsPath() + "/gf/")) if (FileSystem.isDirectory('${Paths.getSkinsPath()}/gf/$s')) s];
        gfSkins.insert(0, "default");
        gfSkins.remove("template");

        var posGF:Int = gfSkins.indexOf(Settings.engineSettings.data.customGFSkin);

        if (gfSkins.indexOf(Settings.engineSettings.data.customGFSkin) == -1) Settings.engineSettings.data.customGFSkin = "default";

        options.push({
            name : "Girlfriend skin",
            desc : "Select a Girlfriend skin from a mod, or from your skins folder.",
            onLeft: function(o) {o.value = Settings.engineSettings.data.customGFSkin;},
            onUpdate: function(o) {
                if (controls.RIGHT_P) posGF++;
                if (controls.LEFT_P) posGF++;
                posGF %= gfSkins.length;
                if (posGF < 0) posGF = gfSkins.length + posGF;

                Settings.engineSettings.data.customGFSkin = gfSkins[posGF];
                o.value = '< ${Settings.engineSettings.data.customGFSkin} >';
            },
            value: Settings.engineSettings.data.customGFSkin
        });
        super.create();
    }
}