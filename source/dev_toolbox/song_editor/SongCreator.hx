package dev_toolbox.song_editor;

import haxe.io.Path;
import flixel.FlxSprite;
import flixel.addons.ui.*;

class SongCreator extends MusicBeatSubstate {
    public override function new() {
        var tabMenu = new FlxUITabMenu(null, [
            {
                name: "add",
                label: "Add a song"
            }
        ], true);
        tabMenu.resize(500, 720);
        var tab = new FlxUI(null, tabMenu);
        
        var labels:Array<FlxUIText> = [];

        var label = new FlxUIText(10, 10, 480, "Song Name");
        labels.push(label);
        var songName = new FlxUIInputText(10, label.y + label.height, 480, "");
        tab.add(songName);

        var label = new FlxUIText(10, 10, 480, "Song Instrumental");
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
                songInst.label.text = "(Browse...) Vocals selected.";
            });
        });
        songInst.resize(480, 20);
        tab.add(songInst);

        var label = new FlxUIText(10, 10, 480, "Song Voices (optionnal but recommended)");
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
        tab.add(songVoices);

        tabMenu.addGroup(tab);
        add(tabMenu);
        super();
    }
}