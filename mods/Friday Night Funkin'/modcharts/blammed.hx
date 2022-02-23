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
    
    phillyTrain = global['phillyTrain'];
    bg = global['bg'];
    city = global['city'];
    street = global['street'];
    streetBehind = global['streetBehind'];
    light = global['light'];
    if (EngineSettings.blammedEffect) {
        PlayState.boyfriend.shader = new CustomShader("Friday Night Funkin':blammed");
        PlayState.boyfriend.shader.shaderData.enabled.value = [false];

        PlayState.dad.shader = new CustomShader("Friday Night Funkin':blammed");
        PlayState.dad.shader.shaderData.enabled.value = [false];

        PlayState.gf.shader = new CustomShader("Friday Night Funkin':blammed");
        PlayState.gf.shader.shaderData.enabled.value = [false];

    }
}

function update(elapsed) {
    if (PlayState.iconP1 != null) {
        if (PlayState.iconP1.shader == null) {
            PlayState.iconP1.shader = new CustomShader("Friday Night Funkin':blammed");
            PlayState.iconP1.shader.shaderData.enabled.value = [false];
        }
    }
    if (PlayState.iconP2 != null) {
        if (PlayState.iconP2.shader == null) {
            PlayState.iconP2.shader = new CustomShader("Friday Night Funkin':blammed");
            PlayState.iconP2.shader.shaderData.enabled.value = [false];
        }
    } 
    if (PlayState.healthBarBG != null) {
        if (PlayState.healthBarBG.shader == null) {
            PlayState.healthBarBG.shader = new CustomShader("Friday Night Funkin':blammed");
            PlayState.healthBarBG.shader.shaderData.enabled.value = [false];
        }
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

            PlayState.boyfriend.shader.shaderData.enabled.value = [true];
            PlayState.dad.shader.shaderData.enabled.value = [true];
            PlayState.gf.shader.shaderData.enabled.value = [true];
            PlayState.iconP1.shader.shaderData.enabled.value = [true];
            PlayState.iconP2.shader.shaderData.enabled.value = [true];
            PlayState.healthBarBG.shader.shaderData.enabled.value = [true];
            PlayState.healthBar.visible = false;

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
            
            phillyTrain.visible = true;
            bg.visible = true;
            city.visible = true;
            streetBehind.visible = true;
            street.visible = true;
            
            PlayState.boyfriend.shader.shaderData.enabled.value = [false];
            PlayState.dad.shader.shaderData.enabled.value = [false];
            PlayState.gf.shader.shaderData.enabled.value = [false];
            PlayState.iconP1.shader.shaderData.enabled.value = [false];
            PlayState.iconP2.shader.shaderData.enabled.value = [false];
            PlayState.healthBarBG.shader.shaderData.enabled.value = [false];
            PlayState.healthBar.visible = true;

            // picoDarkMode.dispose();
            // picoDarkMode.disposeImage();

            // bfDarkMode.dispose();
            // bfDarkMode.disposeImage();
        }
    }
    
    
    if (curBeat % 4 == 0) {
        var color = new FlxColor(light.color);
		for (i in [PlayState.boyfriend, PlayState.gf, PlayState.dad, PlayState.iconP1, PlayState.iconP2, PlayState.healthBarBG]) {
			i.shader.shaderData.r.value = [color.redFloat];
			i.shader.shaderData.g.value = [color.greenFloat];
			i.shader.shaderData.b.value = [color.blueFloat];
		}
		/*
        .shader.setColors(color.red, color.green, color.blue);
        PlayState.dad.shader.setColors(color.red, color.green, color.blue);
        PlayState.gf.shader.setColors(color.red, color.green, color.blue);
        PlayState.iconP1.shader.setColors(color.red, color.green, color.blue);
        PlayState.iconP2.shader.setColors(color.red, color.green, color.blue);
        PlayState.healthBarBG.shader.setColors(color.red, color.green, color.blue);
		*/
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