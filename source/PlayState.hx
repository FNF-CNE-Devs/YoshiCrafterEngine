package;

import Highscore.SaveDataRating;
import Highscore.AdvancedSaveData;
using FlxSpriteCenterFix;

import flixel.system.scaleModes.RatioScaleMode;
import flixel.system.debug.interaction.Interaction;
import StoryMenuState.FNFWeek;
import StoryMenuState.WeeksJson;
import flixel.input.keyboard.FlxKey;
import Note.NoteDirection;
import flixel.system.macros.FlxMacroUtil;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.display.BitmapData;
import openfl.filters.ShaderFilter;
import LoadSettings.Settings;

using StringTools;

class Rating {
	
	public var name:String = "Sick";
	public var image(default, set):String = "Friday Night Funkin':ratings/sick";
	public var accuracy:Float = 1;
	public var health:Float = 0.1;
	public var maxDiff:Float = 35;
	public var score:Int = 350;
	public var color:FlxColor = 0xFF24DEFF;
	public var miss:Bool = false;
	public var scale:Float = 1;
	public var antialiasing:Bool = true;

	public var bitmap:BitmapData = null;

	public function new() {}

	private function set_image(path:String):String {
		var splittedPath = path.split(":");
		if (splittedPath.length < 2) return path;
		var mod = splittedPath[0];
		var path = splittedPath[1];
		var mPath = Paths.getModsFolder();
		var bData = Paths.getBitmapOutsideAssets('$mPath/$mod/images/$path.png');
		if (bData != null) {
			if (bitmap != null) bitmap.dispose();
			image = path;
			bitmap = bData;
		}
		return path;
	}
}
class PlayState extends MusicBeatState
{
	public var vars:Map<String, Dynamic> = [];
	public var ratings:Array<Rating> = [];

	public var hits:Map<String, Int> = [];

	static public var curStage:String = '';
	static public var SONG:SwagSong;
	static public var _SONG:SwagSong; // DO NOT TOUCH !!!
	public var song(get, set):SwagSong;
	public function set_song(s:SwagSong):SwagSong {
		PlayState.SONG = s;
		return s;
	}
	public function get_song():SwagSong {
		return PlayState.SONG;
	}
	static public var isStoryMode:Bool = false;
	static public var storyWeek:Int = 0;
	static public var storyPlaylist:Array<String> = [];
	static public var storyDifficulty:String = "Normal";
	public static var actualModWeek:FNFWeek;
	public static var log:Array<String> = [];
	
	public var halloweenLevel:Bool = false;
	public var validScore:Bool = true;
	
	public var vocals:FlxSound;

	public var songPercentPos(get, null):Float;

	public function get_songPercentPos():Float {
		if (FlxG.sound.music != null) {
			return Conductor.songPosition / FlxG.sound.music.length;
		} else {
			return 0;
		}
	}
	
	public var dads:Array<Character> = [];
	public var boyfriends:Array<Boyfriend> = [];
	public var currentDad:Int = 0;
	public var currentBoyfriend:Int = 0;

	public var gf:Character;
	@:isVar public var dad(get, set):Character;
	@:isVar public var boyfriend(get, set):Boyfriend;

	function get_boyfriend():Boyfriend 	{return boyfriends[0];}
	function get_dad():Character 		{return dads[0];}

	function set_boyfriend(bf):Boyfriend {
		boyfriends.push(bf);
		return bf;
	}

	function set_dad(dad):Character {
		dads.push(dad);
		return dad;
	}
	
	public function updateHealthBarColors() {
		var dadColor = 0xFFFF0000;
		var bfColor = 0xFF66FF33;
		try {
			var c:Null<Int> = dad.getColors()[0];
			if (c != 0 && c != null) dadColor == c;
		} catch(e) {

		}
		try {
			var c:Null<Int> = boyfriend.getColors()[0];
			if (c != 0 && c != null) bfColor == c;
		} catch(e) {
			
		}
		healthBar.createFilledBar(dadColor, bfColor);
	}
	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public static var current:PlayState = null;
	public static var songMod:String = "Friday Night Funkin'";
	
	public var strumLine:FlxSprite;
	public var curSection:Int = 0;
	
	public var camFollow:FlxObject;
	
	static public var prevCamFollow:FlxObject;
	
	public var strumLineNotes:FlxTypedGroup<FlxSprite>;
	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var cpuStrums:FlxTypedGroup<FlxSprite>;
	
	public var camZooming:Bool = false;
	public var curSong:String = "";
	
	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;
	
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	
	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;
	
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	
	public var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	
	public var talking:Bool = true;
	public var songScore:Int = 0;
	public var scoreTxt:FlxText;
	public var scoreTxtTween:FlxTween;
	
	static public var campaignScore:Int = 0;
	
	public var defaultCamZoom:Float = 1.05;
	
	// how big to stretch the pixel art assets
	static public var daPixelZoom:Float = 6;
	
	public var inCutscene:Bool = false;
	
	#if desktop
	// Discord RPC public variables
	public var storyDifficultyText:String = "";
	public var iconRPC:String = "";
	public var songLength:Float = 0;
	public var detailsText:String = "";
	public var detailsPausedText:String = "";
	#end
	
	
	public var paused:Bool = false;
	public var startedCountdown:Bool = false;
	public var canPause:Bool = true;
	
	//Score and shit
	public var accuracy:Float = 0;
	public var numberOfNotes:Float = 0;
	public var numberOfArrowNotes:Float = 0;
	public var misses:Int = 0;
	public var accuracy_(get, null):Float;
	function get_accuracy_():Float {
		return accuracy / numberOfNotes;
	}

	public var isWidescreen(get, set):Bool;
	public function get_isWidescreen():Bool {
		return Std.is(FlxG.scaleMode, WideScreenScale);
	}
	public function set_isWidescreen(enable:Bool):Bool {
		if (enable) {
			FlxG.scaleMode = new WideScreenScale();
			camHUD.x = (FlxG.width / 2) - 640;
		} else {
			FlxG.scaleMode = new RatioScaleMode();
			FlxG.camera.width = 1280;
			FlxG.camera.height = 720;
			FlxG.camera.follow(camFollow, LOCKON, 0.02);
			camHUD.x = 0;
		}
		return enable;
	}

	public function showKeys() {
		for(i in 0...SONG.keyNumber) {
			var m = playerStrums.members[i];
			var t = new FlxText(0, m.y + m.height + 10);
			t.setFormat(Paths.font("vcr.ttf"), Std.int(16), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			t.cameras = [camHUD];
			t.antialiasing = true;
			if (!engineSettings.botplay) {
				var field = cast(Reflect.field(engineSettings, 'control_' + SONG.keyNumber + '_$i'), FlxKey);
				// if (field != null) {
					t.text = ControlsSettingsSubState.ControlsSettingsSub.getKeyName(field);
				// }
			}
			t.x = playerStrums.members[i].x + (playerStrums.members[i].width / 2) - (t.width / 2);

			if (engineSettings.downscroll) {
				t.y = playerStrums.members[i].y - 10 - t.height;
			}
			add(t);
			FlxTween.tween(t, {alpha : 1}, 0.25, {onComplete : function(ti) {
				new FlxTimer().start(5, function(ti) {
					FlxTween.tween(t, {alpha : 0}, 0.25, {
						onComplete : function(ti) {
							remove(t);
							t.destroy();
						}
					});
				});
			}});
		}
	}
	public var delayTotal:Float = 0;

	public var hitCounter:FlxText;

	public var msScoreLabel:FlxText;
	public var msScoreLabelTween:FlxTween;

	public var songAltName:String;
	
	public var startTimer:FlxTimer;
	public var perfectMode:Bool = false;
	
	public var previousFrameTime:Int = 0;
	public var lastReportedPlayheadPosition:Int = 0;
	public var songTime:Float = 0;
	
	public var debugNum:Int = 0;
	
	public var endingSong:Bool = false;

	public var engineSettings:Dynamic;
	
	public var startedMoving:Bool = false;

	public var guiOffset(get, null):FlxPoint;
	public function get_guiOffset():FlxPoint {
		return new FlxPoint((1280 - (1280 / engineSettings.noteScale)), (720 - (720 / engineSettings.noteScale)));
	}

	public function setDownscroll(downscroll:Bool, autoPos:Bool) {
		var p:Bool = autoPos;
		engineSettings.downscroll = downscroll;
		if (p) {
			
			var oldStrumLinePos = strumLine.y;
			strumLine.y = (engineSettings.downscroll ? FlxG.height - 150 : 50) * (1 / engineSettings.noteScale) + (guiOffset.y / 2);
			for (strum in playerStrums.members) {
				strum.y = strum.y - oldStrumLinePos + strumLine.y;
			}
			for (strum in cpuStrums.members) {
				strum.y = strum.y - oldStrumLinePos + strumLine.y;
			}
		}
	}

	public static var modchart:hscript.Interp;
	public static var stage:hscript.Interp;
	public static var cutscene:hscript.Interp;

	public var noteScripts:Array<hscript.Interp> = [];

	public var stage_persistent_vars:Map<String, Dynamic> = [];
	
	// public var songEvents:SongEventsManager.SongEventsManager;
	public static var bfList:Array<String> = ["bf", "bf-car", "bf-christmas", "bf-pixel", "bf-pixel-dead"];

	public var numberOfExceptionsShown:Int = 0;
	public static function showException(ex:String) {
		if (PlayState.current != null) {
			var warningSign = new FlxSprite(0, FlxG.height - (25 + (90 * PlayState.current.numberOfExceptionsShown))).loadGraphic(Paths.image("warning", "preload"));
			warningSign.antialiasing = true;
			warningSign.x = -warningSign.width;
			warningSign.cameras = [PlayState.current.camHUD];
			warningSign.y -= warningSign.height;

			var text = new FlxText(-warningSign.width + 58, warningSign.y + 10);
			text.text = ex;
			text.antialiasing = true;
			// text.y -= warningSign.height;
			text.setFormat(Paths.font("vcr.ttf"), Std.int(16), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			text.fieldWidth = text.width - 58 - 15;
			text.cameras = [PlayState.current.camHUD];

			// Offset : 58
			PlayState.current.add(warningSign);
			PlayState.current.add(text);
			FlxTween.tween(warningSign, {x : 25}, 0.1, {ease : FlxEase.smoothStepInOut, onComplete: function(t) {
				FlxTween.tween(warningSign, {x : -warningSign.width}, 0.1, {ease : FlxEase.smoothStepInOut, startDelay: 5});
				FlxTween.tween(text, {x : -warningSign.width + 58}, 0.1, {ease : FlxEase.smoothStepInOut, startDelay: 5, onComplete: function(t) {
					PlayState.current.remove(warningSign);
					PlayState.current.remove(text);
					warningSign.destroy();
					text.destroy();
				}});
			}});

			FlxTween.tween(text, {x : 25 + 58}, 0.1, {ease : FlxEase.smoothStepInOut});
			PlayState.current.numberOfExceptionsShown++;
		}
		trace(ex);
	}
	override public function create()
	{
		PlayState.current = this;
		engineSettings = Reflect.copy(Settings.engineSettings.data);
		
		FlxG.scaleMode = new WideScreenScale();
		// Assets.loadLibrary("songs");
		#if sys
		if (engineSettings.emptySkinCache) {
			Paths.clearCache();
		}
		#end

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		WideScreenScale.updatePlayStateHUD();
		if (engineSettings.greenScreenMode) {
			camHUD.bgColor = new FlxColor(0xFF00FF00);
		} else {
			camHUD.bgColor.alpha = 0;
		}

		camHUD.zoom = engineSettings.noteScale;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (_SONG.keyNumber == null)
			_SONG.keyNumber = 4;
		
		if (_SONG.noteTypes == null)
			_SONG.noteTypes = ["Friday Night Funkin':Default Note"];

		if (_SONG == null)
			_SONG = Song.loadModFromJson('tutorial', 'Friday Night Funkin\'');

		SONG = Reflect.copy(_SONG);

		
			
		if (engineSettings.botplay || !SONG.validScore)
			validScore = false;
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		// switch (SONG.song.toLowerCase())
		// {
		// 	case 'tutorial':
		// 		dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
		// 	case 'bopeebo':
		// 		dialogue = [
		// 			'HEY!',
		// 			"You think you can just sing\nwith my daughter like that?",
		// 			"If you want to date her...",
		// 			"You're going to have to go \nthrough ME first!"
		// 		];
		// 	case 'fresh':
		// 		dialogue = ["Not too shabby boy.", ""];
		// 	case 'dadbattle':
		// 		dialogue = [
		// 			"gah you think you're hot stuff?",
		// 			"If you can beat me here...",
		// 			"Only then I will even CONSIDER letting you\ndate my daughter!"
		// 		];
		// 	case 'senpai':
		// 		dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
		// 	case 'roses':
		// 		dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
		// 	case 'thorns':
		// 		dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		// }

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = storyDifficulty;
		// switch (storyDifficulty)
		// {
		// 	case 0:
		// 		storyDifficultyText = "Easy";
		// 	case 1:
		// 		storyDifficultyText = "Normal";
		// 	case 2:
		// 		storyDifficultyText = "Hard";
		// }

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC);
		#end

		ModSupport.currentMod = songMod;
		ModSupport.parseSongConfig();

        stage = new hscript.Interp();
		modchart = new hscript.Interp();
		cutscene = new hscript.Interp();
		for(script in [stage, modchart]) {
			script.variables.set("update", function(elapsed:Float) {});
			script.variables.set("create", function() {});
			script.variables.set("musicstart", function() {});
			script.variables.set("beatHit", function(curBeat:Int) {});
			script.variables.set("stepHit", function(curStep:Int) {});
			script.variables.set("setSharedVars", function() {return [];});
			script.variables.set("getVar", function(v) {return null;});
			script.variables.set("botplay", engineSettings.botplay);
		}
		stage.variables.set("gfVersion", "gf");
		modchart.variables.set("getStageVar", function(v:String) {
			return ModSupport.executeFunc(stage, "getVar", [v]);
		});
		modchart.variables.set("ratings", [
			{
				name : "Sick",
				image : "Friday Night Funkin':ratings/sick",
				accuracy : 1,
				health : 0.10,
				maxDiff : 50,
				score : 350,
				color : "#24DEFF"                                                                                                                                                                        
			},
			{
				name : "Good",
				image : "Friday Night Funkin':ratings/good",
				accuracy : 2 / 3,
				health : 0.06,
				maxDiff : 100,
				score : 200,
				color : "#3FD200"
			},
			{
				name : "Bad",
				image : "Friday Night Funkin':ratings/bad",
				accuracy : 1 / 3,
				health : 0.0,
				maxDiff : 150,
				score : 50,
				color : "#D70000"
			},
			{
				name : "Shit",
				image : "Friday Night Funkin':ratings/shit",
				accuracy : 1 / 6,
				health : 0.0,
				maxDiff : 1000,
				score : -150,
				color : "#804913",
				miss : true
			}
		]);
		stage.variables.set("getModchartVar", function(v:String) {
			return ModSupport.executeFunc(modchart, "getVar", [v]);
		});
		modchart.variables.set("getCameraZoom", function(curBeat) {
			if (curBeat % 4 == 0) {
				return {
					hud : 0.03,
					game : 0.015
				};
			} else {
				return {
					hud : 0,
					game : 0
				};
			}
		});

		ModSupport.setHaxeFileDefaultVars(stage, songMod, {});
		ModSupport.setHaxeFileDefaultVars(modchart, songMod, {});
		ModSupport.setHaxeFileDefaultVars(cutscene, songMod, {});

		var endCutsceneFunc = function() {

		};

		cutscene.variables.set("update", function(elapsed) {

		});
		cutscene.variables.set("onSongEnd", function() {

		});
		cutscene.variables.set("create", function() {
			startCountdown(); //Only execute when cutscene ended
		});
		cutscene.variables.set("startCountdown", startCountdown);
		try {
			var ex = ModSupport.getExpressionFromPath(ModSupport.song_stage_path + ".hx");
			// trace(ex);
			stage.execute(ex);
		} catch(e) {
			trace("Stage : " + e);
		}
		try {
			if (ModSupport.song_modchart_path != "") {
				modchart.execute(ModSupport.getExpressionFromPath(ModSupport.song_modchart_path));
			}
		} catch(e) {
			trace("Modchart : " + e);
		}
		try {
			if (ModSupport.song_cutscene_path != "") {
				cutscene.execute(ModSupport.getExpressionFromPath(ModSupport.song_cutscene_path));
			}
		} catch(e) {
			trace("Cutscene : " + e);
		}


		var resultRatings:Array<Dynamic> = modchart.variables.get("ratings");
		for(rating in resultRatings) {
			var r:Rating = new Rating();
			if (rating.accuracy != null) r.accuracy = rating.accuracy;
			if (rating.antialiasing != null) r.antialiasing = rating.antialiasing;
			if (rating.color != null) {
				var c = FlxColor.fromString(rating.color);
				if (c != null) r.color = c;
			}
			if (rating.health != null) r.health = rating.health;
			if (rating.image != null) r.image = rating.image;
			if (rating.maxDiff != null) r.maxDiff = rating.maxDiff;
			if (rating.miss != null) r.miss = rating.miss;
			if (rating.name != null) r.name = rating.name;
			if (rating.scale != null) r.scale = rating.scale;
			if (rating.score != null) r.score = rating.score;

			if (rating.bitmap == null) {
				rating.bitmap = new BitmapData(1, 1, true, 0x00000000);
			}

			ratings.push(r);
			hits[r.name] = 0;
		}
		hits["Misses"] = 0;

		// var sVars:Array<String> = ModSupport.executeFunc(stage, "setSharedVars");
		// var mVars:Array<String> = ModSupport.executeFunc(modchart, "setSharedVars");
		// var mVars:Array<String> = ModSupport.executeFunc(cutscene, "setSharedVars");
		// for(s in sVars) {
		// 	stage.variables.set(s, null);
		// }
		// for(s in mVars) {
		// 	modchart.variables.set(s, null);
		// }

		
		ModSupport.executeFunc(stage, "create");


		// trace('== BEGINNING OF STAGE VARIABLES ==');
		// for(k=>v in stage.variables) trace('$k = $v');
		// trace('== END OF STAGE VARIABLES ==');

		// songEvents = new SongEventsManager.SongEventsManager();

		var gfVersion:String = stage.variables.get("gfVersion");
		// songEvents.create();

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		
		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			// case "spooky":
			// 	dad.y += 200;
			// case "monster":
			// 	dad.y += 100;
			// case 'monster-christmas':
			// 	dad.y += 130;
			// case 'dad':
			// 	camPos.x += 400;
			// case 'pico':
			// 	camPos.x += 600;
			// 	dad.y += 300;
			// case 'parents-christmas':
			// 	dad.x -= 500;
			case 'senpai':
			// 	dad.x += 150;
			// 	dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
			// 	dad.x += 150;
			// 	dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
			// 	dad.x -= 150;
			// 	dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
		}

		boyfriend = new Boyfriend(770, 100, SONG.player1);

		// boyfriend.x += boyfriend.charGlobalOffset.x;
		// boyfriend.y += boyfriend.charGlobalOffset.y;
		// dad.x += dad.charGlobalOffset.x;
		// dad.y += dad.charGlobalOffset.y;
		// gf.x += gf.charGlobalOffset.x;
		// gf.y += gf.charGlobalOffset.y;

		// REPOSITIONING PER STAGE
		// switch (curStage)
		// {
		// 	case 'limo':
		// 		boyfriend.y -= 220;
		// 		boyfriend.x += 260;

		// 	case 'mall':
		// 		boyfriend.x += 200;

		// 	case 'mallEvil':
		// 		boyfriend.x += 320;
		// 		dad.y -= 80;
		// 	case 'school':
		// 		gf.x += 180;
		// 		gf.y += 300;
		// 	case 'schoolEvil':
		// 		var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
		// 		add(evilTrail);
		// 		gf.x += 180;
		// 		gf.y += 300;
		// }
		// boyfriend.x += songEvents.stage.bfOffset.x;
		// boyfriend.y += songEvents.stage.bfOffset.y;
		// dad.x += songEvents.stage.dadOffset.x;
		// dad.y += songEvents.stage.dadOffset.y;
		// gf.x += songEvents.stage.gfOffset.x;
		// gf.y += songEvents.stage.gfOffset.y;
		ModSupport.executeFunc(stage, "createAfterChars");
		add(gf);

		ModSupport.executeFunc(stage, "createAfterGf");

		add(dad);
		add(boyfriend);
		
		ModSupport.executeFunc(stage, "createInFront");
		if (modchart != null) ModSupport.executeFunc(modchart, "create");
		// songEvents.createInFront();

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, (engineSettings.downscroll ? FlxG.height - 150 : 50) * (1 / engineSettings.noteScale) + (guiOffset.y / 2)).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (engineSettings.showRatingTotal) {
			hitCounter = new FlxText(-(guiOffset.x / 2) + 20,720 + (guiOffset.y / 2) - ((ratings.length + 1) * 16), 1280, "Misses : 0", 12);
			hitCounter.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			hitCounter.antialiasing = true;
			hitCounter.cameras = [camHUD];
			add(hitCounter);
		}

		healthBarBG = new FlxSprite(0, FlxG.height * (engineSettings.downscroll ? 0.075 : 0.9) * (1 / engineSettings.noteScale) + (guiOffset.y / 2)).loadGraphic(Paths.image('healthBar'));
		healthBarBG.cameras = [camHUD];
		healthBarBG.cameraCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.cameras = [camHUD];
		// healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		updateHealthBarColors();
		// healthBar
		add(healthBar);

		// scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt = new FlxText(0, healthBarBG.y + 30, 1280 * engineSettings.textQualityLevel, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), Std.int(16 * engineSettings.textQualityLevel), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scale.x = 1 / engineSettings.textQualityLevel;
		scoreTxt.scale.y = 1 / engineSettings.textQualityLevel;
		scoreTxt.antialiasing = true;
		scoreTxt.cameras = [camHUD];
		scoreTxt.cameraCenter(X);
		scoreTxt.scrollFactor.set();

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		
		add(iconP1);
		add(iconP2);
		add(scoreTxt);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			// switch (curSong.toLowerCase())
			// {
			// 	case "winter-horrorland":
			// 		var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
			// 		add(blackScreen);
			// 		blackScreen.scrollFactor.set();
			// 		camHUD.visible = false;

			// 		new FlxTimer().start(0.1, function(tmr:FlxTimer)
			// 		{
			// 			remove(blackScreen);
			// 			FlxG.sound.play(Paths.sound('Lights_Turn_On'));
			// 			camFollow.y = -2050;
			// 			camFollow.x += 200;
			// 			FlxG.camera.focusOn(camFollow.getPosition());
			// 			FlxG.camera.zoom = 1.5;

			// 			new FlxTimer().start(0.8, function(tmr:FlxTimer)
			// 			{
			// 				camHUD.visible = true;
			// 				remove(blackScreen);
			// 				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
			// 					ease: FlxEase.quadInOut,
			// 					onComplete: function(twn:FlxTween)
			// 					{
			// 						startCountdown();
			// 					}
			// 				});
			// 			});
			// 		});
			// 	case 'senpai':
			// 		schoolIntro(doof);
			// 	case 'roses':
			// 		FlxG.sound.play(Paths.sound('ANGRY'));
			// 		schoolIntro(doof);
			// 	case 'thorns':
			// 		schoolIntro(doof);
			// 	default:
			// 		startCountdown();
			// }
			if (cutscene != null) {
				inCutscene = true;
				ModSupport.executeFunc(cutscene, "create");
			} else {
				startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		songAltName = SONG.song;
		// switch(SONG.song.toLowerCase()) {
		// 	case "why-do-you-hate-me":
		// 		songAltName = "No nene i'm not playing a camellia song";
		// }

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				remove(black);
			}
		});
	}

	public function popUpGUIelements() {
		for (elem in [healthBar, iconP1, iconP2, scoreTxt, msScoreLabel, healthBarBG]) {
			var oldElemY = elem.y;
			var oldAlpha = elem.alpha;
			elem.alpha = 0;
			if (elem.y < FlxG.height / 2) {
				elem.y = -elem.height;
				FlxTween.tween(elem, {y : oldElemY, alpha : oldAlpha}, 0.75, {ease : FlxEase.quartInOut});
			} else {
				elem.y = FlxG.height + elem.height;
				FlxTween.tween(elem, {y : oldElemY, alpha : oldAlpha}, 0.75, {ease : FlxEase.quartInOut});
			}
			elem.visible = true;
		}
	}
	public function startCountdown():Void
	{
		inCutscene = false;

		trace("SONG.keyNumber = " + Std.string(SONG.keyNumber));
		if (SONG.keyNumber == 0 || SONG.keyNumber == null) SONG.keyNumber = 4;
		
		generateStaticArrows(0);
		generateStaticArrows(1);

		msScoreLabel = new FlxText(playerStrums.members[0].x, playerStrums.members[0].y - 25, playerStrums.members[playerStrums.members.length - 1].width + playerStrums.members[playerStrums.members.length - 1].x - playerStrums.members[0].x, "0ms", 20);
		msScoreLabel.setFormat(Paths.font("vcr.ttf"), Std.int(30 * engineSettings.textQualityLevel), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		msScoreLabel.antialiasing = true;
		msScoreLabel.scale.x = 1 / engineSettings.textQualityLevel;
		msScoreLabel.scale.y = 1 / engineSettings.textQualityLevel;
		msScoreLabel.scrollFactor.set();
		msScoreLabel.cameras = [camHUD];
		msScoreLabel.alpha = 0;
		add(msScoreLabel);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			for (i => d in dads) {
				if (d != null) {
					// d.playAnim('idle');
					d.dance();
				} else {
					#if debug
						trace("Dad at index " + Std.string(i) + " is null.");
					#end
				}
			}
			gf.dance();
			for (i => bf in boyfriends) {
				if (bf != null) {
					// bf.playAnim('idle');
					bf.dance();
				} else {
					#if debug
						trace("Boyfriend at index " + Std.string(i) + " is null.");
					#end
				}
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
		// songEvents.start();
		popUpGUIelements();
	}

	public var timerBG:FlxSprite = null;
	public var timerBar:FlxBar = null;
	public var timerTotalLength:FlxText = null;

	function startSong():Void
	{
		startingSong = false;


		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.modInst(PlayState.SONG.song, songMod), 1, false);
			// FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);

		

		if (engineSettings.showTimer) {
			var apparitionPos = -25 - (guiOffset.y / 2);
			if (engineSettings.downscroll) {
				apparitionPos = 720 + (guiOffset.y / 2) + 25;
			}
			timerBG = new FlxSprite(0, apparitionPos).makeGraphic(300, 25, 0xFF222222);
			timerBG.alpha = 0;
			timerBG.cameras = [camHUD];
			timerBG.cameraCenter(X);
			timerBG.scrollFactor.set();
			add(timerBG);

			timerBar = new FlxBar(timerBG.x + 4, timerBG.y + 4, LEFT_TO_RIGHT, Std.int(timerBG.width - 8)*5, Std.int(timerBG.height - 8), Conductor, 'songPosition', 0, FlxG.sound.music.length);
			timerBar.scale.x = 0.2;
			timerBar.alpha = 0;
			timerBar.cameras = [camHUD];
			timerBar.cameraCenter(X);
			timerBar.antialiasing = true;
			// timerBar.barWidth = Std.int(FlxG.sound.music.length / 1000);
			timerBar.scrollFactor.set();
			timerBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
			add(timerBar);

			if (engineSettings.downscroll) {
				FlxTween.tween(timerBG, {y : 720 - 29 + (guiOffset.y / 2), alpha : 1}, 0.5, {ease : FlxEase.circInOut});
				FlxTween.tween(timerBar, {y : 720 - 25 + (guiOffset.y / 2), alpha : 1}, 0.5, {ease : FlxEase.circInOut});
			} else {
				FlxTween.tween(timerBG, {y : 25 + (guiOffset.y / 2), alpha : 1}, 0.5, {ease : FlxEase.circInOut});
				FlxTween.tween(timerBar, {y : 29 + (guiOffset.y / 2), alpha : 1}, 0.5, {ease : FlxEase.circInOut});
			}
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();
		ModSupport.executeFunc(stage, "musicstart");
		ModSupport.executeFunc(modchart, "musicstart");

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.modVoices(PlayState.SONG.song, songMod));
			// vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;
		// if (FlxG.save.data.customArrowSkin) Note.skinBitmap = ;
		// Paths.getSparrowAtlas_Custom("skins/notes/" + FlxG.save.data.customArrowSkin.toLowerCase())

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		
		if (PlayState.SONG.keyNumber == 0 || PlayState.SONG.keyNumber == null) PlayState.SONG.keyNumber = 4;
		for(t in PlayState.SONG.noteTypes) {
			var script = new hscript.Interp();
			script.variables.set("enableRating", true);
			var noteScriptName = "Default Note";
			var noteScriptMod = "Friday Night Funkin'";
			var splittedThingy = t.split(":");
			if (splittedThingy.length < 2) {
				noteScriptName = splittedThingy[0];
			} else {
				noteScriptName = splittedThingy[1];
				noteScriptMod = splittedThingy[0];
			}
			script.variables.set("generateStaticArrow", function(babyArrow:FlxSprite, i:Int) {
				babyArrow.frames = (engineSettings.customArrowSkin == "default") ? Paths.getSparrowAtlas(engineSettings.customArrowColors ? 'NOTE_assets_colored' : 'NOTE_assets') : Paths.getSparrowAtlas_Custom(Paths.getModsFolder() + "/notes/" + engineSettings.customArrowSkin.toLowerCase());
					
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
					
					var noteNumberScheme:Array<NoteDirection> = Note.noteNumberSchemes[PlayState.SONG.keyNumber];
					if (noteNumberScheme == null) noteNumberScheme = Note.noteNumberSchemes[4];
					switch (noteNumberScheme[i % noteNumberScheme.length])
					{
						case Left:
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case Down:
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case Up:
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case Right:
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			});
			script.variables.set("onDadHit", function(e) {
				// dad.playAnim("sing")
			});
			script.execute(ModSupport.getExpressionFromPath(Paths.getModsFolder() + '/$noteScriptMod/notes/$noteScriptName.hx', true));
			ModSupport.setHaxeFileDefaultVars(script, noteScriptMod, {});
			noteScripts.push(script);
		}

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1]);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] % (SONG.keyNumber * 2) >= SONG.keyNumber)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, gottaHitNote, section.altAnim);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				if (!engineSettings.downscroll) unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * (susNote + 0.5)), daNoteData, oldNote, true, gottaHitNote, section.altAnim);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += 1280 / 2; // general offset
					}
				}

				if (engineSettings.downscroll) unspawnNotes.push(swagNote);

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += 1280 / 2; // general offset
				}
				else {}

				
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...SONG.keyNumber)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			// switch (curStage)
			// {
			// 	case 'school' | 'schoolEvil':
					

			// 	default:
					
				
			// }
			ModSupport.executeFunc(noteScripts[0], "generateStaticArrow", [babyArrow, i]);
			babyArrow.x += Note.swagWidth * i;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			} else {
				cpuStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			if 		  (PlayState.SONG.keyNumber <= 4) {
				babyArrow.x += 50;
			} else if (PlayState.SONG.keyNumber == 5) {
				babyArrow.x += 30;
			} else if (PlayState.SONG.keyNumber >= 6) {
				babyArrow.x += 10;
			}
			babyArrow.x += ((1280 / 2) * player);
			
			babyArrow.scale.x *= Math.min(1, 5 / (PlayState.SONG.keyNumber == null ? 5 : PlayState.SONG.keyNumber));
			babyArrow.scale.y *= Math.min(1, 5 / (PlayState.SONG.keyNumber == null ? 5 : PlayState.SONG.keyNumber));

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (startTimer != null)
				if (!startTimer.finished)
					startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC);
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, songAltName + " (" + storyDifficultyText + ")", iconRPC);
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}
	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end
		if (engineSettings.customArrowColors) {
			// var noteColors:Array<FlxColor> = [
			// 	new FlxColor(engineSettings.arrowColor0),
			// 	new FlxColor(engineSettings.arrowColor1),
			// 	new FlxColor(engineSettings.arrowColor2),
			// 	new FlxColor(engineSettings.arrowColor3)
			// ];
			var noteColors:Array<FlxColor> = boyfriend.getColors();
			for (strum in playerStrums) {
				#if secret
					var c:FlxColor = new FlxColor(0xFFFF0000);
					c.hue = (Conductor.songPosition / 100) % 359;
					if (strum.animation.curAnim != null) strum.color = (strum.animation.curAnim.name == "static" ? new FlxColor(0xFFFFFFFF) : c);
				#else
					if (strum.animation.curAnim != null) strum.color = (strum.animation.curAnim.name == "static" ? new FlxColor(0xFFFFFFFF) : noteColors[(strum.ID % (noteColors.length - 1)) + 1]);
				#end
			}
		}
		
		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		

		super.update(elapsed);

		// scoreTxt.text = "Score:" + songScore + " | Misses:" + Std.string(misses) + " | Accuracy:" + (numberOfNotes == 0 ? "0%" : Std.string((Math.round(accuracy * 10000 / numberOfNotes) / 10000) * 100) + "%");
		scoreTxt.text = ScoreText.generate(this);

		if (hitCounter != null) {
			var hitsText = "";
			var hitIterator = hits.keys();
			while(true) {
				var it = hitIterator.next();
				if (it != "Misses") {
					var amount = Std.string(hits[it]);
					hitsText = '\r\n$it : $amount' + hitsText;
				}
				if (!hitIterator.hasNext()) break;
			}
			hitCounter.text = hitsText;
			hitCounter.y = 700 + (guiOffset.y / 2) - hitCounter.height;
		}

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, songAltName + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}
		if (FlxG.keys.justPressed.SEVEN)
		{
			if (FlxG.sound.music != null) FlxG.sound.music.pause();
			if (engineSettings.yoshiEngineCharter)
				// FlxG.switchState(new YoshiEngineCharter());
				FlxG.switchState(new ChartingState_New());
			else
				FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.offset.x = -75;
		iconP2.offset.x = -75;
		// iconP1.offset.y = -iconOffset;
		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset) + iconP1.offset.x;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset) + iconP2.offset.x;

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				// switch (dad.curCharacter)
				// {
				// 	case 'mom':
				// 		camFollow.y = dad.getMidpoint().y;
				// 	case 'senpai':
				// 		camFollow.y = dad.getMidpoint().y - 430;
				// 		camFollow.x = dad.getMidpoint().x - 100;
				// 	case 'senpai-angry':
				// 		camFollow.y = dad.getMidpoint().y - 430;
				// 		camFollow.x = dad.getMidpoint().x - 100;
				// }
				camFollow.setPosition(dad.getMidpoint().x + 150 + dad.camOffset.x, dad.getMidpoint().y - 100 + dad.camOffset.y);
				if (camFollow.x != dad.getMidpoint().x + 150) {
					if (dad.curCharacter == 'mom')
						vocals.volume = 1;
	
					if (SONG.song.toLowerCase() == 'tutorial')
					{
						tweenCamIn();
					}
				}

				
			}
			

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				// var camMovement:FlxPoint = new FlxPoint(0,0);

				// if (boyfriend.animation.curAnim != null) {
				// 	var n = boyfriend.animation.curAnim.name;
				// 	if (n.startsWith("singLEFT")) camMovement.x = -1;
				// 	if (n.startsWith("singRIGHT")) camMovement.x = 1;
				// 	if (n.startsWith("singUP")) camMovement.y = -1;
				// 	if (n.startsWith("singDOWN")) camMovement.y = 1;
				// }

				// var ang = Math.atan2(camMovement.x, camMovement.y);

				// camFollow.setPosition(boyfriend.getMidpoint().x - 100 + boyfriend.camOffset.x + (Math.sin(ang) * 20), boyfriend.getMidpoint().y - 100 + boyfriend.camOffset.y + (Math.cos(ang) * 20));
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + boyfriend.camOffset.x, boyfriend.getMidpoint().y - 100 + boyfriend.camOffset.y);

				if (camFollow.x != boyfriend.getMidpoint().x - 100) {
					if (SONG.song.toLowerCase() == 'tutorial')
					{
						FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
					}
				}
			}

			

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1 * engineSettings.noteScale, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("oh no he died");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, songAltName + " (" + storyDifficultyText + ")", iconRPC);
			#end
			return;
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (inCutscene) {
			ModSupport.executeFunc(cutscene, "update", [elapsed]);
		} else {
			ModSupport.executeFunc(stage, "update", [elapsed]);
			ModSupport.executeFunc(modchart, "update", [elapsed]);
		}

			if (generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote == null) return;
					// if (daNote.y > FlxG.height - guiOffset.y)
					// {
					// 	daNote.active = false;
					// 	daNote.visible = false;
					// }
					// else
					// {
					// 	daNote.visible = true;
					// 	daNote.active = true;
					// }
					if (daNote.tooLate && daNote.mustPress)
					{
						daNote.script.variables.set("note", daNote);
						ModSupport.executeFunc(daNote.script, "onMiss", [Note.noteNumberScheme[daNote.noteData % PlayState.SONG.keyNumber]]);
						// noteMiss((daNote.noteData % _SONG.keyNumber) % SONG.keyNumber);
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
						return;
					}

					var pos:FlxPoint = new FlxPoint(-(daNote.noteOffset.x + ((daNote.isSustainNote ? daNote.width / 2 : 0) * (engineSettings.downscroll ? 1 : -1))),(daNote.noteOffset.y));
					var strum = (daNote.mustPress ? playerStrums.members : cpuStrums.members)[daNote.noteData % _SONG.keyNumber];
					if (strum.angle == 0) {

						pos.y = (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(engineSettings.customScrollSpeed ? engineSettings.scrollSpeed : SONG.speed, 2)) + (daNote.noteOffset.y);
					} else {
						pos.x = Math.sin((strum.angle + 180) * Math.PI / 180) * ((Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(engineSettings.customScrollSpeed ? engineSettings.scrollSpeed : SONG.speed, 2)));
						pos.x += Math.sin((strum.angle + (engineSettings.downscroll ? 90 : 270)) * Math.PI / 180) * ((daNote.noteOffset.x));
						pos.y = Math.cos((strum.angle) * Math.PI / 180) * (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(engineSettings.customScrollSpeed ? engineSettings.scrollSpeed : SONG.speed, 2));
						pos.y += Math.cos((strum.angle + (engineSettings.downscroll ? 270 : 90)) * Math.PI / 180) * ((daNote.noteOffset.y));
					}

					if (engineSettings.downscroll) {
						// daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(engineSettings.customScrollSpeed ? engineSettings.scrollSpeed : SONG.speed, 2)));
						// Code above not modchart proof

						daNote.y = (strum.y + pos.y);
						if (strum.angle == 0)
							daNote.x = (strum.x - pos.x);
						else
							daNote.x = (strum.x + pos.x);

						if (daNote.isSustainNote) {
							daNote.x -= daNote.width;
							daNote.flipY = true;
						}
					} else {
						daNote.y = (strum.y - pos.y);
						daNote.x = (strum.x - pos.x);
					}
					daNote.angle = strum.angle;

					// i am so fucking sorry for this if condition

					if (engineSettings.downscroll) {
						if (daNote.isSustainNote
							// && (daNote.y + daNote.height - daNote.offset.y >= strumLine.y + Note.swagWidth / 2)
							&& (daNote.y + daNote.height - (daNote.offset.y * daNote.scale.y) >= (daNote.mustPress ? playerStrums.members : cpuStrums.members)[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber].y + Note.swagWidth / 2)
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var strum = (daNote.mustPress ? playerStrums.members : cpuStrums.members)[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber];
							var size = Math.abs(daNote.y - daNote.height);
							// var swagRect = new FlxRect(0, -(daNote.height / 2), daNote.frameWidth * 2, FlxMath.wrap(Std.int(FlxMath.remapToRange(size, (Note.swagWidth / 2) + strum.y - (daNote.height / 2), strum.y + (Note.swagWidth / 2), 0, 50)), 0, 50));
							var swagRect = new FlxRect(0, 0, daNote.width * 2, CoolUtil.wrapFloat(FlxMath.remapToRange(daNote.y, strumLine.y - (Note.swagWidth) - (daNote.height / 2), strumLine.y - (Note.swagWidth / 2), 50, 0), 0, 50));
							// swagRect.height -= swagRect.y;
							// swagRect.height = ((daNote.mustPress ? playerStrums.members : cpuStrums.members)[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber].y + (Note.swagWidth / 2) - daNote.y) / daNote.scale.y;

							// daNote.offset.y = daNote.height / 2;
							// newRect.height -= swagRect.y;

							if (swagRect.height < 1) {
							// if (swagRect.height < 0.5) {
								remove(daNote);
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							}
							
							// trace(swagRect);
							daNote.clipRect = swagRect;
						}
					} else {
						if (daNote.isSustainNote
							&& (daNote.y + daNote.offset.y <= (daNote.mustPress ? playerStrums.members : cpuStrums.members)[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber].y + Note.swagWidth / 2)
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, (daNote.mustPress ? playerStrums.members : cpuStrums.members)[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber].y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
							swagRect.y /= daNote.scale.y;
							swagRect.height -= swagRect.y;
		
							daNote.clipRect = swagRect;
						}
					}
					
					if (!daNote.mustPress && daNote.wasGoodHit)
					{
						if (SONG.song != 'Tutorial')
							camZooming = true;
	
						daNote.script.variables.set("note", daNote);
						try {
							var script = daNote.script;
							ModSupport.executeFunc(daNote.script, "onDadHit", [daNote.noteData % PlayState.SONG.keyNumber]);
						} catch(e) {
							trace(e);
						}
						
	
	
						dad.holdTimer = 0;
	
						if (SONG.needsVoices)
							vocals.volume = 1;
	
						remove(daNote);
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
						
						return;
					}

					// WIP interpolation shit? Need to fix the pause issue
					// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

					// if ((daNote.y - (guiOffset.y / 2) < -daNote.height && !engineSettings.downscroll) || ((FlxG.height - (guiOffset.y / 2)) - daNote.y < -daNote.height && engineSettings.downscroll))
					// {
					
						
					// daNote.active = false;
					// daNote.visible = false;

					// daNote.kill();
					// notes.remove(daNote, true);
					// daNote.destroy();
					// }
					if (daNote.isSustainNote) {
						if (daNote.strumTime + Conductor.stepCrochet < Conductor.songPosition && daNote.wasGoodHit) {
							daNote.active = false;
							daNote.visible = false;
		
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
							
						}
					} else {
						if ((daNote.tooLate && !daNote.wasGoodHit) && daNote.mustPress)
						{
							daNote.script.variables.set("note", daNote);
							ModSupport.executeFunc(daNote.script, "onMiss", [Note.noteNumberScheme[daNote.noteData % PlayState.SONG.keyNumber]]);
							// noteMiss((daNote.noteData % _SONG.keyNumber) % SONG.keyNumber);
		
							daNote.active = false;
							daNote.visible = false;
		
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
							
						} else if (daNote.wasGoodHit) {
							daNote.active = false;
							daNote.visible = false;
		
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					}
					
				});
			}

			if (!inCutscene)
				keyShit(elapsed);

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
		
		
	}

	function endSong():Void
	{
		if (FlxG.sound.music == null) return;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (validScore)
		{
			#if !switch
				Highscore.saveScore(songMod, SONG.song, songScore, storyDifficulty);

				var hits:Array<SaveDataRating> = [];
				for (rating in ratings) {
					hits.push({
						name : rating.name,
						accuracyVal : rating.accuracy,
						color : rating.color,
						amount : this.hits[rating.name]
					});
				}
				var data = {
					rating : ScoreText.getRating(accuracy / numberOfNotes),
					misses : misses,
					averageDelay: delayTotal / numberOfArrowNotes,
					accuracy : accuracy / numberOfNotes,
					hits: hits
				};
				#if debug
					trace(data);
				#end
				Highscore.saveAdvancedScore(songMod, SONG.song, songScore, data, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);


			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				FlxG.switchState(new StoryMenuState());

				// if ()
				// StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (validScore)
				{
					// NGio .unlockMedal(60961);
					Highscore.saveModWeekScore(actualModWeek.mod, actualModWeek.name, campaignScore, storyDifficulty);
					// Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				// FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty.toLowerCase() != "normal") {
					difficulty = "-" + storyDifficulty.toLowerCase().replace(" ", "-");
				}
				// if (storyDifficulty == 0)
				// 	difficulty = '-easy';

				// if (storyDifficulty == 2)
				// 	difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				// if (SONG.song.toLowerCase() == 'eggnog')
				// {
				// 	var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
				// 		-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				// 	blackShit.scrollFactor.set();
				// 	add(blackShit);
				// 	camHUD.visible = false;

				// 	FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				// }

				if (cutscene != null) ModSupport.executeFunc(cutscene, "onSongEnd");

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState._SONG = Song.loadModFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, songMod, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	private function popUpScore(strumtime:Float):Rating
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();

		var daRating:Rating = null;
		for(r in ratings) {
			if (r.maxDiff >= noteDiff) {
				daRating = r;
				#if debug
					// trace(r.name);
				#end
				break;
			}
		}

		if (daRating == null) return null;
		if (daRating.bitmap == null) return null;
		accuracy += 1 - (FlxMath.wrap(Std.int(noteDiff), 0, Std.int(Conductor.safeZoneOffset)) / Conductor.safeZoneOffset);
		delayTotal += noteDiff;
		
		numberOfArrowNotes++;

		if (engineSettings.showPressDelay) {
			msScoreLabel.text = Std.string(Math.floor(noteDiff)) + "ms";
			msScoreLabel.alpha = 1;
			if (msScoreLabelTween != null) {
				msScoreLabelTween.cancel();
				msScoreLabelTween.destroy();
			}
			msScoreLabel.color = daRating.color;
			msScoreLabel.scale.x = 1 / engineSettings.textQualityLevel;
			msScoreLabel.scale.y = 1 / engineSettings.textQualityLevel;
			msScoreLabelTween = FlxTween.tween(msScoreLabel, {alpha: 0, "scale.x" : 0.8 / engineSettings.textQualityLevel, "scale.y" : 0.8 / engineSettings.textQualityLevel}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					msScoreLabelTween = null;
				},
				startDelay: 0.75
			});
		}

		numberOfNotes++;
		songScore += daRating.score;

		rating.loadGraphic(daRating.bitmap.clone());
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		rating.antialiasing = daRating.antialiasing;

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('combo'));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		// if (!curStage.startsWith('school'))
		// {
		// 	rating.setGraphicSize(Std.int(rating.width * 0.7));
		// 	rating.antialiasing = true;
		// 	comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		// 	comboSpr.antialiasing = true;
		// }
		// else
		// {
		// 	rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
		// 	comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		// }
		rating.scale.x = rating.scale.y = daRating.scale * 0.7;

		comboSpr.updateHitbox();
		rating.updateHitbox();

		hits[daRating.name] += 1;

		var seperatedScore:Array<Int> = [];

		var stringCombo = Std.string(combo);
		for(i in 0...stringCombo.length) {
			seperatedScore.push(Std.parseInt(stringCombo.charAt(i)));
		}
		if (seperatedScore.length < 3) {
			for(i in seperatedScore.length...3) {
				seperatedScore.insert(0, 0);
			}
		}
		// seperatedScore.push(Math.floor(combo / 100));
		// seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		// seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		
		if (engineSettings.animateInfoBar) {
			if (scoreTxtTween != null) {
				scoreTxtTween.cancel();
				scoreTxtTween.destroy();
			}
			scoreTxt.scale.x = 1.15 / engineSettings.textQualityLevel;
			scoreTxt.scale.y = 1.15 / engineSettings.textQualityLevel;
			scoreTxtTween = FlxTween.tween(scoreTxt, {"scale.x" : 1 / engineSettings.textQualityLevel, "scale.y" : 1 / engineSettings.textQualityLevel}, 0.25, {ease : FlxEase.cubeOut, onComplete: function(tween:FlxTween) {
				scoreTxtTween = null;
				tween.destroy();
			}});
		}
		
		curSection += 1;

		return daRating;
	}
	// private function popUpScore(strumtime:Float):String
	// {
	// 	var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
	// 	// boyfriend.playAnim('hey');
	// 	vocals.volume = 1;

	// 	var placement:String = Std.string(combo);

	// 	var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
	// 	coolText.screenCenter();
	// 	coolText.x = FlxG.width * 0.55;
	// 	//

	// 	var rating:FlxSprite = new FlxSprite();
	// 	var score:Int = 350;

	// 	var daRating:String = "sick";
	// 	var good = true;
	// 	var ratingColor:FlxColor = new FlxColor(0xFFFFFFFF);
	// 	if (noteDiff < 35) {
	// 		daRating = 'sick';
	// 		ratingColor = new FlxColor(0xFF24DEFF);
	// 	} else if (noteDiff < 65) {
	// 		daRating = 'good';
	// 		score = 200;
	// 		ratingColor = new FlxColor(0xFF3FD200);
	// 	} else if (noteDiff < 100) {
	// 		daRating = 'bad';
	// 		score = 50;
	// 		ratingColor = new FlxColor(0xFFD70000);
	// 	} else {
	// 		daRating = 'shit';
	// 		score = -150;
	// 		ratingColor = new FlxColor(0xFF804913);
	// 		good = false;
	// 	}
	// 	var accuracyAdd:Float = 0;

	// 	switch(engineSettings.accuracyMode) {
	// 		case 0:
	// 			accuracyAdd = 1 - (FlxMath.wrap(Std.int(noteDiff), 0, Std.int(Conductor.safeZoneOffset)) / Conductor.safeZoneOffset);
	// 		case 1:
	// 			switch(daRating) {
	// 				case 'sick':
	// 					accuracyAdd = 1;
	// 				case 'good':
	// 					accuracyAdd = 2 / 3;
	// 				case 'bad':
	// 					accuracyAdd = 1 / 3;
	// 				default:
	// 					accuracyAdd = 0;
	// 			}
	// 	}
	// 	delayTotal += noteDiff;
		
	// 	numberOfArrowNotes++;

	// 	if (engineSettings.showPressDelay) {
	// 		msScoreLabel.text = Std.string(Math.floor(noteDiff)) + "ms";
	// 		msScoreLabel.alpha = 1;
	// 		if (msScoreLabelTween != null) {
	// 			msScoreLabelTween.cancel();
	// 			msScoreLabelTween.destroy();
	// 		}
	// 		msScoreLabel.color = ratingColor;
	// 		msScoreLabel.scale.x = 1 / engineSettings.textQualityLevel;
	// 		msScoreLabel.scale.y = 1 / engineSettings.textQualityLevel;
	// 		msScoreLabelTween = FlxTween.tween(msScoreLabel, {alpha: 0, "scale.x" : 0.8 / engineSettings.textQualityLevel, "scale.y" : 0.8 / engineSettings.textQualityLevel}, 0.2, {
	// 			onComplete: function(tween:FlxTween)
	// 			{
	// 				msScoreLabelTween = null;
	// 			},
	// 			startDelay: 0.75
	// 		});
	// 	}
	// 	// if (noteDiff > Conductor.safeZoneOffset * 0.9)
	// 	// {
	// 	// 	daRating = 'shit';
	// 	// 	score = 50;
	// 	// }
	// 	// else if (noteDiff > Conductor.safeZoneOffset * 0.75)
	// 	// {
	// 	// 	daRating = 'bad';
	// 	// 	score = 100;
	// 	// }
	// 	// else if (noteDiff > Conductor.safeZoneOffset * 0.2)
	// 	// {
	// 	// 	daRating = 'good';
	// 	// 	score = 200;
	// 	// }

	// 	accuracy += accuracyAdd;
	// 	numberOfNotes++;
	// 	songScore += score;

	// 	/* if (combo > 60)
	// 			daRating = 'sick';
	// 		else if (combo > 12)
	// 			daRating = 'good'
	// 		else if (combo > 4)
	// 			daRating = 'bad';
	// 	 */

	// 	var pixelShitPart1:String = "";
	// 	var pixelShitPart2:String = '';

	// 	if (curStage.startsWith('school'))
	// 	{
	// 		pixelShitPart1 = 'weeb/pixelUI/';
	// 		pixelShitPart2 = '-pixel';
	// 	}

	// 	rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
	// 	rating.screenCenter();
	// 	rating.x = coolText.x - 40;
	// 	rating.y -= 60;
	// 	rating.acceleration.y = 550;
	// 	rating.velocity.y -= FlxG.random.int(140, 175);
	// 	rating.velocity.x -= FlxG.random.int(0, 10);

	// 	var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
	// 	comboSpr.screenCenter();
	// 	comboSpr.x = coolText.x;
	// 	comboSpr.acceleration.y = 600;
	// 	comboSpr.velocity.y -= 150;

	// 	comboSpr.velocity.x += FlxG.random.int(1, 10);
	// 	add(rating);

	// 	if (!curStage.startsWith('school'))
	// 	{
	// 		rating.setGraphicSize(Std.int(rating.width * 0.7));
	// 		rating.antialiasing = true;
	// 		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
	// 		comboSpr.antialiasing = true;
	// 	}
	// 	else
	// 	{
	// 		rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
	// 		comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
	// 	}

	// 	comboSpr.updateHitbox();
	// 	rating.updateHitbox();

	// 	var seperatedScore:Array<Int> = [];

	// 	var stringCombo = Std.string(combo);
	// 	for(i in 0...stringCombo.length) {
	// 		seperatedScore.push(Std.parseInt(stringCombo.charAt(i)));
	// 	}
	// 	if (seperatedScore.length < 3) {
	// 		for(i in seperatedScore.length...3) {
	// 			seperatedScore.insert(0, 0);
	// 		}
	// 	}
	// 	// seperatedScore.push(Math.floor(combo / 100));
	// 	// seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
	// 	// seperatedScore.push(combo % 10);

	// 	var daLoop:Int = 0;
	// 	for (i in seperatedScore)
	// 	{
	// 		var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
	// 		numScore.screenCenter();
	// 		numScore.x = coolText.x + (43 * daLoop) - 90;
	// 		numScore.y += 80;

	// 		if (!curStage.startsWith('school'))
	// 		{
	// 			numScore.antialiasing = true;
	// 			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
	// 		}
	// 		else
	// 		{
	// 			numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
	// 		}
	// 		numScore.updateHitbox();

	// 		numScore.acceleration.y = FlxG.random.int(200, 300);
	// 		numScore.velocity.y -= FlxG.random.int(140, 160);
	// 		numScore.velocity.x = FlxG.random.float(-5, 5);

	// 		if (combo >= 10 || combo == 0)
	// 			add(numScore);

	// 		FlxTween.tween(numScore, {alpha: 0}, 0.2, {
	// 			onComplete: function(tween:FlxTween)
	// 			{
	// 				numScore.destroy();
	// 			},
	// 			startDelay: Conductor.crochet * 0.002
	// 		});

	// 		daLoop++;
	// 	}
	// 	/* 
	// 		trace(combo);
	// 		trace(seperatedScore);
	// 	 */

	// 	coolText.text = Std.string(seperatedScore);
	// 	// add(coolText);

	// 	FlxTween.tween(rating, {alpha: 0}, 0.2, {
	// 		startDelay: Conductor.crochet * 0.001
	// 	});

	// 	FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
	// 		onComplete: function(tween:FlxTween)
	// 		{
	// 			coolText.destroy();
	// 			comboSpr.destroy();

	// 			rating.destroy();
	// 		},
	// 		startDelay: Conductor.crochet * 0.001
	// 	});

		
	// 	if (engineSettings.animateInfoBar) {
	// 		if (scoreTxtTween != null) {
	// 			scoreTxtTween.cancel();
	// 			scoreTxtTween.destroy();
	// 		}
	// 		scoreTxt.scale.x = 1.15 / engineSettings.textQualityLevel;
	// 		scoreTxt.scale.y = 1.15 / engineSettings.textQualityLevel;
	// 		scoreTxtTween = FlxTween.tween(scoreTxt, {"scale.x" : 1 / engineSettings.textQualityLevel, "scale.y" : 1 / engineSettings.textQualityLevel}, 0.25, {ease : FlxEase.cubeOut, onComplete: function(tween:FlxTween) {
	// 			scoreTxtTween = null;
	// 			tween.destroy();
	// 		}});
	// 	}
		
	// 	curSection += 1;

	// 	return daRating;
	// }

	public var botplayNoteHitMoment:Array<Float> = [];
	public var botplayHitNotes:Array<Note> = [
		
	];

	private function keyShit(elapsed:Float):Void
	{
		if (botplayNoteHitMoment.length == 0) {
			for(i in 0...SONG.keyNumber) {
				botplayNoteHitMoment.push(0);
			}
		}
		// HOLDING
		// var up = controls.UP;
		// var right = controls.RIGHT;
		// var down = controls.DOWN;
		// var left = controls.LEFT;

		// var upP = controls.UP_P;
		// var rightP = controls.RIGHT_P;
		// var downP = controls.DOWN_P;
		// var leftP = controls.LEFT_P;

		// var upR = controls.UP_R;
		// var rightR = controls.RIGHT_R;
		// var downR = controls.DOWN_R;
		// var leftR = controls.LEFT_R;
		// var up = controls.UP;
		// var right = controls.RIGHT;
		// var down = controls.DOWN;
		// var left = controls.LEFT;

		// var upP = controls.UP_P;
		// var rightP = controls.RIGHT_P;
		// var downP = controls.DOWN_P;
		// var leftP = controls.LEFT_P;

		// var upR = controls.UP_R;
		// var rightR = controls.RIGHT_R;
		// var downR = controls.DOWN_R;
		// var leftR = controls.LEFT_R;

		// var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		
		// var pressedArray:Array<Bool> = [FlxG.keys.pressed.W, FlxG.keys.pressed.X, FlxG.keys.pressed.C, FlxG.keys.pressed.NUMPADONE, FlxG.keys.pressed.NUMPADTWO, FlxG.keys.pressed.NUMPADTHREE];
		// var justPressedArray:Array<Bool> = [FlxG.keys.justPressed.W, FlxG.keys.justPressed.X, FlxG.keys.justPressed.C, FlxG.keys.justPressed.NUMPADONE, FlxG.keys.justPressed.NUMPADTWO, FlxG.keys.justPressed.NUMPADTHREE];
		// var justReleasedArray:Array<Bool> = [FlxG.keys.justReleased.W, FlxG.keys.justReleased.X, FlxG.keys.justReleased.C, FlxG.keys.justReleased.NUMPADONE, FlxG.keys.justReleased.NUMPADTWO, FlxG.keys.justReleased.NUMPADTHREE];
		var kNum = Std.string(SONG.keyNumber);
		var pressedArray:Array<Bool> = [];
		var justPressedArray:Array<Bool> = [];
		var justReleasedArray:Array<Bool> = [];

		if (!engineSettings.botplay) {
			for(i in 0...SONG.keyNumber) {
				var key:FlxKey = cast(Reflect.field(engineSettings, 'control_' + kNum + '_$i'), FlxKey);
				pressedArray.push(FlxG.keys.anyPressed([key])); // Should prob fix this
				justPressedArray.push(FlxG.keys.anyJustPressed([key])); // Should prob fix this
				justReleasedArray.push(FlxG.keys.anyJustReleased([key])); // Should prob fix this
			}
		} else {
			// BOTPLAY CODE
			justPressedArray = [for (i in 0...SONG.keyNumber) false];
			notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.hitOnBotplay)
					{
						if (daNote.strumTime < Conductor.songPosition) {
							botplayNoteHitMoment[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] = Math.max(Conductor.songPosition, botplayNoteHitMoment[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber]);
							// botplayHitNotes.push(daNote);
							justPressedArray[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] = true; // (Math.abs(daNote.strumTime - Conductor.songPosition) < elapsed * 1000) || 
						} else if (daNote.isSustainNote) {
							botplayNoteHitMoment[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] = Math.max(Conductor.songPosition, botplayNoteHitMoment[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber]);
							pressedArray[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] = true; // (Math.abs(daNote.strumTime - Conductor.songPosition) < elapsed * 1000) || 
						}
						
					}
				});
			for(i in 0...SONG.keyNumber) {
				justReleasedArray.push((botplayNoteHitMoment[i] + 150 < Conductor.songPosition) && !pressedArray[i] && !justPressedArray[i]);
			}
			// END OF BOTPLAY CODE
		}
		
		// FlxG.watch.addQuick('asdfa', upP);
		if ((justPressedArray.indexOf(true) != -1) && generatedMusic) // smart ass code lmao
		{
			boyfriend.holdTimer = 0;
			boyfriend.stunned = false;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			var notesToHit:Array<Note> = [];
			for (i in 0...SONG.keyNumber) notesToHit.push(null);
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote)
				{
					if (justPressedArray[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber]) {
						var can = false;
						if (notesToHit[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] != null) {
							if (notesToHit[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber].strumTime > daNote.strumTime)
								can = true;
							if (notesToHit[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber].strumTime == daNote.strumTime) {
								goodNoteHit(daNote);
							}
						} else {
							can = true;
						}
						if (can) notesToHit[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] = daNote;
					}
				}
			});
			for (note in notesToHit) {
				if (note != null) {
					goodNoteHit(note);
				}
			}
		}

		if ((pressedArray.indexOf(true) != -1) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					if (pressedArray[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber])
						goodNoteHit(daNote);
					// switch ((daNote.noteData % _SONG.keyNumber) % SONG.keyNumber)
					// {
					// 	// NOTES YOU ARE HOLDING
					// 	case 0:
					// 		if (left)
					// 			goodNoteHit(daNote);
					// 	case 1:
					// 		if (down)
					// 			goodNoteHit(daNote);
					// 	case 2:
					// 		if (up)
					// 			goodNoteHit(daNote);
					// 	case 3:
					// 		if (right)
					// 			goodNoteHit(daNote);
					// }
				}
			});
		}

		// notes.forEachAlive(function(daNote:Note) {
		// 	if (daNote.mustPress && daNote.tooLate && !daNote.wasGoodHit) {
		// 		noteMiss(daNote.noteData % 4);
		// 		daNote.kill();
		// 		notes.remove(daNote);
		// 		daNote.destroy();
		// 	}
		// });

		for (bf in boyfriends) {
				if (bf.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (pressedArray.indexOf(true) == -1 || bf != boyfriend))
				{
					if (bf.animation.curAnim.name.startsWith('sing') && !bf.animation.curAnim.name.endsWith('miss'))
					{
						// bf.playAnim('idle');
						bf.dance();
					}
				}
		}
		
		
		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (justPressedArray[spr.ID % SONG.keyNumber] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (justReleasedArray[spr.ID % SONG.keyNumber])
				spr.animation.play('static');
			// switch (spr.ID)
			// {
			// 	case 0:
			// 		if (leftP && spr.animation.curAnim.name != 'confirm')
			// 			spr.animation.play('pressed');
			// 		if (leftR)
			// 			spr.animation.play('static');
			// 	case 1:
			// 		if (downP && spr.animation.curAnim.name != 'confirm')
			// 			spr.animation.play('pressed');
			// 		if (downR)
			// 			spr.animation.play('static');
			// 	case 2:
			// 		if (upP && spr.animation.curAnim.name != 'confirm')
			// 			spr.animation.play('pressed');
			// 		if (upR)
			// 			spr.animation.play('static');
			// 	case 3:
			// 		if (rightP && spr.animation.curAnim.name != 'confirm')
			// 			spr.animation.play('pressed');
			// 		if (rightR)
			// 			spr.animation.play('static');
			// }

			if (spr != null) {
				if (spr.animation != null) {
					if (spr.animation.curAnim != null) {
						if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
						{
							spr.centerOffsets();
							// spr.offset.x -= 13;
							// spr.offset.y -= 13;
							spr.centerOrigin();
						}
						else {
							spr.centerOffsets();
							spr.centerOrigin();
						}
					}
				}
			}
			
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		vocals.volume = 0;
		if (!boyfriend.stunned)
		{
			// health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			hits["Misses"]++;
			misses++;
			numberOfNotes++;
			songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (Note.noteNumberScheme[direction % Note.noteNumberScheme.length])
			{
				case Left:
					boyfriend.playAnim('singLEFTmiss', true);
				case Down:
					boyfriend.playAnim('singDOWNmiss', true);
				case Up:
					boyfriend.playAnim('singUPmiss', true);
				case Right:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		// ok then -Y

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (note.enableRating) {
				var rating;
				if (!note.isSustainNote)
				{
					rating = popUpScore(note.strumTime);
					combo += 1;

					if (rating != null) {
						health += rating.health;
						if (rating.miss) 
							noteMiss((note.noteData % _SONG.keyNumber) % SONG.keyNumber);
					}
				}
			}

			// if (note.noteData >= 0)
			// 	health += 0.023;
			// else
			// 	health += 0.004;

			note.script.variables.set("note", note);
			ModSupport.executeFunc(note.script, "onPlayerHit", [note.noteData % PlayState.SONG.keyNumber]);

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs((note.noteData % _SONG.keyNumber) % SONG.keyNumber) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			if (note.isSustainNote && note.enableRating) {
				numberOfNotes += 0.25;
				accuracy += 0.25;
			}
		}
	}
	// function goodNoteHit(note:Note):Void
	// {
	// 	if (!note.wasGoodHit)
	// 	{
	// 		var rating = "";
	// 		if (!note.isSustainNote)
	// 		{
	// 			rating = popUpScore(note.strumTime);
	// 			combo += 1;
	// 		}
	// 		if (rating == "shit") {
	// 			health -= 0.09375;
	// 			noteMiss((note.noteData % _SONG.keyNumber) % SONG.keyNumber);
	// 			note.kill();
	// 			notes.remove(note, true);
	// 			note.destroy();
	// 			return;
	// 		}
	// 		switch(rating) {
	// 			case "bad" :
	// 			case "good" :
	// 				health += 0.06;
	// 			case "sick" :
	// 				health += 0.10;
	// 		}

	// 		// if (note.noteData >= 0)
	// 		// 	health += 0.023;
	// 		// else
	// 		// 	health += 0.004;

			
	// 		switch (Note.noteNumberScheme[note.noteData % Note.noteNumberScheme.length])
	// 		{
	// 			case Left:
	// 				boyfriend.playAnim('singLEFT', true);
	// 			case Down:
	// 				boyfriend.playAnim('singDOWN', true);
	// 			case Up:
	// 				boyfriend.playAnim('singUP', true);
	// 			case Right:
	// 				boyfriend.playAnim('singRIGHT', true);
	// 		}

	// 		playerStrums.forEach(function(spr:FlxSprite)
	// 		{
	// 			if (Math.abs(note.noteData) == spr.ID)
	// 			{
	// 				spr.animation.play('confirm', true);
	// 			}
	// 		});

	// 		note.wasGoodHit = true;
	// 		vocals.volume = 1;

	// 		if (!note.isSustainNote)
	// 		{
	// 			note.kill();
	// 			notes.remove(note, true);
	// 			note.destroy();
	// 		}
	// 		if (note.isSustainNote) {
	// 			numberOfNotes += 0.25;
	// 			accuracy += 0.25;
	// 		}
	// 	}
	// }

	override function stepHit()
	{
		ModSupport.executeFunc(stage, "stepHit", [curStep]);
		ModSupport.executeFunc(modchart, "stepHit", [curStep]);
		
		super.stepHit();
		// songEvents.stepHit(curStep);
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	override function beatHit()
	{
		super.beatHit();
		ModSupport.executeFunc(stage, "beatHit", [curBeat]);
		ModSupport.executeFunc(modchart, "beatHit", [curBeat]);
		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			
			for (i => d in dads) {
				d.dance();
			}
			// if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			// 	dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (camZooming)
		{
			var z = ModSupport.executeFunc(modchart, "getCameraZoom", [curBeat]);
			if (Reflect.hasField(z, "game"))
				FlxG.camera.zoom = Math.min(FlxG.camera.zoom + z.game, 1.35);
			if (Reflect.hasField(z, "hud"))
				camHUD.zoom = Math.min(camHUD.zoom + z.hud, 1.35);
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		for (bf in boyfriends) {
			if (bf == null) continue;
			if (!bf.animation.curAnim.name.startsWith("sing"))
			{
				// bf.playAnim('idle');
				bf.dance();
			}
		}

		// if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		// {
		// 	boyfriend.playAnim('hey', true);
		// }

		// if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		// {
		// 	boyfriend.playAnim('hey', true);
		// 	dad.playAnim('cheer', true);
		// }
	}
}
