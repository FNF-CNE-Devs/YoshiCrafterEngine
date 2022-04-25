package options;

typedef FunkinOption = {
    var name:String;
    var desc:String;
    var value:String;
    var onUpdate:Float->Void;
    var img:String;
}