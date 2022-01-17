package dev_toolbox.character_editor;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import ModSupport.CharacterSkin;
import flixel.math.FlxPoint;
import dev_toolbox.CharacterJSON.CharacterAnim;
import flixel.FlxG;
import flixel.addons.ui.*;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;

using StringTools;

class CharacterEditor extends MusicBeatState {
    var camHUD:FlxCamera;
    public var character:Character;
    var animSelection:FlxUIDropDownMenu;
    var anim:FlxUITabMenu;
    var dad:Character;
    var animationTab:FlxUI;
    var closeButton:FlxUIButton;
    var saveButton:FlxUIButton;
    var addAnimButton:FlxUIButton;
    var animSettingsTabs:FlxUITabMenu;
    var animSettings:FlxUI;
    var offsetX:FlxUINumericStepper;
    var offsetY:FlxUINumericStepper;
    var loopCheckBox:FlxUICheckBox;
    var indices:FlxUIInputText;
    var framerate:FlxUINumericStepper;
    var flipCheckbox:FlxUICheckBox = null;
    var globalOffsetX:FlxUINumericStepper = null;
    var globalOffsetY:FlxUINumericStepper = null;
    var c:String = "";

    var isPlayer:Bool = false;

    var currentAnim(default, set):String = "";
    public function set_currentAnim(v:String) {
        currentAnim = v;
        updateAnim();
        return currentAnim;
    }

    public static var current:CharacterEditor;

    public function updateAnim() {
        var anim = character.animation.getByName(currentAnim);
        framerate.value = anim.frameRate;
        loopCheckBox.checked = anim.looped;
        var offsets = character.animOffsets[currentAnim];
        if (offsets == null) offsets = [0, 0];
        offsetX.value = offsets[0];
        offsetY.value = offsets[1];
        character.playAnim(currentAnim);
    }

    public function save() {
        var anims:Array<CharacterAnim> = [];
        @:privateAccess
        var it = character.animation._animations.keys();
        while(it.hasNext()) {
            var anim = it.next();
            var a = character.animation.getByName(anim);
            var animName = character.frames.getByIndex(a.frames[0]).name;
            var offset = character.animOffsets[anim];
            @:privateAccess
            anims.push({
                name: anim,
                anim: animName.substr(0, animName.length - 4),
                framerate: Std.int(a.frameRate),
                x: offset[0],
                y: offset[1],
                loop: a.looped,
                indices: null
                });
        }
        var json:CharacterJSON = {
            anims: anims,
            globalOffset: {
                x: character.x - 100,
                y: character.y - 100
            },
            camOffset: {
                x: character.camOffset.x,
                y: character.camOffset.y
            },
            antialiasing: character.antialiasing,
            scale: (character.scale.x + character.scale.y) / 2,
            danceSteps: ['idle'],
            healthIconSteps: [[20, 0], [0, 1]],
            flipX: isPlayer ? !character.flipX : character.flipX,
            healthbarColor: cast(character.getColors()[0], FlxColor).toWebString(),
            arrowColors: [for (k=>c in character.getColors()) if (k > 0) cast(k, FlxColor).toWebString()]
        }
        File.saveContent('${Paths.getModsFolder()}\\${ToolboxHome.selectedMod}\\characters\\$c\\Character.json', Json.stringify(json, "\t"));
    }
    public function new(char:String) {
        super();
        current = this;
        this.c = char;

        // CREATES STAGE
        
        var bg = new FlxSprite(-600, -200).loadGraphic(Paths.image('default_stage/stageback', 'shared'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);
        bg.active = false;
        add(bg);

        var stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('default_stage/stagefront', 'shared'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('default_stage/stagecurtains', 'shared'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;
        add(stageCurtains);

        dad = new Character(100, 100, "Friday Night Funkin':dad");
        add(dad);



        character = new Character(100, 100, '${ToolboxHome.selectedMod}:$char');
        // character.curCharacter = '${ToolboxHome.selectedMod}:$char';
        // character.frames = Paths.getModCharacter();
        // character.loadJSON(true);
        character.setPosition(100 + character.charGlobalOffset.x, 100 + character.charGlobalOffset.y);
        
        add(character);

        anim = new FlxUITabMenu(null, [
            {
                name : "anims",
                label : "Animations"
            }
        ], true);
        anim.scrollFactor.set();
        anim.resize(300, 80);
        anim.x = 1280 - anim.width - 10;
        anim.y = 10;

        
        animationTab = new FlxUI(null, anim);
        animationTab.name = "anims";
        anim.addGroup(animationTab);
        
        animSelection = new FlxUIDropDownMenu(10, 10, [new StrNameLabel("idle", "idle")], function(id) {
            currentAnim = id;
        });
        animSelection.cameras = [camHUD];

        addAnimButton = new FlxUIButton(10, 32, "Add", function() {
            openSubState(new NewAnimDialogue());
        });
        animationTab.add(addAnimButton);
        animationTab.add(animSelection);
        updateAnimSelection();

        closeButton = new FlxUIButton(1257, 3, "X", function() {
            FlxG.switchState(new ToolboxHome(ToolboxHome.selectedMod));
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = FlxColor.WHITE;

        saveButton = new FlxUIButton(1167, 3, "Save", function() {
            save();
            openSubState(ToolboxMessage.showMessage("Success", "Character successfully saved."));
        });
        saveButton.resize(80, 20);

        
        animSettingsTabs = new FlxUITabMenu(null, [
            {
                name: "settings",
                label: "Animation Settings"
            }
        ], true);
        animSettings = new FlxUI(null, animSettingsTabs);
        animSettings.name = "settings";
        animSettingsTabs.scrollFactor.set();

        var label:FlxUIText = new FlxUIText(10, 10, 280, "Animation Framerate");
        animSettings.add(label);
        framerate = new FlxUINumericStepper(10, label.y + label.height, 1, 24, 1, 120, 0);
        animSettings.add(framerate);
        var label:FlxUIText = new FlxUIText(10, framerate.y + framerate.height + 10, 280, "Animation Offset");
        animSettings.add(label);
        offsetX = new FlxUINumericStepper(10, label.y + label.height, 10, 0, -999, 999, 0);
        offsetY = new FlxUINumericStepper(20 + offsetX.width, label.y + label.height, 10, 0, -999, 999, 0);
        animSettings.add(offsetX);
        animSettings.add(offsetY);
        loopCheckBox = new FlxUICheckBox(10, offsetX.y + offsetX.height + 10, null, null, "Loop Animation", 250);
        animSettings.add(loopCheckBox);
        // var label:FlxUIText = new FlxUIText(10, loopCheckBox.y + loopCheckBox.height + 10, 280, "Indices (separate by \",\", leave blank for no indices)");
        // animSettings.add(label);
        // indices = new FlxUIInputText(10, label.y + label.height, 280, "");
        // animSettings.add(indices);


        animSettingsTabs.addGroup(animSettings);
        animSettingsTabs.resize(300, 200);
        animSettingsTabs.setPosition(anim.x, anim.y + anim.height + 10);

        var characterSettingsTabs = new FlxUITabMenu(null, [
            {
                name: "char",
                label: "Char. Settings"
            },
            {
                name: "health",
                label: "Health Color"
            }
        ], true);
        var charSettings = new FlxUI(null, characterSettingsTabs);
        characterSettingsTabs.resize(300, 200);
        charSettings.name = "char";
        characterSettingsTabs.scrollFactor.set();

        flipCheckbox = new FlxUICheckBox(10, 10, null, null, "Flip Character", 280, null, function() {
            character.flipX = flipCheckbox.checked;
            if (isPlayer) character.flipX = !character.flipX;
        });
        characterSettingsTabs.addGroup(charSettings);
        characterSettingsTabs.x = 1280 - characterSettingsTabs.width - 10;
        characterSettingsTabs.y = animSettingsTabs.y + animSettingsTabs.height + 10;
        globalOffsetX = new FlxUINumericStepper(10, 36, 10, 0, -999, 999, 0);
        globalOffsetY = new FlxUINumericStepper(globalOffsetX.x + globalOffsetX.width + 5, 36, 10, 0, -999, 999, 0);
        charSettings.add(flipCheckbox);
        charSettings.add(globalOffsetX);
        charSettings.add(globalOffsetY);

        
        globalOffsetX.value = character.charGlobalOffset.x;
        globalOffsetY.value = character.charGlobalOffset.y;

        add(characterSettingsTabs);
        add(animSettingsTabs);
        add(anim);

        
        var healthSettings = new FlxUI(null, characterSettingsTabs);
        healthSettings.name = "health";

        var healthBar:FlxUISprite = new FlxUISprite(10, 35);
        healthBar.makeGraphic(255, 10, 0xFFFFFFFF);
        healthBar.pixels.lock();
        for (x in 0...healthBar.pixels.width) {
            healthBar.pixels.setPixel(x, 0, 0xFF000000);
            healthBar.pixels.setPixel(x, 1, 0xFF000000);
            healthBar.pixels.setPixel(x, 8, 0xFF000000);
            healthBar.pixels.setPixel(x, 9, 0xFF000000);
        }
        for (y in 0...healthBar.pixels.height) {
            healthBar.pixels.setPixel(0, y, 0xFF000000);
            healthBar.pixels.setPixel(1, y, 0xFF000000);
            healthBar.pixels.setPixel(253, y, 0xFF000000);
            healthBar.pixels.setPixel(254, y, 0xFF000000);
        }
        healthBar.pixels.unlock();
        var icon = new HealthIcon(character.curCharacter, false, ToolboxHome.selectedMod);
        icon.setGraphicSize(50, 50);
        icon.updateHitbox();
        icon.x = healthBar.x + healthBar.width - 25;
        icon.y = healthBar.y + (healthBar.height / 2) - 25;

        var color = 0xFFFFFFFF;
        var charColors = character.getColors();
        if (charColors.length > 0) {
            color = charColors[0];
        }
        healthBar.color = color;
        healthSettings.add(healthBar);
        healthSettings.add(icon);

        characterSettingsTabs.addGroup(healthSettings);
        add(saveButton);
        add(closeButton);
    }

    public function addAnim(name:String, anim:String):Bool {
        character.animation.addByPrefix(name, anim, 24, false);
        updateAnimSelection();
        if (character.animation.getByName(name) != null) {
            return true;
        } else {
            return false;
        }
    }

    public function updateAnimSelection() {
        var oldSelec = animSelection.selectedLabel;
        var anims:Array<StrNameLabel> = [];
        @:privateAccess
        var it = character.animation._animations.keys();
        while (it.hasNext()) {
            var n = it.next();
            anims.push(new StrNameLabel(n, n));
        }
        if (anims.length == 0) anims.push(new StrNameLabel("", "")); // Since bitchass drop down menu crashes with no elements
        animSelection.setData(anims);
        animSelection.selectedLabel = oldSelec;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        var move:FlxPoint = new FlxPoint(0, 0);
        if (FlxG.keys.pressed.RIGHT) move.x += 1;
        if (FlxG.keys.pressed.UP) move.y -= 1;
        if (FlxG.keys.pressed.LEFT) move.x -= 1;
        if (FlxG.keys.pressed.DOWN) move.y += 1;
        FlxG.camera.scroll.x += move.x * 400 * elapsed * (FlxG.keys.pressed.SHIFT ? 2.5 : 1);
        FlxG.camera.scroll.y += move.y * 400 * elapsed * (FlxG.keys.pressed.SHIFT ? 2.5 : 1);
        character.x = 100 + globalOffsetX.value;
        character.y = 100 + globalOffsetY.value;

        if (character.animation.curAnim != null) {
            // YOU CANT STOP ME HAXEFLIXEL
            var anim = character.animation.getByName(character.animation.curAnim.name);
            @:privateAccess
            anim.looped = loopCheckBox.checked;
            @:privateAccess
            anim.frameRate = framerate.value;

            character.animOffsets[character.animation.curAnim.name] = [offsetX.value, offsetY.value];
            character.offset.set(character.animOffsets[character.animation.curAnim.name][0], character.animOffsets[character.animation.curAnim.name][1]);

        }
        // var midpoint = character.getGraphicMidpoint();
        // FlxG.camera.scroll.x = midpoint.x + character.camOffset.x + 150 - 640;
        // FlxG.camera.scroll.y = midpoint.y + character.camOffset.y - 100 - 360;
    }
}

