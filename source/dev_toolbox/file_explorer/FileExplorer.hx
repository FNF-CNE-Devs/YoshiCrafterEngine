package dev_toolbox.file_explorer;

import flixel.FlxSprite;
import flixel.addons.ui.*;
import cpp.abi.Abi;

enum FileExplorerType {
    Any;
    SparrowAtlas;
    Bitmap;
    XML;
    JSON;
    HScript;
    Lua;
    OGG;
}

class FileExplorer extends MusicBeatSubstate {
    var mod:String;
    var path:String = "";
    var type:FileExplorerType;

    var pathText:FlxUIText;

    public function navigateTo(path:String) {
        this.path = path;
        // TODO
    }

    public override function new(mod:String, type:FileExplorerType, ?defaultFolder:String = "", callback:String->Void) {
        super();
        path = defaultFolder;
        this.mod = mod;

        add(new FlxSprite(0, 0).makeGraphic(1280, 720, 0x88000000));

        var fileType = switch(type) {
            case Any:
                "file";
            case SparrowAtlas:
                "Sparrow atlas";
            case Bitmap:
                "Bitmap (PNG)";
            case XML:
                "XML file";
            case JSON:
                "JSON file";
            case HScript:
                ".hx or .hscript script";
            case Lua:
                ".lua script";
            case OGG:
                "OGG sound";
        }
        var tabThingy = new FlxUITabMenu(null, [
            {
                label: 'Select a $fileType.',
                name: 'explorer'
            }
        ], true);
        tabThingy.resize(1280 * 0.75, 720 * 0.75);

        var tab = new FlxUI(null, tabThingy);
        tab.name = "explorer";

        pathText = new FlxUIText(10, 10, 0, path);





        tab.add(pathText);

        tabThingy.screenCenter();
        tabThingy.addGroup(tab);
        add(tabThingy);
    }
}