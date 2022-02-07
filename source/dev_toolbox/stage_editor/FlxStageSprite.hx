package dev_toolbox.stage_editor;

import Stage.StageAnim;
import flixel.FlxSprite;

class FlxStageSprite extends FlxSprite {
    public var name:String = null;
    public var animType:String = "loop";
    public var type:String = "Bitmap";
    public var anim:StageAnim = null;
    public var spritePath:String = "";
}