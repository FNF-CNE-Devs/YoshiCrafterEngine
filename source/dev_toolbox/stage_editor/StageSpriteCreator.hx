package dev_toolbox.stage_editor;

import Stage.StageSprite;
import sys.FileSystem;
import flixel.util.FlxColor;
import haxe.io.Path;
import dev_toolbox.file_explorer.FileExplorer;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.*;

using StringTools;

class StageSpriteCreator extends MusicBeatSubstate {
    var state:StageEditor;

    var tabs:FlxUITabMenu;
    var tabWidth:Int = Std.int(FlxG.width / 2);
    var tabHeight:Int = Std.int(FlxG.height / 2);

    public override function new(state:StageEditor) {
        super();
        this.state = state;
        cameras = [state.dummyHUDCamera, state.camHUD];

        var bg = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000);
        add(bg);
        
        tabs = new FlxUITabMenu(null, [
            {
                name: "Bitmap",
                label: "Bitmap"
            },
            {
                name: "SparrowAtlas",
                label: "Sparrow Atlas"
            }
        ], true);

        addBitmapTab();
        addSparrowTab();

        tabs.resize(tabWidth, tabHeight);
        tabs.screenCenter();
        tabs.y += 10;

        var uselessBGButton = new FlxUIButton(tabs.x, tabs.y - 20, "Add a sprite");
        uselessBGButton.resize(tabWidth, 40);
        uselessBGButton.screenCenter(X);
        uselessBGButton.active = false;
        uselessBGButton.color = FlxColor.fromRGB(181, 181, 181);
        uselessBGButton.label.offset.y = -5;
        uselessBGButton.label.color = 0xFFFFFFFF;
        add(uselessBGButton);
        add(tabs);

        var closeButton = new FlxUIButton(tabs.x + tabs.width - 20, tabs.y - 20, "X", function() {
            close();
        });
        closeButton.color = 0xFFFF4444;
        closeButton.label.color = FlxColor.WHITE;
        closeButton.resize(20, 20);
        add(closeButton);

        trace(tabs);

        for(m in members) if (Std.isOfType(m, FlxSprite)) cast(m, FlxSprite).scrollFactor.set(0, 0);
    }

    function addBitmapTab() {
        var tab = new FlxUI(null, tabs);
        tab.name = "Bitmap";


        var nameLabel:FlxUIText = new FlxUIText(10, 10, tabWidth - 20, "Name");
        var nameTextBox:FlxUIInputText = new FlxUIInputText(10, nameLabel.y + nameLabel.height, tabWidth - 20, "Sprite");

        var pathLabel:FlxUIText = new FlxUIText(10, nameTextBox.y + nameTextBox.height + 10, tabWidth - 20, "Path to the Bitmap");
        var bitmapTabField:FlxUIInputText;
        var browseButton = new FlxUIButton(tabWidth - 10, pathLabel.y + pathLabel.height, "Browse...", function() {
            var fe = new FileExplorer(ToolboxHome.selectedMod, FileExplorerType.Bitmap, "/images", function(p) {
                var splitThing = [for (e in p.split("/")) if (e.trim() != "") e];
                if (splitThing[0].toLowerCase() != "images") {
                    openSubState(ToolboxMessage.showMessage("Error", "The Bitmap must be in the \"images\" folder."));
                } else {
                    bitmapTabField.text = Path.withoutExtension([for (i in 1...splitThing.length) splitThing[i]].join("/"));
                }
            });
            fe.cameras = [state.dummyHUDCamera, state.camHUD];
            for(m in fe.members) if (Std.isOfType(m, FlxSprite)) cast(m, FlxSprite).scrollFactor.set(0, 0);
            openSubState(fe);
        });
        browseButton.x -= browseButton.width;
        bitmapTabField = new FlxUIInputText(10, browseButton.y, Std.int(tabWidth - 30 - browseButton.width), "");
        browseButton.y += (bitmapTabField.height - browseButton.height) / 2;

        var acceptButton = new FlxUIButton(tabWidth / 2, tabHeight - 50, "Create", function() {
            
            var path = Path.withoutExtension(bitmapTabField.text.trim());
            if (nameLabel.text.trim() == "") {
                showMessage("Error", 'Sprite name cannot be empty.');
                return;
            }
            if (bitmapTabField.text.trim() == "") {
                showMessage("Error", 'No sprite path was entered/selected. Please select one.');
                return;
            }
            if (!FileSystem.exists('${Paths.modsPath}/${ToolboxHome.selectedMod}/images/${path}.png')) {
                showMessage("Error", 'The Bitmap at the path "${Paths.modsPath}/${ToolboxHome.selectedMod}/images/${path}.png" does not exist.');
                return;
            }
            for(s in state.stage.sprites) {
                // CaSe SeNsItIvE
                if (s.name.trim() == nameTextBox.text.trim()) {
                    showMessage("Error", 'Another sprite with that name already exists.');
                    return;
                }
            }
            state.stage.sprites.push({
                type: "Bitmap",
                scrollFactor: [1, 1],
                name: nameTextBox.text.trim(),
                src: path
            });
            state.updateStageElements();
            close();
        });
        acceptButton.x -= acceptButton.width / 2;


        tab.add(nameLabel);
        tab.add(nameTextBox);

        tab.add(pathLabel);
        tab.add(bitmapTabField);
        tab.add(browseButton);

        tab.add(acceptButton);

        tabs.addGroup(tab);
        //  = 
    }

    function addSparrowTab() {
        var tab = new FlxUI(null, tabs);
        tab.name = "SparrowAtlas";


        var nameLabel:FlxUIText = new FlxUIText(10, 10, tabWidth - 20, "Name");
        var nameTextBox:FlxUIInputText = new FlxUIInputText(10, nameLabel.y + nameLabel.height, tabWidth - 20, "Sprite");

        var pathLabel:FlxUIText = new FlxUIText(10, nameTextBox.y + nameTextBox.height + 10, tabWidth - 20, "Path to the Sparrow");
        var bitmapTabField:FlxUIInputText;
        var browseButton = new FlxUIButton(tabWidth - 10, pathLabel.y + pathLabel.height, "Browse...", function() {
            var fe = new FileExplorer(ToolboxHome.selectedMod, FileExplorerType.SparrowAtlas, "/images", function(p) {
                var splitThing = [for (e in p.split("/")) if (e.trim() != "") e];
                if (splitThing[0].toLowerCase() != "images") {
                    openSubState(ToolboxMessage.showMessage("Error", "The Sparrow Atlas must be in the \"images\" folder."));
                } else {
                    bitmapTabField.text = Path.withoutExtension([for (i in 1...splitThing.length) splitThing[i]].join("/"));
                }
            });
            fe.cameras = [state.dummyHUDCamera, state.camHUD];
            for(m in fe.members) if (Std.isOfType(m, FlxSprite)) cast(m, FlxSprite).scrollFactor.set(0, 0);
            openSubState(fe);
        });
        browseButton.x -= browseButton.width;
        bitmapTabField = new FlxUIInputText(10, browseButton.y, Std.int(tabWidth - 30 - browseButton.width), "");
        browseButton.y += (bitmapTabField.height - browseButton.height) / 2;

        var acceptButton = new FlxUIButton(tabWidth / 2, tabHeight - 50, "Create", function() {
            var path = Path.withoutExtension(bitmapTabField.text.trim());
            if (nameLabel.text.trim() == "") {
                showMessage("Error", 'Sprite name cannot be empty.');
                return;
            }
            if (bitmapTabField.text.trim() == "") {
                showMessage("Error", 'No sprite path was entered/selected. Please select one.');
                return;
            }
            if (!FileSystem.exists('${Paths.modsPath}/${ToolboxHome.selectedMod}/images/$path.png')) {
                showMessage("Error", 'The Sparrow Atlas PNG at the path "${Paths.modsPath}/${ToolboxHome.selectedMod}/images/$path.png" does not exist.');
                return;
            }
            if (!FileSystem.exists('${Paths.modsPath}/${ToolboxHome.selectedMod}/images/$path.xml')) {
                showMessage("Error", 'The Sparrow Atlas XML at the path "${Paths.modsPath}/${ToolboxHome.selectedMod}/images/$path.xml" does not exist.');
                return;
            }
            for(s in state.stage.sprites) {
                // CaSe SeNsItIvE
                if (s.name.trim() == nameTextBox.text.trim()) {
                    showMessage("Error", 'Another sprite with that name already exists.');
                    return;
                }
            }
            state.stage.sprites.push({
                type: "SparrowAtlas",
                scrollFactor: [1, 1],
                name: nameTextBox.text.trim(),
                src: path,
                animation: {
                    type: "Loop",
                    name: "",
                    fps: 24
                }
            });
            state.updateStageElements();
            close();
        });
        acceptButton.x -= acceptButton.width / 2;


        tab.add(nameLabel);
        tab.add(nameTextBox);

        tab.add(pathLabel);
        tab.add(bitmapTabField);
        tab.add(browseButton);

        tab.add(acceptButton);

        tabs.addGroup(tab);
        //  = 
    }

    function showMessage(title:String, text:String) {
        var m = ToolboxMessage.showMessage(title, text);
        m.cameras = cameras;
        openSubState(m);
    }
}