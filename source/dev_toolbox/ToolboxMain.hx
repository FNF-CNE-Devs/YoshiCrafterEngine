package dev_toolbox;

import openfl.sensors.Accelerometer;
import flixel.addons.ui.*;
import flixel.FlxG;
import flixel.FlxState;

class ToolboxMain extends FlxState {
    public override function create() {
        CoolUtil.addBG(this);
        var tabs = [
			{name: "main", label: 'Select a mod...'}
		];
        var UI_Main = new FlxUITabMenu(null, tabs, true);
        UI_Main.resize(640, 620);
        UI_Main.screenCenter();
        add(UI_Main);

        
		var tab = new FlxUI(null, UI_Main);
		tab.name = "main";
        
		var label = new FlxUIText(10, 10, 620, "Select a mod to begin, or click on \"Create a new mod\".");

        var selectbutton = new FlxUIButton(10, 590, "Edit mod...", function() {
            
        });

        var modsContainer = new FlxUIList(10, label.height + 20, null, 620, 570 - label.height, "Show <X> more...");

        tab.add(modsContainer);
		tab.add(label);
		tab.add(selectbutton);
		UI_Main.addGroup(tab);
    }
}