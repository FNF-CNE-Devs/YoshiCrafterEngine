var oldCharacter:Character = null;
var newCharacter:Character = null;
var stage:Stage = null;
var gf:Character = null;

function create(){
    gf = PlayState.gf;
}

function bfSwitch(character:String, xPos:String, yPos:String) {
    PlayState.remove(PlayState.boyfriend);
    PlayState.boyfriend.destroy();
    PlayState.boyfriends = [new Boyfriend(Std.parseFloat(xPos), Std.parseFloat(yPos), mod + ":" + character)];
    PlayState.add(PlayState.boyfriend);
    PlayState.iconP1.changeCharacter(character, mod);
}

function dadSwitch(character:String, xPos:String, yPos:String) {
    PlayState.remove(PlayState.dad);
    newCharacter = new Character(Std.parseFloat(xPos), Std.parseFloat(yPos), mod + ":" + character);
    newCharacter.visible = false;
    PlayState.dads.push(newCharacter);
    PlayState.add(newCharacter);
    PlayState.iconP2.changeCharacter(character, mod);
    newCharacter.visible = true;
}

function dadAdd(character:String, xPos:String, yPos:String) {
    oldCharacter = PlayState.dad;
    newCharacter = new Character(Std.parseFloat(xPos), Std.parseFloat(yPos), mod + ":" + character);
    newCharacter.visible = false;
    PlayState.dads.push(newCharacter);
    PlayState.add(newCharacter);
    PlayState.iconP2.changeCharacter(character, mod);
    newCharacter.visible = true;
}

function bfAdd(character:String, xPos:String, yPos:String) {
    oldCharacter = PlayState.boyfriend;
    newCharacter = new Boyfriend(Std.parseFloat(xPos), Std.parseFloat(yPos), mod + ":" + character);
    newCharacter.visible = false;
    PlayState.boyfriends.push(newCharacter);
    PlayState.add(newCharacter);
    PlayState.iconP1.changeCharacter(character, mod);
    newCharacter.visible = true;
}

// function pixelbois(){
//     PlayState.iconP1.antialiasing = false;
//     PlayState.iconP2.antialiasing = false;

//     var pixelgf:FlxSprite;

//     pixelgf = new FlxSprite(80, 50);
//     pixelgf.frames = Paths.getSparrowAtlas('Pixel_gf');
//     pixelgf.animation.addByPrefix('dance', 'Pixel gf dance', 12, true);
//     pixelgf.animation.play('dance');
//     PlayState.add(pixelgf);
//     pixelgf.antialiasing = false;

//     PlayState.remove(PlayState.boyfriend);
//     PlayState.boyfriend.destroy();
//     var bf:Boyfriend;
//     PlayState.boyfriends = [bf = new Boyfriend(750, 100, mod + ":bfPixel")];
//     PlayState.iconP1.changeCharacter("bfPixel", mod);
//     bf.antialiasing = false;

//     oldCharacter = PlayState.dad;
//     PlayState.dads = [newCharacter = new Character(100, 100, mod + ":sonicpixel")];
//     PlayState.iconP2.changeCharacter("sonicpixel", mod);
//     newCharacter.antialiasing = false;

//     stage = loadStage("pixel");
//     global["stage"] = stage;
//     stage.onBeat();
//     stage.antialiasing = false;
// }

// function normbois(){
//     PlayState.iconP1.antialiasing = true;
//     PlayState.iconP2.antialiasing = true;

//     PlayState.remove(gf);
//     PlayState.dads = [gf = new Character(80, 50, "gf")];
//     PlayState.add(gf);
//     gf.updateHitbox();

//     PlayState.remove(PlayState.boyfriend);
//     PlayState.boyfriend.destroy();
//     var bf:Boyfriend;
//     PlayState.boyfriends = [bf = new Boyfriend(750, 100, 'bf')];
//     PlayState.iconP1.changeCharacter("bf");
//     PlayState.boyfriend.updateHitbox();

//     oldCharacter = PlayState.dad;
//     PlayState.dads = [newCharacter = new Character(100, 100, mod + ":sonicMad")];
//     PlayState.iconP2.changeCharacter("sonicMad", mod);
//     newCharacter.updateHitbox();

//     stage = loadStage("forest");
//     global["stage"] = stage;
//     stage.onBeat();
// }

//Pixel Sonic Pos (-110, -589)
//Pixel BF Pos (-25, -241)

// function gfSwitch(character:String){
//     var newCharacter = new Character(Std.parseFloat()); 
// }
