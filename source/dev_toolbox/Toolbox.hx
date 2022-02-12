package dev_toolbox;

import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import ModSupport.ModConfig;
using StringTools;

class Toolbox {
    public static var currentMod:String = "Friday Night Funkin'";

    public static var folder_allowedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-' ";
    public static function generateModFolderName(modName:String):String {
        var newString = "";
        for(i in 0...modName.length) {
            if (folder_allowedChars.indexOf(modName.charAt(i)) >= 0)
                newString += modName.charAt(i);
        }
        while(newString.contains("  ")) newString = newString.replace("  ", " ");
        return newString.trim();
    }

    public static function createMod(config:ModConfig, folderName:String, ?modIcon:BitmapData, ?titlebarIcon:BitmapData) {
        FileSystem.createDirectory('${Paths.modsPath}/$folderName');
        File.saveContent('${Paths.modsPath}/$folderName/config.json', Json.stringify(config, "\t"));
        File.saveContent('${Paths.modsPath}/$folderName/song_conf.hx', '// USABLE VARIABLES : song, difficulty\r\n// The "song" variable corresponds to the song\'s name in lower case\r\n// The difficulty variable corresponds to the difficulty name (case sensitive, not in lower case)\r\nscripts = ["Friday Night Funkin\':stages/default_stage"];');
        for (dir in ["characters", "data"]) {
            FileSystem.createDirectory('${Paths.modsPath}/$folderName/$dir');
        }
        if (modIcon != null) {
            sys.io.File.saveBytes('${Paths.modsPath}/$folderName/modIcon.png', modIcon.encode(modIcon.rect, new PNGEncoderOptions(true)));
        }
        if (titlebarIcon != null) {
            sys.io.File.saveBytes('${Paths.modsPath}/$folderName/icon.png', titlebarIcon.encode(titlebarIcon.rect, new PNGEncoderOptions(true)));
        }
        ModSupport.reloadModsConfig();
        ModSupport.modConfig[folderName] = config;
    }
}