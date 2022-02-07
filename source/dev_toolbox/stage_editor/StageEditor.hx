package dev_toolbox.stage_editor;

import flixel.addons.ui.FlxUITypedButton;
import hscript.Checker.CNamedType;
import flixel.input.FlxPointer;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import sys.io.File;
import haxe.Json;
import Stage.StageJSON;
import flixel.FlxCamera;
import flixel.addons.ui.FlxUIButton;
import flixel.FlxG;
import Stage.StageSprite;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

// typedef SpawnedElements = {
//     var sprite:FlxSprite;
//     var jsonData:StageSprite;
// }

class StageEditor extends MusicBeatState {
    var ui:FlxSpriteGroup;
    // var spawnedElements:Array<SpawnedElements>;
    var camHUD:FlxCamera;
    var camGame:FlxCamera;
    var stage:StageJSON;
    var stageFile:String;
    var bfDefPos:FlxPoint = new FlxPoint(770, 100 + 350);
    var gfDefPos:FlxPoint = new FlxPoint(400, 130 - 9);
    var dadDefPos:FlxPoint = new FlxPoint(100, 100);

    var bf:FlxStageSprite; // Not a Character since loading it would take too much time
    var gf:FlxStageSprite; // Not a Character since loading it would take too much time
    var dad:FlxStageSprite; // Not a Character since loading it would take too much time

    var camThingy:FlxSprite;

    var doNotDelete:Array<String> = ["BF", "GF", "Dad"];

    public override function new(stage:String) {
        this.stageFile = stage;
        super();
    }
    public override function create() {
        super.create();
        camHUD = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
        // FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
        camHUD.bgColor = 0x00000000;
        persistentDraw = true;
        persistentUpdate = true;

        // FlxG.cameras.setDefaultDrawTarget(FlxG.camera, true);

        camThingy = new FlxSprite(0, 0).loadGraphic(Paths.image('ui/camThingy', 'shared'));
        camThingy.cameras = [camHUD];
        camThingy.alpha = 0.5;
        add(camThingy);
        ui = new FlxSpriteGroup(0, 0);

        var addSpriteButton = new FlxUIButton(0, 0, "Add Sprite");
        addSpriteButton.cameras = [camHUD];
        

        ui.add(addSpriteButton);
        ui.cameras = [camHUD];
        add(ui);

        stage = Json.parse(File.getContent('${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/${stageFile}.json'));
        FlxG.camera.zoom = stage.defaultCamZoom == null ? 1 : stage.defaultCamZoom;

        bf = new FlxStageSprite(bfDefPos.x, bfDefPos.y);
        bf.type = "BF";

        gf = new FlxStageSprite(gfDefPos.x, gfDefPos.y);
        gf.type = "GF";

        dad = new FlxStageSprite(dadDefPos.x, dadDefPos.y);
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

        updateStageElements();
    }
    
    public function updateStageElements() {
        var alreadySpawnedSprites:Map<String, FlxStageSprite> = [];
        var toDelete:Array<FlxStageSprite> = [];
        for (e in members) {
            if (Std.isOfType(e, FlxStageSprite)) {
                var sprite = cast(e, FlxStageSprite);
                if (!doNotDelete.contains(sprite.type)) {
                    alreadySpawnedSprites[sprite.name] = sprite;
                    toDelete.push(sprite);
                }
                remove(sprite);
            }
        }
        for(s in stage.sprites) {
            if (alreadySpawnedSprites[s.name] != null) {
                toDelete.remove(alreadySpawnedSprites[s.name]);
                add(alreadySpawnedSprites[s.name]);
            } else {
                switch(s.type) {
                    case "SparrowAtlas":
                        var sprAtlas = Stage.generateSparrowAtlas(s, ToolboxHome.selectedMod);
                        trace(sprAtlas);
                        add(sprAtlas);
                    case "Bitmap":
                        var bMap = Stage.generateBitmap(s, ToolboxHome.selectedMod);
                        trace(bMap);
                        add(bMap);
                    case "BF":
                        // TODO
                        // add(Stage.generateBitmap(s, ToolboxHome.selectedMod));
                        add(bf);
                    case "GF":
                        // TODO
                        // add(Stage.generateBitmap(s, ToolboxHome.selectedMod));
                        add(gf);
                    case "Dad":
                        // TODO
                        // add(Stage.generateBitmap(s, ToolboxHome.selectedMod));
                        add(dad);
                    
                }
            }
        }
    }

    var moveOffset:FlxPoint = new FlxPoint(0, 0);
    var objBeingMoved:FlxStageSprite = null;

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
    }
    public override function update(elapsed:Float) {
        camThingy.scale.x = camThingy.scale.y = stage.defaultCamZoom * FlxG.camera.zoom;
        ui.scale.x = ui.scale.x = 1 / FlxG.camera.zoom;
        if (FlxG.mouse.wheel != 0 && objBeingMoved == null) {
            FlxG.camera.zoom += 0.1 * FlxG.mouse.wheel;
            if (FlxG.camera.zoom < 0.1) FlxG.camera.zoom = 0.1;
        }
        if (FlxG.keys.pressed.LEFT) {
            FlxG.camera.scroll.x -= elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / FlxG.camera.zoom;
        }
        if (FlxG.keys.pressed.RIGHT) {
            FlxG.camera.scroll.x += elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / FlxG.camera.zoom;
        }
        if (FlxG.keys.pressed.DOWN) {
            FlxG.camera.scroll.y += elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / FlxG.camera.zoom;
        }
        if (FlxG.keys.pressed.UP) {
            FlxG.camera.scroll.y -= elapsed * 250 * (FlxG.keys.pressed.SHIFT ? 2.5 : 1) / FlxG.camera.zoom;
        }
        if (FlxG.keys.pressed.BACKSPACE) {
            FlxG.camera.scroll.x = FlxG.camera.scroll.y = 0;
        }
        try {
            super.update(elapsed);
        } catch(e) {

        }
        var mousePos = FlxG.mouse.getScreenPosition(FlxG.camera);
        if (objBeingMoved != null) {
            if (FlxG.mouse.pressed) {
                // new FlxPointer().getScreenPosition();
                objBeingMoved.x = mousePos.x + moveOffset.x;
                objBeingMoved.y = mousePos.y + moveOffset.y;
                if (FlxG.mouse.wheel != 0) {
                    if (FlxG.keys.pressed.CONTROL) {
                        objBeingMoved.scale.x = objBeingMoved.scale.y = ((objBeingMoved.scale.x + objBeingMoved.scale.y) / 2) + (0.1 * FlxG.mouse.wheel);
                    }
                }
            } else {
                objBeingMoved = null;
                updateJsonData();
            }
        } else {
            var i = members.length - 1;
            while(i >= 0) {
                var s = members[i];
                if (Std.isOfType(s, FlxStageSprite)) {
                    var sprite = cast(s, FlxStageSprite);
                    if (overlaps(sprite, mousePos)) {
                        if (FlxG.mouse.justPressed) {
                            moveOffset.x = sprite.x - mousePos.x;
                            moveOffset.y = sprite.y - mousePos.y;
                            objBeingMoved = sprite;
                        }
                        break;
                    }
                }
                i--;
            }
        }

        for (e in members) {
            if (Std.isOfType(e, FlxUITypedButton)) {
                var el = cast(e, FlxUITypedButton<Dynamic>);
                el.scale.x = el.scale.y = 1;
            }
        }
    }

    function overlaps(sprite:FlxStageSprite, mousePos:FlxPoint):Bool {
        if (FlxG.mouse.overlaps(sprite)) {
            // if (sprite.type == "Bitmap") {
            //     var mPos = FlxG.mouse.getPosition();
            //     var rX = FlxG.camera.scroll.x + ((sprite.x - FlxG.camera.scroll.x) / sprite.scrollFactor.x);
            //     var rY = FlxG.camera.scroll.y + ((sprite.y - FlxG.camera.scroll.y) / sprite.scrollFactor.y);
            //     var pX = FlxMath.wrap(Std.int((mPos.x - rX) / (sprite.width) * sprite.pixels.width), 0, sprite.pixels.width);
            //     var pY = FlxMath.wrap(Std.int((mPos.y - rY) / (sprite.height) * sprite.pixels.height), 0, sprite.pixels.height);
            //     trace(pX);
            //     trace(pY);
                
            //     var pixel:FlxColor = sprite.pixels.getPixel32(pX, pY);
            //     sprite.pixels.setPixel32(pX, pY, 0xFFFFFFFF);
            //     if (pixel.alphaFloat < 0.1) {
            //         return false;
            //     } else {
            //         return true;
            //     }
            // } else {
                return true;
            // }
            
        }
        return false;
    }
}