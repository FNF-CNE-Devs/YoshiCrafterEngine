package dev_toolbox;

import openfl.desktop.ClipboardTransferMode;
import flixel.tweens.FlxTween;
import openfl.desktop.ClipboardFormats;
import openfl.desktop.Clipboard;
import openfl.display.PNGEncoderOptions;
import flixel.addons.transition.FlxTransitionableState;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import flixel.util.FlxColor;
import flixel.FlxG;
import openfl.display.BitmapData;
import flixel.addons.ui.*;
import flixel.FlxSprite;

using StringTools;

class ColorPicker extends MusicBeatSubstate {
    public override function new(color:FlxColor, callback:FlxColor->Void) {
        super();
        var bg:FlxSprite = new FlxSprite(0, 0).makeGraphic(1280, 720, 0x88000000);
        bg.scrollFactor.set();
        add(bg);

        var tabs = [
            {name: "colorPicker", label: 'Select a color...'}
		];
        var UI_Tabs = new FlxUITabMenu(null, tabs, true);
        UI_Tabs.x = 0;
        UI_Tabs.resize(420, 720);
        UI_Tabs.scrollFactor.set();
        UI_Tabs.screenCenter();
        add(UI_Tabs);

		var tab = new FlxUI(null, UI_Tabs);
		tab.name = "colorPicker";

        var colorSprite:FlxUISprite = new FlxUISprite(10, 10);
        colorSprite.makeGraphic(70, 55, 0xFFFFFFFF);
        colorSprite.pixels.lock();
        for (x in 0...colorSprite.pixels.width) {
            colorSprite.pixels.setPixel32(x, 0, 0xFF000000);
            colorSprite.pixels.setPixel32(x, 1, 0xFF000000);
            colorSprite.pixels.setPixel32(x, 53, 0xFF000000);
            colorSprite.pixels.setPixel32(x, 54, 0xFF000000);
        }
        for (y in 0...colorSprite.pixels.height) {
            colorSprite.pixels.setPixel32(0, y, 0xFF000000);
            colorSprite.pixels.setPixel32(1, y, 0xFF000000);
            colorSprite.pixels.setPixel32(68, y, 0xFF000000);
            colorSprite.pixels.setPixel32(69 /* nice */, y, 0xFF000000);
        }
        colorSprite.pixels.unlock();
        colorSprite.x = 175;
        tab.add(colorSprite);
		var label = new FlxUIText(10, 75, 400, "RGB");
        var redNumeric:FlxUINumericStepperPlus = new FlxUINumericStepperPlus(10, 75 + label.height, 1, 0, 0, 255, 0);
        var greenNumeric:FlxUINumericStepperPlus = new FlxUINumericStepperPlus(20 + redNumeric.width, 75 + label.height, 1, 0, 0, 255, 0);
        var blueNumeric:FlxUINumericStepperPlus = new FlxUINumericStepperPlus(30 + greenNumeric.width + redNumeric.width, 75 + label.height, 1, 0, 0, 255, 0);
        redNumeric.value = color.red;
        greenNumeric.value = color.green;
        blueNumeric.value = color.blue;
        tab.add(label);
        redNumeric.onChange = function(value) {
            color.red = Std.int(redNumeric.value);
            colorSprite.color = color;
        };
        greenNumeric.onChange = function(value) {
            color.green = Std.int(greenNumeric.value);
            colorSprite.color = color;
        };
        blueNumeric.onChange = function(value) {
            color.blue = Std.int(blueNumeric.value);
            colorSprite.color = color;
        };
        redNumeric.onChange(0);

        var flashTween:FlxTween = null;
        var pasteFromClipboard:FlxUIButton = null;
        pasteFromClipboard = new FlxUIButton(blueNumeric.x + blueNumeric.width + 10, 75 + label.height, "Paste from Clipboard", function() {
            var clipboard = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT, ClipboardTransferMode.CLONE_PREFERRED);
            if (clipboard == null) {
                if (flashTween != null) {
                    flashTween.cancel();
                    flashTween = null;
                }
                pasteFromClipboard.color = 0xFFFF4444;
                flashTween = FlxTween.color(pasteFromClipboard, 0.2, 0xFFFF4444, 0xFFFFFFFF, {startDelay: 0.2});
                return;
            }
            var generatedColor = FlxColor.fromString(clipboard.toString());
            if (clipboard == null) {
                if (flashTween != null) {
                    flashTween.cancel();
                    flashTween = null;
                }
                pasteFromClipboard.color = 0xFFFF4444;
                flashTween = FlxTween.color(pasteFromClipboard, 0.2, 0xFFFF4444, 0xFFFFFFFF, {startDelay: 0.2});
                return;
            }
            redNumeric.value = generatedColor.red;
            greenNumeric.value = generatedColor.green;
            blueNumeric.value = generatedColor.blue;
            colorSprite.color = generatedColor;
            color = generatedColor;
        });
        pasteFromClipboard.resize(280 - (blueNumeric.x + blueNumeric.width + 10), 20);

        tab.add(label);
        tab.add(redNumeric);
        tab.add(greenNumeric);
        tab.add(blueNumeric);
        tab.add(pasteFromClipboard);

        var okButton = new FlxUIButton(0, redNumeric.y + redNumeric.height + 10, "OK", function() {
            close();
            callback(color);
        });
        tab.add(okButton);

        var closeButton = new FlxUIButton(UI_Tabs.x + UI_Tabs.width - 23, UI_Tabs.y + 3, "X", function() {
            close();
        });
        UI_Tabs.resize(420, okButton.y + 50);
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = FlxColor.WHITE;
        closeButton.scrollFactor.set();
        add(closeButton);

        UI_Tabs.addGroup(tab);
    }
}