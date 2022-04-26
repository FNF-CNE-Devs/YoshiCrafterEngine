package options.screens;

import flixel.addons.transition.FlxTransitionableState;
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
                img: Paths.image('newgrounds_logo', 'preload'),
                onUpdate: null
            },
            {
                name: "Gameplay",
                desc: "Customize Gameplay Settings such as Downscroll, Middlescroll and more.",
                value: "",
                img: null,
                onUpdate: null
            },
            {
                name: "GUI Settings",
                desc: "Customize GUI Settings such as Gui Size, or Score Bar appearance.",
                value: "",
                img: null,
                onUpdate: null
            },
            {
                name: "Notes",
                desc: "Customize Note settings, such as note colors and splashes.",
                value: "",
                img: null,
                onUpdate: null
            },
            {
                name: "Skins",
                desc: "Select your BF or GF skin here.",
                value: "",
                img: null,
                onUpdate: null
            },
            {
                name: "Miscellaneous",
                desc: "Other settings that does not fit any of the categories above.",
                value: "",
                img: null,
                onUpdate: null
            },
            {
                name: "Developer Settings",
                desc: "Enable Developer Mode to access the Toolbox.",
                value: "",
                img: null,
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

    public override function onSelect(id:Int) {
        switch(id) {
            case 0:
                doFlickerAnim(id, function() {FlxG.switchState(new KeybindsMenu());});
            case 1:
                doFlickerAnim(id, function() {FlxG.switchState(new GameplayMenu());});
            default:
                trace(id);
        }
    }
}