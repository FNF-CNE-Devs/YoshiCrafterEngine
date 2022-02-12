package;

import haxe.io.Bytes;
import lime.ui.FileDialogType;
import lime.ui.FileDialog;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import openfl.net.FileReference;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxButtonPlus;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxUIInputText;
import NoteShader.ColoredNoteShader;
import EngineSettings.Settings;
import Controls.Control;
import Options;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import openfl.Lib;

class OptionsNotesColors extends MusicBeatState
{
	var selector:FlxText;
	var arrowSelected:Int = 0;
	var channelSelected:Int = 0;
	var colors:Array<FlxColor> = [
		new FlxColor(Settings.engineSettings.data.arrowColor0),
		new FlxColor(Settings.engineSettings.data.arrowColor1),
		new FlxColor(Settings.engineSettings.data.arrowColor2),
		new FlxColor(Settings.engineSettings.data.arrowColor3)
	];

	var arrowSprites:Array<FlxSprite> = [];
	// var arrowNames:Array<String> = ["Left", "Down", "Up", "Right"];
	var arrowSelectorThingy:FlxSprite;

	var rgbChannelSprites:Array<FlxText> = [];

	var hexCodeInput:FlxUIInputText;

	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0xFF7EACCD;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		var legend:FlxText = new FlxText(5, FlxG.height - 52, 0,
			"[Tab] Select Arrow | [▼][▲] Select RGB channel | [◄][►] Change selected RGB value (Hold [SHIFT] for precision)", 16);
		legend.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(legend);

		var legend2:FlxText = new FlxText(5, FlxG.height - 26, 0, "[Enter] Save and return to the options menu | [R] Reset | [Escape] Exit without saving",
			16);
		legend2.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(legend2);

		var arrowAnimsNames = ["purple0", "blue0", "green0", "red0"];
		for (i in 0...4)
		{
			var arrow0:FlxSprite = new FlxSprite((FlxG.width / 2) + ((50 + (200 * (i - 2.25))) * 0.7), 75);
			arrow0.frames = Paths.getSparrowAtlas("NOTE_assets_colored", "shared");
			arrow0.animation.addByPrefix("arrow", arrowAnimsNames[i]);
			arrow0.animation.play("arrow");
			arrow0.shader = new ColoredNoteShader(colors[i].red, colors[i].green, colors[i].blue);
			arrow0.antialiasing = true;
			arrow0.setGraphicSize(Std.int(arrow0.width * 0.7));
			arrowSprites.push(arrow0);
		}
		arrowSelectorThingy = new FlxSprite(arrowSprites[0].x + 10, arrowSprites[0].y + 10);
		arrowSelectorThingy.loadGraphic(Paths.image("optionsArrowSelector", "shared"));
		arrowSelectorThingy.antialiasing = true;
		add(arrowSelectorThingy);
		for (i in 0...arrowSprites.length)
		{
			add(arrowSprites[i]);
		}
		for (i in 0...3)
		{
			var rgbThingy = new FlxText(arrowSprites[1].x, 75 + arrowSprites[i].height + 25 + (i * 52), 0, "- : 0", 32);
			rgbThingy.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(rgbThingy);
			rgbChannelSprites.push(rgbThingy);
		}
		var hexHashtag = new FlxText(arrowSprites[1].x, 0, 0, "#");
		hexHashtag.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(hexHashtag);
		hexCodeInput = new FlxUIInputText(arrowSprites[1].x + hexHashtag.width + 5, rgbChannelSprites[2].y + rgbChannelSprites[2].height + 10, 250, "000000", 12);
		hexHashtag.y = hexCodeInput.y + (hexCodeInput.height / 2) - (hexHashtag.height / 2);
		var errorMessage:FlxText = new FlxText(hexCodeInput.x, hexCodeInput.y + hexCodeInput.height + 10, 0, "");
		errorMessage.setFormat("VCR OSD Mono", 16, 0xFFFF4444, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);


		var applyButton:FlxButton = new FlxButton(hexCodeInput.x + hexCodeInput.width + 10, hexCodeInput.y, "Apply", function() {
			var c = FlxColor.fromString("#" + hexCodeInput.text);
			if (c == null) {
				errorMessage.text = "Invalid color. The color must be of format #000000.";
			} else {
				errorMessage.text = "";
				c.alphaFloat = 1;
				colors[arrowSelected] = c;
				refreshColorCodes();
			}
		});
		applyButton.y = hexCodeInput.y + (hexCodeInput.height / 2) - (applyButton.height / 2);
		add(hexCodeInput);
		add(errorMessage);
		add(applyButton);


		var resetButton:FlxButton = new FlxButton(hexHashtag.x, errorMessage.y + errorMessage.height + 10, "Reset", resetColors);
		add(resetButton);

		#if sys
		var saveButton:FlxButton = new FlxButton(resetButton.x + resetButton.width + 10, resetButton.y, "Save", function() {
			var _file = new FileReference();
			var onClose:Event->Void = null;
			var errFunc:Event->Void = function(e) {
				errorMessage.text = e.toString();
				onClose(e);
			};
			onClose = function(e) {
				_file.removeEventListener(Event.COMPLETE, onClose);
				_file.removeEventListener(Event.CANCEL, onClose);
				_file.removeEventListener(IOErrorEvent.IO_ERROR, errFunc);
			};
			_file.addEventListener(Event.COMPLETE, onClose);
			_file.addEventListener(Event.CANCEL, onClose);
			_file.addEventListener(IOErrorEvent.IO_ERROR, errFunc);
			var t = [];
			for(k => c in colors) {
				t[k] = c.toWebString();
			}
			_file.save(t.join(" "), "notes.txt");
		});
		add(saveButton);

		var openButton:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Open", function() {
			var fDial = new FileDialog();
			fDial.onSelect.add(function(path) {
				var text = Paths.getTextOutsideAssets(path);
				var colors = [
					new FlxColor(0xFFC24B99),
					new FlxColor(0xFF00FFFF),
					new FlxColor(0xFF12FA05),
					new FlxColor(0xFFF9393F),
				];
				for(k => c in text.split(" ")) {
					colors[k] = FlxColor.fromString(c);
				}
				this.colors = colors;
				refreshColorCodes();
				refreshNotes();
			});
			fDial.browse(FileDialogType.OPEN, null, null, "Select your note skin text file.");
		});
		add(openButton);
		#end
	}

	public function resetColors() {
		colors = [
			new FlxColor(0xFFC24B99),
			new FlxColor(0xFF00FFFF),
			new FlxColor(0xFF12FA05),
			new FlxColor(0xFFF9393F),
		];
		refreshNotes();
		refreshColorCodes();
	}
	public static function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxControls.justPressed.ENTER)
		{
			Settings.engineSettings.data.arrowColor0 = cast(colors[0], Int);
			Settings.engineSettings.data.arrowColor1 = cast(colors[1], Int);
			Settings.engineSettings.data.arrowColor2 = cast(colors[2], Int);
			Settings.engineSettings.data.arrowColor3 = cast(colors[3], Int);
			FlxG.switchState(new OptionsMenu(0, 0));
		}

		if (FlxControls.justPressed.ESCAPE)
		{
			FlxG.switchState(new OptionsMenu(0, 0));
		}
		if (FlxControls.justPressed.TAB)
		{
			if (FlxControls.pressed.SHIFT)
				arrowSelected--;
			else
				arrowSelected++;

			if (arrowSelected > 3)
				arrowSelected = 0;
			if (arrowSelected < 0)
				arrowSelected = 3;
			arrowSelectorThingy.x = arrowSprites[arrowSelected].x + 10;
			FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);
			refreshColorCodes();
		}
		if (FlxControls.justPressed.DOWN)
		{
			changeChannel(1);
		}
		if (FlxControls.justPressed.R)
		{
			resetColors();
		}
		if (FlxControls.justPressed.UP)
		{
			changeChannel(-1);
		}
		if (FlxControls.pressed.SHIFT)
		{
			if (FlxControls.justPressed.LEFT)
			{
				changeRGB(-1);
			}
			if (FlxControls.justPressed.RIGHT)
			{
				changeRGB(1);
			}
		}
		else
		{
			if (FlxControls.pressed.LEFT)
			{
				changeRGB(-1);
			}
			if (FlxControls.pressed.RIGHT)
			{
				changeRGB(1);
			}
		}
		FlxG.save.flush();
	}

	var isSettingControl:Bool = false;

	function changeChannel(change:Int = 0)
	{
		channelSelected += change;
		if (channelSelected > 2)
			channelSelected = 2;
		if (channelSelected < 0)
			channelSelected = 0;
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);
		for (i in 0...3)
		{
			rgbChannelSprites[i].color = FlxColor.WHITE;
		}
		rgbChannelSprites[channelSelected].color = FlxColor.YELLOW;
	}

	function refreshNotes()
	{
		for (i in 0...4)
		{
			cast(arrowSprites[i].shader, ColoredNoteShader).setColors(colors[i].red, colors[i].green, colors[i].blue);
		}
	}

	function refreshColorCodes()
	{
		rgbChannelSprites[0].text = "R : " + colors[arrowSelected].red;
		rgbChannelSprites[1].text = "G : " + colors[arrowSelected].green;
		rgbChannelSprites[2].text = "B : " + colors[arrowSelected].blue;
		hexCodeInput.text = colors[arrowSelected].toWebString().substr(1);
	}

	function changeRGB(change:Int)
	{
		// switch(channelSelected) {
		// 	case 0:
		// 		colors[arrowSelected].red += change;
		// 	case 1:
		// 		colors[arrowSelected].green += change;
		// 	case 2:
		// 		colors[arrowSelected].blue += change;
		// }
		colors[arrowSelected].setRGB(channelSelected == 0 ? colors[arrowSelected].red + change : colors[arrowSelected].red,
			channelSelected == 1 ? colors[arrowSelected].green + change : colors[arrowSelected].green,
			channelSelected == 2 ? colors[arrowSelected].blue + change : colors[arrowSelected].blue);
		refreshNotes();
		refreshColorCodes();
	}
}
