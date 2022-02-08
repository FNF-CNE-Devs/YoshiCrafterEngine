package dev_toolbox.stage_editor;

import flixel.addons.ui.*;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import sys.io.File;
import haxe.Json;
import Stage.StageJSON;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

// typedef SpawnedElements = {
//     var sprite:FlxSprite;
//     var jsonData:StageSprite;
// }

class StageEditor extends MusicBeatState {
    public static var fromFreeplay = false;
    var ui:FlxSpriteGroup;
    // var spawnedElements:Array<SpawnedElements>;
    var camHUD:FlxCamera;
    var camGame:FlxCamera;
    var dummyHUDCamera:FlxCamera;
    var stage:StageJSON;
    var stageFile:String;
    var bfDefPos:FlxPoint = new FlxPoint(770, 100 + 350);
    var gfDefPos:FlxPoint = new FlxPoint(400, 130 - 9);
    var dadDefPos:FlxPoint = new FlxPoint(100, 100);

    var bf:FlxStageSprite; // Not a Character since loading it would take too much time
    var gf:FlxStageSprite; // Not a Character since loading it would take too much time
    var dad:FlxStageSprite; // Not a Character since loading it would take too much time

    var selectedObj(default, set):FlxStageSprite;

    function set_selectedObj(n:FlxStageSprite):FlxStageSprite {
        selectedObj = n;
        objName.text = selectedObj != null ? selectedObj.name : "(No selected sprite)";
        if (selectedObj == null || homies.contains(selectedObj.type)) {
             // global shit
            for (e in [posLabel, sprPosX, sprPosY, scaleLabel, scaleNum, antialiasingCheckbox]) {
                e.visible = false;
            }
            // sparrow shit
            for (e in [sparrowAnimationTitle, animationNameTitle, animationNameTextBox, animationFPSNumeric, fpsLabel, animationLabel, animationTypeLabel, applySparrowButton]) {
                e.visible = false;
            }
        } else {
            for (e in [posLabel, sprPosX, sprPosY, scaleLabel, scaleNum, antialiasingCheckbox]) {
                e.visible = true;
            }
            sprPosX.value = selectedObj.x;
            sprPosY.value = selectedObj.y;
            scaleNum.value = (selectedObj.scale.x + selectedObj.scale.y) / 2;
            antialiasingCheckbox.checked = selectedObj.antialiasing;

            if (selectedObj.type.toLowerCase() == "sparrowatlas" && selectedObj.anim != null) {
                for (e in [sparrowAnimationTitle, animationNameTitle, animationNameTextBox, animationFPSNumeric, fpsLabel, animationLabel, animationTypeLabel, applySparrowButton]) {
                    e.visible = true;
                }
                animationNameTextBox.text = selectedObj.anim.name;
                animationFPSNumeric.value = selectedObj.anim.fps;
                animationLabel.selectedId = selectedObj.anim.type;

            } else {
                for (e in [sparrowAnimationTitle, animationNameTitle, animationNameTextBox, animationFPSNumeric, fpsLabel, animationLabel, animationTypeLabel, applySparrowButton]) {
                    e.visible = false;
                }
            }
        }

        return selectedObj;
    }

    var camThingy:FlxSprite;
    var tabs:FlxUITabMenu;

    var homies:Array<String> = ["BF", "GF", "Dad"];

    var stageTab:FlxUI;
    var globalSetsTab:FlxUI;
    var selectedObjTab:FlxUI;

    var defCamZoomNum:FlxUINumericStepper;

    var objName:FlxUIText;
    var posLabel:FlxUIText;
    var sprPosX:FlxUINumericStepper;
    var sprPosY:FlxUINumericStepper;
    var scaleLabel:FlxUIText;
    var scaleNum:FlxUINumericStepper;
    var antialiasingCheckbox:FlxUICheckBox;
    var sparrowAnimationTitle:FlxUIText;
    var animationNameTitle:FlxUIText;
    var animationNameTextBox:FlxUIInputText;
    var animationLabel:FlxUIDropDownMenu;
    var animationFPSNumeric:FlxUINumericStepper;
    var fpsLabel:FlxUIText;
    var animationTypeLabel:FlxUIText;
    var applySparrowButton:FlxUIButton;

    var oldTab = "";
    var selectOnly(default, set):FlxStageSprite = null;
    var selectOnlyButtons:Array<FlxUIButton> = [];
    var moveOffset:FlxPoint = new FlxPoint(0, 0);
    var objBeingMoved:FlxStageSprite = null;

    function set_selectOnly(s:FlxStageSprite):FlxStageSprite {
        selectOnly = s;

        for (m in members) {
            if (Std.isOfType(m, FlxStageSprite)) {
                var sprite = cast(m, FlxStageSprite);
                if (sprite == selectOnly || selectOnly == null) {
                    sprite.colorTransform.redOffset = 0;
                    sprite.colorTransform.greenOffset = 0;
                    sprite.colorTransform.blueOffset = 0;
                    sprite.colorTransform.redMultiplier = 1;
                    sprite.colorTransform.greenMultiplier = 1;
                    sprite.colorTransform.blueMultiplier = 1;
                } else {
                    sprite.colorTransform.redOffset = 128;
                    sprite.colorTransform.greenOffset = 128;
                    sprite.colorTransform.blueOffset = 128;
                    sprite.colorTransform.redMultiplier = 0.25;
                    sprite.colorTransform.greenMultiplier = 0.25;
                    sprite.colorTransform.blueMultiplier = 0.25;
                }
            }
        }
        camGame.bgColor = selectOnly == null ? FlxColor.BLACK : 0xFF888888;

        return s;
    }


    public override function new(stage:String) {
        this.stageFile = stage;
        super();
    }

    public function bye() {
        if (fromFreeplay)
            FlxG.switchState(new PlayState());
        else
            FlxG.switchState(new ToolboxHome(ToolboxHome.selectedMod));
    }

    function addStageTab() {
        stageTab = new FlxUI(null, tabs);
        stageTab.name = "stage";

        var names:FlxUIText = new FlxUIText(10, 10, 280, "Sprites");
        names.alignment = CENTER;

        var all = new FlxUIButton(10, names.y + names.height + 10, "(Can Select All)", function() {
            selectOnly = null;
        });
        all.resize(280, 20);

        stageTab.add(names);
        stageTab.add(all);

        tabs.addGroup(stageTab);
    }

    function addGlobalSetsTab() {
        globalSetsTab = new FlxUI(null, tabs);
        globalSetsTab.name = "globalSets";

        defCamZoomNum = new FlxUINumericStepper(10, 10, 0.05, stage.defaultCamZoom == null ? 1 : stage.defaultCamZoom, 0.1, 5, 2);
        
        globalSetsTab.add(defCamZoomNum);
        tabs.addGroup(globalSetsTab);
    }

    function addSelectedObjectTab() {
        selectedObjTab = new FlxUI(null, tabs);
        // selectedObjTab
        selectedObjTab.name = "selectedElem";

        objName = new FlxUIText(10, 10, 280, "(No selected sprite)", 12);
        posLabel = new FlxUIText(10, objName.y + objName.height + 10, 280, "Sprite position");

        sprPosX = new FlxUINumericStepper(10, posLabel.y + (posLabel.height / 2), 10, 0, -99999, 99999);
        sprPosX.y -= sprPosX.height / 2;
        sprPosY = new FlxUINumericStepper(10, sprPosX.y, 10, 0, -99999, 99999);

        sprPosY.x = 290 - sprPosY.width;
        sprPosX.x = sprPosY.x - sprPosY.width - 5;

        scaleLabel = new FlxUIText(10, posLabel.y + sprPosX.height + 5, 280, "Scale");
        scaleNum = new FlxUINumericStepper(10, scaleLabel.y + (scaleLabel.height / 2), 0.1, 0, 0, 10, 2);
        scaleNum.y -= scaleLabel.height / 2;
        scaleNum.x = 290 - scaleNum.width;

        antialiasingCheckbox = new FlxUICheckBox(10, scaleNum.y + scaleNum.height, null, null, "Anti-aliasing", 100, null, function() {
            // sets antialiasing
            if (selectedObj != null) selectedObj.antialiasing = antialiasingCheckbox.checked;
        });

        sparrowAnimationTitle = new FlxUIText(10, antialiasingCheckbox.y + antialiasingCheckbox.height + 10, 280, "Sparrow Animation Settings");
        sparrowAnimationTitle.alignment = CENTER;
        animationNameTitle = new FlxUIText(10, sparrowAnimationTitle.y + sparrowAnimationTitle.height + 10, 280, "Animation Name");

        animationNameTextBox = new FlxUIInputText(10, animationNameTitle.y + animationNameTitle.height, 280, "", 8);
        animationFPSNumeric = new FlxUINumericStepper(10, animationNameTextBox.y + animationNameTextBox.height + 5, 1, 24, 1, 120, 0);
        // animationFPSNumeric.x -= animationFPSNumeric.width;

        fpsLabel = new FlxUIText(10, animationFPSNumeric.y + (animationFPSNumeric.height / 2), 0, "FPS: ");
        fpsLabel.y -= fpsLabel.height / 2;
        animationFPSNumeric.x += fpsLabel.width;

        animationLabel = new FlxUIDropDownMenu(10, animationFPSNumeric.y + animationFPSNumeric.height + 10, [
            new StrNameLabel("OnBeat", "On Beat"),
            new StrNameLabel("Loop", "Loop")
        ], function(id) {
            // animationLabel.label
        });

        animationTypeLabel = new FlxUIText(10, animationLabel.y + (10), 0, "Animation Type: ");
        animationTypeLabel.y -= animationTypeLabel.height / 2;
        animationLabel.x += animationTypeLabel.width;

        applySparrowButton = new FlxUIButton(150, animationLabel.y + 30, "Apply", function () {
            selectedObj.anim = {
                type: animationLabel.selectedId,
                name: animationNameTextBox.text,
                fps: Std.int(animationFPSNumeric.value)
            };
            selectedObj.animation.addByPrefix(selectedObj.anim.name, selectedObj.anim.name, selectedObj.anim.fps, selectedObj.anim.type.toLowerCase() == "loop");
            selectedObj.animation.play(selectedObj.anim.name);
        });



       

        selectedObjTab.add(objName);
        selectedObjTab.add(posLabel);
        selectedObjTab.add(sprPosX);
        selectedObjTab.add(sprPosY);
        selectedObjTab.add(scaleLabel);
        selectedObjTab.add(scaleNum);
        selectedObjTab.add(antialiasingCheckbox);
        selectedObjTab.add(sparrowAnimationTitle);
        selectedObjTab.add(animationNameTitle);
        selectedObjTab.add(animationNameTextBox);
        selectedObjTab.add(animationFPSNumeric);
        selectedObjTab.add(fpsLabel);
        selectedObjTab.add(animationLabel);
        selectedObjTab.add(animationTypeLabel);
        selectedObjTab.add(applySparrowButton);
        tabs.addGroup(selectedObjTab);

        selectedObj = null;
    }
    public override function create() {
        
        #if desktop
            Discord.DiscordClient.changePresence("In the Stage Editor...", null, "Stage Editor Icon");
        #end
        super.create();
        // persistentDraw = false;
        persistentUpdate = false;
        camGame = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        dummyHUDCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        FlxG.cameras.reset(dummyHUDCamera);
        FlxG.cameras.add(camGame);
		FlxG.cameras.add(camHUD, false);
        camHUD.bgColor = 0x00000000;

        // FlxG.cameras.setDefaultDrawTarget(camGame, true);

        camThingy = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/camThingy', 'shared'));
        camThingy.cameras = [dummyHUDCamera, camHUD];
        camThingy.alpha = 0.5;
        camThingy.x = ((FlxG.width - 300) / 2) - (camThingy.width / 2);
        add(camThingy);

        tabs = new FlxUITabMenu(null, [
            {
                label: "Elements",
                name: "stage"
            },
            {
                label: "Selected Elem.",
                name: "selectedElem"
            },
            {
                label: "Global Settings",
                name: "globalSets"
            }
        ], true);

        stage = Json.parse(File.getContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/${stageFile}.json'));
        camGame.zoom = stage.defaultCamZoom == null ? 1 : stage.defaultCamZoom;

        if (stage.bfOffset == null || stage.bfOffset.length == 0) stage.bfOffset = [0, 0];
        if (stage.bfOffset.length < 2) stage.bfOffset = [stage.bfOffset[0], 0];

        if (stage.gfOffset == null || stage.gfOffset.length == 0) stage.gfOffset = [0, 0];
        if (stage.gfOffset.length < 2) stage.gfOffset = [stage.gfOffset[0], 0];

        if (stage.dadOffset == null || stage.dadOffset.length == 0) stage.dadOffset = [0, 0];
        if (stage.dadOffset.length < 2) stage.dadOffset = [stage.dadOffset[0], 0];

        bf = new FlxStageSprite(bfDefPos.x + stage.bfOffset[0], bfDefPos.y + stage.bfOffset[1]);
        bf.name = "Boyfriend";
        bf.type = "BF";

        gf = new FlxStageSprite(gfDefPos.x + stage.gfOffset[0], gfDefPos.y + stage.gfOffset[1]);
        gf.name = "Girlfriend";
        gf.type = "GF";

        dad = new FlxStageSprite(dadDefPos.x + stage.dadOffset[0], dadDefPos.y + stage.dadOffset[1]);
        dad.name = "Dad";
        dad.type = "Dad";

        for(e in [bf, gf, dad]) {
            e.frames = Paths.getSparrowAtlas("stageEditorChars", "shared");
            switch(e.type) {
                case "BF":
                    e.animation.addByPrefix("dance", "BF idle dance", 24);
                case "GF":
                    e.animation.addByPrefix("dance", "GF Dancing Beat", 24);
                case "Dad":
                    e.animation.addByPrefix("dance", "Dad idle dance", 24);
            }
            e.animation.play("dance");
            e.antialiasing = true;
            e.updateHitbox();
        }

        addStageTab();
        addSelectedObjectTab();
        addGlobalSetsTab();

        tabs.addGroup(stageTab);

        tabs.cameras = [dummyHUDCamera, camHUD];
        tabs.resize(300, FlxG.height - 20);
        tabs.x = FlxG.width - tabs.width;
        tabs.y = 20;
        add(tabs);
        var closeButton = new FlxUIButton(FlxG.width - 20, 0, "X", function() {
            if (unsaved) {
                openSubState(new ToolboxMessage("Warning", "Some changes to the stage weren't saved. Do you want to save them ?", [
                    {
                        label: "Save",
                        onClick: function(mes) {
                            save();
                            bye();
                        }
                    },
                    { 
                        label: "Don't Save",
                        onClick: function(mes) {
                            bye();
                        }
                    },
                    {
                        label: "Cancel",
                        onClick: function(mes) {}
                    }
                ], null, camHUD));
            } else {
                bye();
            }
        });
        closeButton.resize(20, 20);
        closeButton.color = 0xFFFF4444;
        closeButton.label.color = FlxColor.WHITE;
        closeButton.cameras = [dummyHUDCamera, camHUD];

        var saveButton = new FlxUIButton(FlxG.width - 20, 0, "Save", function() {
            try {
                save();
            } catch(e) {
                openSubState(ToolboxMessage.showMessage('Error', 'Failed to save stage\n\n$e', null, camHUD));
                return;
            }
            openSubState(ToolboxMessage.showMessage('Success', 'Stage saved successfully !', null, camHUD));
        });
        saveButton.x -= saveButton.width;
        saveButton.cameras = [dummyHUDCamera, camHUD];
        add(closeButton);
        add(saveButton);
        updateStageElements();

    }
    
    var unsaved = false;
    public function save() {
        File.saveContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/${stageFile}.json', Json.stringify(stage, "\t"));
        unsaved = true;
    }
    public function updateStageElements() {
        var alreadySpawnedSprites:Map<String, FlxStageSprite> = [];
        var toDelete:Array<FlxStageSprite> = [];
        for (e in selectOnlyButtons) {
            remove(e);
            stageTab.remove(e);
            e.destroy();
        }
        selectOnlyButtons = [];
        for (e in members) {
            if (Std.isOfType(e, FlxStageSprite)) {
                var sprite = cast(e, FlxStageSprite);
                if (!homies.contains(sprite.type)) {
                    alreadySpawnedSprites[sprite.name] = sprite;
                    toDelete.push(sprite);
                }
                remove(sprite);
            }
        }
        for(s in stage.sprites) {
            var spr = alreadySpawnedSprites[s.name];
            if (spr != null) {
                toDelete.remove(spr);
                add(spr);
            } else {
                switch(s.type) {
                    case "SparrowAtlas":
                        spr = Stage.generateSparrowAtlas(s, ToolboxHome.selectedMod);
                        trace(spr);
                        add(spr);
                    case "Bitmap":
                        spr = Stage.generateBitmap(s, ToolboxHome.selectedMod);
                        trace(spr);
                        add(spr);
                    case "BF":
                        add(bf);
                        // spr = bf;
                    case "GF":
                        add(gf);
                        // spr = gf;
                    case "Dad":
                        add(dad);
                        // spr = dad;
                }
            }
            if (spr != null) {
                var button = new FlxUIButton(10, 58 + (selectOnlyButtons.length * 20), spr.name, function() {
                    selectedObj = spr;
                    selectOnly = spr;
                });
                button.resize(280, 20);
                stageTab.add(button);
                selectOnlyButtons.push(button);
            }
        }
    }

    public function updateJsonData() {
        stage.sprites = [];
        for (e in members) {
            if (Std.isOfType(e, FlxStageSprite)) {
                var sprite = cast(e, FlxStageSprite);
                stage.sprites.push({
                    type: sprite.type,
                    src: sprite.spritePath,
                    scrollFactor: [sprite.scrollFactor.x, sprite.scrollFactor.y],
                    scale: ((sprite.scale.x + sprite.scale.y) / 2),
                    pos: [sprite.x, sprite.y],
                    name: sprite.name,
                    antialiasing: sprite.antialiasing,
                    animation: sprite.anim
                });
            }
        }
        stage.bfOffset = [bf.x - bfDefPos.x, bf.y - bfDefPos.y];
        stage.gfOffset = [gf.x - gfDefPos.x, gf.y - gfDefPos.y];
        stage.dadOffset = [dad.x - dadDefPos.x, dad.y - dadDefPos.y];
        
        // stage.defaultCamZoom = 
        unsaved = true;
    }
    public override function update(elapsed:Float) {
        if (tabs.selected_tab_id != oldTab) {
            // if (oldTab == )
            oldTab = tabs.selected_tab_id;
            switch(tabs.selected_tab_id) {
                case "selectedElem":
                    selectedObj = selectedObj;
            }
        }

        stage.defaultCamZoom = defCamZoomNum.value;
        camThingy.scale.x = camThingy.scale.y = camGame.zoom / stage.defaultCamZoom;
        var scrollVal = elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / camGame.zoom;
        if (FlxG.keys.pressed.LEFT) {
            camGame.scroll.x -= scrollVal;
            moveOffset.x -= scrollVal;
        }
        if (FlxG.keys.pressed.RIGHT) {
            camGame.scroll.x += scrollVal;
            moveOffset.x += scrollVal;
        }
        if (FlxG.keys.pressed.DOWN) {
            camGame.scroll.y += elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / camGame.zoom;
            moveOffset.y += scrollVal;
        }
        if (FlxG.keys.pressed.UP) {
            camGame.scroll.y -= elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / camGame.zoom;
            moveOffset.y -= scrollVal;
        }
        if (FlxG.keys.pressed.BACKSPACE) {
            // resets
            camGame.scroll.x = camGame.scroll.y = 0;
        }
        try {
            super.update(elapsed);
        } catch(e) {

        }
        var mousePos = FlxG.mouse.getWorldPosition(camGame);
        if (objBeingMoved != null) {
            camHUD.alpha = FlxMath.lerp(camHUD.alpha, 0.2, 0.30 * 30 * elapsed);
            if (FlxG.mouse.pressed) {
                // new FlxPointer().getScreenPosition();
                objBeingMoved.x = mousePos.x + moveOffset.x;
                objBeingMoved.y = mousePos.y + moveOffset.y;
                if (FlxG.mouse.wheel != 0 && !homies.contains(objBeingMoved.type)) {
                    if (FlxG.keys.pressed.CONTROL) {
                        objBeingMoved.scale.x = objBeingMoved.scale.y = ((objBeingMoved.scale.x + objBeingMoved.scale.y) / 2) + (0.1 * FlxG.mouse.wheel);
                        objBeingMoved.updateHitbox();
                    }
                }

                if (selectedObj != null) {
                    sprPosX.value = selectedObj.x;
                    sprPosY.value = selectedObj.y;
                    scaleNum.value = (selectedObj.scale.x + selectedObj.scale.y) / 2;
                }
            } else {
                objBeingMoved = null;
                updateJsonData();
            }
        } else {
            camHUD.alpha = FlxMath.lerp(camHUD.alpha, 1, 0.30 * 30 * elapsed);
            camGame.zoom += 0.1 * FlxG.mouse.wheel;
            if (camGame.zoom < 0.1) camGame.zoom = 0.1;

            if (FlxG.mouse.getScreenPosition(camHUD).x >= FlxG.width - 300) {
                // when on tabs thingy
                if (selectedObj != null) {
                    selectedObj.x = sprPosX.value;
                    selectedObj.y = sprPosY.value;
                    if (scaleNum.value != selectedObj.scale.x) {
                        selectedObj.scale.set(scaleNum.value, scaleNum.value);
                        selectedObj.updateHitbox();
                    }
                }
            } else {
                
                if (selectedObj != null) {
                    sprPosX.value = selectedObj.x;
                    sprPosY.value = selectedObj.y;
                    scaleNum.value = (selectedObj.scale.x + selectedObj.scale.y) / 2;
                }

                // when on stage thingy
                var i = members.length - 1;
                if (selectOnly != null) {
                    if (FlxG.mouse.justPressed)
                        select(selectOnly, mousePos);
                } else {
                    while(i >= 0) {
                        var s = members[i];
                        if (Std.isOfType(s, FlxStageSprite)) {
                            s.cameras = [camGame];
                            var sprite = cast(s, FlxStageSprite);
                            if (overlaps(sprite, mousePos)) {
                                if (FlxG.mouse.justPressed) {
                                    select(sprite, mousePos);
                                }
                                break;
                            }
                        }
                        i--;
                    }
                }
            }
            
        }
    }

    
    function select(sprite:FlxStageSprite, mousePos:FlxPoint):Void {
        moveOffset.x = sprite.x - mousePos.x;
        moveOffset.y = sprite.y - mousePos.y;
        objBeingMoved = sprite;
        selectedObj = sprite;
    }
    function overlaps(sprite:FlxStageSprite, mousePos:FlxPoint):Bool {
        return mousePos.x >= sprite.x && mousePos.x < sprite.width + sprite.x && mousePos.y >= sprite.y && mousePos.y < sprite.height + sprite.y;
        // if (FlxG.mouse.overlaps(sprite, camGame)) {
        //     // if (sprite.type == "Bitmap") {
        //     //     var mPos = FlxG.mouse.getPosition();
        //     //     var rX = camGame.scroll.x + ((sprite.x - camGame.scroll.x) / sprite.scrollFactor.x);
        //     //     var rY = camGame.scroll.y + ((sprite.y - camGame.scroll.y) / sprite.scrollFactor.y);
        //     //     var pX = FlxMath.wrap(Std.int((mPos.x - rX) / (sprite.width) * sprite.pixels.width), 0, sprite.pixels.width);
        //     //     var pY = FlxMath.wrap(Std.int((mPos.y - rY) / (sprite.height) * sprite.pixels.height), 0, sprite.pixels.height);
        //     //     trace(pX);
        //     //     trace(pY);
                
        //     //     var pixel:FlxColor = sprite.pixels.getPixel32(pX, pY);
        //     //     sprite.pixels.setPixel32(pX, pY, 0xFFFFFFFF);
        //     //     if (pixel.alphaFloat < 0.1) {
        //     //         return false;
        //     //     } else {
        //     //         return true;
        //     //     }
        //     // } else {
        //         return true;
        //     // }
            
        // }
        // return false;
    }
}