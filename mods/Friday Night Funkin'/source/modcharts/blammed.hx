var stage:Stage.Philly;

var bfDarkMode:BitmapData;
var picoDarkMode:BitmapData;
var gfDarkMode:BitmapData;
var ogBF:BitmapData;
var ogPico:BitmapData;
var ogGF:BitmapData;
var blackScreen:FlxSprite;

var bfDark:Boyfriend;
var dadDark:Character;
var gfDark:Character;

function create() {
    stage = PlayState.stage;
    
    if (EngineSettings.blammedEffect) {
        var cBF = EngineSettings.customBFSkin;
        if (!FileSystem.exists(Paths.getSkinsPath() + '/bf/$cBF/blammed.png')) {
            bfDarkMode = new BitmapData(PlayState.boyfriend.pixels.image.width, PlayState.boyfriend.pixels.image.height, true, 0xFF000000);
            bfDarkMode.lock();
            var bfBitmap:BitmapData = PlayState.boyfriend.pixels;
            for(x in 0...bfBitmap.width) {
                for (y in 0...bfBitmap.height) {
                    var color = new FlxColor(bfBitmap.getPixel32(x, y));
                    var average = (color.red + color.green + color.blue) / 3;
                    if (average < 50) {
                        var newColor:Float = (1 - (average / 50));
                        var c = 0xFFFFFFFF;
                        c.redFloat = newColor;
                        c.blueFloat = newColor;
                        c.greenFloat = newColor;
                        c.alphaFloat = color.alphaFloat;
                        bfDarkMode.setPixel32(x, y, c.color);
                    }
                }
            }
            bfDarkMode.unlock();
            File.saveBytes(Paths.getSkinsPath() + '/bf/$cBF/blammed.png', bfDarkMode.encode(bfDarkMode.rect, new PNGEncoderOptions(true)));
        }

        if (!FileSystem.exists(Paths.getSkinsPath() + '/bf/$cBF/blammed.xml')) File.copy(Paths.getSkinsPath() + '/bf/$cBF/spritesheet.xml', Paths.getSkinsPath() + '/bf/$cBF/blammed.xml');
        
        


        var cGF = EngineSettings.customGFSkin;
        if (!FileSystem.exists(Paths.getSkinsPath() + '/gf/$cGF/blammed.png')) {
            gfDarkMode = new BitmapData(PlayState.gf.pixels.image.width, PlayState.gf.pixels.image.height, true, 0xFF000000);
            gfDarkMode.lock();
            var gfBitmap:BitmapData = PlayState.gf.pixels;
            for(x in 0...gfBitmap.width) {
                for (y in 0...gfBitmap.height) {
                    var color = new FlxColor(gfBitmap.getPixel32(x, y));
                    var average = (color.red + color.green + color.blue) / 3;
                    if (average < 50) {
                        var newColor:Float = (1 - (average / 50)) * color.alphaFloat;
                        var c = new FlxColor(0xFFFFFFFF);
                        c.alphaFloat = newColor;
                        gfDarkMode.setPixel32(x, y, c.color);
                    }
                }
            }
            gfDarkMode.unlock();
            File.saveBytes(Paths.getSkinsPath() + '/gf/$cGF/blammed.png', gfDarkMode.encode(gfDarkMode.rect, new PNGEncoderOptions(true)));
        }
        if (!FileSystem.exists(Paths.getSkinsPath() + '/gf/$cGF/blammed.xml')) File.copy(Paths.getSkinsPath() + '/gf/$cGF/spritesheet.xml', Paths.getSkinsPath() + '/gf/$cGF/blammed.xml');

        gfDark = new Character(400, 130, PlayState.gf.curCharacter, false, "blammed");
        gfDark.visible = false;
        PlayState.add(gfDark);

        // bfDark = new Boyfriend(770, 100, PlayState.SONG.player1, EngineSettings.customBFSkin == "default" ? "BF_blammed" : "blammed");
        bfDark = new Boyfriend(770, 100, "BF_blammed");
        bfDark.visible = false;
        PlayState.add(bfDark);
        PlayState.boyfriends.push(bfDark);

        dadDark = new Character(100, 100, "pico-blammed");
        dadDark.visible = false;
        PlayState.dads.push(dadDark);
        PlayState.add(dadDark);
        

        // picoDarkMode = Paths.getBitmapOutsideAssets('assets/characters/PICO_blammed.png');
        // ogPico = PlayState.dad.pixels.clone();
        // ogBF = PlayState.boyfriend.pixels.clone();
        // ogGF = PlayState.gf.pixels.clone();

        blackScreen = new FlxSprite(0, 0).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
        blackScreen.cameras = [PlayState.camHUD];
        blackScreen.alpha = 0;
        PlayState.add(blackScreen);
    }
    
}
function beatHit(curBeat:Int) {
    if (gfDark != null) gfDark.dance();
    
    if (EngineSettings.blammedEffect) {
        if (curBeat == 128) {
            // switchBF(bfDarkMode);
            // switchGF(gfDarkMode);
            // switchPico(picoDarkMode);
            PlayState.currentBoyfriend = 1;
            PlayState.boyfriends[0].visible = false;
            PlayState.boyfriends[1].visible = true;
            PlayState.currentDad = 1;
            PlayState.dads[0].visible = false;
            PlayState.dads[1].visible = true;
            PlayState.gf.visible = false;
            gfDark.visible = true;

            blackScreen.alpha = 1;
            blackScreen.color = 0xFFFFFFFF;
            FlxTween.tween(blackScreen, {alpha : 0}, 2);
            stage.phillyTrain.visible = false;
            stage.bg.visible = false;
            stage.city.visible = false;
            stage.streetBehind.visible = false;
            stage.street.visible = false;
        }
        if (curBeat == 192) {
            // switchBF(ogBF);
            // switchGF(ogGF);
            // switchPico(ogPico);
            PlayState.currentBoyfriend = 0;
            PlayState.boyfriends[1].visible = false;
            PlayState.boyfriends[0].visible = true;
            PlayState.currentDad = 0;
            PlayState.dads[0].visible = true;
            PlayState.dads[1].visible = false;
            PlayState.gf.visible = true;
            gfDark.visible = false;
            
            blackScreen.alpha = 1;
            blackScreen.color = 0xFF000000;
            FlxTween.tween(blackScreen, {alpha : 0}, 2);
            stage.phillyTrain.visible = true;
            stage.bg.visible = true;
            stage.city.visible = true;
            stage.streetBehind.visible = true;
            stage.street.visible = true;
            PlayState.boyfriend.color = 0xFFFFFFFF;
            PlayState.dad.color = 0xFFFFFFFF;
            PlayState.gf.color = 0xFFFFFFFF;

            // picoDarkMode.dispose();
            // picoDarkMode.disposeImage();

            // bfDarkMode.dispose();
            // bfDarkMode.disposeImage();
        }
    }
    
    
    if (curBeat % 4 == 0) {
        if (curBeat >= 128 && curBeat < 192 && EngineSettings.blammedEffect) {
            PlayState.boyfriend.color = stage.light.color;
            PlayState.dad.color = stage.light.color;
            gfDark.color = stage.light.color;
            // PlayState.gf.color = stage.light.color;
        } else {
            PlayState.boyfriend.color = -1;
            PlayState.dad.color = -1;
            // PlayState.gf.color = -1;
        }
    }
}


function switchBF(newBitmap:BitmapData) {
    var cBF = EngineSettings.customBFSkin;
    var oldAnim = PlayState.boyfriend.animation.curAnim.name;
    PlayState.boyfriend.frames = FlxAtlasFrames.fromSparrow(newBitmap, Paths.getTextOutsideAssets('skins/bf/$cBF/spritesheet.xml'));
    // PlayState.boyfriend.pixels = bfDarkMode;
    
    PlayState.boyfriend.configureAnims();
    PlayState.boyfriend.playAnim(oldAnim);
}
function switchGF(newBitmap:BitmapData) {
    var cGF = EngineSettings.customGFSkin;
    var oldAnim = PlayState.gf.animation.curAnim.name;
    PlayState.gf.frames = FlxAtlasFrames.fromSparrow(newBitmap, Paths.getTextOutsideAssets('skins/gf/$cGF/spritesheet.xml'));
    // PlayState.gf.pixels = bfDarkMode;
    
    PlayState.gf.configureAnims();
    PlayState.gf.playAnim(oldAnim);
}

function switchPico(newBitmap:BitmapData) {
    var oldAnim = PlayState.dad.animation.curAnim.name;
    PlayState.dad.frames = FlxAtlasFrames.fromSparrow(newBitmap, Assets.getText("characters:assets/characters/Pico_FNF_assetss.xml"));
    PlayState.dad.animation.addByPrefix('idle', "Pico Idle Dance", 24);
    PlayState.dad.animation.addByPrefix('singUP', 'pico Up note0', 24, false);
    PlayState.dad.animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
    PlayState.dad.animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
    PlayState.dad.animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
    PlayState.dad.animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
    PlayState.dad.animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
    PlayState.dad.animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
    PlayState.dad.animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);
    PlayState.dad.playAnim(oldAnim);
}