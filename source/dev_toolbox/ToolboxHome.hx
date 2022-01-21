package dev_toolbox;

import Song.SwagSong;
import haxe.io.Path;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.FlxSprite;
import flixel.util.FlxCollision;
import flixel.addons.transition.FlxTransitionableState;
import dev_toolbox.song_editor.SongCreator;
import FreeplayState.FreeplaySongList;
import openfl.display.PNGEncoderOptions;
import sys.io.File;
import openfl.display.BitmapData;
import ModSupport.ModConfig;
import lime.ui.FileDialogType;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.addons.ui.*;
import flixel.FlxG;
import haxe.Json;
import FreeplayState;
import StoryMenuState.WeeksJson;
import flixel.text.FlxText;

using StringTools;

class ToolboxHome extends MusicBeatState {

    public var nonEditableMods:Array<String> = ["Friday Night Funkin'", "YoshiEngine"];

    public static var selectedMod:String = "Friday Night Funkin'";
    public var oldTab:String = "";
    public var bg:FlxSprite;
    public var bgColorTween:FlxTween;
    public var bgTweenColor(default, set):Null<FlxColor>;
    private function set_bgTweenColor(c:Null<FlxColor>) {
        bgTweenColor = c;
        if (bgTweenColor == null) bgTweenColor = 0xFFFFFFFF;
        if (bgColorTween != null) {
            bgColorTween.cancel();
            bgColorTween.destroy();
        }
        bgColorTween = FlxTween.color(bg, 1, bg.color, bgTweenColor, {
            ease : FlxEase.quartInOut
        });
        return c;
    }

    // Characters tab
    public var character:Character = null;
    public var danceTime:Float = 0;
    public var UI_Tabs:FlxUITabMenu;
    public var legend:FlxUIText;
    public var anims_text:FlxUIText;

    public var anims:Array<String> = [];
    public var selectedAnim:Int = 0;

    // Info tab
    public var card:ModCard;

    // Songs tab
    public var songsRadioList:FlxUIRadioGroup;
    public var displayHealthIcon:HealthIcon;
    public var displayAlphabet:Alphabet;
    // var songName:FlxUIInputText;
    var songDisplayName:FlxUIInputText;
    var difficulties:FlxUIInputText;
    var fpIcon:FlxUIInputText;
    var colorPanel:FlxUISprite;
    var songTabThingy:FlxUITabMenu;
    var fpSongToEdit:FreeplaySong;
    public var freeplaySonglist:FreeplaySongList = {
        songs : []
    }

    public override function new(mod:String) {
        if (mod != null) selectedMod = mod;
        super();
        if (ModSupport.modConfig[mod] == null) {
            var conf:ModConfig = {
                name : mod,
                description : "(No description)",
                titleBarName: "Friday Night Funkin' - " + mod,
                keyNumbers: [4],
                BFskins: [],
                GFskins: [],
                skinnableBFs : [],
                skinnableGFs : []
            };
            ModSupport.modConfig[mod] = conf;
        }
        bg = CoolUtil.addWhiteBG(this);
        bgTweenColor = 0xFFFFFFFF;
        var tabs = [
            {name: "info", label: 'Mod Info'},
			{name: "songs", label: 'Songs'},
			{name: "chars", label: 'Characters'},
			{name: "weeks", label: 'Weeks'},
		];
        UI_Tabs = new FlxUITabMenu(null, tabs, true);
        UI_Tabs.x = 0;
        UI_Tabs.resize(320, 720);
        UI_Tabs.screenCenter(Y);
        UI_Tabs.scrollFactor.set();
        add(UI_Tabs);

        addInfo();
        addChars();
        addSongs();
        addWeeks();

        var closeButton = new FlxUIButton(FlxG.width - 23, 3, "X", function() {
            FlxG.switchState(new ToolboxMain());
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = FlxColor.WHITE;
        add(closeButton);
       
		// tab.add(modDropDown);
    }

    public function save() {
        File.saveContent('${Paths.getModsFolder()}\\$selectedMod\\data\\freeplaySonglist.json', Json.stringify(freeplaySonglist, "\t"));
    }
    public function refreshSongs() {
        FileSystem.createDirectory('${Paths.getModsFolder()}\\$selectedMod\\songs\\');   
        FileSystem.createDirectory('${Paths.getModsFolder()}\\$selectedMod\\data\\');
        if (!FileSystem.exists('${Paths.getModsFolder()}\\$selectedMod\\data\\freeplaySonglist.json')) {
            var json:FreeplaySongList = {
                songs : []
            };
            File.saveContent('${Paths.getModsFolder()}\\$selectedMod\\data\\freeplaySonglist.json', Json.stringify(json));
        }
        // var songs = [for (s in FileSystem.readDirectory('${Paths.getModsFolder()}\\$selectedMod\\songs\\')) if (FileSystem.isDirectory('${Paths.getModsFolder()}\\$selectedMod\\songs\\$s\\')) s];
        var displayNames = [];
        freeplaySonglist = try {Json.parse(File.getContent('${Paths.getModsFolder()}\\$selectedMod\\data\\freeplaySonglist.json'));} catch(e) {null;};
        if (freeplaySonglist == null) freeplaySonglist = {songs : []};
        if (freeplaySonglist.songs == null) freeplaySonglist.songs = [];

        for (e in freeplaySonglist.songs) {
            var freeplayThingy:FreeplayState.FreeplaySong = e;

            displayNames.push(freeplayThingy.displayName != null ? freeplayThingy.displayName : freeplayThingy.name);
        }

        songsRadioList.updateRadios([for (e in freeplaySonglist.songs) e.name], displayNames);
    }

    function updateSongTab(s:FreeplaySong, ?replace:Bool = true) {
        if (replace) fpSongToEdit = s;
        if (displayAlphabet != null) {
            remove(displayAlphabet);
            displayAlphabet.destroy();
        }
        if (displayHealthIcon != null) {
            remove(displayHealthIcon);
            displayHealthIcon.destroy();
        }

        songDisplayName.text = s.displayName == null ? "" : s.displayName;
        difficulties.text = s.difficulties.join(", ");
        fpIcon.text = s.char;
        var c:Null<FlxColor> = FlxColor.fromString(s.color);
        if (c == null) c = 0xFFFFFFFF;
        colorPanel.color = c;

        displayAlphabet = new Alphabet(0, 0, s.displayName == null ? s.name : s.displayName, true);
        add(displayAlphabet);
        displayAlphabet.x = 500;
        displayAlphabet.y = 50;
        bgTweenColor = FlxColor.fromString(s.color);
        if (bgTweenColor == null) bgTweenColor = 0xFFFFFFFF;

        displayHealthIcon = new HealthIcon(s.char == null ? "unknown" : s.char, false, selectedMod);
        displayHealthIcon.x = displayAlphabet.x + displayAlphabet.width;
        displayHealthIcon.y = displayAlphabet.y + (displayAlphabet.height / 2) - (displayHealthIcon.height / 2);
        add(displayHealthIcon);
    }
    public function addSongs() {
        var tab = new FlxUI(null, UI_Tabs);
        tab.name = "songs";
        
        songTabThingy = new FlxUITabMenu(null, [
            {
                label: "Song Settings",
                name: "settings"
            }
        ], true);
        songTabThingy.resize(500, 350);
        songTabThingy.x = 320 + ((1280 - 320) / 2) - 250;

        var songSettings = new FlxUI(null, songTabThingy);
        songSettings.name = "settings";

        var labels:Array<FlxUIText> = [];

        // var label = new FlxUIText(10, 10, 480, "Song Name");
        // labels.push(label);
        // songName = new FlxUIInputText(10, label.y + label.height, 480, "");

        var label = new FlxUIText(10, 10, 480, "Song Display Name (leave blank for none)");
        labels.push(label);
        songDisplayName = new FlxUIInputText(10, label.y + label.height, 480, "");

        var label = new FlxUIText(10, songDisplayName.y + songDisplayName.height + 10, 480, "Song Difficulties (seperate using \",\")");
        labels.push(label);
        difficulties = new FlxUIInputText(10, label.y + label.height, 480, "Easy, Normal, Hard");

        var label = new FlxUIText(10, difficulties.y + difficulties.height + 10, 480, "Freeplay Character Icon");
        labels.push(label);
        fpIcon = new FlxUIInputText(10, label.y + label.height, 480, "bf");
        colorPanel = new FlxUISprite(10, fpIcon.y + fpIcon.height + 10);
        colorPanel.makeGraphic(30, 20, 0xFFFFFFFF);
        colorPanel.pixels.lock();
        for (x in 0...colorPanel.pixels.width) {
            colorPanel.pixels.setPixel32(x, 0, 0xFF000000);
            colorPanel.pixels.setPixel32(x, 1, 0xFF000000);
            colorPanel.pixels.setPixel32(x, 18, 0xFF000000);
            colorPanel.pixels.setPixel32(x, 19, 0xFF000000);
        }
        for (y in 0...colorPanel.pixels.height) {
            colorPanel.pixels.setPixel32(0, y, 0xFF000000);
            colorPanel.pixels.setPixel32(1, y, 0xFF000000);
            colorPanel.pixels.setPixel32(28, y, 0xFF000000);
            colorPanel.pixels.setPixel32(29, y, 0xFF000000);
        }
        var editButton = new FlxUIButton(colorPanel.x + colorPanel.width + 10, colorPanel.y, "Select Color", function() {
            openSubState(new dev_toolbox.ColorPicker(colorPanel.color, function(c) {
                colorPanel.color = c;
            }));
        });
        var applyButton = new FlxUIButton(editButton.x + editButton.width + 10, colorPanel.y, "Apply & Save", function() {
            fpSongToEdit.displayName = songDisplayName.text.trim() == "" ? null : songDisplayName.text.trim();
            var diffs = difficulties.text.split(",");
            var bpm = 100;
            try {
                for (f in FileSystem.readDirectory('${Paths.getModsFolder()}\\$selectedMod\\data\\${fpSongToEdit.name}\\')) {
                    if (f.toLowerCase().startsWith('${fpSongToEdit.name.toLowerCase()}') && f.toLowerCase().endsWith('.json')) {
                        trace('$f is a chart.');
                        var chart:SwagSong = Json.parse('${Paths.getModsFolder()}\\$selectedMod\\data\\${fpSongToEdit.name}\\$f');
                        bpm = chart.bpm;
                        break;
                    }
                }
            } catch(e) {

            }
            var _song = {
                song : {
                    song: fpSongToEdit.name,
                    notes: [],
                    bpm: bpm,
                    needsVoices: true,
                    player1: 'bf',
                    player2: 'dad',
                    speed: 1,
                    validScore: true,
                    keyNumber: 4,
                    noteTypes : ["Friday Night Funkin':Default Note"]
                }
			};
            for(d in diffs) {
                var diff = d.trim().toLowerCase().replace(" ", "-");
                var path = '${Paths.getModsFolder()}\\$selectedMod\\data\\${fpSongToEdit.name}\\${fpSongToEdit.name}-${d.trim().toLowerCase()}.json';
                if (diff == "normal") {
                    path = '${Paths.getModsFolder()}\\$selectedMod\\data\\${fpSongToEdit.name}\\${fpSongToEdit.name}.json';
                }
                if (!FileSystem.exists(path)) {
                    File.saveContent(path, Json.stringify(_song, "\t"));
                }
            }
            fpSongToEdit.difficulties = [for(t in diffs) t.trim()];
            fpSongToEdit.color = colorPanel.color.toWebString();
            fpSongToEdit.char = fpIcon.text.trim();
            
            save();
            refreshSongs();
            for(s in freeplaySonglist.songs) {
                if (s.name == fpSongToEdit.name) {
                    fpSongToEdit = s;
                }
            }
            updateSongTab(fpSongToEdit, false);
        });

        songTabThingy.resize(500, applyButton.y + applyButton.height + 30);
        songTabThingy.y = 710 - songTabThingy.height;


        for (l in labels) songSettings.add(l);
        songSettings.add(songDisplayName);
        songSettings.add(difficulties);
        songSettings.add(colorPanel);
        songSettings.add(fpIcon);
        songSettings.add(editButton);
        songSettings.add(applyButton);
        songTabThingy.addGroup(songSettings);

        songsRadioList = new FlxUIRadioGroup(10, 10, [], [], function(id) {
            var s:FreeplaySong = null;
            for(so in freeplaySonglist.songs) if (so.name == id) s = so;
            updateSongTab(s);
            add(songTabThingy);
        }, 25, 300, 640);
        tab.add(songsRadioList);
        refreshSongs();

        
        var createButton = new FlxUIButton(10, 670, "Add", function() {
            openSubState(new SongCreator());
        });
        tab.add(createButton);


        UI_Tabs.addGroup(tab);
    }

    public function addWeeks() {
        var weekJson:WeeksJson = {
            weeks : []
        };
        var weeksPath = '${Paths.getModsFolder()}\\$selectedMod\\weeks.json';
        if (FileSystem.exists(weeksPath)) {
            weekJson = Json.parse(File.getContent(weeksPath));
        } else {
            File.saveContent(weeksPath, Json.stringify(weekJson));
        }
        
        var tab = new FlxUI(null, UI_Tabs);
        tab.name = "weeks";

        

        var x = UI_Tabs.x + UI_Tabs.width;
        var blackBG = new FlxSprite(x, 0).makeGraphic(Std.int(1280 - UI_Tabs.width), 720, 0xFF000000);
        add(blackBG);
        
        var scoreText = new FlxText(x + 10, 10, 0, "SCORE: 0", 36);
		scoreText.setFormat("VCR OSD Mono", 32);
        add(scoreText);

        var txtWeekTitle = new FlxText(x, 10, FlxG.width - x, "Select a week...", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;
        add(txtWeekTitle);

        var yellowBG = new FlxSprite(x + 0, 56).makeGraphic(Std.int(FlxG.width - x), 400, FlxColor.WHITE);
		yellowBG.color = 0xFFF9CF51;
        add(yellowBG);

        var bf:MenuCharacter = new MenuCharacter(x + (FlxG.width * 0.25) * (2 + 0) - 150, "bf");
        bf.y += 70;
        bf.antialiasing = true;
        bf.setGraphicSize(Std.int(bf.width * 0.9));
        bf.updateHitbox();
        bf.x -= 80;
        add(bf);

        var weekButton:FlxSprite = new FlxSprite(0, yellowBG.y + yellowBG.height + 10);
        weekButton.antialiasing = true;

        var labels:Array<FlxUIText> = [];
        var label = new FlxUIText(10, FlxG.height / 2, 300, "Week Name");
        var weekName:FlxUIInputText = new FlxUIInputText(10, label.y + label.height, 300, "");
        

        var radioList = new FlxUIRadioGroup(10, 10, [for (i in 0...weekJson.weeks.length) Std.string(i)], [for(w in weekJson.weeks) w.name.trim() == "" ? "(Untitled)" : w.name], function(id) {
            trace(id);
            var w = weekJson.weeks[Std.parseInt(id)];
            var b = null;
            try {
                b = Paths.getBitmapOutsideAssets('${Paths.getModsFolder()}\\$selectedMod\\${w.buttonSprite}');
            } catch(e) {
                trace(e);
            }
            if (b == null) b = new BitmapData(1, 1, 0x00000000);
            weekButton.loadGraphic(b);
            weekButton.x = (2*x) + (((FlxG.width - (2*x)) / 2) - (weekButton.width / 2));
            add(weekButton);
        },  25, 280);

        tab.add(radioList);
        UI_Tabs.addGroup(tab);
    }
    public function addInfo() {
		var tab = new FlxUI(null, UI_Tabs);
		tab.name = "info";

        var name = ModSupport.modConfig[selectedMod].name;
        if (name == null) name = selectedMod;
        var desc = ModSupport.modConfig[selectedMod].description;
        if (desc == null) desc = "(No description)";
        var title = ModSupport.modConfig[selectedMod].titleBarName;
        if (title == null) title = "(No description)";
        
        card = new ModCard(selectedMod, ModSupport.modConfig[selectedMod]);
        card.screenCenter(Y);
        card.x = 320 + ((1280 - 320) / 2) - (card.width / 2);
        var label = new FlxUIText(10, 10, 300, "Mod name");
        var mod_name = new FlxUIInputText(10, label.y + label.height, 300, name);
        tab.add(label);
        tab.add(mod_name);

		var label = new FlxUIText(10, mod_name.y + mod_name.height + 10, 300, "Mod description");
        var mod_description = new FlxUIInputText(10, label.y + label.height, 300, desc.replace("\r", "").replace("\n", "\\n"));
        tab.add(label);
        tab.add(mod_description);

		var label = new FlxUIText(10, mod_description.y + mod_description.height + 10, 300, "Titlebar Name");
        var titlebarName = new FlxUIInputText(10, label.y + label.height, 300, title);
        tab.add(label);
        tab.add(titlebarName);

        // var icon = new FlxUISprite(520, titlebarName.y).loadGraphic(Paths.image("defaultTitlebarIcon", "preload"));
        // icon.antialiasing = true;
        // icon.setGraphicSize(20, 20);
        // icon.updateHitbox();
        // tab.add(icon);

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
        // tab.add(chooseIconButton);

        var modIcon = new FlxUISprite(85, titlebarName.y + titlebarName.height + 10)
        .loadGraphic(
            FileSystem.exists('${Paths.getModsFolder()}\\$selectedMod\\modIcon.png')
            ? BitmapData.fromFile('${Paths.getModsFolder()}\\$selectedMod\\modIcon.png')
            : Paths.image("modEmptyIcon", "preload")
        );
        modIcon.setGraphicSize(150, 150);
        modIcon.updateHitbox();
        tab.add(modIcon);

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
        tab.add(chooseIconButton);

        var saveButton = new FlxUIButton(10, chooseIconButton.y + 30, "Save", function() {
            var e = ModSupport.modConfig[selectedMod];
            e.name = mod_name.text;
            e.description = mod_description.text.replace("\\n", "\n");
            e.titleBarName = titlebarName.text;
            File.saveBytes('${Paths.getModsFolder()}\\$selectedMod\\modIcon.png', modIcon.pixels.encode(modIcon.pixels.rect, new PNGEncoderOptions(true)));
            ModSupport.saveModData(selectedMod);
            card.updateMod(e);
        });
        saveButton.resize(145, 20);
        tab.add(saveButton);
		UI_Tabs.addGroup(tab);
    }

    public function addChars() {
		var tab = new FlxUI(null, UI_Tabs);
		tab.name = "chars";

        FileSystem.createDirectory('${Paths.getModsFolder()}\\$selectedMod\\characters');
        var chars =[
            for(folder in FileSystem.readDirectory('${Paths.getModsFolder()}\\$selectedMod\\characters'))
                if (FileSystem.isDirectory('${Paths.getModsFolder()}\\$selectedMod\\characters\\$folder'))
                    folder
        ];
        var radios = new FlxUIRadioGroup(10, 10, chars, chars, function(char) {
            
        }, 25, 300, 640);
        var charLayer = 0;
        var previewButton = new FlxUIButton(10, 670, "Preview", function() {
            if (character != null) {
                remove(character);
                character.destroy();
            }
            character = new Character(0, 0, CoolUtil.getCharacterFullString(radios.selectedLabel, selectedMod));
            insert(charLayer, character);
            character.screenCenter(Y);
            character.x = 320 + ((1280 - 320) / 2) - (character.width / 2);
            character.setPosition(character.x - character.camOffset.x, character.y - character.camOffset.y);
            anims = [];
            @:privateAccess
            var it = character.animation._animations.keys();
            while (it.hasNext()) {
                anims.push(it.next());
            }
            anims.sort(function(a, b) {return (a.toUpperCase() < b.toUpperCase()) ? -1 : ((a.toUpperCase() > b.toUpperCase()) ? 1 : 0);});
        });
        previewButton.resize(67, 20);
        tab.add(previewButton);
        var createButton = new FlxUIButton(previewButton.x + previewButton.width + 10, 670, "Create", function() {
            openSubState(new CharacterCreator());
        });
        createButton.resize(67, 20);
        var editButton = new FlxUIButton(createButton.x + createButton.width + 10, 670, "Edit", function() {
            if (radios.selectedId == null || radios.selectedId == "") {
                openSubState(ToolboxMessage.showMessage("Error", "No character was selected."));
                return;
            }
            // if (!FileSystem.exists('${Paths.getModsFolder()}\\$selectedMod\\characters\\${radios.selectedId}\\Character.json')) {
            //     openSubState(ToolboxMessage.showMessage("Error", "Character editor currently only works with characters with JSON files."));
            //     return;
            // }
            dev_toolbox.character_editor.CharacterEditor.fromFreeplay = false;
            FlxG.switchState(new dev_toolbox.character_editor.CharacterEditor(radios.selectedId));
        });
        editButton.resize(67, 20);
        var deleteButton = new FlxUIButton(editButton.x + editButton.width + 10, 670, "Delete", function() {
            if (radios.selectedId == null || radios.selectedId == "") {
                openSubState(ToolboxMessage.showMessage("Error", "No character was selected."));
                return;
            }
            openSubState(new ToolboxMessage("Delete Character", 'Are you sure you want to delete ${radios.selectedId} ? This operation is irreversible.', [
                {
                    label: "Yes",
                    onClick: function(t) {
                        CoolUtil.deleteFolder('${Paths.getModsFolder()}\\$selectedMod\\characters\\${radios.selectedId}\\');
                        FileSystem.deleteDirectory('${Paths.getModsFolder()}\\$selectedMod\\characters\\${radios.selectedId}\\');
                        openSubState(ToolboxMessage.showMessage("Success", '${radios.selectedId} was successfully deleted.', function() {
                            FlxTransitionableState.skipNextTransIn = true;
                            FlxTransitionableState.skipNextTransOut = true;
                            FlxG.resetState();
                        }));
                    }
                },
                {
                    label: "No",
                    onClick: function(t) {}
                }
            ]));
        });
        deleteButton.resize(67, 20);
        tab.add(createButton);
        tab.add(editButton);
        tab.add(deleteButton);
        tab.add(radios);
        legend = new FlxUIText(330, 666, FlxG.width - 330, "[Up/Down] Change animation | [Space] Play Animation | [Enter] Flip");
        legend.size = 20;
        legend.color = FlxColor.BLACK;
        tab.add(legend);

        anims_text = new FlxUIText(330, 0, FlxG.width - 330, "");
        anims_text.size = 12;
        anims_text.color = FlxColor.BLACK;
        tab.add(anims_text);

		UI_Tabs.addGroup(tab);
        charLayer = 1;
    }

    public function onChangeTab(tab:String) {
        switch(oldTab) {
            case "info":
                remove(card);
            case "chars":
                if (character != null) {
                    character.destroy();
                    remove(character);
                    character = null;
                }
            case "songs":
                bgTweenColor = 0xFFFFFFFF;
                if (displayAlphabet != null) {
                    remove(displayAlphabet);
                    displayAlphabet.destroy();
                    displayAlphabet = null;
                }
                if (displayHealthIcon != null) {
                    remove(displayHealthIcon);
                    displayHealthIcon.destroy();
                    displayHealthIcon = null;
                }
                remove(songTabThingy);
        }
        switch(tab) {
            case "info":
                add(card);
            case "chars":

        }
    }
    public override function update(elapsed:Float) {
        super.update(elapsed);

        FlxMath.lerp(bg.color.redFloat, bgTweenColor.redFloat, 0.2);
        FlxMath.lerp(bg.color.greenFloat, bgTweenColor.greenFloat, 0.2);
        FlxMath.lerp(bg.color.blueFloat, bgTweenColor.blueFloat, 0.2);

        if (UI_Tabs.selected_tab_id != oldTab) {
            onChangeTab(UI_Tabs.selected_tab_id);
            oldTab = UI_Tabs.selected_tab_id;
        }

        switch(oldTab) {
            case "info":

            case "chars":
                if (character == null) {
                    anims_text.text = "Select a character...";
                    return;
                }
                var t = (selectedAnim == 0 ? "> " : "") + "Dance animation";
                for (k=>e in anims) {
                    if (k == selectedAnim - 1) {
                        t += '\n> ${anims[k]}';
                    } else {
                        t += '\n${anims[k]}';
                    }
                }
                anims_text.text = t;
                if (FlxG.keys.justPressed.UP) {
                    selectedAnim--;
                }
                if (FlxG.keys.justPressed.DOWN) {
                    selectedAnim++;
                }
                if (FlxG.keys.justPressed.ENTER) {
                    character.flipX = !character.flipX;
                }
                if (selectedAnim > anims.length) selectedAnim = 0;
                if (selectedAnim < 0) selectedAnim = anims.length;
                if (selectedAnim == 0) {
                    danceTime += elapsed;
                    if (danceTime > 0.5) {
                        danceTime -= 0.5;
                        if (character != null) {
                            character.dance();
                        }
                    }
                } else {
                    if (character.animation.curAnim == null || character.animation.curAnim.name != anims[selectedAnim - 1]) {
                        character.playAnim(anims[selectedAnim - 1]);
                    }
                }

                if (FlxG.keys.justPressed.SPACE && selectedAnim > 0) {
                    character.playAnim(anims[selectedAnim - 1], true);
                }
                
        }
        
    }
}