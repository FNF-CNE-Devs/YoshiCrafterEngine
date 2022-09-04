package options.screens;

import options.OptionScreen;

class CustomMenu extends OptionScreen {

    public function new() {
        super('Options > Mod Options');
    }

    public override function create() {
        options = [];
    }
}

typedef CustomSettingsJSON = {
    var main:SettingsScreenJSON;
}

typedef SettingsScreenJSON = {
    var script:String; // path to string like in song conf basically
    var options:Array<CustomOption>;
}

typedef CustomOption = {
    var name:String;
    var desc:String;
    var defaultValue:Dynamic;
    var type:String;

    // NUMBER
    var min:Float;
    var max:Float;

    // FLOAT
    var increment:Float;

    // LIST
    var availableOptions:Array<String>;

    // CALLBACK, REQUIRES SCRIPT ON MENU
    var callback:String;

    // SUBMENU
    var submenu:SettingsScreenJSON;
}

enum OptionType {
    Callback;
    Number;
    String;
    List;
    Submenu;
    Skip;
}