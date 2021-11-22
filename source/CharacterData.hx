import flixel.math.FlxPoint;
import flixel.util.FlxColor;



/**
* JSON support, unused for now
*/
typedef CharacterData = {
    public var color:FlxColor;
    public var flipX:Bool;
    public var pixel:Bool;
    public var globalOffset:FlxPoint;
    public var anims:Array<CharacterAnims>;
    public var animsIndices:Array<CharacterAnims>;
    public var idleDanceSteps:Array<String>;
    public var emotes:Array<String>;
}

typedef CharacterAnims = {
    public var name:String;
    public var anim:String;
    public var framerate:Int;
    public var x:Int;
    public var y:Int;
    public var loop:Bool;
    public var animPrefixKeys:Array<Int>;
}

// typedef CharacterData = {
//     public var color:FlxColor = new FlxColor(0xFF31B0D1);
//     public var flipX:Bool = false;
//     public var pixel:Bool = false;
//     public var globalOffset:FlxPoint = new FlxPoint(0, 0);
//     public var anims:Array<CharacterAnims> = [];
//     public var idleDanceSteps:Array<String> = ["idle"];
//     public var emotes = ["hey"];

//     public function new() {}
// }

// typedef CharacterAnims = {
//     public var name:String = "idle";
//     public var anim:String = "BF idle dance";
//     public var framerate:Int = 24;
//     public var x:Int = -5;
//     public var y:Int = 0;
//     public var loop:Bool = false;
//     public var animPrefixKeys:Array<Int> = null;

//     public function new() {}
// }