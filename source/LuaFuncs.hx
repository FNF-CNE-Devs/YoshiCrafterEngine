import flixel.tweens.misc.VarTween;
import hscript.Interp;
import flixel.ui.FlxBar;
import openfl.display.ShaderInput;
import haxe.Json;
import openfl.display.ShaderParameter;
import TaggedElement.FlxTagText;
import flixel.text.FlxText;
import openfl.system.System;
import flixel.FlxState;
import mod_support_stuff.ModState;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;
#if ENABLE_LUA
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.FlxObject;
import TaggedElement.FlxTagSprite;
import haxe.io.Path;
import openfl.utils.Assets;
import llua.Lua.Lua_helper;
import Script.LuaScript;
import flixel.FlxG;
import flixel.FlxSprite;

// TIP: PRESS CTRL+K+0 ON VISUAL STUDIO CODE
// THEN UNFOLD THE CLASS THEN THE CONSTRUCTOR (NEW) TO GET A CLEAN LIST OF ALL FUNCTIONS

class LuaFuncs {
    /**
        static cause im lazy
    **/
    public static function addCallbacks(script:LuaScript) {
        return new LuaFuncs(script);
    }

    /**
        non static
    **/
    public var cameras:Map<String, FlxCamera> = [];
    public var script:LuaScript;

    function getCam(cam:Dynamic) {
        if (cam is String) {
            var camName = cast(cam, String).toLowerCase();
            if (cameras[camName] == null) {
                script.trace('Camera ${camName} was not found.', true);
                return null;
            }
            return cameras[camName];
        } else if (cam is Int) {
            var cam = FlxG.cameras.list[cast(cam, Int)];
            if (cam == null) {
                script.trace('Camera with ID ${cam} is either null or out of range (Range: 0-${FlxG.cameras.list.length}).', true);
                return null;
            }
            return cam;
        } else {
            script.trace('Parameter ${cam} is invalid', true);
            return null;
        }
    }
    
    function getSprite(tag:String, checkEverywhere:Bool = true):FlxObject {
        if (tag.charAt(0) == script.zws) tag = tag.substr(1);
        var sprite = script.variables[tag];
        var scriptObject = script.scriptObject;
        if (!(sprite is FlxObject)) {
            sprite = null;
        }
        if (sprite == null && checkEverywhere) {
            var el:FlxObject = null;
            FlxG.state.forEach(function(s) {
                if (el != null) return; // theres no way to stop a loop like that so
                if (s is TaggedElement) {
                    var s:TaggedElement = cast(s);
                    if (s.tag == tag)
                        el = cast s;
                }
            });
            if (el == null) {
                if (scriptObject != null) {
                    var _spr = Reflect.getProperty(scriptObject, tag);
                    if (_spr is FlxObject) {
                        el = _spr;
                    }
                }
                if (el == null)
                    script.trace('Sprite named ${tag} not found.', true);   
            }
            return cast el;
        }
        if (sprite == null)
            script.trace('Sprite named ${tag} not found.', true);
        return sprite;
    }

    // function getVariable(tag:String) {
    //     if (tag.charAt(0) == script.zws) tag = tag.substr(1);
    //     if (script.variables[tag] != null)
    //         return script.variables[tag];
    //     if (script.scriptObject != null) {
    //         var val = Reflect.getProperty(script.scriptObject, tag);
    //         return val;
    //     }
    // }

    function getShader(name:String, warn:Bool = true):CustomShader {
        if (script.variables[name] == null) {
            if (warn) script.trace('Shader with name ${name} wasn\'t found.', true);
            return null;
        }
        if (!(script.variables[name] is CustomShader)) {
            if (warn) script.trace('Variable with name ${name} is not a shader.', true);
            return null;
        }
        return cast script.variables[name];
    }

    function getColor(color:Dynamic, defaultColor:Null<FlxColor> = -1):Null<FlxColor> {
        var c:Null<FlxColor> = 0xFFFFFFFF;
        if (color is String) {
            c = FlxColor.fromString(color);
            if (c == null)
                c = 0xFFFFFFFF;
        } else if (color is Int) {
            c = cast color;
        }
        return c == null ? defaultColor : c;
    }
    public function new(script:LuaScript) {
        this.script = script;
        script.luaFuncs = this;

        if (FlxG.state is MusicBeatState)
            cast(FlxG.state, MusicBeatState).addLuaCallbacks(script);

        var state = script.state;

        /**
            SPRITES
        **/
        script.addLuaCallback("createSprite", function(tag:String, x:Float, y:Float, spritePath:String, isGridSprite:Bool, width:Int, height:Int) {
            if (script.variables.exists(tag)) {
                script.trace('Variable named ${tag} already exists and will be overriden. If you dont want this message to reappear, use the "clearVariable" function.');
            }
            var sprite = new FlxTagSprite(x, y);
            sprite.tag = tag;
            sprite.antialiasing = true;
            if (spritePath != null) {
                var path = Assets.exists(spritePath) ? spritePath : Paths.image(spritePath); // in case someone uses get("Paths.image", {"image"})
                var noExt = Path.withoutExtension(path);
                var xml = '${noExt}.xml';
                var txt = '${noExt}.txt';
                if (Assets.exists(xml)) {
                    // is sparrow
                    sprite.frames = Paths.getSparrowAtlas(spritePath);
                } else if (Assets.exists(txt)) {
                    sprite.frames = Paths.getPackerAtlas(spritePath);
                } else {
                    sprite.loadGraphic(path, isGridSprite, width, height);
                }
            }
            script.variables.set(tag, sprite);
        });
        script.addLuaCallback("getSpritePosition", function(tag:String) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                LuaScript.callbackReturnVariables = [sprite.x, sprite.y];
                return true;
            }
            return false;
        });
        script.addLuaCallback("getSpriteInfo", function(tag:String) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                var table = {
                    x: sprite.x,
                    y: sprite.y,
                    width: sprite.width,
                    height: sprite.height,
                    angle: sprite.angle,
                    scaleX: 0.0,
                    scaleY: 0.0,
                    scale: 0.0,
                    tag: null
                };
                if (sprite is FlxSprite) {
                    var spr = cast(sprite, FlxSprite);
                    table.scaleX = spr.scale.x;
                    table.scaleY = spr.scale.y;
                    table.scale = (spr.scale.x + spr.scale.y) / 2;
                }
                if (sprite is TaggedElement)
                    table.tag = cast(sprite, TaggedElement).tag;
                return table;
            }
            return null;
        });
        script.addLuaCallback("getSprite", function(tag:String, lookEverywhere:Bool = true) {
            var e = getSprite(tag, lookEverywhere);
            if (e != null) {
                script.variables[tag] = e;
                return '${script.zws}${tag}';
            }
            return null;
        });
        script.addLuaCallback("getSpriteX", function(tag:String) {
            var sprite = getSprite(tag, true);
            if (sprite != null)
                return sprite.x;
            return 0;
        });
        script.addLuaCallback("getSpriteY", function(tag:String) {
            var sprite = getSprite(tag, true);
            if (sprite != null)
                return sprite.y;
            return 0;
        });
        script.addLuaCallback("getSpriteAngle", function(tag:String) {
            var sprite = getSprite(tag, true);
            if (sprite != null)
                return sprite.angle;
            return 0;
        });
        script.addLuaCallback("setSpriteAngle", function(tag:String, angle:Float) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                sprite.angle = angle;
                return true;
            }
            return false;
        });
        script.addLuaCallback("getSpriteAlpha", function(tag:String) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    return cast(sprite, FlxSprite).alpha;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return -1;
                }
            }
            return -1;
        });
        script.addLuaCallback("setSpriteAlpha", function(tag:String, alpha:Float) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    cast(sprite, FlxSprite).alpha = alpha;
                    return true;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return false;
                }
            }
            return false;
        });
        script.addLuaCallback("getSpriteScale", function(tag:String) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    var spr = cast(sprite, FlxSprite);
                    return (spr.scale.x + spr.scale.y) / 2;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return -1;
                }
            }
            return -1;
        });
        script.addLuaCallback("setSpriteScale", function(tag:String, scale:Float) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    cast(sprite, FlxSprite).scale.set(scale, scale);
                    return true;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return false;
                }
            }
            return false;
        });
        script.addLuaCallback("getSpriteScaleX", function(tag:String) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    var spr = cast(sprite, FlxSprite);
                    return spr.scale.x;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return -1;
                }
            }
            return -1;
        });
        script.addLuaCallback("setSpriteScaleX", function(tag:String, scale:Float) {
                var sprite = getSprite(tag, true);
                if (sprite != null) {
                    if (sprite is FlxSprite) {
                        cast(sprite, FlxSprite).scale.x = scale;
                        return true;
                    } else {
                        script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                        return false;
                    }
                }
                return false;
        });
        script.addLuaCallback("getSpriteScaleY", function(tag:String) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    var spr = cast(sprite, FlxSprite);
                    return spr.scale.y;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return -1;
                }
            }
            return -1;
        });
        script.addLuaCallback("setSpriteScaleY", function(tag:String, scale:Float) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    cast(sprite, FlxSprite).scale.y = scale;
                    return true;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return false;
                }
            }
            return false;
        });
        script.addLuaCallback("getSpriteOffsetX", function(tag:String) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    var spr = cast(sprite, FlxSprite);
                    return spr.offset.x;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return -1;
                }
            }
            return -1;
        });
        script.addLuaCallback("getSpriteOffsetY", function(tag:String) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    var spr = cast(sprite, FlxSprite);
                    return spr.offset.y;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return -1;
                }
            }
            return -1;
        });
        script.addLuaCallback("setSpriteOffset", function(tag:String, x:Null<Float>, y:Null<Float>) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    var sprite = cast(sprite, FlxSprite);
                    if (x != null) sprite.offset.x = x;
                    if (y != null) sprite.offset.y = y;
                    return true;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return false;
                }
            }
            return false;
        });
        script.addLuaCallback("setSpriteGraphicSize", function(tag:String, width:Int, height:Int, updateHitbox:Bool = true) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    var spr = cast(sprite, FlxSprite);
                    spr.setGraphicSize(width, height);
                    if (updateHitbox) spr.updateHitbox();
                    return true;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return false;
                }
            }
            return false;
        });
        script.addLuaCallback("updateSpriteHitbox", function(tag:String) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    cast(sprite, FlxSprite).updateHitbox();
                    return true;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return false;
                }
            }
            return false;
        });
        script.addLuaCallback("getSpriteAntialiasing", function(tag:String):Null<Bool> {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    return cast(sprite, FlxSprite).antialiasing;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return null;
                }
            }
            return null;
        });
        script.addLuaCallback("setSpriteAntialiasing", function(tag:String, aa:Bool):Bool {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    cast(sprite, FlxSprite).antialiasing = aa;
                    return true;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return false;
                }
            }
            return false;
        });
        script.addLuaCallback("getSpriteFlipX", function(tag:String):Null<Bool> {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    return cast(sprite, FlxSprite).flipX;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return null;
                }
            }
            return null;
        });
        script.addLuaCallback("setSpriteFlipX", function(tag:String, flip:Bool):Bool {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    cast(sprite, FlxSprite).flipX = flip;
                    return true;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return false;
                }
            }
            return false;
        });
        script.addLuaCallback("getSpriteFlipY", function(tag:String):Null<Bool> {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    return cast(sprite, FlxSprite).flipY;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return null;
                }
            }
            return null;
        });
        script.addLuaCallback("setSpriteFlipY", function(tag:String, flip:Bool):Bool {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    cast(sprite, FlxSprite).flipY = flip;
                    return true;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return false;
                }
            }
            return false;
        });
        script.addLuaCallback("getSpriteVisible", function(tag:String):Null<Bool> {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    return cast(sprite, FlxSprite).visible;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return null;
                }
            }
            return null;
        });
        script.addLuaCallback("setSpriteVisible", function(tag:String, visible:Bool):Bool {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    cast(sprite, FlxSprite).visible = visible;
                    return true;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return false;
                }
            }
            return false;
        });
        script.addLuaCallback("applySpriteInfo", function(info:Dynamic, tag:String) {
            if (info == null || !(info is Dynamic)) {
                // wrong type
                script.trace('Could not apply info to sprite. "info" parameter is not valid.', true);
            }
            var tag = tag;
            if (tag == null) tag = info.tag;
            if (tag == null) {
                script.trace('Tag cannot be null.', true);
                return false;
            }

            var sprite = getSprite(tag);
            if (sprite == null) {
                return false;
            }
            var fields = Reflect.fields(info);
            for(f in fields) {
                switch(f) {
                    case "x":       sprite.x = info.x;
                    case "y":       sprite.y = info.y;
                    case "width":   sprite.width = info.width;
                    case "height":  sprite.height = info.height;
                    case "angle":   sprite.angle = info.angle;
                    case "scale":   if (sprite is FlxSprite) cast(sprite, FlxSprite).scale.set(info.scale, info.scale);
                    case "scaleX":  if (sprite is FlxSprite) cast(sprite, FlxSprite).scale.x = info.scaleX;
                    case "scaleY":  if (sprite is FlxSprite) cast(sprite, FlxSprite).scale.y = info.scaleY;
                }
            }

            return true;
        });
        script.addLuaCallback("setSpritePosition", function(tag:String, x:Dynamic, y:Null<Float>) {
            var realX:Null<Float> = null;
            var realY:Null<Float> = null;
            if (x is Array) {
                realX = x[0];
                realY = x[1];
            } else {
                realX = x;
                realY = y;
            }
            var sprite = getSprite(tag);
            if (sprite == null) {
                script.trace('Sprite named ${tag} not found.');
                return;
            }
            if (realX != null) sprite.x = realX;
            if (realY != null) sprite.y = realY;
        });
        script.addLuaCallback("setSpriteCamera", function(tag:String, cam:Dynamic, lookEverywhere:Bool = true) {
            var e = getSprite(tag, lookEverywhere);
            if (e != null){
                var cam = getCam(cam);
                if (cam != null) {
                    e.cameras = [cam];
                    return true;
                }
            }
            return false;
        });
        script.addLuaCallback("setSpriteColor", function(tag:String, color:Dynamic, lookEverywhere:Bool = true) {
            var e = getSprite(tag, lookEverywhere);
            if (e != null){
                var color = getColor(color, -1);
                if (e is FlxSprite) {
                    cast(e, FlxSprite).color = color;
                    return true;
                }
            }
            return false;
        });
        script.addLuaCallback("setSpriteFlip", function(tag:String, flipX:Null<Bool>, flipY:Null<Bool>, lookEverywhere:Bool = true) {
            var e = getSprite(tag, lookEverywhere);
            if (e != null){
                if (e is FlxSprite) {
                    var sprite = cast(e, FlxSprite);
                    if (flipX != null) sprite.flipX = flipX;
                    if (flipY != null) sprite.flipY = flipY;
                    return true;
                }
            }
            return false;
        });
        script.addLuaCallback("setSpriteScrollFactor", function(tag:String, scrollX:Null<Float>, scrollY:Null<Float>, lookEverywhere:Bool = true) {            
            var e = getSprite(tag, lookEverywhere);
            if (e != null) {
                if (scrollX != null) e.scrollFactor.x = scrollX;
                if (scrollY != null) e.scrollFactor.y = scrollY;
                return true;
            }
            return false;
        });
        script.addLuaCallback("getSpriteScrollFactorX", function(tag:String, lookEverywhere:Bool = true):Null<Float> {
            var e = getSprite(tag, lookEverywhere);
            if (e != null) {
                return e.scrollFactor.x;
            }
            return null;
        });
        script.addLuaCallback("getSpriteScrollFactorY", function(tag:String, lookEverywhere:Bool = true):Null<Float> {            
            var e = getSprite(tag, lookEverywhere);
            if (e != null) {
                return e.scrollFactor.y;
            }
            return null;
        });
        script.addLuaCallback("addSprite", function(tag:String, lookEverywhere:Bool = true) {
            var e = getSprite(tag, lookEverywhere);
            if (e == null)
                return false;
            FlxG.state.add(e);
            return true;
        });
        script.addLuaCallback("setSpriteVelocity", function(tag:String, x:Null<Float>, y:Null<Float>) {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    var sprite = cast(sprite, FlxSprite);
                    if (x != null) sprite.velocity.x = x;
                    if (y != null) sprite.velocity.y = y;
                    return true;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return false;
                }
            }
            return false;
        });
        script.addLuaCallback("getSpriteVelocityX", function(tag:String):Null<Float> {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    var sprite = cast(sprite, FlxSprite);
                    return sprite.velocity.x;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return null;
                }
            }
            return null;
        });
        script.addLuaCallback("getSpriteVelocityY", function(tag:String):Null<Float> {
            var sprite = getSprite(tag, true);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    var sprite = cast(sprite, FlxSprite);
                    return sprite.velocity.y;
                } else {
                    script.trace('Sprite named ${tag} is not an FlxSprite.', true);
                    return null;
                }
            }
            return null;
        });

        /**
            TEXT
        **/
        script.addLuaCallback("createText", function(tag:String, x:Float, y:Float, value:String, width:Int, color:Dynamic):String {
            if (tag == null) {
                script.trace('Text sprite\'s name cannot be null.', true);
                return null;
            }
            var text = new FlxTagText(x, y, width, value == null ? "" : value);
            text.tag = tag;
            var color = getColor(color, 0xFFFFFFFF);
            text.color = color;
            script.variables.set(tag, text);
            return '${script.zws}${tag}';
        });
        script.addLuaCallback("setTextValue", function(tag:String, text:String) {
            var textBox = getSprite(tag);
            if (textBox == null) return false;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return false;
            }
            if (text == null) text = "";
            cast(textBox, FlxText).text = text;
            return true;
        });
        script.addLuaCallback("getTextValue", function(tag:String):String {
            var textBox = getSprite(tag);
            if (textBox == null) return null;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return null;
            }
            return cast(textBox, FlxText).text;
        });
        script.addLuaCallback("setTextBorderStyle", function(tag:String, _style:String) {
            var style:FlxTextBorderStyle = switch(_style.toLowerCase()) {
                case "shadow":
                    SHADOW;
                case "outline":
                    OUTLINE;
                case "outline fast" | "outline2" | "outlinefast" | "outline_fast" | "outline-fast":
                    OUTLINE_FAST;
                case "none" | null:
                    NONE;
                default:
                    null;
            }
            if (style == null) {
                script.trace('Style "${_style}" is incorrect.', true);
                return false;
            }

            var textBox = getSprite(tag);
            if (textBox == null) return false;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return false;
            }
            cast(textBox, FlxText).borderStyle = style;
            return true;
        });
        script.addLuaCallback("setTextBorderSize", function(tag:String, size:Float = 0) {
            var textBox = getSprite(tag);
            if (textBox == null) return false;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return false;
            }
            cast(textBox, FlxText).borderSize = size;
            return true;
        });
        script.addLuaCallback("setTextBorderColor", function(tag:String, color:Dynamic) {
            var textBox = getSprite(tag);
            if (textBox == null) return false;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return false;
            }
            var c = getColor(color, FlxColor.BLACK);
            cast(textBox, FlxText).borderColor = c;
            return true;
        });
        script.addLuaCallback("setTextBorder", function(tag:String, _style:Dynamic, size:Float = 1, color:Dynamic) {
            var style:FlxTextBorderStyle = switch(_style.toLowerCase()) {
                case "shadow":
                    SHADOW;
                case "outline":
                    OUTLINE;
                case "outline fast" | "outline2" | "outlinefast" | "outline_fast" | "outline-fast":
                    OUTLINE_FAST;
                case "none" | null:
                    NONE;
                default:
                    null;
            }
            if (style == null) {
                script.trace('Style "${_style}" is incorrect.', true);
                return false;
            }

            var textBox = getSprite(tag);
            if (textBox == null) return false;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return false;
            }
            var c = getColor(color, FlxColor.BLACK);
            var text = cast(textBox, FlxText);
            text.borderStyle = style;
            text.borderColor = c;
            text.borderSize = size;
            return true;
        });
        script.addLuaCallback("setTextColor", function(tag:String, color:Dynamic) {
            var textBox = getSprite(tag);
            if (textBox == null) return false;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return false;
            }
            var c = getColor(color, FlxColor.BLACK);
            cast(textBox, FlxText).color = c;
            return true;
        });
        script.addLuaCallback("getTextColor", function(tag:String):Null<Int> {
            var textBox = getSprite(tag);
            if (textBox == null) return null;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return null;
            }
            return cast(textBox, FlxText).color;
        });
        script.addLuaCallback("getTextFont", function(tag:String):String {
            var textBox = getSprite(tag);
            if (textBox == null) return null;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return null;
            }
            return cast(textBox, FlxText).font;
        });
        script.addLuaCallback("setTextFont", function(tag:String, font:String, passInPaths:Bool = true):Bool {
            var textBox = getSprite(tag);
            if (textBox == null) return false;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return false;
            }
            if (passInPaths) {
                font = Paths.font(font);
            }
            cast(textBox, FlxText).font = font;
            return true;
        });
        var alignments:Map<String, FlxTextAlign> = [
            "center" => CENTER,
            "justify" => JUSTIFY,
            "left" => LEFT,
            "right" => RIGHT,
            
            // ADDITIONAL
            "middle" => CENTER,
        ];
        script.addLuaCallback("getTextAlignment", function(tag:String):String {
            var textBox = getSprite(tag);
            if (textBox == null) return null;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return null;
            }
            for(k=>e in alignments) {
                if (e == cast(textBox, FlxText).alignment) {
                    return k;
                }
            }
            return null;
        });
        script.addLuaCallback("setTextAlignment", function(tag:String, alignment:String):Bool {
            var textBox = getSprite(tag);
            if (textBox == null) return false;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return false;
            }
            if (!alignments.exists(alignment.toLowerCase())) {
                script.trace('Alignement named ${alignment} is not valid.', true);
                return false;
            }
            cast(textBox, FlxText).alignment = alignments[alignment.toLowerCase()];
            return true;
        });
        script.addLuaCallback("getTextValue", function(tag:String):String {
            var textBox = getSprite(tag);
            if (textBox == null) return null;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return null;
            }
            return cast(textBox, FlxText).text;
        });
        script.addLuaCallback("setTextValue", function(tag:String, value:String):Bool {
            var textBox = getSprite(tag);
            if (textBox == null) return false;
            if (!(textBox is FlxText)) {
                script.trace('Sprite named ${tag} is not a Text Sprite.', true);
                return false;
            }
            cast(textBox, FlxText).text = value;
            return true;
        });

        /**
            ANIMATIONS
        **/
        script.addLuaCallback("playAnimation", function(tag:String, AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0) {
            var e = getSprite(tag);
            if (e != null) {
                if (e is FlxSprite) {
                    var sprite = cast(e, FlxSprite);
                    if (sprite is Character) {
                        cast(sprite, Character).playAnim(AnimName, Force, Reversed, Frame);
                    } else {
                        sprite.animation.play(AnimName, Force, Reversed, Frame);
                    }
                    return true;
                } else {
                    script.trace('Object ${tag} is not a FlxSprite and does not support animations.', true);
                }
            }
            return false;
        });
        script.addLuaCallback("addAnimationByIndices", function(tag:String, name:String, prefix:String, indices:Array<Int>, fps:Int = 24, looped:Bool = false, flipX:Bool = false, flipY:Bool = false) {
            var e = getSprite(tag);
            if (e != null) {
                if (e is FlxSprite) {
                    var sprite = cast(e, FlxSprite);
                    sprite.animation.addByIndices(name, prefix, indices, "", fps, looped, flipX, flipY);
                    return true;
                } else {
                    script.trace('Object ${tag} is not a FlxSprite and does not support animations.', true);
                }
            }
            return false;
        });
        script.addLuaCallback("addAnimationByPrefix", function(tag:String, name:String, prefix:String, fps:Int = 24, looped:Bool = false, flipX:Bool = false, flipY:Bool = false) {
            var e = getSprite(tag);
            if (e != null) {
                if (e is FlxSprite) {
                    var sprite = cast(e, FlxSprite);
                    sprite.animation.addByPrefix(name, prefix, fps, looped, flipX, flipY);
                    return true;
                } else {
                    script.trace('Object ${tag} is not a FlxSprite and does not support animations.', true);
                }
            }
            return false;
        });
        script.addLuaCallback("getPlayingAnimation", function(tag:String):String {
            var sprite = getSprite(tag);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    var spr:FlxSprite = cast sprite;
                    return spr.animation.curAnim != null ? spr.animation.curAnim.name : null;
                }
            }
            return null;
        });
        script.addLuaCallback("isAnimationFinished", function(tag:String):Bool {
            var sprite = getSprite(tag);
            if (sprite != null) {
                if (sprite is FlxSprite) {
                    var spr:FlxSprite = cast sprite;
                    return spr.animation.curAnim != null ? spr.animation.curAnim.finished : false;
                }
            }
            return false;
        });

        /**
            CAMERA
        **/
        var lastCamAngleTween:Map<FlxCamera, FlxTween> = [];
        script.addLuaCallback("setCameraAngle", function(cam:Dynamic, angle:Float) {
            var cam = getCam(cam);
            if (cam != null) {
                cam.angle = angle;
            }
        });
        script.addLuaCallback("tweenCameraAngle", function(cam:Dynamic, angle:Float, duration:Float = 1.0, ease:String, tweenTag:String) {
            var cam = getCam(cam);
            if (cam != null) {
                if (lastCamAngleTween[cam] != null)
                    lastCamAngleTween[cam].cancel();
                FlxTween.tween(cam, {angle: angle}, duration, {ease: CoolUtil.getEase(ease, script), onComplete:function(t) {
                    if (tweenTag != null) {
                        script.executeFunc("onTweenComplete", [tweenTag]);
                        script.executeFunc(tweenTag);
                    }
                }});
            }
        });
        script.addLuaCallback("shakeCamera", function(cam:Dynamic, intensity:Float = 0.05, duration:Float = 1.0, callback:String) {
            var cam = getCam(cam);
            if (cam != null) {
                cam.shake(intensity, duration, function() {
                    if (callback != null) {
                        script.executeFunc("onShakeComplete", [callback]);
                        script.executeFunc(callback);
                    }
                });
            }
        });
        script.addLuaCallback("flashCamera", function(cam:Dynamic, duration:Float, color:Dynamic = 0xFFFFFFFF, callback:String, force:Bool = false) {
            var cam = getCam(cam);
            if (cam != null) {
                var c = getColor(color, -1);
                cam.flash(c, duration, function() {
                    if (callback != null) {
                        script.executeFunc("onFlashComplete", [callback]);
                        script.executeFunc(callback);
                    }
                }, force);
            }
        });
        script.addLuaCallback("setCameraBackgroundColor", function(cam:Dynamic, color:Dynamic = 0xFFFFFFFF) {
            var cam = getCam(cam);
            if (cam != null) {
                var c = getColor(color, 0);
                cam.bgColor = c;
            }
        });

        /**
            SHADERS
        **/
        script.addLuaCallback("createShader", function(tag:String, name:String) {
            if (tag == null) {
                script.trace("Shader tag cannot be null.");
                return null;
            }
            var shader = new CustomShader(Paths.shader(name), null, null);
            script.variables.set(tag, shader);
            return '${script.zws}${tag}';
        });
        script.addLuaCallback("setSpriteShader", function(spriteTag:String, shaderTag:String) {
            var spr = getSprite(spriteTag);
            var shader = getShader(shaderTag, shaderTag != null);
            if (spr != null && (shader != null || shaderTag == null)) {
                if (!(spr is FlxSprite)) {
                    script.trace('Sprite ${spriteTag} is not a FlxSprite.', true);
                    return false;
                }
                cast(spr, FlxSprite).shader = shader;
                return true;
            }
            return false;
        });
        script.addLuaCallback("setShaderValue", function(tag:String, name:String, value:Dynamic, ?value2:Dynamic, ?value3:Dynamic, ?value4:Dynamic) {
            if (name == null) {
                script.trace('Variable name cannot be null.', true);
                return false;
            }
            switch(Type.typeof(value)) {
                case TBool | TFloat | TNull:
                    var shader = getShader(tag);
                    if (shader == null) return false;

                    var data = shader.data;
                    if (!Reflect.hasField(data, name)) {
                        script.trace('Shader doesn\'t have a uniform variable named $name. Are you sure it compiled?', true);
                        return false;
                    }
                    var _field = Reflect.field(data, name);
                    var val = [];
                    if (value != null) {
                        val.push(value);
                        if (value2 != null) {
                            val.push(value2);
                            if (value3 != null) {
                                val.push(value3);
                                if (value4 != null) {
                                    val.push(value4);
                                }
                            }
                        }
                    }
                    Reflect.setProperty(_field, "value", val);
                    return true;
                default:
                    script.trace('Value cannot be nil or anything else than a float/int/bool.', true);
            }
            return false;
        });
        script.addLuaCallback("setShaderSampler", function(tag:String, name:String, assetName:String) {
            if (name == null) {
                script.trace('Variable name cannot be null.', true);
                return false;
            }
            if (!(assetName is String) || assetName == null) {
                script.trace('Value should be a string and not equal to nil.', true);
                return false;
            }
            var assetPath = assetName;
            if (!Assets.exists(assetPath))
                assetPath = Paths.image(assetName);
            if (!Assets.exists(assetPath)) {
                script.trace('Image asset at ${assetPath} does not exist.', true);
                return false;
            }
            var shader = getShader(tag);
            if (shader == null) return false;

            var data = shader.data;
            if (!Reflect.hasField(data, name)) {
                script.trace('Shader doesn\'t have a uniform variable named $name. Are you sure it compiled?', true);
                return false;
            }
            var _field = Reflect.field(data, name);
            if (Type.getClassName(Type.getClass(_field)) == "openfl.display.ShaderInput_openfl_display_BitmapData") { // cause haxe is a dumbass
                Reflect.setProperty(_field, "input", Assets.getBitmapData(assetPath));
                return true;
            } else {
                script.trace('Parameter ${name} is not a ShaderParameter, but is a ${Type.getClassName(Type.getClass(_field))}', true);
            }
            return false;
        });
        script.addLuaCallback("addCameraShader", function(cam:Dynamic, shader:String) {
            var camera = getCam(cam);
            if (camera == null) return false;
            var shader = getShader(shader);
            if (shader == null) return false;
            camera.addShader(shader);

            return true;
        });
        script.addLuaCallback("removeCameraShader", function(cam:Dynamic, shader:String) {
            var camera = getCam(cam);
            if (camera == null) return false;
            var shader = getShader(shader);
            if (shader == null) return false;
            return camera.removeShader(shader);
        });
        script.addLuaCallback("clearCameraShaders", function(cam:Dynamic) {
            var camera = getCam(cam);
            if (camera == null) return false;
            @:privateAccess
            camera._filters = [];
            return true;
        });


        /**
            ASSETS
        **/
        script.addLuaCallback("assetExists", function(assetPath:String, usePaths:Bool = false) {
            if (usePaths)
                return Assets.exists(Paths.file(assetPath));
            else
                return Assets.exists(assetPath);
            
            return true;
        });
        script.addLuaCallback("getJSONPath", function(assetPath:String, ?mod:String):String {
            if (assetPath == null) return null;
            return Paths.json(assetPath, mod);
        });
        script.addLuaCallback("getTxtPath", function(assetPath:String, ?mod:String):String {
            if (assetPath == null) return null;
            return Paths.txt(assetPath, mod);
        });
        script.addLuaCallback("getImagePath", function(assetPath:String, ?mod:String):String {
            if (assetPath == null) return null;
            return Paths.image(assetPath, mod);
        });
        script.addLuaCallback("getXmlPath", function(assetPath:String, ?mod:String):String {
            if (assetPath == null) return null;
            return Paths.xml(assetPath, mod);
        });
        script.addLuaCallback("getSoundPath", function(assetPath:String, ?mod:String):String {
            if (assetPath == null) return null;
            return Paths.sound(assetPath, mod);
        });
        script.addLuaCallback("getVoicesPath", function(assetPath:String):String {
            if (assetPath == null) return null;
            return Paths.voices(assetPath);
        });
        script.addLuaCallback("getInstPath", function(assetPath:String):String {
            if (assetPath == null) return null;
            return Paths.inst(assetPath);
        });
        script.addLuaCallback("getFontPath", function(assetPath:String, ?mod:String):String {
            if (assetPath == null) return null;
            return Paths.font(assetPath, mod);
        });
        script.addLuaCallback("getVideoPath", function(assetPath:String, ?mod:String):String {
            if (assetPath == null) return null;
            return Paths.video(assetPath, mod);
        });
        script.addLuaCallback("getSplashesPath", function(assetPath:String, ?mod:String):String {
            if (assetPath == null) return null;
            return Paths.splashes(assetPath, mod);
        });
        script.addLuaCallback("getShaderFragPath", function(assetPath:String, ?mod:String):String {
            if (assetPath == null) return null;
            return Paths.shaderFrag(assetPath, mod);
        });
        script.addLuaCallback("getShaderVertPath", function(assetPath:String, ?mod:String):String {
            if (assetPath == null) return null;
            return Paths.shaderVert(assetPath, mod);
        });
        script.addLuaCallback("getIconPath", function(assetPath:String, ?mod:String):String {
            if (assetPath == null) return null;
            return Paths.getCharacterIcon(assetPath, mod);
        });
        script.addLuaCallback("getIconXmlPath", function(assetPath:String, ?mod:String):String {
            if (assetPath == null) return null;
            return Paths.getCharacterIconXml(assetPath, mod);
        });
        script.addLuaCallback("readTextAsset", function(assetPath:String):String {
            if (!Assets.exists(assetPath)) assetPath = Paths.txt(assetPath);
            if (!Assets.exists(assetPath)) {
                script.trace('Text asset at ${assetPath} does not exist.');
                return null;
            }
            return Assets.getText(assetPath);
        });
        script.addLuaCallback("readJSONAsset", function(assetPath:String):String {
            if (!Assets.exists(assetPath)) assetPath = Paths.json(assetPath);
            if (!Assets.exists(assetPath)) {
                script.trace('JSON asset at ${assetPath} does not exist.');
                return null;
            }
            return Json.parse(Assets.getText(assetPath));
        });


        /**
            WINDOW & SCREEN
        **/
        script.addLuaCallback("getWindowPosition", function(id:Int = -1) {         
            var app = lime.app.Application.current;
            var window = (id < 0) ? app.window : app.windows[id];
            if (window == null) {
                script.trace('Window with ID ${id} was not found.', true);
                return null;
            }
            return [window.x, window.y];
        });
        script.addLuaCallback("setWindowPosition", function(x:Null<Int>, y:Null<Int>, id:Int = -1) {   
            var app = lime.app.Application.current;
            var window = (id < 0) ? app.window : app.windows[id];
            if (window == null) {
                script.trace('Window with ID ${id} was not found.', true);
                return false;
            }

            var realX:Int = Std.int(x);
            var realY:Int = Std.int(y);
            if (x != null && !Math.isNaN(x)) window.x = realX;
            if (y != null && !Math.isNaN(y)) window.y = realY;
            return true;
        });
        script.addLuaCallback("getWindowX", function(id:Int = -1) { 
            var app = lime.app.Application.current;
            var window = (id < 0) ? app.window : app.windows[id];
            if (window == null) {
                script.trace('Window with ID ${id} was not found.', true);
                return 0;
            }
            return window.x;
        });
        script.addLuaCallback("getWindowY", function(id:Int = -1) { 
            var app = lime.app.Application.current;
            var window = (id < 0) ? app.window : app.windows[id];
            if (window == null) {
                script.trace('Window with ID ${id} was not found.', true);
                return 0;
            }
            return window.y;
        });
        script.addLuaCallback("getWindowTitle", function(id:Int = -1) { 
            var app = lime.app.Application.current;
            var window = (id < 0) ? app.window : app.windows[id];
            if (window == null) {
                script.trace('Window with ID ${id} was not found.', true);
                return null;
            }
            return window.title;
        });
        script.addLuaCallback("setWindowTitle", function(title:String, id:Int = -1) { 
            var app = lime.app.Application.current;
            var window = (id < 0) ? app.window : app.windows[id];
            if (window == null) {
                script.trace('Window with ID ${id} was not found.', true);
                return false;
            }
            window.title = (title == null) ? ModSupport.getModTitleBarTitle(Settings.engineSettings.data.selectedMod) : title;
            return true;
        });
        script.addLuaCallback("doWindowAlert", function(title:String, message:String, id:Int = -1) {           
            var app = lime.app.Application.current;
            var window = (id < 0) ? app.window : app.windows[id];
            if (window == null) {
                script.trace('Window with ID ${id} was not found.', true);
                return false;
            }
            window.alert(title, message);
            return true;
        });

        /**
            AUDIO
        **/
        script.addLuaCallback("playSound", function(soundPath:String, library:String, callback:String, volume:Float = 1) {
            var snd = FlxG.sound.play(Paths.sound(soundPath, library), volume);
        });

        /**
            TWEENING & TIMERS
        **/
        script.addLuaCallback("tween", function(_cl:Dynamic, _path:Dynamic, _destValue:Dynamic, _duration:Dynamic = 1, _ease:Dynamic, _onComplete:Dynamic) {
            var cl:String;
            var path:String;
            var destValue:Float;
            var duration:Float;
            var ease:String;
            var onComplete:String;
            if (_path is Float || _path is Int) {
                cl = null;
                onComplete = cast _ease;
                ease = cast _duration;
                duration = cast _destValue;
                destValue = cast _path;
                path = cast _cl;
            } else {
                cl = _cl;
                path = _path;
                destValue = _destValue;
                duration = _duration;
                ease = _ease;
                onComplete = _onComplete;
            }
            var split = path.split(".");

            var obj = null;
            if (cl == null) {
                if (split.length < 2) {
                    if (script.variables[split[0]] != null) {
                        obj = script.variables[split[0]];
                    } else if (script.scriptObject != null && (obj = Reflect.getProperty(script.scriptObject, split[0])) == null)
                    {
                        script.trace("Cannot tween depth 0 variables.", true);
                        return false;
                    }
                    var e = {};
                    Reflect.setField(e, '${split[0]}', destValue);
                    FlxTween.tween(script.scriptObject, e, duration, {ease: CoolUtil.getEase(ease, script), onComplete: function(t) {
                        if (onComplete != null) {
                            script.executeFunc("onTweenComplete", [onComplete]);
                            script.executeFunc(onComplete);
                        }
                    }});
                    return true;
                } else {
                    var first = split.shift();
                    if (script.variables[first] != null)
                        obj = script.variables[first];
                    else if (script.scriptObject != null && (obj = Reflect.getProperty(script.scriptObject, first)) == null) {
                        script.trace('Variable ${first} is null.', true);
                        return false;
                    }
                }
            } else {
                var cla = script.getClass(cl);
                if (cla == null)
                    return false;
                obj = cla;
            }
            for(i in 0...split.length-1) {
                obj = Reflect.getProperty(obj, split[i]);
                if (obj == null) {
                    script.trace('Variable ${split[i]} is null.');
                }
            }
            var e = {};
            Reflect.setField(e, '${split[split.length-1]}', destValue);
            script.variables.set(onComplete, FlxTween.tween(obj, e, duration, {ease: CoolUtil.getEase(ease, script), onComplete: function(t) {
                if (onComplete != null) {
                    script.executeFunc("onTweenComplete", [onComplete]);
                    script.executeFunc(onComplete);
                }
                }
            }));
            return true;
        });
        script.addLuaCallback("cancelTween", function(callback:String) {
            if (script.variables[callback] is VarTween) {
                cast(script.variables[callback], VarTween).cancel();
                return true;
            } else {
                return false;
            }
        });
        script.addLuaCallback("startTimer", function(callback:String, duration:Float, loops:Int = 1) {
            script.variables.set(callback, new FlxTimer().start(duration, function(t) {
                script.executeFunc("onTimerLoop", [callback]);
                script.executeFunc(callback);
            }, loops));
        });
        script.addLuaCallback("stopTimer", function(callbackName:String) {
            var timer:FlxTimer = null;
            if (script.variables[callbackName] is FlxTimer) {
                timer = cast script.variables[callbackName];
                timer.cancel();
                return true;
            } else {
                script.trace('Timer named ${callbackName} does not exist.');
                return false;
            }
        });
        script.addLuaCallback("resetTimer", function(callbackName:String) {
            var timer:FlxTimer = null;
            if (script.variables[callbackName] is FlxTimer) {
                timer = cast script.variables[callbackName];
                timer.reset();
                return true;
            } else {
                script.trace('Timer named ${callbackName} does not exist.');
                return false;
            }
        });
        script.addLuaCallback("setTimerLoops", function(callbackName:String, loops:Int = 1) {
            var timer:FlxTimer = null;
            if (script.variables[callbackName] is FlxTimer) {
                timer = cast script.variables[callbackName];
                timer.loops = loops;
                return true;
            } else {
                script.trace('Timer named ${callbackName} does not exist.');
                return false;
            }
        });

        /**
            CONTROLS & KEYBINDS
        **/
        script.addLuaCallback("getControlState", function(controlName:String) {
            var state:MusicBeatState;
            if (FlxG.state is MusicBeatState) {
                state = cast FlxG.state;
                @:privateAccess
                if (state.controls != null) {
                    @:privateAccess
                    switch(controlName.toLowerCase()) {
                        case "accept":       @:privateAccess return state.controls.ACCEPT;
                        case "back":         @:privateAccess return state.controls.BACK;
                        case "pause":        @:privateAccess return state.controls.PAUSE;
                        case "reset":        @:privateAccess return state.controls.RESET;
                        case "cheat":        @:privateAccess return state.controls.CHEAT;
                        case "up":           @:privateAccess return state.controls.UP;
                        case "down":         @:privateAccess return state.controls.DOWN;
                        case "left":         @:privateAccess return state.controls.LEFT;
                        case "right":        @:privateAccess return state.controls.RIGHT;
                        case "up_p":         @:privateAccess return state.controls.UP_P;
                        case "down_p":       @:privateAccess return state.controls.DOWN_P;
                        case "left_p":       @:privateAccess return state.controls.LEFT_P;
                        case "right_p":      @:privateAccess return state.controls.RIGHT_P;
                        case "up_r":         @:privateAccess return state.controls.UP_R;
                        case "down_r":       @:privateAccess return state.controls.DOWN_R;
                        case "left_r":       @:privateAccess return state.controls.LEFT_R;
                        case "right_r":      @:privateAccess return state.controls.RIGHT_R;
                    }
                }
            }
            return false;
        });
        script.addLuaCallback("getControls", function(uselessParameter:Bool = false) { // uselessParameter cause it crashes if i dont add it
            var state:MusicBeatState;
            if (FlxG.state is MusicBeatState) {
                state = cast FlxG.state;
                @:privateAccess
                if (state.controls != null) {
                    return {
                        LEFT:       @:privateAccess state.controls.LEFT,
                        UP:         @:privateAccess state.controls.UP,
                        RIGHT:      @:privateAccess state.controls.RIGHT,
                        DOWN:       @:privateAccess state.controls.DOWN,
                        UP_P:       @:privateAccess state.controls.UP_P,
                        LEFT_P:     @:privateAccess state.controls.LEFT_P,
                        RIGHT_P:    @:privateAccess state.controls.RIGHT_P,
                        DOWN_P:     @:privateAccess state.controls.DOWN_P,
                        UP_R:       @:privateAccess state.controls.UP_R,
                        LEFT_R:     @:privateAccess state.controls.LEFT_R,
                        RIGHT_R:    @:privateAccess state.controls.RIGHT_R,
                        DOWN_R:     @:privateAccess state.controls.DOWN_R,
                        ACCEPT:     @:privateAccess state.controls.ACCEPT,
                        BACK:       @:privateAccess state.controls.BACK,
                        PAUSE:      @:privateAccess state.controls.PAUSE,
                        RESET:      @:privateAccess state.controls.RESET,
                    };
                }
            }
            return {
                LEFT:      false,
                UP:        false,
                RIGHT:     false,
                DOWN:      false,
                UP_P:      false,
                LEFT_P:    false,
                RIGHT_P:   false,
                DOWN_P:    false,
                UP_R:      false,
                LEFT_R:    false,
                RIGHT_R:   false,
                DOWN_R:    false,
                ACCEPT:    false,
                BACK:      false,
                PAUSE:     false,
                RESET:     false,
            };
        });
        script.addLuaCallback("isKeyPressed", function(keyName:String) {
            var key:Null<FlxKey> = FlxKey.fromString(keyName.toUpperCase());
            if (key == null) {
                script.trace('Key named $keyName does not exists. Please check the FlxKey doc.');
                return false;
            }
            return FlxG.keys.checkStatus(key, PRESSED);
        });
        script.addLuaCallback("isKeyJustPressed", function(keyName:String) {
            var key:Null<FlxKey> = FlxKey.fromString(keyName.toUpperCase());
            if (key == null) {
                script.trace('Key named $keyName does not exists. Please check the FlxKey doc.');
                return false;
            }
            return FlxG.keys.checkStatus(key, JUST_PRESSED);
        });
        script.addLuaCallback("isKeyJustReleased", function(keyName:String) {
            var key:Null<FlxKey> = FlxKey.fromString(keyName.toUpperCase());
            if (key == null) {
                script.trace('Key named $keyName does not exists. Please check the FlxKey doc.');
                return false;
            }
            return FlxG.keys.checkStatus(key, JUST_RELEASED);
        });
        
        /**
            STATES AND SUBSTATES
        **/
        script.addLuaCallback("switchState", function(stateName:String, custom:Bool = false, ?args:Array<Dynamic>) {        
            if (stateName == null) {
                script.trace('State name cannot be null.', true);
                return false;
            }
            if (custom) {
                var state = new ModState(stateName, null, args == null ? [] : args);
                FlxG.switchState(state);
                return true;
            } else {
                var cla = script.getClass(stateName, true);
                if (cla == null) {
                    script.trace('State class named ${stateName} not found.', true);
                    return false;
                }
                var instance = Type.createEmptyInstance(cla);
                if (!(instance is FlxState)) {
                    script.trace('The specified class ${stateName} is not a FlxState.', true);
                    return false;
                }
                instance = Type.createInstance(cla, args); // dumbass
                if (instance == null) {
                    script.trace('An instance of ${stateName} could not be created.', true);
                    return false;
                }
                FlxG.switchState(instance);
            }
            return false;
        });
        script.addLuaCallback("resetState", FlxG.resetState);

        /**
            CHARACTERS
        **/
        script.addLuaCallback("createCharacter", function(varName:String, charName:String, posX:Float = 0, posY:Float = 0, isPlayer:Bool = false):String {
            if (varName == null) {
                script.trace('Variable name cannot be null.');
                return null;
            }
            if (charName == null) {
                script.trace('Character name cannot be null.');
                return null;
            }
            script.variables.set(varName, new Character(posX, posY, charName, isPlayer));
            return '${script.zws}${varName}';
        });
        script.addLuaCallback("preloadCharacterAsync", function(character:String, characterMod:String, ?callback:String) {
            Character.preloadCharacterAsync(character, characterMod, function() {
                if (callback != null) {
                    if (FlxG.state is MusicBeatState) {
                        cast(FlxG.state, MusicBeatState).nextCallbacks.push(function() {
                            script.executeFunc(callback, [character, characterMod]);
                        });
                    }
                }
            });
        });
        script.addLuaCallback("preloadCharacter", Character.preloadCharacter);
        script.addLuaCallback("unloadCharacter", Character.unloadCharacter);
        script.addLuaCallback("switchCharacter", function(charName:String, newChar:String, newCharMod:String) {
            var spr = getSprite(charName);
            if (spr == null) return false;
            if (!(spr is Character)) {
                script.trace('Sprite named ${charName} is not a Character.', true);
                return false;
            }
            cast(spr, Character).switchCharacter(newChar, newCharMod);
            return true;
        });
        script.addLuaCallback("switchCharacterAsync", function(charName:String, newChar:String, newCharMod:String, ?callback:String) {
            var spr = getSprite(charName);
            if (spr == null) return false;
            if (!(spr is Character)) {
                script.trace('Sprite named ${charName} is not a Character.', true);
                return false;
            }
            cast(spr, Character).switchCharacterAsync(newChar, newCharMod, function() {
                if (callback != null) {
                    if (FlxG.state is MusicBeatState) {
                        cast(FlxG.state, MusicBeatState).nextCallbacks.push(function() {
                            script.executeFunc(callback, [newChar, newCharMod]);
                        });
                    }
                }
            });
            return true;
        });
        script.addLuaCallback("setCharacterDanceSteps", function(charName:String, danceSteps:Array<String>) {
            var realDanceSteps = [];
            var _char = getSprite(charName);
            if (!(_char is Character)) {
                script.trace('Sprite named $charName isn\'t a Character', true);
                return false;
            }
            var char = cast(_char, Character);

            if (!(danceSteps is Array)) {
                script.trace('danceSteps cannot be nil or anything else than an array.', true);
                return false;
            }
            if (char.json == null) {
                script.trace('Cannot apply new dance steps to ${charName}, since this character doesn\'t use a JSON.');
                return false;
            }
            for(e in danceSteps)
                if (e is String)
                    realDanceSteps.push(e);

            if (realDanceSteps.length <= 0) realDanceSteps.push("idle");
            char.json.danceSteps = realDanceSteps;
            char.danceStep = 0;
            return true;
        });

        /**
            MISC
        **/
        var currentFart = null;
        script.addLuaCallback("reverbFart", function(v1:Bool) {
            if (v1) {
                if (currentFart != null) currentFart.stop();
                currentFart = FlxG.sound.play(Paths.sound("test", "preload"));
            }
        });
        script.addLuaCallback("getFramerate", function(dummy:Int = -1) {            
            return 1 / FlxG.elapsed;
        });
        script.addLuaCallback("getMemory", function(dummy:Int = -1) {            
            return System.totalMemory;
        });
        script.addLuaCallback("getMemoryPeak", function(dummy:Int = -1) {           
            return Main.fps.peak;
        });
        script.addLuaCallback("changeBarColors", function(name:String, bgColors:Dynamic, fgColors:Dynamic, angle:Int = 90, chunkSize:Int = 1) {
            var spr = getSprite(name);
            if (spr == null) return false;
            if (spr is FlxBar) {
                var bar = cast(spr, FlxBar);
                var bg:Array<FlxColor> = [];
                var fg:Array<FlxColor> = [];

                if (bgColors is Array) {
                    for(e in cast(bgColors, Array<Dynamic>)) {
                        var color = getColor(e, null);
                        if (color != null)
                            bg.push(Std.int(color));
                    }
                } else {
                    var color = getColor(bgColors, null);
                    if (color != null)
                        bg.push(Std.int(color));
                }
                if (fgColors is Array) {
                    for(e in cast(fgColors, Array<Dynamic>)) {
                        var color = getColor(e, null);
                        if (color != null)
                            fg.push(Std.int(color));
                    }
                } else {
                    var color = getColor(fgColors, null);
                    if (color != null)
                        fg.push(Std.int(color));
                }
                if (bg.length == 0) bg.push(0xFFFF0000);
                if (fg.length == 0) fg.push(0xFF66FF33);

                bar.createGradientBar(bg, fg, chunkSize, angle);
            } else {
                script.trace('${name} is not a FlxBar.', true);
                return false;
            }
            return false;
        });
    }
}

#end