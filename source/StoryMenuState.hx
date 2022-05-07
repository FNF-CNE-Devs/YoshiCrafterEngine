package;

import Script.HScript;
import mod_support_stuff.SwitchModSubstate;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxTileFrames;
import openfl.Assets;
import openfl.display.BitmapData;
import EngineSettings.Settings;
import flixel.tweens.FlxEase;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;

typedef StoryMenuCharacter = {
	var file:String;
	var animation:String;
	var scale:Float;
	var flipX:Bool;
	var offset:Array<Float>;
}
typedef FNFWeek = {
	var name:String;
	var songs:Array<String>;
	var mod:String; // Set automatically, no need to worry
	var buttonSprite:String;
	var color:String;
	var dad:StoryMenuCharacter;
	var difficulties:Array<WeekDifficulty>;
	@:optional var locked:Bool;
}
typedef WeekDifficulty = {
	var name:String;
	var sprite:String;
}
typedef WeeksJson = {
	var weeks:Array<FNFWeek>;
}
class StoryMenuState extends MusicBeatState
{
	var colorTween:FlxTween;
	var scoreText:FlxText;

	var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;

	var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var yellowBG:FlxSprite;
	var blackBG:FlxSprite;

	var switchMod:FlxText;

	var menuScript:Script;

	public static var weekData:Array<FNFWeek> = null;
	public var activeWeekData:Array<FNFWeek> = [];
	public static var weekButtons:Array<String> = null;
	public static var weekCharacters:Map<String, String> = null;

	var modWeekCharacters:Map<String, FlxSprite> = [];

	public static function loadWeeks() {
		weekData = [];
		weekButtons = [];
		weekCharacters = [];
		var fnfWeekData = [];
		var fnfWeekButtons = [];
		
		for (mod in ModSupport.getMods()) {
			// var exists = false;
			// var a = [for (e in Main.supportedFileTypes) e];
			// a.push("json");
			// for (e in a) {
			// 	exists = FileSystem.exists(Paths.modsPath + '/$mod/song_conf.$e');
			// 	if (exists) break;
			// }
			var jsonPath = Paths.getPath('weeks.json', TEXT, 'mods/$mod');
			if (Assets.exists(jsonPath)) {
				var json:WeeksJson = null;
				try {
					json = Json.parse(Assets.getText(jsonPath));
				} catch(e) {

				}
				if (json == null) continue;
				if (json.weeks == null) {
					PlayState.log.push('"week" value for $mod\'s weeks.json is null. Skipping...');
					continue;
				};
				for(week in json.weeks) {
					week.mod = mod;
					if (week.difficulties == null) week.difficulties = [
						{"name" : "Easy", "sprite" : "Friday Night Funkin':storymenu/easy"},
						{"name" : "Normal", "sprite" : "Friday Night Funkin':storymenu/normal"},
						{"name" : "Hard", "sprite" : "Friday Night Funkin':storymenu/hard"}
					];
					var sprite = week.buttonSprite;
					trace(mod);
					(mod == "Friday Night Funkin'" ? fnfWeekData : weekData).push(week);

					var weekButton = Paths.getPath('$sprite', IMAGE, 'mods/$mod');
					/*
					if (!Assets.exists(weekButton)) {
						weekButton = new BitmapData(443, 82, true, 0x00000000);
					}
					*/
					(mod == "Friday Night Funkin'" ? fnfWeekButtons : weekButtons).push(weekButton);

					var f = mod + ":" + week.dad.file.trim().replace("/", "/").replace("\\", "/");
					if (weekCharacters[f] == null) {
						#if debug
						// trace('Creating bitmap for $f');
						#end
						var mod = week.mod;
						var file = week.dad.file;
						var sparrowPath = Paths.modsPath + '/$mod/$file';
						#if debug
							trace(sparrowPath);
						#end
						var b = Paths.getPath('$file.png', IMAGE, 'mods/$mod');
						// if (b == null) b = new BitmapData(1, 1, true, 0x00000000);
						weekCharacters[f] = b;
					}
				}
			}
		}
		
		if (!(Settings.engineSettings.data.hideOriginalGame && weekData.length > 0)) {
			for (s in fnfWeekData) weekData.push(s);
			for (b in fnfWeekButtons) weekButtons.push(b);
		}
	}

	var difficultySprites:Map<String, FlxSprite> = [];
	override function create()
	{
		reloadModsState = true;
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		
		CoolUtil.playMenuMusic();

		menuScript = Script.create('${Paths.getModsPath()}/${Settings.engineSettings.data.selectedMod}/ui/StoryMenuState');
		var validated = true;
		if (menuScript == null) {
			menuScript = new HScript();
			validated = false;
		}
		ModSupport.setScriptDefaultVars(menuScript, '${Settings.engineSettings.data.selectedMod}', {});
		menuScript.setVariable("state", this);
		// menuScript.setVariable("addSong", addSong);
		if (validated) {
			menuScript.loadFile('${Paths.getModsPath()}/${Settings.engineSettings.data.selectedMod}/ui/StoryMenuState');
		}
		menuScript.executeFunc("create", []);

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: -", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getCustomizableSparrowAtlas('campaign_menu_UI_assets');
		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, FlxColor.WHITE);
		yellowBG.color = 0xFFF9CF51;
		blackBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		blackBG.color = 0xFFF9CF51;

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var invalid = false;
		/*
		for(bitmap in weekButtons) {
			if (!bitmap.readable) {
				invalid = true;
				break;
			}
		}
		*/
		if (weekData == null || CoolUtil.isDevMode() || invalid) { // If it never was loaded before OR if in developer mode
			loadWeeks();
		}

		var currentWeekButtons = [];

		for (i in 0...weekData.length) {
			if (weekData[i].mod == Settings.engineSettings.data.selectedMod) {
				activeWeekData.push(weekData[i]);
				currentWeekButtons.push(weekButtons[i]);
			}
		}
		var height:Float = 0;
		
		menuScript.setVariable("setWeekLocked", function(weekName:String, lock:Bool) {
			if (weekName == null) PlayState.trace("Week Name is null");
			for (w in activeWeekData) {
				if (w.name == weekName) {
					w.locked = lock;
				}
			}
		});
		menuScript.executeFunc("createWeeks");

		for (i in 0...activeWeekData.length)
		{
			var w:FNFWeek = activeWeekData[i];
			var sprite:String = w.buttonSprite;
			var m:String = w.mod;

			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, currentWeekButtons[i]);
			weekThing.y += height;
			weekThing.targetY = grpWeekText.length; //big brain
			weekThing.antialiasing = true;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			height += weekThing.height + 20;

			if (w.locked == true)
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
			
			// weekThing.updateHitbox();

			// Needs an offset thingie
		}

		trace("Line 136");

		var vi = true;
		for (week in activeWeekData) {
			var mod = week.mod;
			var file = week.dad.file.trim().replace("/", "/").replace("\\", "/");
			var sparrowPath = Paths.modsPath + '/$mod/$file';
			if (modWeekCharacters['$mod:$file'] == null) {
				var charFrames = null;
				try {
					charFrames = FlxAtlasFrames.fromSparrow(weekCharacters['$mod:$file'], Paths.getPath('$file.xml', TEXT, 'mods/$mod'));
				} catch(e) {
	
				}
				/*
				if (charFrames == null) {
					modWeekCharacters['$mod:$file'] = new FlxSprite(0,0).makeGraphic(1,1,FlxColor.TRANSPARENT);
					continue;
				}
				*/
				var menuCharacter = new FlxSprite((FlxG.width * 0.25) - 150);
				
				menuCharacter.frames = charFrames;
				menuCharacter.y += 70;
				menuCharacter.antialiasing = true;
				// menuCharacter.flipX = (week.dad.flipX == true ? true : false); //prevents null error shit
				// menuCharacter.setGraphicSize(Std.int(menuCharacter.width * week.dad.scale));
				// menuCharacter.scale.x = menuCharacter.scale.y = week.dad.scale;
				// menuCharacter.updateHitbox();
				// if (week.dad.offset != null) {
				// 	menuCharacter.offset.x = week.dad.offset.length > 0 ? week.dad.offset[0] : 0;
				// 	menuCharacter.offset.y = week.dad.offset.length > 1 ? week.dad.offset[1] : 0;
				// }
				menuCharacter.visible = vi;
	
				modWeekCharacters['$mod:$file'] = menuCharacter;
				vi = false;
			}
			modWeekCharacters['$mod:$file'].animation.addByPrefix(week.dad.animation, week.dad.animation, 24);
			modWeekCharacters['$mod:$file'].animation.play(week.dad.animation);
		}
		for (char in 0...2)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (2 + char) - 150, char == 0 ? "bf" : "gf");
			weekCharacterThing.y += 70;
			weekCharacterThing.antialiasing = true;
			switch (weekCharacterThing.character)
			{
				case 'bf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.9));
					weekCharacterThing.updateHitbox();
					weekCharacterThing.x -= 80;
				case 'gf':
					weekCharacterThing.setGraphicSize(Std.int(weekCharacterThing.width * 0.5));
					weekCharacterThing.updateHitbox();
			}

			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		for(week in weekData) {
			if (week.mod == Settings.engineSettings.data.selectedMod) {
				for (diff in week.difficulties) {
					if (difficultySprites[diff.sprite] == null) {
						var modsPath = Paths.modsPath;
						sprDifficulty = new FlxSprite(1070, grpWeekText.members[0].y + 10);
						var bitmapMod = week.mod;
						var bitmapPath = "";
						var bitmapSplit:Array<String> = diff.sprite.split(":");
						if (bitmapSplit[0].toLowerCase() == "yoshiengine") bitmapSplit[0] = "YoshiCrafterEngine";
						if (bitmapSplit.length < 2) {
							bitmapPath = diff.sprite;
						} else {
							bitmapMod = bitmapSplit[0];
							bitmapPath = bitmapSplit[1];
						}
						sprDifficulty.loadGraphic(Paths.image(bitmapPath, 'mods/$bitmapMod'));
						if (sprDifficulty.width > 290) sprDifficulty.setGraphicSize(290);
						sprDifficulty.x -= (sprDifficulty.width / 2);
						difficultySelectors.add(sprDifficulty);
						sprDifficulty.antialiasing = true;
						difficultySprites[diff.sprite] = sprDifficulty;
					}
				}
			}
		}

		// difficultySelectors.add(sprDifficulty);


		switchMod = new FlxText(10, 10, 0, '${ModSupport.getModName(Settings.engineSettings.data.selectedMod)}\n[Tab] to switch\n', 24);
		switchMod.alignment = CENTER;
		switchMod.font = rankText.font;
		switchMod.color = 0xFFFFFFFF;
		switchMod.alpha = 2 / 3;
		switchMod.y = FlxG.height + 14 - switchMod.height;
		switchMod.x = FlxG.width - 10 - switchMod.width;
		add(switchMod);

		if (activeWeekData.length <= 0) {
			add(blackBG);
			add(yellowBG);
			add(grpWeekCharacters);
			add(txtTracklist);
			// add(rankText);
			add(scoreText);
			add(txtWeekTitle);
			
			var text = new FlxText(10, yellowBG.y + yellowBG.height + 10, FlxG.width - 20, "This mod does not contain any Story Mode weeks.", 18);
			text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.alpha = 0.66;
			add(text);
			super.create();
			return;
		}
		leftArrow = new FlxSprite(FlxG.width - (1280 - (1190 - 175 + 48)), grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = true;
		leftArrow.x -= leftArrow.width;
		difficultySelectors.add(leftArrow);

		rightArrow = new FlxSprite(FlxG.width - (1280 - 1222), leftArrow.y);
		// rightArrow = new FlxSprite(leftArrow.x + 130 + 196 + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = true;
		// rightArrow.x = FlxG.width - 10 - rightArrow.width;
		difficultySelectors.add(rightArrow);

		changeDifficulty();

		trace("Line 150");

		add(blackBG);
		add(yellowBG);
		add(grpWeekCharacters);
		for(c in modWeekCharacters) add(c);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);
		updateText();

		trace("Line 165");

		super.create();
		menuScript.executeFunc("createPost");
	}

	override function update(elapsed:Float)
	{
		menuScript.executeFunc("preUpdate", [elapsed]);
		
		if (FlxControls.justPressed.F5) FlxG.resetState();
		if (FlxControls.justPressed.TAB) {
			persistentUpdate = false;
			openSubState(new SwitchModSubstate());
		}
		
		if (activeWeekData.length <= 0) {
			if (controls.BACK) FlxG.switchState(new MainMenuState());
			super.update(elapsed);
			return;
		}
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5 * 60 * elapsed));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = activeWeekData[curWeek].name;
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		// difficultySelectors.visible = weekUnlocked[curWeek];
		
		menuScript.executeFunc("update", [elapsed]);
		if (!movedBack)
		{
			if (!selectedWeek)
			{
				if (controls.UP_P)
				{
					changeWeek(-1);
				}

				if (controls.DOWN_P)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			CoolUtil.playMenuSFX(2);
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});
		menuScript.executeFunc("postUpdate", [elapsed]);
		menuScript.executeFunc("updatePost", [elapsed]);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		// if (weekUnlocked[curWeek])
		if (activeWeekData[curWeek].locked != true)
		{
			if (stopspamming == false)
			{
				CoolUtil.playMenuSFX(1);

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[0].animation.play('bfConfirm');
				stopspamming = true;
			}

			PlayState.actualModWeek = activeWeekData[curWeek];
			PlayState.songMod = activeWeekData[curWeek].mod;
			PlayState.storyPlaylist = activeWeekData[curWeek].songs;
			PlayState.isStoryMode = true;
			PlayState.startTime = 0;
			selectedWeek = true;

			// var diffic = "";

			// switch (curDifficulty)
			// {
			// 	case 0:
			// 		diffic = '-easy';
			// 	case 2:
			// 		diffic = '-hard';
			// }

			PlayState.storyDifficulty = activeWeekData[curWeek].difficulties[curDifficulty].name;

			PlayState._SONG = Song.loadModFromJson(Highscore.formatSong(PlayState.storyPlaylist[0].toLowerCase(), activeWeekData[curWeek].difficulties[curDifficulty].name), PlayState.songMod, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.jsonSongName = PlayState.storyPlaylist[0].toLowerCase();
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			PlayState.fromCharter = false;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		} else {
			CoolUtil.playMenuSFX(3);
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		var oldDiff = curDifficulty;
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty >= activeWeekData[curWeek].difficulties.length)
			curDifficulty = 0;

		if (menuScript.executeFunc("onChangeDifficulty", [curDifficulty]) == false) {
			curDifficulty = oldDiff;
			CoolUtil.playMenuSFX(3);
			return;
		}

		var sprDifficulty = difficultySprites[activeWeekData[curWeek].difficulties[curDifficulty].sprite];
		sprDifficulty.offset.x = 0;
		for(diffSprite in difficultySprites) {
			diffSprite.visible = false;
		}
		sprDifficulty.visible = true;

		// switch (curDifficulty)
		// {
		// 	case 0:
		// 		sprDifficulty.animation.play('easy');
		// 		sprDifficulty.offset.x = 20;
		// 	case 1:
		// 		sprDifficulty.animation.play('normal');
		// 		sprDifficulty.offset.x = 70;
		// 	case 2:
		// 		sprDifficulty.animation.play('hard');
		// 		sprDifficulty.offset.x = 20;
		// }

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getModWeekScore(activeWeekData[curWeek].mod, activeWeekData[curWeek].name, activeWeekData[curWeek].difficulties[curDifficulty].name);

		#if !switch
		intendedScore = Highscore.getModWeekScore(activeWeekData[curWeek].mod, activeWeekData[curWeek].name, activeWeekData[curWeek].difficulties[curDifficulty].name);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);

		menuScript.executeFunc("onChangeDifficultyPost", [curDifficulty]);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		var diffName = activeWeekData[curWeek].difficulties[curDifficulty].name;
		var oldWeek = curWeek;
		curWeek += change;

		if (curWeek >= activeWeekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = activeWeekData.length - 1;

		if (menuScript.executeFunc("onChangeWeek", [curWeek]) == false) {
			curWeek = oldWeek;
			CoolUtil.playMenuSFX(3);
			return;
		}
		var bullShit:Int = 0;

		var diffIndex = 0;
		for(i in 0...activeWeekData[curWeek].difficulties.length) {
			if (activeWeekData[curWeek].difficulties[i].name == diffName) {
				diffIndex = i;
				break;
			}
		}
		curDifficulty = diffIndex;
		changeDifficulty();
		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			// if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
			if (item.targetY == Std.int(0))
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		CoolUtil.playMenuSFX(0);

		updateText();
		menuScript.executeFunc("onChangeWeekPost", [curWeek]);
	}

	function updateText()
	{
		for(char in modWeekCharacters) {
			char.visible = false;
		}
		var week = activeWeekData[curWeek];
		var menuCharacter = modWeekCharacters[week.mod + ":" + week.dad.file.trim().replace("/", "/").replace("\\", "/")];
		menuCharacter.visible = true;
		menuCharacter.animation.play(week.dad.animation);
		menuCharacter.flipX = (week.dad.flipX == true ? true : false); //prevents null error shit
		menuCharacter.setGraphicSize(Std.int(menuCharacter.width * week.dad.scale));
		menuCharacter.scale.x = menuCharacter.scale.y = week.dad.scale;
		menuCharacter.updateHitbox();
		if (week.dad.offset != null) {
			menuCharacter.offset.x = week.dad.offset.length > 0 ? week.dad.offset[0] : 0;
			menuCharacter.offset.y = week.dad.offset.length > 1 ? week.dad.offset[1] : 0;
		}
		
		if (colorTween != null) colorTween.cancel();
		var co = 0xFFF9CF51;
		if (week.color != null) {
			var c = FlxColor.fromString(week.color);
			if (c != null) co = c;
		}
		colorTween = FlxTween.color(yellowBG, 0.25, yellowBG.color, co, {ease : FlxEase.smoothStepInOut});
		// grpWeekCharacters.members[0].animation.play(weekCharacters[curWeek][0]);
		// grpWeekCharacters.members[1].animation.play(weekCharacters[curWeek][1]);
		// grpWeekCharacters.members[2].animation.play(weekCharacters[curWeek][2]);
		txtTracklist.text = "Tracks\n";
		// modWeekCharacters
		

		var stringThing:Array<String> = week.songs;

		for (i in stringThing)
		{
			txtTracklist.text += "\n" + i;
		}

		txtTracklist.text += "\n";
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getModWeekScore(week.mod, week.name, week.difficulties[curDifficulty].name);
		// intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
