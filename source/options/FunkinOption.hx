package options;

typedef FunkinOption = {
    var name:String;
    var desc:String;
    var value:String;
    @:optional var onUpdate:Float->Void;
    @:optional var img:String;
}