var stage = null;

var bfDarkMode:BitmapData = null;
var picoDarkMode:BitmapData = null;
var gfDarkMode:BitmapData = null;
var ogBF:BitmapData = null;
var ogPico:BitmapData = null;
var ogGF:BitmapData = null;
var blackScreen:FlxSprite = null;

var bfDark:Boyfriend = null;
var dadDark:Character = null;
var gfDark:Character = null;

var phillyTrain:FlxSprite = null;
var bg:FlxSprite = null;
var city:FlxSprite = null;
var streetBehind:FlxSprite = null;
var street:FlxSprite = null;
var light:FlxSprite = null;

function create() {
    stage = PlayState_.stage;
    
    phillyTrain = getStageVar('phillyTrain');
    bg = getStageVar('bg');
    city = getStageVar('city');
    street = getStageVar('street');
    streetBehind = getStageVar('streetBehind');
    light = getStageVar('light');
    
    if (EngineSettings.blammedEffect) {

        trace("creating gf");
        gfDark = new Character(400, 130, "gf", false, true);
        gfDark.pixels.copyPixels(BitmapDataPlus.GenerateBlammedEffect(gfDark.pixels.clone(), 0xFF000000, 0xFFFFFFFF), new Rectangle(0, 0, gfDark.pixels.width, gfDark.pixels.height), new Point(0,0));
        gfDark.visible = false;
        gfDark.setPosition(PlayState.gf.x, PlayState.gf.y);
        PlayState.add(gfDark);

        // bfDark = new Boyfriend(770, 100, PlayState.SONG.player1, EngineSettings.customBFSkin == "default" ? "BF_blammed" : "blammed");
        
        trace("creating bf");
        bfDark = new Character(400, 130, PlayState.song.player1, false, true);
        bfDark.pixels.copyPixels(BitmapDataPlus.GenerateBlammedEffect(bfDark.pixels.clone(), 0xFF000000, 0xFFFFFFFF), new Rectangle(0, 0, bfDark.pixels.width, bfDark.pixels.height), new Point(0,0));
        bfDark.visible = false;
        bfDark.flipX = !bfDark.flipX;
        bfDark.setPosition(PlayState.boyfriend.x, PlayState.boyfriend.y);
        PlayState.boyfriends.push(bfDark);
        PlayState.add(bfDark);

        trace("creating pico");
        dadDark = new Character(400, 130, PlayState.song.player2, false, true);
        dadDark.pixels.copyPixels(BitmapDataPlus.GenerateBlammedEffect(dadDark.pixels.clone(), 0xFF000000, 0xFFFFFFFF), new Rectangle(0, 0, dadDark.pixels.width, dadDark.pixels.height), new Point(0,0));
        dadDark.visible = false;
        dadDark.setPosition(PlayState.dad.x, PlayState.dad.y);
        PlayState.dads.push(dadDark);
        PlayState.add(dadDark);
        
        trace("done");

        // picoDarkMode = Paths.getBitmapOutsideAssets('assets/characters/PICO_blammed.png');
        // ogPico = PlayState.dad.pixels.clone();
        // ogBF = PlayState.boyfriend.pixels.clone();
        // ogGF = PlayState.gf.pixels.clone();

        // blackScreen = new FlxSprite(0, 0).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
        // blackScreen.cameras = [PlayState.camHUD];
        // blackScreen.alpha = 0;
        // PlayState.add(blackScreen);
    }
}
function beatHit(curBeat:Int) {
    if (gfDark != null) gfDark.dance();
    
    if (EngineSettings.blammedEffect) {
        if (curBeat == 128) {
            // switchBF(bfDarkMode);
            // switchGF(gfDarkMode);
            // switchPico(picoDarkMode);
            FlxG.camera.flash(0xFFFFFFFF, 2);
            PlayState.currentBoyfriend = 1;
            PlayState.boyfriends[0].visible = false;
            PlayState.boyfriends[1].visible = true;
            PlayState.currentDad = 1;
            PlayState.dads[0].visible = false;
            PlayState.dads[1].visible = true;
            PlayState.gf.visible = false;
            gfDark.visible = true;


            phillyTrain.visible = false;
            bg.visible = false;
            city.visible = false;
            streetBehind.visible = false;
            street.visible = false;
        }
        if (curBeat == 192) {
            // switchBF(ogBF);
            // switchGF(ogGF);
            // switchPico(ogPico);
            FlxG.camera.flash(0xFF000000, 2);
            PlayState.currentBoyfriend = 0;
            PlayState.boyfriends[1].visible = false;
            PlayState.boyfriends[0].visible = true;
            PlayState.currentDad = 0;
            PlayState.dads[0].visible = true;
            PlayState.dads[1].visible = false;
            PlayState.gf.visible = true;
            gfDark.visible = false;
            
            phillyTrain.visible = true;
            bg.visible = true;
            city.visible = true;
            streetBehind.visible = true;
            street.visible = true;
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
            PlayState.boyfriend.color = light.color;
            PlayState.dad.color = light.color;
            gfDark.color = light.color;
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
    PlayState.boyfriend.frames = FlxAtlasFrames.fromSparrow(newBitmap, Paths.getTextOutsideAssets('skins/bf/' + cBF + '/spritesheet.xml'));
    // PlayState.boyfriend.pixels = bfDarkMode;
    
    PlayState.boyfriend.configureAnims();
    PlayState.boyfriend.playAnim(oldAnim);
}
function switchGF(newBitmap:BitmapData) {
    var cGF = EngineSettings.customGFSkin;
    var oldAnim = PlayState.gf.animation.curAnim.name;
    PlayState.gf.frames = FlxAtlasFrames.fromSparrow(newBitmap, Paths.getTextOutsideAssets('skins/gf/' + cGF + '/spritesheet.xml'));
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