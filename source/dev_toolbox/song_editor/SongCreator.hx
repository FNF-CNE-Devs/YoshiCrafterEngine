package dev_toolbox.song_editor;

import haxe.io.Path;
import flixel.FlxSprite;
import flixel.addons.ui.*;
import sys.FileSystem;
import flixel.FlxG;
import dev_toolbox.ToolboxHome;

using StringTools;

class SongCreator extends MusicBeatSubstate {
    public override function new() {
        super();

        add(new FlxSprite(0, 0).makeGraphic(1280, 720, 0x88000000));

        var tabMenu = new FlxUITabMenu(null, [
            {
                name: "add",
                label: "Add a song"
            }
        ], true);
        tabMenu.resize(500, 720);
        var tab = new FlxUI(null, tabMenu);
        tab.name = "add";
        
        var labels:Array<FlxUIText> = [];

        var label = new FlxUIText(10, 10, 480, "Song Name");
        labels.push(label);
        var songName = new FlxUIInputText(10, label.y + label.height, 480, "");

        var label = new FlxUIText(10, songName.y + songName.height + 10, 480, "Song Display Name (leave blank for none)");
        labels.push(label);
        var songDisplayName = new FlxUIInputText(10, label.y + label.height, 480, "");

        var label = new FlxUIText(10, songDisplayName.y + songDisplayName.height + 10, 480, "Song Instrumental");
        labels.push(label);
        var instPath = "";
        var songInst:FlxUIButton = null;
        songInst = new FlxUIButton(10, label.y + label.height, "Browse...", function() {
            CoolUtil.openDialogue(OPEN, "Choose your song's instrumental (.ogg)", function(t) {
                if (Path.extension(t).toLowerCase() != "ogg") {
                    songInst.color = 0xFFFF4444;
                    songInst.label.text = "(Browse...) File must be in .ogg format.";
                    instPath = "";
                    return;
                }
                instPath = t;
                songInst.color = 0xFF44FF44;
                songInst.label.text = "(Browse...) Inst selected.";
            });
        });
        songInst.resize(480, 20);

        var label = new FlxUIText(10, songInst.y + songInst.height + 10, 480, "Song Voices (optionnal but recommended)");
        labels.push(label);
        var songVoices:FlxUIButton = null;
        var voicesPath = "";
        songVoices = new FlxUIButton(10, label.y + label.height, "Browse...", function() {
            CoolUtil.openDialogue(OPEN, "Choose your song's voices (.ogg)", function(t) {
                if (Path.extension(t).toLowerCase() != "ogg") {
                    songVoices.color = 0xFFFF4444;
                    songVoices.label.text = "(Browse...) File must be in .ogg format.";
                    voicesPath = "";
                    return;
                }
                voicesPath = t;
                songVoices.color = 0xFF44FF44;
                songVoices.label.text = "(Browse...) Vocals selected.";
            });
        });
        songVoices.resize(480, 20);

        var label = new FlxUIText(10, songVoices.y + songVoices.height + 10, 480, "Song Difficulties (seperate using \",\")");
        labels.push(label);
        var difficulties = new FlxUIInputText(10, label.y + label.height, 480, "Easy, Normal, Hard");

        var label = new FlxUIText(10, difficulties.y + difficulties.height + 10, 480, "Freeplay Character Icon");
        labels.push(label);
        var fpIcon = new FlxUIInputText(10, label.y + label.height, 480, "bf");

        var validateButton = new FlxUIButton(250, fpIcon.y + fpIcon.height + 10, "Create", function() {
            if (songName.text.trim() == "") {
                openSubState(ToolboxMessage.showMessage("Error", "The song name cannot be empty."));
                return;
            }
            if (FileSystem.exists('${Paths.getModsFolder()}\\${ToolboxHome.selectedMod}\\songs\\${songName.text.trim()}\\')) {
                openSubState(ToolboxMessage.showMessage("Error", "The song already exists."));
                return;
            }
            if (instPath.trim() == "") {
                openSubState(ToolboxMessage.showMessage("Error", "You haven't selected any instrumental OGG file or the file is invalid."));
                return;
            }
            if (fpIcon.trim() == "") {
                openSubState(ToolboxMessage.showMessage("Error", "A Freeplay icon character is required."));
                return;
            }
            if (!FileSystem.exists(instPath)) {
                openSubState(ToolboxMessage.showMessage("Error", "The selected instrumental file does not exist."));
                return;
            }
            var home = cast(FlxG.state, dev_toolbox.ToolboxHome);
            home.freeplaySongs[songName] = {
                char: fpIcon.text,
                displayName: songDisplayName.text.trim() == "" ? null : songDisplayName.text.trim(),
                difficulties: difficulties.text,
                color: 0xFFFFFFFF,
                inFreeplayMenu: true
            };
            close();
        });

        for (l in labels) tab.add(l);
        tab.add(songName);
        tab.add(songDisplayName);
        tab.add(songInst);
        tab.add(songVoices);
        tab.add(difficulties);
        tab.add(validateButton);

        tabMenu.resize(500, 30 + validateButton.y + validateButton.height);
        tabMenu.screenCenter();

        tabMenu.addGroup(tab);
        add(tabMenu);

        var closeButton = new FlxUIButton(tabMenu.x + tabMenu.width - 23, tabMenu.y + 3, "X", function() {
            close();
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = 0xFFFFFFFF;
        add(closeButton);
    }
}