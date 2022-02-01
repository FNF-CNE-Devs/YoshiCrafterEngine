package dev_toolbox.toolbox_tabs;

import openfl.display.PNGEncoderOptions;
import lime.ui.FileDialogType;
import flixel.addons.transition.FlxTransitionableState;
import dev_toolbox.file_explorer.FileExplorer;
import dev_toolbox.week_editor.WeekCharacterSettings;
import openfl.display.BitmapData;
import flixel.tweens.FlxTween;
using StringTools;

import flixel.util.FlxColor;
import flixel.FlxG;
import dev_toolbox.week_editor.CreateWeekWizard;
import flixel.addons.ui.*;
import haxe.Json;
import sys.io.File;
import flixel.text.FlxText;
import flixel.FlxSprite;
import StoryMenuState.FNFWeek;
import StoryMenuState.WeeksJson;
import sys.FileSystem;

class InfoTab extends ToolboxTab {
    public var card:ModCard;
    
    public function new(x:Float, y:Float, home:ToolboxHome) {
        super(x, y, "info", home);
        var name = ModSupport.modConfig[ToolboxHome.selectedMod].name;
        if (name == null) name = ToolboxHome.selectedMod;
        var desc = ModSupport.modConfig[ToolboxHome.selectedMod].description;
        if (desc == null) desc = "(No description)";
        var title = ModSupport.modConfig[ToolboxHome.selectedMod].titleBarName;
        if (title == null) title = 'Friday Night Funkin\' ${ToolboxHome.selectedMod}';
        
        card = new ModCard(ToolboxHome.selectedMod, ModSupport.modConfig[ToolboxHome.selectedMod]);
        card.screenCenter(Y);
        card.x = 320 + ((1280 - 320) / 2) - (card.width / 2);
        var label = new FlxUIText(10, 10, 300, "Mod name");
        var mod_name = new FlxUIInputText(10, label.y + label.height, 300, name);
        add(label);
        add(mod_name);

		var label = new FlxUIText(10, mod_name.y + mod_name.height + 10, 300, "Mod description");
        var mod_description = new FlxUIInputText(10, label.y + label.height, 300, desc.replace("\r", "").replace("\n", "\\n"));
        add(label);
        add(mod_description);

		var label = new FlxUIText(10, mod_description.y + mod_description.height + 10, 300, "Titlebar Name");
        var titlebarName = new FlxUIInputText(10, label.y + label.height, 300, title);
        add(label);
        add(titlebarName);

        // var icon = new FlxUISprite(520, titlebarName.y).loadGraphic(Paths.image("defaultTitlebarIcon", "preload"));
        // icon.antialiasing = true;
        // icon.setGraphicSize(20, 20);
        // icon.updateHitbox();
        // add(icon);

        // var chooseIconButton = new FlxUIButton(icon.x + 30, icon.y, "Choose game icon", function() {
        //     var fDial = new FileDialog();
		// 	fDial.onSelect.add(function(path) {
		// 		var img = Paths.getBitmapOutsideAssets(path);
        //         if (img == null) return;
        //         icon.loadGraphic(img);
        //         icon.setGraphicSize(20, 20);
        //         icon.updateHitbox();
		// 	});
		// 	fDial.browse(FileDialogType.OPEN, null, null, "Select an icon.");
        // });
        // chooseIconButton.resize(620 - 546, 20);
        // add(chooseIconButton);

        var modIcon = new FlxUISprite(85, titlebarName.y + titlebarName.height + 10)
        .loadGraphic(
            FileSystem.exists('${Paths.getModsFolder()}\\${ToolboxHome.selectedMod}\\modIcon.png')
            ? BitmapData.fromFile('${Paths.getModsFolder()}\\${ToolboxHome.selectedMod}\\modIcon.png')
            : Paths.image("modEmptyIcon", "preload")
        );
        modIcon.setGraphicSize(150, 150);
        modIcon.updateHitbox();
        add(modIcon);

        var chooseIconButton = new FlxUIButton(85, modIcon.y + 160, "Choose a mod icon", function() {
            CoolUtil.openDialogue(FileDialogType.OPEN, "Select an mod icon.", function(path) {
				var img = Paths.getBitmapOutsideAssets(path);
                if (img == null) return;
                modIcon.loadGraphic(img);
                modIcon.setGraphicSize(150, 150);
                modIcon.updateHitbox();
            });
        });
        chooseIconButton.resize(150, 20);
        add(chooseIconButton);

        var saveButton = new FlxUIButton(10, chooseIconButton.y + 30, "Save", function() {
            var e = ModSupport.modConfig[ToolboxHome.selectedMod];
            e.name = mod_name.text;
            e.description = mod_description.text.replace("\\n", "\n");
            e.titleBarName = titlebarName.text;
            File.saveBytes('${Paths.getModsFolder()}\\${ToolboxHome.selectedMod}\\modIcon.png', modIcon.pixels.encode(modIcon.pixels.rect, new PNGEncoderOptions(true)));
            ModSupport.saveModData(ToolboxHome.selectedMod);
            card.updateMod(e);
        });
        saveButton.resize(145, 20);
        add(saveButton);
    }
}