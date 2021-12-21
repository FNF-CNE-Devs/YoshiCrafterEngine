package;

import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxTileFrames;
import openfl.display.BitmapData;
import LoadSettings.Settings;
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

	public static var weekData:Array<FNFWeek> = null;
	public static var weekButtons:Array<BitmapData> = null;
	public static var weekCharacters:Map<String, BitmapData> = null;

	var modWeekCharacters:Array<FlxSprite> = [];

	public static function loadWeeks() {
		weekData = [];
		weekButtons = [];
		weekCharacters = [];
		
		for (mod in FileSystem.readDirectory(Paths.getModsFolder() + "/")) {
			if (FileSystem.exists(Paths.getModsFolder() + '/$mod/weeks.json') && FileSystem.exists(Paths.getModsFolder() + '/$mod/song_conf.hx')) {
				var json:WeeksJson = Json.parse(sys.io.File.getContent(Paths.getModsFolder() + '/$mod/weeks.json'));
				for(week in json.weeks) {
					week.mod = mod;
					if (week.difficulties == null) week.difficulties = [
						{"name" : "Easy", "sprite" : "Friday Night Funkin':storymenu/easy"},
						{"name" : "Normal", "sprite" : "Friday Night Funkin':storymenu/normal"},
						{"name" : "Hard", "sprite" : "Friday Night Funkin':storymenu/hard"}
					];
					var sprite = week.buttonSprite;
					weekData.push(week);

					var weekButton = Paths.getBitmapOutsideAssets(Paths.getModsFolder() + '/$mod/$sprite');
					if (weekButton == null) {
						weekButton = new BitmapData(443, 82, true, 0x00000000);
					}
					weekButtons.push(weekButton);

					var f = mod + ":" + week.dad.file;
					if (weekCharacters[f] == null) {
						#if debug
						trace('Creating bitmap for $f');
						#end
						var mod = week.mod;
						var file = week.dad.file;
						var sparrowPath = Paths.getModsFolder() + '/$mod/$file';
						#if debug
							trace(sparrowPath);
						#end
						var b = Paths.getBitmapOutsideAssets(sparrowPath + ".png");
						if (b == null) b = new BitmapData(1, 1, true, 0x00000000);
						weekCharacters[f] = b;
					}
				}
			}
		}
	}

	var difficultySprites:Map<String, FlxSprite> = [];
	override function create()
	{
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		yellowBG = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, FlxColor.WHITE);
		yellowBG.color = 0xFFF9CF51;

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
		for(bitmap in weekButtons) {
			if (!bitmap.readable) {
				invalid = true;
				break;
			}
		}
		if (weekData == null || Settings.engineSettings.data.developerMode || invalid) { // If it never was loaded before OR if in developer mode
			loadWeeks();
		}

		for (i in 0...weekData.length)
		{
			var w:FNFWeek = weekData[i];
			var sprite:String = w.buttonSprite;
			var m:String = w.mod;

			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, weekButtons[i].clone());
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			
			// weekThing.updateHitbox();

			// Needs an offset thingie
		}

		trace("Line 136");

		var vi = true;
		for (week in weekData) {
			var mod = week.mod;
			var file = week.dad.file;
			var sparrowPath = Paths.getModsFolder() + '/$mod/$file';
			var charFrames = null;
			try {
				charFrames = FlxAtlasFrames.fromSparrow(weekCharacters[week.mod + ":" + week.dad.file].clone(), Paths.getTextOutsideAssets(sparrowPath + ".xml", true));
			} catch(e) {

			}
			if (charFrames == null) {
				modWeekCharacters.push(new FlxSprite(0,0).makeGraphic(1,1,FlxColor.TRANSPARENT));
				continue;
			}
			var menuCharacter = new FlxSprite((FlxG.width * 0.25) - 150);
			
			menuCharacter.frames = charFrames;
			menuCharacter.y += 70;
			menuCharacter.antialiasing = true;
			menuCharacter.animation.addByPrefix("char", week.dad.animation, 24);
			menuCharacter.animation.play("char");
			menuCharacter.flipX = (week.dad.flipX == true ? true : false); //prevents null error shit
			menuCharacter.setGraphicSize(Std.int(menuCharacter.width * week.dad.scale));
			menuCharacter.updateHitbox();
			if (week.dad.offset != null) {
				menuCharacter.offset.x = week.dad.offset.length > 0 ? week.dad.offset[0] : 0;
				menuCharacter.offset.y = week.dad.offset.length > 1 ? week.dad.offset[1] : 0;
			}
			menuCharacter.visible = vi;

			modWeekCharacters.push(menuCharacter);
			vi = false;
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

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		for(week in weekData) {
			for (diff in week.difficulties) {
				if (difficultySprites[diff.sprite] == null) {
					var modsPath = Paths.getModsFolder();
					sprDifficulty = new FlxSprite(1070, leftArrow.y);
					var bitmapMod = week.mod;
					var bitmapPath = "";
					var bitmapSplit:Array<String> = diff.sprite.split(":");
					if (bitmapSplit.length < 2) {
						bitmapPath = diff.sprite;
					} else {
						bitmapMod = bitmapSplit[0];
						bitmapPath = bitmapSplit[1];
					}
					sprDifficulty.loadGraphic(Paths.getBitmapOutsideAssets('$modsPath/$bitmapMod/images/$bitmapPath.png'));
					if (sprDifficulty.width > 290) sprDifficulty.setGraphicSize(290);
					sprDifficulty.x -= (sprDifficulty.width / 2);
					difficultySelectors.add(sprDifficulty);
					difficultySprites[diff.sprite] = sprDifficulty;
				}
			}
		}
		changeDifficulty();

		// difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(1222, leftArrow.y);
		// rightArrow = new FlxSprite(leftArrow.x + 130 + 196 + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		// rightArrow.x = FlxG.width - 10 - rightArrow.width;
		difficultySelectors.add(rightArrow);

		trace("Line 150");

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
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekData[curWeek].name;
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		// difficultySelectors.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

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
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		// if (weekUnlocked[curWeek])
		if (true)
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[0].animation.play('bfConfirm');
				stopspamming = true;
			}

			PlayState.actualModWeek = weekData[curWeek];
			PlayState.songMod = weekData[curWeek].mod;
			PlayState.storyPlaylist = weekData[curWeek].songs;
			PlayState.isStoryMode = true;
			selectedWeek = true;

			var diffic = "";

			switch (curDifficulty)
			{
				case 0:
					diffic = '-easy';
				case 2:
					diffic = '-hard';
			}

			PlayState.storyDifficulty = weekData[curWeek].difficulties[curDifficulty].name;

			PlayState._SONG = Song.loadModFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.songMod, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty >= weekData[curWeek].difficulties.length)
			curDifficulty = 0;

		var sprDifficulty = difficultySprites[weekData[curWeek].difficulties[curDifficulty].sprite];
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
		intendedScore = Highscore.getModWeekScore(weekData[curWeek].mod, weekData[curWeek].name, weekData[curWeek].difficulties[curDifficulty].name);

		#if !switch
		intendedScore = Highscore.getModWeekScore(weekData[curWeek].mod, weekData[curWeek].name, weekData[curWeek].difficulties[curDifficulty].name);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		var diffName = weekData[curWeek].difficulties[curDifficulty].name;
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		var diffIndex = 0;
		for(i in 0...weekData[curWeek].difficulties.length) {
			if (weekData[curWeek].difficulties[i].name == diffName) {
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

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		for(char in modWeekCharacters) {
			char.visible = false;
		}
		modWeekCharacters[curWeek].visible = true;
		
		if (colorTween != null) colorTween.cancel();
		var co = 0xFFF9CF51;
		if (weekData[curWeek].color != null) {
			var c = FlxColor.fromString(weekData[curWeek].color);
			if (c != null) co = c;
		}
		colorTween = FlxTween.color(yellowBG, 0.25, yellowBG.color, co, {ease : FlxEase.smoothStepInOut});
		// grpWeekCharacters.members[0].animation.play(weekCharacters[curWeek][0]);
		// grpWeekCharacters.members[1].animation.play(weekCharacters[curWeek][1]);
		// grpWeekCharacters.members[2].animation.play(weekCharacters[curWeek][2]);
		txtTracklist.text = "Tracks\n";
		// modWeekCharacters
		

		var stringThing:Array<String> = weekData[curWeek].songs;

		for (i in stringThing)
		{
			txtTracklist.text += "\n" + i;
		}

		txtTracklist.text += "\n";
		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		#if !switch
		intendedScore = Highscore.getModWeekScore(weekData[curWeek].mod, weekData[curWeek].name, weekData[curWeek].difficulties[curDifficulty].name);
		// intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
