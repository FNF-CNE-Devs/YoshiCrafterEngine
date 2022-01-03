# Yoshi Engine's documentation - Stages
In each mod, every stages is located under `/mods/(Your Mod)/stages/`. Each stage is represented by a hx file.

---
## Stage Documentation

---
**`create():Void`**

Fired during the stage creation, **before Boyfriend, Girlfriend and Dad are created**.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- `gfVersion:String` - Girlfriend's sprite version. Only have effect in create();
- [Every other default variables](defaultVars.md)

Example usage :
```haxe
function create() {
    // Creates a sprite, loads a graphica and adds it.
    var sprite = new FlxSprite(100, 100);
    var tex = Paths.getSparrowAtlas("sprite");
    sprite.frames = tex;
    sprite.animation.add("animation name", "XML (Animate) name", 24, true);
    sprite.animation.play("animation name");
    PlayState.add(sprite);
}
```

---
**`createAfterChars():Void`**

Fired after Boyfriend, Girlfriend and Dad are created, but not added yet. Useful for applying offsets on them.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- [Every other default variables](defaultVars.md)

Example usage :
```haxe
function createAfterChars() {
    // Moves BF by 100 pixels to the right.
    PlayState.boyfriend.x += 100;
}
```

---
**`createAfterGf():Void`**

Fired after Girlfriend have been added in the stage, but before Boyfriend and Dad are added. Useful for layering between Girlfriend and Dad & BF.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- [Every other default variables](defaultVars.md)

Example usage :
```haxe
function createAfterGf() {
    add(spriteThatNeedsToBeBetweenGFandBF);
}
```

---
**`createInFront():Void`**

Fired after all of the characters have been added. Useful for adding sprites in front of everything.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- [Every other default variables](defaultVars.md)

---
**`createInFront():Void`**

Fired after all of the characters have been added. Useful for adding sprites in front of everything.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- [Every other default variables](defaultVars.md)

---
**`musicstart():Void`**

Fired when the countdown finished and the music starts

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- [Every other default variables](defaultVars.md)

---
**`update(elapsed:Float):Void`**

Fired every frames. Does not fire when in cutscene.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- [Every other default variables](defaultVars.md)


Example usage :
```haxe
function update(elapsed:Float) {
    // Spins the dad
    PlayState.dad.angle = (PlayState.dad.angle + (180 * elapsed)) % 360;
}
```
---
**`stepHit(curStep:Int):Void`**

Fired every step.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- [Every other default variables](defaultVars.md)


Example usage :
```haxe
function stepHit(curStep:Int) {
    // i have no example here lmao
}
```
---
**`beatHit(curBeat:Int):Void`**

Fired every beat.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- [Every other default variables](defaultVars.md)


Example usage :
```haxe
function beatHit(curBeat:Int) {
    // Makes a sprite dance.
    sprite.animation.play("dance");
}
```