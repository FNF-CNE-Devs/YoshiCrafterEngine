package options.screens;

import flixel.FlxG;

class OptionMain extends OptionScreen {
    public static var fromFreeplay:Bool = false;

    public function new(x:Float, y:Float) {
        super();
    }

    public override function create() {
        var label = "";
        var keys = CoolUtil.getAllChartKeys();
        for(k=>i in keys) {
            if (k > 0) {
                label += ", ";
                if (k >= keys.length - 1)
                    label += "and ";
            }
            label += Std.string(i);
        }
        options = [
            {
                name: "Keybinds",
                desc: 'Edit Keybinds for $label keys charts.',
                value: "",
                onUpdate: null
            },
            {
                name: "Gameplay",
                desc: "Customize Gameplay Settings such as Downscroll, Middlescroll and more.",
                value: "",
                onUpdate: null
            },
            {
                name: "GUI Settings",
                desc: "Customize GUI Settings such as Gui Size, or Score Bar appearance.",
                value: "",
                onUpdate: null
            },
            {
                name: "Notes",
                desc: "Customize Note settings, such as note colors and splashes.",
                value: "",
                onUpdate: null
            },
            {
                name: "Skins",
                desc: "Select your BF or GF skin here.",
                value: "",
                onUpdate: null
            },
            {
                name: "Miscellaneous",
                desc: "Other settings that does not fit any of the categories above.",
                value: "",
                onUpdate: null
            },
            {
                name: "Developer Settings",
                desc: "Enable Developer Mode to access the Toolbox.",
                value: "",
                onUpdate: null
            }
        ];
        super.create();
    }

    public override function onExit() {
        if (fromFreeplay)
            FlxG.switchState(new PlayState());
        else
            FlxG.switchState(new MainMenuState());
    }
}