package dev_toolbox.toolbox_tabs;

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

class WeeksTab extends ToolboxTab {
    public var weekJson:WeeksJson;
    public var selectedWeek:FNFWeek;
    public var yellowBG:FlxSprite;
    public var txtWeekTitle:FlxText;
    public var bf:MenuCharacter;
    public var scoreText:FlxText;
    // public var blackBG:FlxSprite;
    public var txtTracklist:FlxText;
    public var weekButton:FlxSprite;
    public var menuCharacter:FlxSprite;
    public var weekName:FlxUIInputText;

    var uiX = 190;
    var uiY = 0;
    
    public override function new(x:Float, y:Float, home:ToolboxHome) {
        super(x, y, "weeks", home);

        weekJson = {
            weeks : []
        };
        var weeksPath = '${Paths.modsPath}/${ToolboxHome.selectedMod}/weeks.json';
        if (FileSystem.exists(weeksPath)) {
            weekJson = Json.parse(File.getContent(weeksPath));
        } else {
            File.saveContent(weeksPath, Json.stringify(weekJson));
        }

        
        // blackBG = new FlxSprite(uiX, 0).makeGraphic(Std.int(1280 - uiX), 720, 0xFF000000);
        
        scoreText = new FlxText(uiX + 10, 10, 0, "SCORE: 0", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

        txtWeekTitle = new FlxText(uiX, 10, FlxG.width - uiX, "Select a week...", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

        yellowBG = new FlxSprite(uiX + 0, 56).makeGraphic(Std.int(FlxG.width - uiX), 400, FlxColor.WHITE);
		yellowBG.color = 0xFFF9CF51;

        bf = new MenuCharacter(uiX + (FlxG.width * 0.25) * (2 + 0) - 150, "bf");
        bf.y += 72;
        bf.antialiasing = true;
        bf.setGraphicSize(Std.int(bf.width * 0.9));
        bf.updateHitbox();
        bf.x -= 80;

        weekButton = new FlxSprite(0, yellowBG.y + yellowBG.height + 10);
        weekButton.visible = false;
        weekButton.antialiasing = true;

        txtTracklist = new FlxText(uiX + (FlxG.width * 0.05), yellowBG.height + 100, 0, "TRACKS\n", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = scoreText.font;
		txtTracklist.color = 0xFFe55777;

        // var labels:Array<FlxUIText> = [];
        // var label = new FlxUIText(10, FlxG.height / 2, 300, "Week Name");
        // weekName = new FlxUIInputText(10, label.y + label.height, 300, "");
        

        var radioList = new FlxUIRadioGroup(10, 10, [for (i in 0...weekJson.weeks.length) Std.string(i)], [for(w in weekJson.weeks) w.name.trim() == "" ? "(Untitled)" : w.name], function(id) {
            trace(id);
            selectedWeek = weekJson.weeks[Std.parseInt(id)];
            // trace('${txtTracklist.x}; ${txtTracklist.y}');
            updateWeekInfo();

        }, 25, 280);

        /*
        changeColorButton = new FlxUIButton(10, 10, "Edit week color", function() {
            openSubState(new ColorPicker(FlxColor.fromString(selectedWeek.color), function(c) {
                selectedWeek.color = c.toWebString();
                updateWeekInfo();
            }));
        });
        changeColorButton.y = 1230;
        tab.add(changeColorButton);
        */

        var createWeekButton = new FlxUIButton(10, 670, "Create", function() {
            state.openSubState(new CreateWeekWizard(function() {
                radioList.updateRadios([for (i in 0...weekJson.weeks.length) Std.string(i)], [for(w in weekJson.weeks) w.name.trim() == "" ? "(Untitled)" : w.name]);
                saveFile();
            }, this));
        });
        var deleteWeekButton = new FlxUIButton(createWeekButton.x + createWeekButton.width + 10, 670, "Delete", function() {
            if (selectedWeek == null) return;
            state.openSubState(new ToolboxMessage("Delete Week", 'Are you sure you want to delete the ${selectedWeek.name} week ? This operation is irreversible.', [
                {
                    label: "Yes",
                    onClick: function(e) {
                        weekJson.weeks.remove(selectedWeek);
                        radioList.updateRadios([for (i in 0...weekJson.weeks.length) Std.string(i)], [for(w in weekJson.weeks) w.name.trim() == "" ? "(Untitled)" : w.name]);
                        selectedWeek = null;
                        txtWeekTitle.text = "Select a week...";
                        txtTracklist.text = "TRACKS\n";
                        weekButton.visible = false;
                        remove(menuCharacter);
                    }
                },
                {
                    label: "No",
                    onClick: function(e) {}
                }
            ]));
        });
        menuCharacter = new FlxSprite(0, 0).makeGraphic(1, 1, 0);

        add(radioList);
        add(createWeekButton);
        add(deleteWeekButton);

        // blackBG.y += uiY;
        scoreText.y += uiY;
        txtWeekTitle.y += uiY;
        yellowBG.y += uiY;
        bf.y += uiY;
        txtTracklist.y += uiY;
        weekButton.y += uiY;
        menuCharacter.y += uiY;

        // add(blackBG);
        add(scoreText);
        add(txtWeekTitle);
        add(yellowBG);
        add(bf);
        insert(20000, txtTracklist);
        insert(20001, weekButton);
        insert(20002, menuCharacter);
    }

    public override function tabUpdate(elapsed) {
        super.tabUpdate(elapsed);

        if (selectedWeek != null) {
            if (FlxG.mouse.justReleased) {
                var screenPos = FlxG.mouse.getScreenPosition(FlxG.camera);
                screenPos.x -= uiX;
                if (screenPos.x > 0 && screenPos.x < 400
                 && screenPos.y > yellowBG.y + yellowBG.height) {
                    state.openSubState(new TextInput("Edit Tracks", "Set week tracks (seperate using \",\")", selectedWeek.songs.join(", "), function(t) {
                        selectedWeek.songs = [for(s in t.split(",")) if (s.trim() != "") s.trim()];
                        updateWeekInfo();
                    }));
                } else if (screenPos.x > 0
                    && screenPos.y < yellowBG.y && screenPos.y > 22) {
                        state.openSubState(new TextInput("Edit Week Name", "Write a new week name.", selectedWeek.name, function(t) {
                        selectedWeek.name = t.trim();
                        updateWeekInfo();
                    }));
                } else if (screenPos.x > 457 && screenPos.x < 819
                    && screenPos.y > 465 && screenPos.y < 563) {
                    state.openSubState(new FileExplorer(ToolboxHome.selectedMod, FileExplorerType.Bitmap, "", function(p) {
                        selectedWeek.buttonSprite = p;
                        updateWeekInfo();
                    }));
                } else if (
                    screenPos.x > 0 && screenPos.y > yellowBG.y && screenPos.y < yellowBG.height + yellowBG.y
                ) {
                    if (screenPos.x <= 400) {
                        state.openSubState(new WeekCharacterSettings(this));
                    } else {
                        var c = FlxColor.fromString(selectedWeek.color);
                        if (c == null) c = 0xFFF9CF51;
                        state.openSubState(new ColorPicker(c, function(c) {
                            selectedWeek.color = c.toWebString();
                            updateWeekInfo();
                        }));
                    }
                }
            }
        }
    }

    public override function onTabEnter() {
        state.bg.visible = false;
    }
    public override function onTabExit() {
        state.bg.visible = true;
    }

    public function updateWeekInfo() {
        var w = selectedWeek;
        var path = Paths.getPath(w.buttonSprite, IMAGE, 'mods/${ToolboxHome.selectedMod}');
        // try {
        //     b = Paths.getBitmapOutsideAssets(path);
        // } catch(e) {
        //     trace(e);
        // }
        // if (b == null) b = new BitmapData(10, 10, 0xFF000000);
        weekButton.loadGraphic(path);
        weekButton.x = (2*uiX) + (((FlxG.width - (2*uiX)) / 2) - (weekButton.width / 2));

        txtWeekTitle.text = w.name;

        var stringThing:Array<String> = w.songs;
        var t  = "Tracks\n";
        for (i in stringThing)
        {
            t += "\n" + i;
        }

        t += "\n";
        txtTracklist.text = t.toUpperCase();

        txtTracklist.screenCenter(X);
        txtTracklist.x += uiX;
        txtTracklist.x -= FlxG.width * 0.35;
        txtTracklist.y = yellowBG.height + 100;
        trace(txtTracklist.x);
        trace(txtTracklist.y);
        trace(txtTracklist.pixels.width);
        trace(txtTracklist.pixels.height);
        trace(txtTracklist.scale.x);
        trace(members.indexOf(txtTracklist));
        // add(txtTracklist);

        

        var c = FlxColor.fromString(selectedWeek.color);
        if (c == null) c = 0xFFF9CF51;
        if (state.cTween != null) state.cTween.destroy();
        state.cTween = FlxTween.color(yellowBG, 1, yellowBG.color, c);

        if (menuCharacter != null) {
            remove(menuCharacter);
            menuCharacter.destroy();
        }
        var d = w.dad;
        if (d == null) d = {
                animation: "",
                scale: 1,
                file: "",
                offset: [0, 0],
                flipX: false
            };

		menuCharacter = new FlxSprite(uiX + (FlxG.width * 0.25) - 150, 72 + uiY);
        var sprAtlas = Paths.getSparrowAtlas_Custom('${Paths.modsPath}/${ToolboxHome.selectedMod}/${d.file}', true);
        #if trace_everything trace(sprAtlas); #end
        menuCharacter.frames = sprAtlas;
        menuCharacter.antialiasing = true;
        menuCharacter.animation.addByPrefix("char", d.animation, 24);
        menuCharacter.animation.play("char");
        if (menuCharacter.animation.curAnim == null) {
            menuCharacter.animation.add("undef", [0]);
            menuCharacter.animation.play("undef");
        }
        menuCharacter.flipX = (w.dad.flipX == true); // To prevent null exception thingy
        if (w.dad.scale == 0) w.dad.scale = 1;
        menuCharacter.scale.set(w.dad.scale, w.dad.scale);
        menuCharacter.updateHitbox();
        if (d.offset == null) d.offset = [];
        for(k=>v in d.offset) {
            switch(k) {
                case 0:
                    menuCharacter.offset.x = v;
                case 1:
                    menuCharacter.offset.y = v;
            }
        }
        // remove(blackBG);

        weekButton.visible = true;
        add(menuCharacter);
        remove(txtTracklist);
        add(txtTracklist);
        
        // insert(20001, txtTracklist);

        saveFile();
    }

    function saveFile() {
        File.saveContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/weeks.json', Json.stringify(weekJson, "\t"));
    }
}