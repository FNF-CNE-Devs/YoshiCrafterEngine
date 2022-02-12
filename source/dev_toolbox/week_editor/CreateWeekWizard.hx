package dev_toolbox.week_editor;

import dev_toolbox.toolbox_tabs.WeeksTab;
import StoryMenuState.FNFWeek;
import openfl.desktop.ClipboardTransferMode;
import openfl.desktop.ClipboardFormats;
import openfl.desktop.Clipboard;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import dev_toolbox.file_explorer.FileExplorer;
import flixel.FlxG;
import flixel.addons.ui.*;

using StringTools;

class CreateWeekWizard extends MusicBeatSubstate {
    // var state:ToolboxHome;
    public override function new(whenDone:Void->Void, state:WeeksTab) {
        super();
        // state = cast(FlxG.state, ToolboxHome);

        add(new FlxSprite(0, 0).makeGraphic(1280, 720, 0x88000000));

        var tabs = new FlxUITabMenu(null, [
            {
                name: "tab",
                label: "New Week Wizard"
            }
        ], true);

        var tab = new FlxUI(null, tabs);
        tab.name = "tab";

        var labels = [];
        var label = new FlxUIText(10, 10, 620, "Week Name");
        labels.push(label);
        var weekName = new FlxUIInputText(10, label.y + label.height, 620, "YOUR WEEK NAME");

        var label = new FlxUIText(10, weekName.y + weekName.height + 10, 620, "Week Tracks (separate with \",\")");
        labels.push(label);
        var weekTracks = new FlxUIInputText(10, label.y + label.height, 620, "");

        var label = new FlxUIText(10, weekTracks.y + weekTracks.height + 10, 620, "Button Sprite");
        labels.push(label);
        var bSpritePath = "";
        var buttonSprite:FlxUIButton = null;
        buttonSprite = new FlxUIButton(10, label.y + label.height, "(Browse...) None", function() {
            openSubState(new FileExplorer(ToolboxHome.selectedMod, FileExplorerType.Bitmap, "", function(p) {
                bSpritePath = p;
                buttonSprite.label.text = '(Browse...) $p';
            }));
        });
        buttonSprite.resize(620, 20);
        buttonSprite.label.alignment = LEFT;

        var colorThingy:FlxUISprite = new FlxUISprite(10, buttonSprite.y + buttonSprite.height + 10);
        colorThingy.makeGraphic(80, 50);
        colorThingy.pixels.lock();
        for (x in 0...colorThingy.pixels.width) {
            colorThingy.pixels.setPixel32(x, 0, 0xFF000000);
            colorThingy.pixels.setPixel32(x, 1, 0xFF000000);
            colorThingy.pixels.setPixel32(x, 48, 0xFF000000);
            colorThingy.pixels.setPixel32(x, 49, 0xFF000000);
        }
        for (y in 0...colorThingy.pixels.height) {
            colorThingy.pixels.setPixel32(0, y, 0xFF000000);
            colorThingy.pixels.setPixel32(1, y, 0xFF000000);
            colorThingy.pixels.setPixel32(78, y, 0xFF000000);
            colorThingy.pixels.setPixel32(79, y, 0xFF000000);
        }
        colorThingy.pixels.unlock();
        colorThingy.color = 0xFFF9CF51;
        var chooseColorButton:FlxUIButton = new FlxUIButton(10, colorThingy.y + colorThingy.height, "Change color...", function() {
            openSubState(new ColorPicker(colorThingy.color, function(c) {
                colorThingy.color = c;
            }));
        });

        var label = new FlxUIText(colorThingy.x + colorThingy.width + 10, colorThingy.y, 610 - colorThingy.width, "Character File");
        labels.push(label);
        var charFilePath:String = "";
        var charFile:FlxUIButton = null;
        charFile = new FlxUIButton(colorThingy.x + colorThingy.width + 10, label.y + label.height, "(Browse...) None", function() {
            openSubState(new FileExplorer(ToolboxHome.selectedMod, FileExplorerType.SparrowAtlas, "", function(p) {
                charFilePath = p;
                charFile.label.text = '(Browse...) $p';
            }));
        });
        charFile.resize(610 - colorThingy.width, 20);
        charFile.label.alignment = LEFT;
        var label = new FlxUIText(colorThingy.x + colorThingy.width + 10, charFile.y + charFile.height + 10, 520 - colorThingy.width, "Character Animation name");
        labels.push(label);
        var charAnimName = new FlxUIInputText(label.x, label.y + label.height, Std.int(520 - colorThingy.width), "");
        var redFlickerAnim:FlxTween = null;
        var animPaste:FlxUIButton = null;
        animPaste = new FlxUIButton(charAnimName.x + charAnimName.width + 10, charAnimName.y, "Paste", function() {
            var c = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT, ClipboardTransferMode.CLONE_PREFERRED);
            if (c == null) {
                if (redFlickerAnim != null) redFlickerAnim.destroy();
                redFlickerAnim = FlxTween.color(animPaste, 1, 0xFFFF4444, 0xFFFFFFFF);
            } else {
                charAnimName.text = c;
            }
        });
        var addButton = new FlxUIButton(320, animPaste.y + animPaste.height + 10, "Create", function() {
            if (weekName.text == "") {
                openSubState(ToolboxMessage.showMessage("Error", "You need to enter a week name."));
                return;
            }
            var songs = [for (e in weekTracks.text.split(",")) if (e.trim() != "") e.trim()];
            if (songs.length == 0) {
                openSubState(ToolboxMessage.showMessage("Error", "You need to add at least one song."));
                return;
            }
            if (bSpritePath.trim() == "") {
                openSubState(ToolboxMessage.showMessage("Error", "You haven't selected any button sprite."));
                return;
            }
            if (charFilePath.trim() == "") {
                openSubState(ToolboxMessage.showMessage("Error", "You haven't selected any character menu spritesheet."));
                return;
            }
            if (charAnimName.text.trim() == "") {
                openSubState(ToolboxMessage.showMessage("Error", "You haven't passed any character animation name."));
                return;
            }
            var w:FNFWeek = {
                name: weekName.text.trim(),
                songs: songs,
                mod: ToolboxHome.selectedMod,
                buttonSprite: bSpritePath,
                color: colorThingy.color.toWebString(),
                dad: {
                    file: charFilePath,
                    animation: charAnimName.text.trim(),
                    scale: 1,
                    flipX: false,
                    offset: [0, 0]
                },
                difficulties: [
                    {name: "Easy",   sprite: "Friday Night Funkin':storymenu/easy"},
                    {name: "Normal", sprite: "Friday Night Funkin':storymenu/normal"},
                    {name: "Hard",   sprite: "Friday Night Funkin':storymenu/hard"}
                ]
            };
            state.weekJson.weeks.push(w);
            var color = colorThingy.color.toWebString();
            close();
            whenDone();
        });
        addButton.x -= addButton.width / 2;

        for(l in labels) tab.add(l);
        tab.add(weekName);
        tab.add(weekTracks);
        tab.add(buttonSprite);
        tab.add(colorThingy);
        tab.add(chooseColorButton);
        tab.add(charFile);
        tab.add(charAnimName);
        tab.add(animPaste);
        tab.add(addButton);

        tabs.addGroup(tab);
        tabs.resize(640, addButton.y + 50);
        tabs.screenCenter();
        add(tabs);

        var closeButton = new FlxUIButton(tabs.x + tabs.width - 23, tabs.y + 3, "X", function() {
            close();
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = 0xFFFFFFFF;
        closeButton.scrollFactor.set();
        add(closeButton);
    }
}