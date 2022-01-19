package dev_toolbox;

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

using StringTools;

class ToolboxHome extends MusicBeatState {

    var nonEditableMods:Array<String> = ["Friday Night Funkin'", "YoshiEngine"];

    public static var selectedMod:String = "Friday Night Funkin'";
    var oldTab:String = "";

    // Characters tab
    var character:Character = null;
    var danceTime:Float = 0;
    var UI_Tabs:FlxUITabMenu;
    var legend:FlxUIText;
    var anims_text:FlxUIText;

    var anims:Array<String> = [];
    var selectedAnim:Int = 0;

    // Info tab
    var card:ModCard;

    // Songs tab
    var songsRadioList:FlxUIRadioGroup;

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
        CoolUtil.addWhiteBG(this);
        var tabs = [
            {name: "info", label: 'Mod Info'},
			{name: "songs", label: 'Songs'},
			{name: "chars", label: 'Characters'},
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

        var closeButton = new FlxUIButton(FlxG.width - 23, 3, "X", function() {
            FlxG.switchState(new ToolboxMain());
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = FlxColor.WHITE;
        add(closeButton);
       
		// tab.add(modDropDown);
    }

    public var freeplaySongs:Map<String, ToolboxFreeplaySong> = [];

    public function refreshSongs() {
        FileSystem.createDirectory('${Paths.getModsFolder()}\\$selectedMod\\songs\\');   
        FileSystem.createDirectory('${Paths.getModsFolder()}\\$selectedMod\\data\\');
        if (!FileSystem.exists('${Paths.getModsFolder()}\\$selectedMod\\data\\freeplaySonglist.json')) {
            var json:FreeplaySongList = {
                songs : []
            };
            File.saveContent('${Paths.getModsFolder()}\\$selectedMod\\data\\freeplaySonglist.json', Json.stringify(json));
        }
        var songs = [for (s in FileSystem.readDirectory('${Paths.getModsFolder()}\\$selectedMod\\songs\\')) if (FileSystem.isDirectory('${Paths.getModsFolder()}\\$selectedMod\\songs\\$s\\')) s];
        var displayNames = [];
        var freeplaySonglist:FreeplaySongList = try {Json.parse(File.getContent('${Paths.getModsFolder()}\\$selectedMod\\data\\freeplaySonglist.json'));} catch(e) {null;};
        if (freeplaySonglist.songs == null) freeplaySonglist.songs = [];
        freeplaySongs = [];
        for (s in songs) {
            var freeplayThingy:FreeplaySong = null;
            for (entry in freeplaySonglist.songs) {
                if (entry.name == s) {
                    freeplayThingy = entry;
                    break;
                }
            }
            var isInFreeplay = freeplayThingy != null;
            if (!isInFreeplay) {
                freeplayThingy = {
                    name : s,
                    char : "dad",
                    displayName : null,
                    difficulties : ["Easy", "Normal", "Hard"],
                    color : "#FFFFFF"
                }
            }
            var json:ToolboxFreeplaySong = {
                char: "dad",
                displayName: null,
                difficulties: "Easy,Normal,Hard",
                color: 0xFFFFFFFF,
                inFreeplayMenu: isInFreeplay
            };
            if (freeplayThingy.char != null) json.char = freeplayThingy.char;
            if (freeplayThingy.displayName != null) json.displayName = freeplayThingy.displayName;
            if (freeplayThingy.difficulties != null) json.difficulties = freeplayThingy.difficulties.join(",");
            if (freeplayThingy.color != null) json.color = FlxColor.fromString(freeplayThingy.color);

            freeplaySongs[s] = json;
            displayNames.push(freeplayThingy.displayName != null ? freeplayThingy.displayName : s);
        }

        songsRadioList.updateRadios(songs, displayNames);
    }
    public function addSongs() {
        var tab = new FlxUI(null, UI_Tabs);
        tab.name = "songs";

        songsRadioList = new FlxUIRadioGroup(10, 10, [], [], function(id) {
            
        }, 25, 300, 640);
        tab.add(songsRadioList);
        refreshSongs();

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
        tab.add(previewButton);
        var createButton = new FlxUIButton(previewButton.x + previewButton.width + 10, 670, "Create", function() {
            openSubState(new CharacterCreator());
        });
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
        tab.add(createButton);
        tab.add(editButton);
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
        charLayer = members.indexOf(lagend);
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
        }
        switch(tab) {
            case "info":
                add(card);
            case "chars":

        }
    }
    public override function update(elapsed:Float) {
        super.update(elapsed);

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