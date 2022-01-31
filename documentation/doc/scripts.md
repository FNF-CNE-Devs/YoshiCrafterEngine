# Yoshi Engine's documentation - Stages
In each mod, every stages is located under `/mods/(Your Mod)/stages/`. Each stage is represented by a hx file.

---
## Scripts Documentation

/!\ NOTE : Lua functions that have parameters that Lua does not support will instead send `nil` as the parameter. To access it, use the global `parameter(number)` (ex : `parameter1`) to access it like this :
```lua
function onDadHit(note)
    -- note is nil, use this instead
    local strumTime = get("parameter1.strumTime");
end
```

---
**`create():Void`**
**`createAfterChars():Void`** (runs after create())

Fired first, **after GF, BF and Dad are created**.

Available variables :
- `botplay:Bool` - Whenever the player is in botplay or not.
- `gfVersion:String` - Girlfriend's sprite version. Only have effect outside of functions (above)
- [Every other default variables](defaultVars.md)

Example usage :
```haxe
gfVersion = "gf-car";
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
```haxe
function create() {
    // Layering example
    var sprite = new FlxSprite(100, 100);
    var tex = Paths.getSparrowAtlas("sprite");
    sprite.frames = tex;
    sprite.animation.add("animation name", "XML (Animate) name", 24, true);
    sprite.animation.play("animation name");
    // Adds GF
    PlayState.add(PlayState.gf);
    // Adds the sprite in front of Girlfriend
    PlayState.add(sprite);
}
```
---
**`createInFront():Void`**
Same as `create()` excepts run after GF, BF and Dad are added in stage.

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
---
**`onDadHit(note:Note):Void`**

Fired when the opponent (dad) hits a note.

Available variables :
- [All default variables](defaultVars.md)


Example usage :
```haxe
function onDadHit(note:Note) {
    // i have no example here lmao
}
```
---
**`onPlayerHit(note:Note):Void`**

Fired when BF (the player) hits a note.

Available variables :
- [All default variables](defaultVars.md)


Example usage :
```haxe
function onPlayerHit(note:Note) {
    // i have no example here lmao
}
```