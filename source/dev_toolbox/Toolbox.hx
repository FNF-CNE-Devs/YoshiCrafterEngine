package dev_toolbox;

import openfl.display.PNGEncoderOptions;
import openfl.display.BitmapData;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;

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
        var modFolder = '${Paths.modsPath}/$folderName';
        FileSystem.createDirectory(modFolder);
        File.saveContent('$modFolder/config.json', Json.stringify(config, "\t"));
        File.saveContent('$modFolder/song_conf.json', Json.stringify(Templates.songConfTemplate, "\t"));
        
        var reader = ZipUtils.openZip("./assets/misc/template_mod.zip");
        ZipUtils.uncompressZip(reader, '$modFolder/');
        
        if (modIcon != null)        sys.io.File.saveBytes('$modFolder/modIcon.png', modIcon.encode(modIcon.rect, new PNGEncoderOptions(true)));
        if (titlebarIcon != null)   sys.io.File.saveBytes('$modFolder/icon.png', titlebarIcon.encode(titlebarIcon.rect, new PNGEncoderOptions(true)));
        
        ModSupport.reloadModsConfig();
        ModSupport.modConfig[folderName] = config;
    }
}