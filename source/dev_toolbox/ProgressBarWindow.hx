package dev_toolbox;

import flixel.text.FlxText;
import flixel.ui.FlxBar;
import haxe.Exception;
import flixel.addons.transition.FlxTransitionableState;
import lime.ui.FileDialogType;
import openfl.display.BitmapData;
import lime.ui.FileDialog;
import flixel.addons.ui.FlxUIDropDownMenu.FlxUIDropDownHeader;
import sys.FileSystem;
import flixel.FlxSprite;
import flixel.addons.ui.*;
import flixel.FlxG;
import flixel.FlxState;

class ProgressBarWindow extends MusicBeatSubstate {
    // VARIABLES
    public var title:String = "";
    public var desc:String = "";
    public var element:IProgressObject;
    public var callback:Void->Void;

    // UI
    public var barPercentage:FlxUIText;

    public function new(element:IProgressObject, ?title:String = "Task is running...", ?desc:String = "Please wait for the current task to end.", ?callback:Void->Void) {
        super();
        this.element = element;
        this.title = title;
        this.desc = desc;
        this.callback = callback;
    }
    public override function create() {
        super.create();

        var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0x88000000);
        add(bg);

        var tabs = [
			{name: "main", label: title}
		];
        var UI_Main = new FlxUITabMenu(null, tabs, true);

		var tab = new FlxUI(null, UI_Main);
		tab.name = "main";

        var label = new FlxUIText(10, 10, (FlxG.width / 2) - 20, desc);


        var progressBar = new FlxBar(10, label.y + label.height + 10, LEFT_TO_RIGHT, Std.int(FlxG.width / 2) - 20, 12, element, "percentage", 0, 1);
        progressBar.createGradientBar([0x88222222], [0xFF7163F1, 0xFFD15CF8], 1, 90, true, 0xFF000000);

        barPercentage = new FlxUIText(10, progressBar.y + (progressBar.height / 2), progressBar.width, "-%");
        barPercentage.alignment = CENTER;
        barPercentage.size *= 2;
        barPercentage.borderStyle = OUTLINE;
        barPercentage.borderSize = 1;
        barPercentage.borderColor = 0xFF000000;
        barPercentage.y -= barPercentage.height / 2;
        tab.add(label);
        tab.add(progressBar);
        tab.add(barPercentage);

        UI_Main.addGroup(tab);
        UI_Main.resize((FlxG.width / 2), progressBar.y + progressBar.height + 50);
        UI_Main.screenCenter();
        add(UI_Main);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        if (element.done) {
            barPercentage.text = "100%";
            close();
            if (callback != null)
                callback();
        } else {
            barPercentage.text = '${Std.int(element.percentage * 100)}%';
        }
    }
}

interface IProgressObject {
    public var percentage(get, null):Float;
    public var error:Exception;
    public var done:Bool;
}