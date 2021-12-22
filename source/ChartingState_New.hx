package;

import haxe.iterators.StringIterator;
import flixel.addons.ui.FlxButtonPlus;
import openfl.geom.Rectangle;
import flixel.addons.ui.FlxUIButton;
import sys.io.File;
import flixel.addons.ui.FlxUIRadioGroup;
import flixel.addons.ui.FlxUIText;
import StoryMenuState.WeeksJson;
import sys.FileSystem;
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

using StringTools;



/**
* In-Game charter (When you press 7)
*/
typedef ModChars = {
	public var modName:String;
	public var chars:Array<String>;
}
class ChartingState_New extends MusicBeatState
{
	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<CharterNote>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

	public static var _song:SwagSong;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Int = 0;

	var vocals:FlxSound;

	var p1:HealthIcon;
	var p2:HealthIcon;

	var noteColors:Array<FlxColor> = [
		FlxColor.fromRGB(255,111,111),
		FlxColor.fromRGB(125,255,111),
		FlxColor.fromRGB(111,201,255),
		FlxColor.fromRGB(255,255,111),
		FlxColor.fromRGB(219,111,255),
		FlxColor.fromRGB(111,248,255),
		FlxColor.fromRGB(111,111,255),
	];

	var gridBlackLines:Array<FlxSprite> = [

	];
	public static var zoom:Float = 1;

	override function create()
	{
		var bg = new FlxSprite().loadGraphic(Paths.image("menuBGYoshi", "preload"));
		bg.scale.x = bg.scale.y = 1.25;
		bg.antialiasing = true;
		bg.screenCenter();
		bg.scrollFactor.set();
		add(bg);

		curSection = lastSection;
		if (FlxG.sound.music == null)
			curSection = 0;
		else
			if (curSection * 4 * Conductor.crochet > FlxG.sound.music.length)
				curSection = 0;

		if (PlayState._SONG != null)
			_song = PlayState._SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				speed: 1,
				validScore: false,
				keyNumber: 4,
				noteTypes : ["Friday Night Funkin':Default Note"]
			};
		}
		
		Assets.loadLibrary("shared");
		Assets.loadLibrary("characters");

		if (_song.keyNumber == null)
			_song.keyNumber = 4;

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * _song.keyNumber * 2 * _song.noteTypes.length, GRID_SIZE * 16);
		add(gridBG);

		p1 = new HealthIcon(_song.player1);
		p2 = new HealthIcon(_song.player2);
		p1.scrollFactor.set(1, 1);
		p2.scrollFactor.set(1, 1);

		p1.setGraphicSize(0, 45);
		p2.setGraphicSize(0, 45);

		add(p1);
		add(p2);

		p1.setPosition(0, -100);
		p2.setPosition(gridBG.width / 2, -100);

		// var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		// add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<CharterNote>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		FlxG.mouse.visible = true;
		// FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;


		loadSong(_song.song);
		updateGrid();
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Controls", label: 'Controls'},
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, FlxG.height - 40);
		UI_box.x = 0;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addControlsUI();

		insert(members.indexOf(UI_box), curRenderedSustains);
		insert(members.indexOf(UI_box), curRenderedNotes);

		super.create();
	}

	function addControlsUI():Void {
		var controls = new FlxUIText(10, 10, 280, Assets.getText(Paths.txt("charterControls", "preload")));
		var tab_group_controls = new FlxUI(null, UI_box);
		tab_group_controls.name = "Controls";
		tab_group_controls.add(controls);
		UI_box.addGroup(tab_group_controls);
	}
	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		
		var reloadSong:FlxButton = new FlxButton(290, 10, "Reload Audio", function()
		{
			loadSong(_song.song);
		});
		reloadSong.x -= reloadSong.width;

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x - 10, reloadSong.y, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});
		reloadSongJson.x -= reloadSongJson.width;
		UI_songTitle.y = reloadSong.y + (reloadSong.height / 2) - (UI_songTitle.height / 2);

		//
		// CHARACTERS SHIT !!!!
		//
		var mods:Array<String> = [];
		var modCharacters:Array<Array<String>> = [];
		var m = Paths.getModsFolder();
		for(folder in FileSystem.readDirectory(m)) {
			if (FileSystem.isDirectory('$m/$folder') && FileSystem.exists('$m/$folder/characters/')) {
				var chars = [];
				for(char in FileSystem.readDirectory('$m/$folder/characters/')) {
					chars.push(char);
				}
				mods.push(folder);
				modCharacters.push(chars);
			}
		}

		// PLAYER 1 SHIT
		var p1label = new FlxUIText(10, reloadSong.y + reloadSong.height + 10, 0, "Player 1 (you)");
		var player1:Array<String> = _song.player1.split(":");
		if (player1.length < 2) player1.insert(0, "Friday Night Funkin'");

		var player1ModDropDown:FlxUIDropDownMenu = null;
		var player1CharDropDown:FlxUIDropDownMenu = null;
		player1CharDropDown = new FlxUIDropDownMenu(295, 0, FlxUIDropDownMenu.makeStrIdLabelArray(modCharacters[mods.indexOf(player1[0])], true), function(character:String)
				{
					_song.player1 = player1ModDropDown.selectedLabel + ":" + modCharacters[mods.indexOf(player1ModDropDown.selectedLabel)][Std.parseInt(character)];
					trace(_song.player1);
				}, new FlxUIDropDownHeader(140));
				player1CharDropDown.selectedLabel = player1[1];

		player1CharDropDown.x -= player1CharDropDown.width;
		player1ModDropDown = new FlxUIDropDownMenu(295, p1label.y + p1label.height + 10, FlxUIDropDownMenu.makeStrIdLabelArray(mods, true), function(character:String)
		{
			_song.player1 = player1ModDropDown.selectedLabel + ":" + modCharacters[mods.indexOf(player1ModDropDown.selectedLabel)][0];
			player1CharDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(modCharacters[mods.indexOf(player1ModDropDown.selectedLabel)], true));
			trace(_song.player1);
		}, new FlxUIDropDownHeader(140));
		player1CharDropDown.y = player1ModDropDown.y + 30;
		player1ModDropDown.x -= player1ModDropDown.width;
		player1ModDropDown.selectedLabel = player1[0];
		player1CharDropDown.selectedLabel = player1[1];
		p1label.x = player1ModDropDown.x + (player1ModDropDown.width / 2) - (p1label.width / 2);



		
		var p2label = new FlxUIText(10, reloadSong.y + reloadSong.height + 10, 0, "Player 2 (them)");
		var player2:Array<String> = _song.player2.split(":");
		if (player2.length < 2) player2.insert(0, "Friday Night Funkin'");

		var player2ModDropDown:FlxUIDropDownMenu = null;
		var player2CharDropDown:FlxUIDropDownMenu = null;
		player2CharDropDown = new FlxUIDropDownMenu(5, 0, FlxUIDropDownMenu.makeStrIdLabelArray(modCharacters[mods.indexOf(player2[0])], true), function(character:String)
				{
					_song.player2 = player2ModDropDown.selectedLabel + ":" + modCharacters[mods.indexOf(player2ModDropDown.selectedLabel)][Std.parseInt(character)];
					trace(_song.player2);
				}, new FlxUIDropDownHeader(140));
				player2CharDropDown.selectedLabel = player2[1];

		player2ModDropDown = new FlxUIDropDownMenu(5, p2label.y + p2label.height + 10, FlxUIDropDownMenu.makeStrIdLabelArray(mods, true), function(character:String)
		{
			_song.player2 = player2ModDropDown.selectedLabel + ":" + modCharacters[mods.indexOf(player2ModDropDown.selectedLabel)][0];
			player2CharDropDown.setData(FlxUIDropDownMenu.makeStrIdLabelArray(modCharacters[mods.indexOf(player2ModDropDown.selectedLabel)], true));
			trace(_song.player2);
		}, new FlxUIDropDownHeader(140));
		player2CharDropDown.y = player2ModDropDown.y + 30;
		player2ModDropDown.selectedLabel = player2[0];
		player2CharDropDown.selectedLabel = player2[1];
		p2label.x = player2ModDropDown.x + (player2ModDropDown.width / 2) - (p2label.width / 2);











		var check_voices = new FlxUICheckBox(10, player2CharDropDown.y + 30, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(20 + check_voices.x + check_voices.width, player2CharDropDown.y + 30, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		noteNumber = new FlxUINumericStepper(290, check_mute_inst.y + check_mute_inst.height + 10, 1, _song.keyNumber, 1);
		noteNumber.x -= noteNumber.width;
		noteNumber.value = _song.keyNumber;
		noteNumber.name = 'note amount';
		var noteNumberLabel = new FlxUIText(10, noteNumber.y + (noteNumber.height / 2), 0, "Note Amount (needs refresh)");
		noteNumberLabel.y -= noteNumberLabel.height / 2;

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(290, noteNumber.y + noteNumber.height, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.x -= stepperSpeed.width;
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';
		var stepperSpeedLabel = new FlxUIText(10, stepperSpeed.y + (stepperSpeed.height / 2), 0, "Scroll Speed");
		stepperSpeedLabel.y -= stepperSpeed.height / 2;

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(290, stepperSpeed.y + stepperSpeed.height, 1, 1, 1, 339, 0);
		stepperBPM.x -= stepperBPM.width;
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';
		var stepperBPMLabel = new FlxUIText(10, stepperBPM.y + (stepperBPM.height / 2), 0, "Beats per minute (BPM)");
		stepperBPMLabel.y -= stepperBPM.height / 2;
		// _song.needsVoices = check_voices.checked;
		

		

		var saveButton:FlxButton = new FlxButton(10, stepperBPM.y + stepperBPM.height + 10, "Save", function()
		{
			saveLevel();
		});
		var saveButton2:FlxButtonPlus = new FlxButtonPlus(saveButton.x, saveButton.y + saveButton.height + 10, function()
		{
			saveLevel("\t");
		}, "Save with\npretty print", 100, 50);
		


		var refresh:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Refresh", function()
		{
			FlxG.resetState();
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(refresh.x + refresh.width + 10, refresh.y, 'Load Autosave', loadAutosave);

		

		// var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));

		

		var tab_group_song = new FlxUI(null, UI_box);


		


		var fixChartButton = new FlxButton(10, 654, "Fix Chart", function() {
			for (s in _song.notes) {
				for (n in s.sectionNotes) {
					s.sectionNotes.remove(n);
					_song.notes[Math.floor(Math.max(0, n[0] + Conductor.stepCrochet) / (Conductor.crochet * 4))].sectionNotes.push(n);
				}
			}
		});
		fixChartButton.y -= fixChartButton.height;
		var fixChartLabel = new FlxUIText(10, fixChartButton.y - 10, 280, "Pressing this button will fix chart's note section problem, where notes are in the wrong section and off the grid. This operation may take a while depending on the size on the chart. Continue at your own risk.");
		fixChartLabel.y -= fixChartLabel.height;



		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(saveButton);
		tab_group_song.add(refresh);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperBPMLabel);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperSpeedLabel);
		tab_group_song.add(noteNumber);
		tab_group_song.add(noteNumberLabel);

		tab_group_song.add(p2label);
		tab_group_song.add(player2CharDropDown);
		tab_group_song.add(player2ModDropDown);

		tab_group_song.add(p1label);
		tab_group_song.add(player1CharDropDown);
		tab_group_song.add(player1ModDropDown);

		tab_group_song.add(fixChartLabel);
		tab_group_song.add(fixChartButton);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var noteNumber:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		{
			var title = new FlxUIText(10, 11, 0, "=====[Section Settings]=====");
			title.x = (300 / 2) - (title.width / 2);

			check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
			check_changeBPM.name = 'check_changeBPM';

			stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
			stepperSectionBPM.value = Conductor.bpm;
			stepperSectionBPM.name = 'section_bpm';
			stepperSectionBPM.x = 292 - stepperSectionBPM.width;
			stepperSectionBPM.y = check_changeBPM.y + (check_changeBPM.height / 2) - (stepperSectionBPM.height / 2);


			tab_group_section.add(title);
			// tab_group_section.add(check_mustHitSection);
			tab_group_section.add(stepperSectionBPM);
			tab_group_section.add(check_changeBPM);
		}

		{
			var title = new FlxUIText(10, check_changeBPM.y + check_changeBPM.height + 10, 0, "=====[Visual Settings]=====");
			title.x = (300 / 2) - (title.width / 2);

			check_mustHitSection = new FlxUICheckBox(10, title.y + title.height + 10, null, null, "Must hit section", 100);
			check_mustHitSection.name = 'check_mustHit';
			check_mustHitSection.checked = true;

			stepperLength = new FlxUINumericStepper(10, check_mustHitSection.y + check_mustHitSection.height + 10, 4, 0, 0, 999, 0);
			stepperLength.value = _song.notes[curSection].lengthInSteps;
			stepperLength.x = 290 - stepperLength.width;
			stepperLength.name = "section_length";

			var stepperLengthLabel = new FlxUIText(10, 0, 0, "Section Length");
			stepperLengthLabel.y = stepperLength.y + (stepperLength.height / 2) - (stepperLengthLabel.height / 2);
			
			var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, stepperLength.y + stepperLength.height + 10, 1, 1, -999, 999, 0);



			var swapSection:FlxButton = new FlxButton(10, 130, "Swap section", function()
			{
				for (i in 0..._song.notes[curSection].sectionNotes.length)
				{
					var note = _song.notes[curSection].sectionNotes[i];
					note[1] = (note[1] + _song.keyNumber) % (_song.keyNumber * 2);
					_song.notes[curSection].sectionNotes[i] = note;
					updateGrid();
				}
			});
			swapSection.y = stepperCopy.y + (stepperCopy.height / 2) - (swapSection.height / 2);
			
			var clearSectionButton:FlxButton = new FlxButton(10, swapSection.y, "Clear", clearSection);
			clearSectionButton.x = swapSection.x + swapSection.width + 10;

			// swapSection.x = copyButton.x + copyButton.width + 10;
			var copyButton:FlxButton = new FlxButton(10, swapSection.y, "Copy Section", function()
			{
				copySection(Std.int(stepperCopy.value));
			});

			// copyButton.x = clearSectionButton.x + clearSectionButton.width + 10;
			copyButton.y += copyButton.height + 10;

			stepperCopy.x = copyButton.x + copyButton.width + 10;
			stepperCopy.y = copyButton.y + (copyButton.height / 2) - (stepperCopy.height / 2);

			
			check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
			check_altAnim.name = 'check_altAnim';
			check_altAnim.y = copyButton.y + copyButton.height + 10;
			
			tab_group_section.add(title);
			tab_group_section.add(check_mustHitSection);
			tab_group_section.add(stepperLengthLabel);
			tab_group_section.add(stepperLength);
			tab_group_section.add(stepperCopy);
			tab_group_section.add(copyButton);
			tab_group_section.add(clearSectionButton);
			tab_group_section.add(swapSection);
			tab_group_section.add(check_altAnim);

		}
		
		

		
		// _song.needsVoices = check_mustHit.checked;

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var noteTypeRadioGroup:FlxUIRadioGroup;

	function updateNoteTypes() {
		noteTypeRadioGroup.updateRadios([for (i in _song.noteTypes) Std.string(i)], _song.noteTypes);
		var r = noteTypeRadioGroup.getRadios();
		for(i in 0...r.length) {
			if (i > 0) {
				var l = r[i].getLabel();
				l.setFormat(null, 8, noteColors[(i - 1) % noteColors.length], null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
		}
		updateGrid(true);
	}
	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';



		stepperSusLength = new FlxUINumericStepper(151, 12, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		var applyLength:FlxButton = new FlxButton(212, 9, 'Apply');
		var nTypes:Array<String> = [];
		var mPath = Paths.getModsFolder();
		for (mod in FileSystem.readDirectory(mPath)) {
			if (FileSystem.exists('$mPath/$mod/notes/')) {
				for (nType in FileSystem.readDirectory('$mPath/$mod/notes/')) {
					if (nType.toLowerCase().endsWith(".hx")) { // ONLY ACCEPTS HX FILES !!!!
						var extless = nType.substr(0, nType.length - 3);
						nTypes.push('$mod:$extless');
					}
				}
			}
		}
		var noteTypeDropdown:FlxUIDropDownMenu = new FlxUIDropDownMenu(10, applyLength.y + applyLength.height + 10, FlxUIDropDownMenu.makeStrIdLabelArray(nTypes, false), null, new FlxUIDropDownHeader(270 - Math.floor(applyLength.width)));
		var addButton:FlxButton = new FlxButton(noteTypeDropdown.x + noteTypeDropdown.width + 10, noteTypeDropdown.y + 10, "Add Type", function() {
			_song.noteTypes.push(noteTypeDropdown.selectedLabel);
			updateNoteTypes();
		});
		var removeSelected:FlxButton = new FlxButton(212, addButton.y + addButton.height + 10, 'Remove Type', function() {
			_song.noteTypes.remove(noteTypeRadioGroup.selectedLabel);
			if (_song.noteTypes.length == 0) _song.noteTypes = ["Friday Night Funkin':Default Note"];
			updateNoteTypes();
		});
		addButton.y -= addButton.height / 2;

		noteTypeRadioGroup = new FlxUIRadioGroup(10, addButton.y + addButton.height + 10, [for (i in _song.noteTypes) Std.string(i)], _song.noteTypes, null, 25, 280, 20, 280);

		tab_group_note.add(new FlxUIText(10, 11, 0, "Sustain Length (ms)"));
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(removeSelected);
		tab_group_note.add(applyLength);
		tab_group_note.add(addButton);
		tab_group_note.add(noteTypeDropdown);
		tab_group_note.add(noteTypeRadioGroup);
		
		updateNoteTypes();

		
		

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(Paths.modInst(daSong, PlayState.songMod), 0.6);
		if (curSection * 4 * Conductor.crochet > FlxG.sound.music.length) curSection = 0;

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Paths.modVoices(daSong, PlayState.songMod));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;

					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				if (nums.value < 1) nums.value = 1;
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				if (curSelectedNote != null) {
					curSelectedNote[2] = nums.value;
					updateGrid();
				}
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'note amount')
			{
				_song.keyNumber = Std.int(nums.value);
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime():Float
	{
		var daBPM:Int = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		var r = noteTypeRadioGroup.getRadios();
		for(i in 0...r.length) {
			if (i > 0) {
				var l = r[i].getLabel();
				l.color = noteColors[(i - 1) % noteColors.length];
				// l.setFormat(null, 8, noteColors[(i - 1) % noteColors.length], null, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			}
		}

		curStep = recalculateSteps();

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));

		var zoomShit = FlxG.mouse.wheel;
		if (FlxG.keys.justPressed.PAGEUP) zoomShit++;
		if (FlxG.keys.justPressed.PAGEDOWN) zoomShit--;

		if (FlxG.keys.pressed.CONTROL && zoomShit != 0) {
			zoom += zoomShit;
			if (zoom < 1) zoom = 1;
			updateGrid(true);
		}
		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		
		if (FlxG.mouse.justPressed && !FlxG.mouse.overlaps(UI_box))
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:CharterNote)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * zoom * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * zoom * _song.notes[curSection].lengthInSteps))
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState._SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;
			}

			if (FlxG.keys.pressed.A || FlxG.keys.pressed.D) {
				var speed = FlxG.keys.pressed.SHIFT ? 3 : 1;
				strumLine.x = Math.min(Math.max(0, strumLine.x + (GRID_SIZE * _song.keyNumber * elapsed * (FlxG.keys.pressed.A ? -speed : speed))), GRID_SIZE * _song.keyNumber * 2 * (_song.noteTypes.length - 1));
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT)
			changeSection(curSection - shiftThing);

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ '\nSection: $curSection\rcurBeat: $curBeat\rcurStep: $curStep';
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			p1.x = (gridBG.x + (gridBG.width / 4)) - p1.width / 2;
			p2.x = (gridBG.x + ((gridBG.width / 4) * 3)) - p2.width / 2;
			// p1.animation.play('bf');
			// p2.animation.play('dad');
		}
		else
		{
			p1.x = (gridBG.x + ((gridBG.width / 4) * 3)) - p1.width / 2;
			p2.x = (gridBG.x + (gridBG.width / 4)) - p2.width / 2;
			// p1.animation.play('dad');
			// p2.animation.play('bf');
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	var gridOverlay:FlxSprite;
	function updateGrid(updateSprite:Bool = false):Void
	{
		if (updateSprite) {
			var oldPos = members.indexOf(gridBG);
			remove(gridBG);
			gridBG.destroy();
			gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * _song.keyNumber * 2 * _song.noteTypes.length, Std.int(GRID_SIZE * 16 * zoom));
			if (gridOverlay != null) {
				remove(gridOverlay);
				gridOverlay.destroy();
			}
			gridOverlay = new FlxSprite(gridBG.x, gridBG.y).makeGraphic(GRID_SIZE * _song.keyNumber * 2 * _song.noteTypes.length, Std.int(GRID_SIZE * 16 * zoom), FlxColor.TRANSPARENT);
			gridOverlay.pixels.lock();
			if (_song.noteTypes.length > 1) {
				for(i in 1..._song.noteTypes.length) {
					var c = noteColors[i - 1];
					c.alphaFloat = 0.5;
					gridOverlay.pixels.fillRect(new Rectangle(GRID_SIZE * _song.keyNumber * 2 * i, 0, GRID_SIZE * _song.keyNumber * 2, Std.int(GRID_SIZE * 16 * zoom)), c);
				}
			}
			for (i in 0...(_song.noteTypes.length * 2)) {
				gridOverlay.pixels.fillRect(new Rectangle(GRID_SIZE * _song.keyNumber * i - (((i % 2) == 0) ? 0 : 1), 0, ((i % 2) == 0) ? 1 : 2, Std.int(GRID_SIZE * 16 * zoom)), FlxColor.BLACK);
			}
			gridOverlay.pixels.unlock();
			insert(oldPos, gridOverlay);
			insert(oldPos, gridBG);
		}
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Int = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		for (i in sectionInfo)
		{
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];

			var note:CharterNote = new CharterNote(daStrumTime, daNoteInfo);
			note.sustainLength = daSus;
			if (daNoteInfo < _song.keyNumber * 2) {
				note.color = FlxColor.WHITE;
			} else {
				note.color = noteColors[(Math.floor(daNoteInfo / (_song.keyNumber * 2)) - 1) % noteColors.length];
			}
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));

			curRenderedNotes.add(note);
			

			if (daSus > 0)
			{
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
					note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:CharterNote):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:CharterNote):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == note.noteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;

		_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus]);

		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + _song.keyNumber) % (_song.keyNumber * 2), noteSus]);
		}

		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + (gridBG.height), 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	public static var difficulties:Map<String, String> = [
		"Easy" => "-easy",
		"Normal" => "",
		"Hard" => "-hard",
	];

	function loadJson(song:String):Void
	{
		_song = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		_song = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel(?space:String)
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, space);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
