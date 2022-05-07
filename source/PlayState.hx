package;


import haxe.ds.EnumValueMap;
import flixel.tweens.misc.VarTween;
import charter.YoshiCrafterCharter;
import charter.ChartingState_New;
import flixel.graphics.FlxGraphic;
import Script.ScriptPack;
import openfl.display.ShaderParameter;
import NoteShader.ColoredNoteShader;

import lime.utils.UInt8Array;
import lime.graphics.ImageBuffer;
import sys.io.File;
import openfl.display.Application;
import lime.graphics.Image;
import sys.FileSystem;
import Script.HScript;
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
import EngineSettings.Settings;

using StringTools;

// i'm going to throw all of you out of the window for this one
typedef PsychEvent = {
	var time:Float;
	var name:String;
	var value1:String;
	var value2:String;
}

typedef SongEvent = {
	var time:Float;
	var name:String;
	var parameters:Array<String>;
}


typedef SustainHit = {
	var time:Float;
	var healthVal:Float;
}
class PlayState extends MusicBeatState
{
	public var currentSustains:Array<SustainHit> = [];
	public var vars:Map<String, Dynamic> = [];
	public var ratings:Array<Rating> = [];

	public var splashes:Map<String, Array<Splash>> = [];

	public var hits:Map<String, Int> = [];

	static public var curStage:String = '';
	static public var SONG:SwagSong;
	@:dox(hide)
	static public var _SONG:SwagSong; // DO NOT TOUCH !!!
	public var song(get, set):SwagSong;
	private function set_song(s:SwagSong):SwagSong {
		PlayState.SONG = s;
		return s;
	}
	private function get_song():SwagSong {
		return PlayState.SONG;
	}
	static public var isStoryMode:Bool = false;
	static public var storyWeek:Int = 0;
	static public var storyPlaylist:Array<String> = [];
	static public var storyDifficulty:String = "Normal";
	static public var difficulty(get, set):String;
	static private function get_difficulty() {return storyDifficulty;}
	static private function set_difficulty(s:String) {return storyDifficulty = s;}
	public static var actualModWeek:FNFWeek;
	public static var log:Array<String> = [];
	public static var startTime:Float = 0;
	public static function trace(thing:String) {
		for (e in thing.split("\n")) log.push(e);
		trace(thing);
	}
	public static var fromCharter:Bool = false;

	public var _ = PlayState;
	
	public var halloweenLevel:Bool = false;
	public var validScore:Bool = true;
	
	public var vocals:FlxSound;
	public var inst:FlxSound;

	public var vocalsOffsetInfraction:Float = 0;

	public var section(get, null):SwagSection;
	private function get_section() {
		return PlayState.SONG.notes[Std.int(curStep / 16)];
	}

	public static var jsonSongName:String = "";

	public var songPercentPos(get, null):Float;

	private function get_songPercentPos():Float {
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
		// try {
		// 	var c:Null<Int> = dad.getColors()[0];
		// 	if (c != 0 && c != null) dadColor == c;
		// } catch(e) {

		// }
		// try {
		// 	var c:Null<Int> = boyfriend.getColors()[0];
		// 	if (c != 0 && c != null) bfColor == c;
		// } catch(e) {
			
		// }
		// healthBar.createFilledBar(dadColor, bfColor);
		try {
			dadColor = dad.getColors()[0];
		} catch(e) {}
		try {
			bfColor = boyfriend.getColors()[0];
		} catch(e) {}
		healthBar.createFilledBar(dadColor, bfColor);
	}
	public var notes:FlxTypedGroup<Note>;
	// nah i'm taking it further than a simple fix
	public var psychEvents:Array<PsychEvent> = [];
	public var events:Array<SongEvent> = [];
	public var unspawnNotes:Array<Note> = [];

	public static var current:PlayState = null;
	public static var songMod:String = "Friday Night Funkin'";
	
	public var strumLine:FlxSprite;
	public var curSection:Int = 0;
	
	public var camFollow:FlxObject;
	public var camFollowLerp:Float = 0.04;
	
	static public var prevCamFollow:FlxObject;
	
	public var strumLineNotes:FlxTypedGroup<FlxSprite>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var cpuStrums:FlxTypedGroup<StrumNote>;
	
	public var camZooming:Bool = true;
	public var autoCamZooming:Bool = true;
	public var curSong:String = "";

	public var devStage:String = null;
	
	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var maxHealth(default, set):Float = 2;
	public var tapMissHealth:Float = 0.125;
	private function set_maxHealth(health:Float):Float {
		maxHealth = health;
		if (health <= 0) {
			/*
				Hello and welcome to what is hopefully
				my final attempt at completing Friday
				Night Funkin' without taking any damage.
				I have a max HP of 1 so any damage from
				any source will immediatly kill me. I also
				want this to be a no hit run, so Boyfriend's
				ability to restore health is disabled. I have
				successfully completed every Friday Night Funkin'
				songs without taking any damage. I just yet have
				to do it in one go. My current personal best is
				1 shit rating and therefore 1 blueball.
			*/
			maxHealth = 0; // VERY SMALL.
			health = 0; // Take any damage and you DIE
			if (healthBar != null) {
				healthBar.visible = false;
				healthBar.setRange(-1, 1);
			}
		}

		if (healthBar != null) {
			@:privateAccess
			healthBar.setRange(0, maxHealth);
			healthBar.dirty = true;
		}
		
		return maxHealth;
	}
	public var combo:Int = 0;
	
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	
	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;
	public var popupArrows:Bool = isStoryMode;
	
	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;
	
	public var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	
	public var talking:Bool = true;
	public var songScore:Int = 0;
	public var scoreTxt:FlxText;
	public var scoreText(get, set):FlxText;
	private function get_scoreText() {return scoreTxt;}
	private function set_scoreText(t:FlxText) {return scoreTxt = t;}
	public var scoreTxtTween:FlxTween;
	public var watermark:FlxText;
	public var scoreWarning:FlxText;
	public var scoreWarningAlphaRot:Float = 0;
	
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
	private function get_isWidescreen():Bool {
		return Std.isOfType(FlxG.scaleMode, WideScreenScale);
	}
	private function set_isWidescreen(enable:Bool):Bool {
		if (enable == isWidescreen) return isWidescreen;
		if (enable) {
			FlxG.scaleMode = new WideScreenScale();
			camHUD.x = (FlxG.width / 2) - 640;
			WideScreenScale.updatePlayStateHUD();
		} else {
			FlxG.scaleMode = new RatioScaleMode();
			FlxG.camera.width = 1280;
			FlxG.camera.height = 720;
			FlxG.camera.follow(camFollow, LOCKON, camFollowLerp);
			camHUD.x = 0;
			camHUD.y = 0;
		}
		if (scripts != null) scripts.executeFunc("onWidescreen", [enable]);

		return enable;
	}

	public function showKeys() {
		var labels = [];
		for(i in 0...SONG.keyNumber) {
			var m = playerStrums.members[i];
			var t = new FlxText(0, m.y + m.height + 10);
			t.setFormat(Paths.font("vcr.ttf"), Std.int(16), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			t.cameras = [camHUD];
			t.antialiasing = true;
			if (!engineSettings.botplay) {
				var field = cast(Reflect.field(engineSettings, 'control_' + SONG.keyNumber + '_$i'), FlxKey);
				// if (field != null) {
					t.text = ControlsSettingsSubState.getKeyName(field);
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
			labels.push(t);
		}
		
		if (scripts != null) scripts.executeFunc("onShowKeys", [labels]);
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

	public var endCutscene:Bool = false;
	public var blockPlayerInput:Bool = false;

	public var guiOffset(get, null):FlxPoint;
	private function get_guiOffset():FlxPoint {
		return new FlxPoint((1280 - (1280 / engineSettings.noteScale)), (720 - (720 / engineSettings.noteScale)));
	}
	public var guiSize(get, null):FlxPoint;
	private function get_guiSize():FlxPoint {
		return new FlxPoint(1280 / engineSettings.noteScale, 720 / engineSettings.noteScale);
	}

	public function setDownscroll(downscroll:Bool, autoPos:Bool) {
		var p:Bool = autoPos;
		engineSettings.downscroll = downscroll;
		if (p) {
			
			var oldStrumLinePos = strumLine.y;
			strumLine.y = (engineSettings.downscroll ? guiSize.y - 150 : 50);
			for (strum in playerStrums.members) {
				strum.y = strum.y - oldStrumLinePos + strumLine.y;
			}
			for (strum in cpuStrums.members) {
				strum.y = strum.y - oldStrumLinePos + strumLine.y;
			}
		}
	}

	// public static var modchart:Script;
	// public static var stage:Script;

	// Cutscene and end_cutscene are still scripts cause they're executed separately.
	public static var cutscene:Script;
	public static var end_cutscene:Script;

	// Stages, modcharts, ect...
	public static var scripts:ScriptPack;

	public static var iconChanged:Bool = false;
	public var noteScripts:Array<Script> = [];

	public var stage_persistent_vars:Map<String, Dynamic> = [];
	
	// public var songEvents:SongEventsManager.SongEventsManager;
	public static var bfList:Array<String> = ["bf", "bf-car", "bf-christmas", "bf-pixel", "bf-pixel-dead"];

	public var numberOfExceptionsShown:Int = 0;

	public function setDefaultControl(noteAmount:Int, index:Int, key:FlxKey) {
		var thingy = 'controls_${noteAmount}_$index';
		if (!Reflect.hasField(engineSettings, thingy))
			Reflect.setField(engineSettings, thingy, key);
		if (!Reflect.hasField(engineSettings, thingy))
			Reflect.setField(engineSettings, thingy, key);
	}
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
	var p2isGF:Bool = false;

	public override function finishTransOut() {
		PlayState.current = null;
		super.finishTransOut();
	}
	public override function destroy() {
		scripts.executeFunc("onDestroy");
		scripts.executeFunc("destroy");
		PlayState.current = null;
		if (engineSettings.memoryOptimization && (!isStoryMode || (isStoryMode && storyPlaylist.length == 0))) {
			// Paths.clearForMod(songMod);
		}
		scripts = null;
		cutscene = null;
		end_cutscene = null;
		SONG = null;
		super.destroy();
	}

	public static function checkSong() {
		if (_SONG.keyNumber == null)
			_SONG.keyNumber = 4;
		
		if (_SONG.noteTypes == null)
			_SONG.noteTypes = ["Friday Night Funkin':Default Note"];

		if (_SONG.events == null)
			_SONG.events = [];

		if (_SONG.gfVersion == null)
			_SONG.gfVersion = "gf";

		if (_SONG.scripts == null)
			_SONG.scripts = [];
	}
	var actualModConfig:ModConfig;
	override public function create()
	{
		Settings.engineSettings.data.selectedMod = songMod;
		Paths.clearOtherModCache(songMod);

		
		GameOverSubstate.char = "Friday Night Funkin':bf-dead";
		GameOverSubstate.firstDeathSFX = "Friday Night Funkin':fnf_loss_sfx";
		GameOverSubstate.gameOverMusic = "Friday Night Funkin':gameOver";
		GameOverSubstate.gameOverMusicBPM = 100;
		GameOverSubstate.retrySFX = "Friday Night Funkin':gameOverEnd";
		GameOverSubstate.scriptName = "";

		PlayState.current = this;
		engineSettings = Reflect.copy(Settings.engineSettings.data);

		if (CoolUtil.isDevMode()) {
			ModSupport.reloadModsConfig();
		}
		actualModConfig = ModSupport.modConfig[songMod];
		// GAME TITLE
		var gameTitle = songMod;
		if (actualModConfig.titleBarName != "" && actualModConfig.titleBarName != null) {
			gameTitle = actualModConfig.titleBarName;
		} else {
			var fullTitleThingies = ["friday night funkin", "-", "fnf"];
			var fullTitle = false;
			for (t in fullTitleThingies) {
				if (songMod.toLowerCase().contains(t)) {
					fullTitle = true;
					break;
				}
			}
			if (!fullTitle) gameTitle = 'Friday Night Funkin\' - $gameTitle';
		}
		
		lime.app.Application.current.window.title = gameTitle;

		// GAME ICON
		var modFolder = Paths.modsPath;
		//trace('$modFolder/$songMod/icon.ico');
		/*
		#if desktop
		if (FileSystem.exists('$modFolder/$songMod/icon.ico')) {
			// Application
			
			@:privateAccess
			var handle = lime.app.Application.current.window.__backend.handle;
			@:privateAccess
			lime._internal.backend.native.NativeCFFI.lime_window_set_icon(handle, new ImageBuffer(UInt8Array.fromBytes(File.getBytes('$modFolder/$songMod/icon.ico'))));
			
			@:privateAccess
			lime.app.Application.current.window.__backend.handle;
			// lime.app.Application.current.window.setIcon(Image.fromFile('$modFolder/$songMod/icon.ico'));
		} else
		#end
		*/
		var iconPath = Paths.file('icon.png', IMAGE, 'mods/$songMod');
		trace(iconPath);
		if (Assets.exists(iconPath)) {
			lime.app.Application.current.window.setIcon(Assets.getImage(iconPath));
			iconChanged = true;
		}
		

		
		// lime_window_set_icon 
		FlxG.scaleMode = new WideScreenScale();
		// Assets.loadLibrary("songs");
		#if sys
		if (engineSettings.emptySkinCache) {
			// Paths.clearCache();
		}
		#end

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		if (_SONG == null)
			_SONG = Song.loadModFromJson('tutorial', 'Friday Night Funkin\'');

		checkSong();

		SONG = Reflect.copy(_SONG);

		ModSupport.currentMod = songMod;
		ModSupport.parseSongConfig();

		

        scripts = new ScriptPack(ModSupport.scripts);
		if (ModSupport.song_cutscene != null) {
			cutscene = Script.create('${Paths.modsPath}/${ModSupport.song_cutscene.path}');
		} else {
			cutscene = new HScript();
		}
		if (ModSupport.song_end_cutscene != null) {
			end_cutscene = Script.create('${Paths.modsPath}/${ModSupport.song_end_cutscene.path}');
		} else {
			end_cutscene = new HScript();
		}
		if (cutscene == null) cutscene = new HScript();
		if (end_cutscene == null) end_cutscene = new HScript();

		scripts.setVariable("update", function(elapsed:Float) {});
		scripts.setVariable("create", function() {});
		scripts.setVariable("newPost", function() {});
		scripts.setVariable("musicstart", function() {});
		scripts.setVariable("beatHit", function(curBeat:Int) {});
		scripts.setVariable("stepHit", function(curStep:Int) {});
		scripts.setVariable("botplay", engineSettings.botplay);
		scripts.setVariable("gfVersion", _SONG.gfVersion);

		var defaultRatings:Array<Dynamic> = [
			{
				name : "Sick",
				image : "Friday Night Funkin':ratings/sick",
				accuracy : 1,
				health : 0.035,
				maxDiff : (166 + (2/3)) * 0.2,
				score : 350,
				color : "#24DEFF",
				fcRating : "MFC",
				showSplashes : true
			},
			{
				name : "Good",
				image : "Friday Night Funkin':ratings/good",
				accuracy : 2 / 3,
				health : 0.025,
				maxDiff : (166 + (2/3)) * 0.60,
				score : 200,
				color : "#3FD200",
				fcRating : "GFC"
			},
			{
				name : "Bad",
				image : "Friday Night Funkin':ratings/bad",
				accuracy : 1 / 3,
				health : 0.010,
				maxDiff : (166 + (2/3)) * 0.80,
				score : 50,
				color : "#D70000"
			},
			{
				name : "Shit",
				image : "Friday Night Funkin':ratings/shit",
				accuracy : 1 / 6,
				health : 0.0,
				maxDiff : 99999,
				score : -150,
				color : "#804913",
				miss : true
			}
		];
		scripts.setVariable("ratings", defaultRatings);
		scripts.setVariable("getCameraZoom", function(curBeat) {
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

		// ModSupport.setScriptDefaultVars(stage, songMod, {});
		// ModSupport.setScriptDefaultVars(modchart, songMod, {});
		// ModSupport.setScriptDefaultVars(cutscene, songMod, {});

		var endCutsceneFunc = function() {

		};

		for (c in [cutscene, end_cutscene]) {
			c.setVariable("update", function(elapsed) {

			});
			c.setVariable("create", function() {
				if (c == cutscene)
					startCountdown();
				else
					endSong2(); //Only execute when cutscene ended
			});
		}
		cutscene.setVariable("startCountdown", startCountdown);
		end_cutscene.setVariable("end", endSong2);

		ModSupport.setScriptDefaultVars(cutscene, ModSupport.song_cutscene == null ? songMod : ModSupport.song_cutscene.mod, {});
		ModSupport.setScriptDefaultVars(end_cutscene, ModSupport.song_end_cutscene == null ? songMod : ModSupport.song_end_cutscene.mod, {});


		scripts.loadFiles();
		if (ModSupport.song_cutscene != null) cutscene.loadFile('${Paths.modsPath}/${ModSupport.song_cutscene.path}');
		if (ModSupport.song_end_cutscene != null) end_cutscene.loadFile('${Paths.modsPath}/${ModSupport.song_end_cutscene.path}');

		// right before camHUD creation lol
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera(0, 0, 1280, 720, engineSettings.noteScale);
		if (isWidescreen) WideScreenScale.updatePlayStateHUD();
		if (engineSettings.greenScreenMode) {
			camHUD.bgColor = new FlxColor(0xFF00FF00);
		} else {
			camHUD.bgColor.alpha = 0;
		}
		camHUD.setSize(Std.int(guiSize.x), Std.int(guiSize.y));

		// @:privateAccess
		// var oldViewOffset = camHUD.viewOffsetX;
		// camHUD.zoom = engineSettings.noteScale;
		// camHUD.setSize(Std.int(guiSize.x, guiSize.y));
		// camHUD.setScale(engineSettings.noteScale, engineSettings.noteScale);
		// @:privateAccess
		//  = 0;

		// @:privateAccess
		// camHUD.viewOffsetWidth = camHUD.width - camHUD.viewOffsetX;

		// @:privateAccess
		// camHUD.viewWidth = camHUD.width - 2 * camHUD.viewOffsetX;
		// camHUD.scroll.x = (-(guiOffset.x / 2));
		// camHUD.height = Std.int(guiSize.y);
		// camHUD.y -= 720 - guiSize.y;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];
		// FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		

		var p1 = CoolUtil.getCharacterFull(SONG.player1, songMod);
		if (ModSupport.modConfig[p1[0]] != null && engineSettings.customBFSkin != "default") {
			if (ModSupport.modConfig[p1[0]].skinnableBFs != null)
				for (skin in ModSupport.modConfig[p1[0]].skinnableBFs)
					if (skin.toLowerCase() == p1[1].toLowerCase())
						// YOOO CUSTOM SKIN POGGERS
						p1 = ['~', 'bf/${engineSettings.customBFSkin}'];
			
		}
		SONG.player1 = p1.join(":");

		var p2 = CoolUtil.getCharacterFull(SONG.player2, songMod);
		if (ModSupport.modConfig[p2[0]] != null && engineSettings.customGFSkin != "default") {
			if (ModSupport.modConfig[p2[0]].skinnableGFs != null)
				for (skin in ModSupport.modConfig[p2[0]].skinnableGFs)
					if (skin.toLowerCase() == p2[1].toLowerCase()) {
						// YOOO CUSTOM SKIN POGGERS
						p2 = ['~', 'gf/${engineSettings.customGFSkin}'];
						p2isGF = true;
					}
			
			
		}
		if (ModSupport.modConfig[p2[0]] != null)
			if (ModSupport.modConfig[p2[0]].skinnableGFs != null)
				for (skin in ModSupport.modConfig[p2[0]].skinnableGFs)
					if (skin.toLowerCase() == p2[1].toLowerCase()) {
						p2isGF = true;
						break;
					}

		SONG.player2 = p2.join(":");
		SONG.player1 = p1.join(":");
			
		if (engineSettings.botplay || !SONG.validScore || PlayState.fromCharter)
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
			detailsText = 'Story Mode: $songMod';
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, '$songMod - ${CoolUtil.prettySong(song.song)} ($storyDifficultyText)', iconRPC);
		#end

		scripts.executeFunc("oldNew");
		

		var resultRatings:Array<Dynamic> = cast(scripts.getVariable("ratings", defaultRatings), Array<Dynamic>);
		if (resultRatings == null) {
			resultRatings = defaultRatings;
		}
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
			if (rating.fcRating != null) r.fcRating = rating.fcRating;
			if (rating.showSplashes != null) r.showSplashes = rating.showSplashes;

			if (rating.bitmap == null) {
				rating.bitmap = new BitmapData(1, 1, true, 0x00000000);
			}

			ratings.push(r);
			hits[r.name] = 0;
		}
		hits["Misses"] = 0;


		var gfVersion:String = scripts.getVariable("gfVersion", "gf");

		// INTENTIONAL SPELLING MISTAKE LOL
		var girlfried = CoolUtil.getCharacterFull(gfVersion, songMod);
		if (ModSupport.modConfig[girlfried[0]] != null && engineSettings.customGFSkin != "default" && engineSettings.customGFSkin != null) {
			if (ModSupport.modConfig[girlfried[0]].skinnableGFs != null)
				for (skin in ModSupport.modConfig[girlfried[0]].skinnableGFs)
					if (skin.toLowerCase() == girlfried[1].toLowerCase())
						// YOOO CUSTOM SKIN POGGERS
						girlfried = ['~', 'gf/${engineSettings.customGFSkin}'];
				
		}
		gf = new Character(400, 130, girlfried.join(":"));
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);
		if (p2isGF) {
			dad.setPosition(gf.x, gf.y);
			gf.visible = false;
		}

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
		}

		boyfriend = new Boyfriend(770, 100, SONG.player1);

		scripts.executeFunc("create");
		scripts.executeFunc("createAfterChars");
		if (!members.contains(gf))
			add(gf);

		if (!members.contains(dad))
			add(dad);
		if (!members.contains(boyfriend))
			add(boyfriend);
		
		scripts.executeFunc("createInFront");

		// var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.scrollFactor.set();
		// doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;
		Conductor.songPositionOld = -5000;

		strumLine = new FlxSprite(0, (engineSettings.downscroll ? guiSize.y - 150 : 50)).makeGraphic(Std.int(guiSize.x), 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StrumNote>();
		cpuStrums = new FlxTypedGroup<StrumNote>();

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);

		var mPoint = gf.getMidpoint();
		camFollow.setPosition(mPoint.x, mPoint.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		//FlxG.camera.scroll.set(camFollow.x - (FlxG.width / 2) + FlxG.camera.targetOffset.x, camFollow.y - (FlxG.height / 2) + FlxG.camera.targetOffset.y);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if (engineSettings.showRatingTotal) {
			hitCounter = new FlxText(-20, 0, guiSize.x, "Misses : 0", 12);
			hitCounter.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			hitCounter.antialiasing = true;
			hitCounter.cameras = [camHUD];
			hitCounter.visible = false;
			add(hitCounter);
		}

		healthBarBG = new FlxSprite(0, guiSize.y * (engineSettings.downscroll ? 0.075 : 0.9)).loadGraphic(Paths.image('healthBar'));
		healthBarBG.cameras = [camHUD];
		healthBarBG.cameraCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = false;
		healthBarBG.antialiasing = true;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, maxHealth);
		healthBar.scrollFactor.set();
		healthBar.cameras = [camHUD];
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.visible = false;
		add(healthBar);
		// adding the bg AFTER to allow things such as round health bar bgs and better inclusion.
		// HEALTHBAR BG MUST BE TRANSPARENT!!!!
		add(healthBarBG);

		// scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt = new FlxText(0, healthBarBG.y + 30, guiSize.x , "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), Std.int(engineSettings.scoreTextSize), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scale.x = 1;
		scoreTxt.scale.y = 1;
		scoreTxt.antialiasing = true;
		scoreTxt.cameras = [camHUD];
		scoreTxt.cameraCenter(X);
		scoreTxt.scrollFactor.set();
		scoreTxt.visible = false;

		if (engineSettings.watermark) {
			watermark = new FlxText(0, 0, guiSize.x, '${ModSupport.getModName(songMod)}\n${CoolUtil.prettySong(SONG.song)}\nYoshiCrafter Engine v${Main.engineVer}');
			watermark.setFormat(Paths.font("vcr.ttf"), Std.int(16), FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			watermark.antialiasing = true;
			watermark.cameras = [camHUD];
			// watermark.y -= watermark.height;
			watermark.visible = false;
			add(watermark);
		}
		var message = '/!\\ Score will not be saved';
		if (PlayState.fromCharter) {
			message = '/!\\ Player used Charter, Score will not be saved';
		} else if (engineSettings.botplay) {
			message = '/!\\ Botplay is enabled, Score will not be saved';
		}
		
		scoreWarning = new FlxText(0, guiSize.y, guiSize.x, message);
		scoreWarning.setFormat(Paths.font("vcr.ttf"), Std.int(16), 0xFFFF2222, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreWarning.antialiasing = true;
		scoreWarning.cameras = [camHUD];
		scoreWarning.y -= scoreWarning.height;
		scoreWarning.visible = false;
		add(scoreWarning);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = false;
		boyfriend.healthIcon = iconP1;

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = false;
		dad.healthIcon = iconP2;
		
		add(iconP1);
		add(iconP2);
		add(scoreTxt);

		if (engineSettings.showTimer) {
			// var apparitionPos:Float = -25;
			// if (engineSettings.downscroll) {
			// 	apparitionPos = guiSize.y + 25;
			// }
			timerBG = new FlxSprite(0, engineSettings.downscroll ? guiSize.y - 35 : 10).makeGraphic(300, 25, 0xFF222222);
			timerBG.cameras = [camHUD];
			timerBG.cameraCenter(X);
			timerBG.scrollFactor.set();
			timerBG.visible = false;
			add(timerBG);

			timerBar = new FlxBar(timerBG.x + 4, timerBG.y + 4, LEFT_TO_RIGHT, Std.int(timerBG.width - 8), Std.int(timerBG.height - 8));
			timerBar.cameras = [camHUD];
			timerBar.cameraCenter(X);
			timerBar.antialiasing = true;
			// timerBar.barWidth = Std.int(FlxG.sound.music.length / 1000);
			timerBar.scrollFactor.set();
			timerBar.createGradientBar([0x88222222], [0xFF7163F1, 0xFFD15CF8], 1, 90, true, 0xFF000000);
			// timerBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
			timerBar.visible = false;
			add(timerBar);

			timerText = new FlxText(timerBG.x, timerBG.y + (timerBG.height / 2), 0, '${CoolUtil.prettySong(SONG.song)}');
			timerText.setFormat(Paths.font("vcr.ttf"), Std.int(24), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timerText.cameras = [camHUD];
			timerText.antialiasing = true;
			timerText.visible = false;
			timerText.y -= timerText.height / 2;
			// timerText.screenCenter(X);
			timerText.x = (guiSize.x / 2) - (timerText.width / 2);
			add(timerText);

			var x = -10 + (timerText.width > timerBG.width ? timerText.x : timerBG.x);
			timerNow = new FlxText(x, timerText.y, 0, "0:00");
			timerNow.setFormat(Paths.font("vcr.ttf"), Std.int(24), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timerNow.cameras = [camHUD];
			timerNow.antialiasing = true;
			timerNow.visible = false;
			timerNow.x = x - timerNow.width;
			add(timerNow);

			var x = 10 + (timerText.width > timerBG.width ? timerText.x + timerText.width: timerBG.x + timerBG.width);
			timerFinal = new FlxText(x, timerText.y, 0, "0:00");
			timerFinal.setFormat(Paths.font("vcr.ttf"), Std.int(24), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timerFinal.cameras = [camHUD];
			timerFinal.antialiasing = true;
			timerFinal.visible = false;
			add(timerFinal);

			// if (engineSettings.downscroll) {
			// 	FlxTween.tween(timerBG, {y : guiSize.y - 29, alpha : 1}, 0.5, {ease : FlxEase.circInOut});
			// 	FlxTween.tween(timerBar, {y : guiSize.y - 25, alpha : 1}, 0.5, {ease : FlxEase.circInOut});
			// 	FlxTween.tween(timerText, {y : guiSize.y - 22.5, alpha : 1}, 0.5, {ease : FlxEase.circInOut});
			// } else {
			// 	FlxTween.tween(timerBG, {y : 25, alpha : 1}, 0.5, {ease : FlxEase.circInOut});
			// 	FlxTween.tween(timerBar, {y : 29, alpha : 1}, 0.5, {ease : FlxEase.circInOut});
			// 	FlxTween.tween(timerText, {y : 27.5, alpha : 1}, 0.5, {ease : FlxEase.circInOut});
			// }
			if (members.contains(msScoreLabel)) remove(msScoreLabel);
			add(msScoreLabel);
		}


		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		// doof.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			if (cutscene != null) {
				inCutscene = true;
				cutscene.executeFunc("create");
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

		#if MOBILE_UI
		var pauseButton = new FlxClickableSprite(guiSize.x - 15, 15);
			pauseButton.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
			pauseButton.animation.addByPrefix("pause", "pause button");
			pauseButton.animation.play("pause");
			pauseButton.key = FlxKey.ENTER;
			pauseButton.setHitbox();
			// pauseButton.hitbox.x /= 2;
			pauseButton.x -= pauseButton.hitbox.x;
			pauseButton.cameras = [camHUD];
			pauseButton.antialiasing = true;
			add(pauseButton);
		#end

		super.create();


		// https://discord.com/channels/860561967383445535/925492025258836059/941454799600242759
		scripts.executeFunc("createPost");
		scripts.executeFunc("postCreate");

		/*
		for (e in members) {
			if (Std.isOfType(e, FlxSprite)) {
				var sprite = cast(e, FlxSprite);
				@:privateAccess
				if (sprite.graphic == null) sprite.graphic = new FlxGraphic("unknown", new BitmapData(1, 1, true, 0), true);
				#if trace_everything
					trace(sprite.graphic);
					trace(sprite.graphic.bitmap);
				#end
				if (sprite.graphic.bitmap == null) {
					sprite.graphic.bitmap = new BitmapData(1, 1, true, 0);
				}
				if (!sprite.graphic.bitmap.readable) {
					sprite.graphic.bitmap.dispose();
					sprite.graphic.bitmap = new BitmapData(1, 1, true, 0);
				}
			}
		}
		*/
	}

	function spawnSplashOnSprite(sprite:FlxSprite, color:FlxColor, splashSprite:String, ?camera:FlxCamera, behindStrums:Bool = false) {
		if (engineSettings.maxSplashes <= 0 || !engineSettings.splashesEnabled) return;
		// if (splashes.length <= 0) return;
		if (camera == null) camera = FlxG.camera;
		if (splashes[splashSprite] == null) splashes[splashSprite] = [];

		var splash = (splashes[splashSprite].length >= engineSettings.maxSplashes) ? splashes[splashSprite].shift() : new Splash(splashSprite);
		splash.alpha = engineSettings.splashesAlpha;

		remove(splash);
		splash.cameras = [camHUD];
		if (behindStrums) {
			insert(members.indexOf(strumLineNotes), splash);
		} else {
			add(splash);
		}
		splash.setPosition(
			sprite.x + ((sprite.width) / 2),
			sprite.y + ((sprite.height) / 2));
		splash.pop(color);

		splashes[splashSprite].push(splash);
	}
	function spawnSplashOnStrum(color:FlxColor, splashSprite:String, strum:Int, player:Int = 0) {
		var strums = player == 0 ? playerStrums : cpuStrums;
		var str = strums.members[strum % strums.length];
		spawnSplashOnSprite(str, color, splashSprite, camHUD, engineSettings.spawnSplashBehind);
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

	var guiElemsPopped = false;
	public function popUpGUIelements() {
		if (guiElemsPopped) return;
		guiElemsPopped = true;

		for (elem in [healthBar, iconP1, iconP2, scoreTxt, msScoreLabel, healthBarBG, hitCounter, watermark, timerText, timerBG, timerBar, timerNow, timerFinal]) {
			if (elem != null) {
				var oldElemY = elem.y;
				var oldAlpha = elem.alpha;
				elem.alpha = 0;
				if (elem.y < Std.int(PlayState.current.guiSize.y / 2)) {
					elem.y = elem.y - Std.int(PlayState.current.guiSize.y / 2);
					FlxTween.tween(elem, {y : oldElemY, alpha : oldAlpha}, 0.75, {ease : FlxEase.quartInOut});
				} else {
					elem.y = elem.y + Std.int(PlayState.current.guiSize.y / 2);
					FlxTween.tween(elem, {y : oldElemY, alpha : oldAlpha}, 0.75, {ease : FlxEase.quartInOut});
				}
				elem.visible = true;
			}
		}
		healthBar.value = 0;
		scripts.executeFunc("onGuiPopup");
	}
	public function startCountdown():Void
	{
		inCutscene = false;
		
		scripts.executeFunc("onStartCountdown");

		trace("SONG.keyNumber = " + Std.string(SONG.keyNumber));
		if (SONG.keyNumber == 0 || SONG.keyNumber == null) SONG.keyNumber = 4;
		
		generateStaticArrows(0);
		generateStaticArrows(1);
		scripts.executeFunc("onStrums");
		scripts.executeFunc("onGenerateStaticArrows");

		var spawnUnder:Bool = engineSettings.downscroll;
		if (engineSettings.middleScroll) {
			spawnUnder = !spawnUnder;
		}
		msScoreLabel = new FlxText(
			playerStrums.members[0].x,
			spawnUnder ? (playerStrums.members[0].y + Note.swagWidth) : (playerStrums.members[0].y - 25),
			playerStrums.members[playerStrums.members.length - 1].width + playerStrums.members[playerStrums.members.length - 1].x - playerStrums.members[0].x,
			"0ms", 20);
		msScoreLabel.setFormat(Paths.font("vcr.ttf"), Std.int(30), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		msScoreLabel.antialiasing = true;
		msScoreLabel.visible = false;
		msScoreLabel.scale.x = 1;
		msScoreLabel.scale.y = 1;
		msScoreLabel.scrollFactor.set();
		msScoreLabel.cameras = [camHUD];
		msScoreLabel.alpha = 0;
		add(msScoreLabel);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = startTime;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			// for (i => d in dads) {
			// 	if (d != null) {
			// 		// d.playAnim('idle');
			// 		d.dance();
			// 	} else {
			// 		#if debug
			// 			trace("Dad at index " + Std.string(i) + " is null.");
			// 		#end
			// 	}
			// }
			for (bf in members) {
				if (Std.isOfType(bf, Character)) {
					cast(bf, Character).dance();
				}
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			curBeat = -5 + swagCounter;

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
					if (scripts.executeFuncMultiple("onCountdown", [3], [true, null]) != false) {
						FlxG.sound.play(Paths.sound('intro3'), 0.6);
					}
				case 1:
					if (scripts.executeFuncMultiple("onCountdown", [2], [true, null]) != false) {
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.scrollFactor.set();
						ready.updateHitbox();
	
						if (curStage.startsWith('school'))
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
	
						ready.cameras = [camHUD];
						ready.cameraCenter();
						add(ready);
						FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2'), 0.6);
					}
				case 2:
					if (scripts.executeFuncMultiple("onCountdown", [1], [true, null]) != false) {
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.scrollFactor.set();
	
						if (curStage.startsWith('school'))
							set.setGraphicSize(Std.int(set.width * daPixelZoom));
	
						set.cameras = [camHUD];
						set.cameraCenter();
						add(set);
						FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1'), 0.6);
					}
					
				case 3:
					if (scripts.executeFuncMultiple("onCountdown", [0], [true, null]) != false) {
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.scrollFactor.set();
	
						if (curStage.startsWith('school'))
							go.setGraphicSize(Std.int(go.width * daPixelZoom));
	
						go.updateHitbox();
						
						go.cameras = [camHUD];
						go.cameraCenter();
						add(go);
						FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo'), 0.6);
					}
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
		// songEvents.start();
		popUpGUIelements();
		
		updateHealthBarColors();
	}

	public var timerBG:FlxSprite = null;
	public var timerBar:FlxBar = null;
	public var timerText:FlxText = null;
	public var timerNow:FlxText = null;
	public var timerFinal:FlxText = null;

	function startSong():Void
	{
		scripts.executeFunc("onPreSongStart");
		startingSong = false;


		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused) {
			// FlxG.sound.playMusic(inst, 1, false);
			FlxG.sound.music = inst;
			FlxG.sound.music.time = startTime;
			FlxG.sound.music.play();
			FlxG.sound.music.time = startTime;
			// FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}
		Conductor.songPosition = startTime;

		

		

		FlxG.sound.music.onComplete = endSong;
		vocals.time = startTime;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, '$songMod - ${CoolUtil.prettySong(song.song)} ($storyDifficultyText)', iconRPC, true, songLength);
		#end
		if (timerBar != null) {
			timerBar.setParent(Conductor, "songPosition");
			timerBar.setRange(0, Math.max(inst.length, 1000));
		}

		scripts.executeFunc("musicstart");
		scripts.executeFunc("onSongStart");
	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		
		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.modVoices(PlayState.SONG.song, songMod, storyDifficulty.toLowerCase() == "normal" ? "" : storyDifficulty.toLowerCase().replace(" ", "-")));
			// vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		inst = new FlxSound().loadEmbedded(Paths.modInst(PlayState.SONG.song, songMod, storyDifficulty.toLowerCase() == "normal" ? "" : storyDifficulty.toLowerCase().replace(" ", "-")));
		inst.stop();

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
			var splittedThingy = t.split(":");
			if (splittedThingy.length < 2) {
				for(ext in Main.supportedFileTypes) {
					if (FileSystem.exists('${Paths.modsPath}/${PlayState.songMod}/notes/${splittedThingy[0]}.$ext')) {
						splittedThingy.insert(0, PlayState.songMod);
						break;
					}
				}
				
				if (splittedThingy.length < 2) {
					splittedThingy.insert(0, "Friday Night Funkin'");
				}
			}

			var noteScriptName = splittedThingy[1];
			var noteScriptMod = splittedThingy[0];
			var p = Paths.modsPath + '/$noteScriptMod/notes/$noteScriptName';
			var script = Script.create(p);
			if (script == null) script = new HScript();
			script.setVariable("enableRating", true);

			var calculateNote = function() {
				var note:Note = script.getVariable("note");
				if (note.isSustainNote) {
					// note.canBeHit = (note.strumTime - (Conductor.stepCrochet * 0.6) < Conductor.songPosition) && (note.strumTime + (Conductor.stepCrochet) > Conductor.songPosition);
					var lastCanBeHit = note.canBeHit;
					note.canBeHit = (note.strumTime + note.maxEarlyDiff > Conductor.songPosition && note.strumTime - Conductor.stepCrochet < Conductor.songPosition);
					if (note.prevSusNote != null)
						if (!note.prevSusNote.isSustainNote)
							note.canBeHit = (note.strumTime - note.maxEarlyDiff < Conductor.songPosition && (note.prevSusNote.wasGoodHit || note.prevSusNote.strumTime < Conductor.songPosition));
							
					note.canBeHit = note.canBeHit || (lastKeys.pressedArray[note.noteData % (SONG.keyNumber)] && (Conductor.songPosition - (lastElapsed * 1000) < note.strumTime) && (Conductor.songPosition > note.strumTime)); // no more misses when freezes during sustains
				} else {
					note.canBeHit = (note.strumTime - note.maxEarlyDiff < Conductor.songPosition && note.strumTime + note.maxLateDiff > Conductor.songPosition);
				}
				if (note.strumTime + note.missDiff < Conductor.songPosition && !note.wasGoodHit && !note.canBeHit)
					note.tooLate = true;
			}
			script.setVariable("calculateNote", calculateNote);
			script.setVariable("update", function(elapsed) {
				calculateNote();
			});
			script.setVariable("globalUpdate", function() {
				
			});
			script.setVariable("create", function() {
				var note:Note = script.getVariable("note");
				note.frames = (engineSettings.customArrowSkin == "default") ? Paths.getCustomizableSparrowAtlas('NOTE_assets_colored', 'shared') : Paths.getSparrowAtlas(engineSettings.customArrowSkin.toLowerCase(), 'skins');
				note.colored = true;
				
				note.animation.addByPrefix('green', 'arrowUP');
				note.animation.addByPrefix('blue', 'arrowDOWN');
				note.animation.addByPrefix('purple', 'arrowLEFT');
				note.animation.addByPrefix('red', 'arrowRIGHT');
				note.colored = true;

				note.splash = Paths.splashes("splashes", "shared");

				note.setGraphicSize(Std.int(note.width * 0.7));
				note.updateHitbox();
				note.antialiasing = true;
				
				var noteNumberScheme:Array<NoteDirection> = Note.noteNumberSchemes[PlayState.SONG.keyNumber];
				if (noteNumberScheme == null) noteNumberScheme = Note.noteNumberSchemes[4];
				switch(noteNumberScheme[note.noteData % noteNumberScheme.length]) {
					case Left:
						note.animation.addByPrefix('scroll', "purple0");
						note.animation.addByPrefix('holdend', "pruple end hold");
						note.animation.addByPrefix('holdpiece', "purple hold piece");
					case Down:
						note.animation.addByPrefix('scroll', "blue0");
						note.animation.addByPrefix('holdend', "blue hold end");
						note.animation.addByPrefix('holdpiece', "blue hold piece");
					case Up:
						note.animation.addByPrefix('scroll', "green0");
						note.animation.addByPrefix('holdend', "green hold end");
						note.animation.addByPrefix('holdpiece', "green hold piece");
					case Right:
						note.animation.addByPrefix('scroll', "red0");
						note.animation.addByPrefix('holdend', "red hold end");
						note.animation.addByPrefix('holdpiece', "red hold piece");
				}

				
			});
			script.setVariable("generateStaticArrow", function(babyArrow:StrumNote, i:Int, player:Int) {
					babyArrow.frames = (engineSettings.customArrowSkin == "default") ? Paths.getCustomizableSparrowAtlas('NOTE_assets_colored', 'shared') : Paths.getSparrowAtlas(engineSettings.customArrowSkin.toLowerCase(), 'skins');
					
					
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
					babyArrow.colored = true;

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
			script.setVariable("onDadHit", function(noteData) {
				var note:Note = script.getVariable("note");
				var noteNumberScheme:Array<NoteDirection> = Note.noteNumberSchemes[PlayState.SONG.keyNumber];
				if (noteNumberScheme == null) noteNumberScheme = Note.noteNumberSchemes[4];

				switch(noteNumberScheme[noteData % noteNumberScheme.length]) {
					case Left:
						for (d in dads) d.playAnim("singLEFT" + ((note.altAnim) ? "-alt" : ""), true);
					case Down:
						for (d in dads) d.playAnim("singDOWN" + ((note.altAnim) ? "-alt" : ""), true);
					case Up:
						for (d in dads) d.playAnim("singUP" + ((note.altAnim) ? "-alt" : ""), true);
					case Right:
						for (d in dads) d.playAnim("singRIGHT" + ((note.altAnim) ? "-alt" : ""), true);
				}
			});
			script.setVariable("onPlayerHit", function(noteData) {
				var noteNumberScheme:Array<NoteDirection> = Note.noteNumberSchemes[PlayState.SONG.keyNumber];
				if (noteNumberScheme == null) noteNumberScheme = Note.noteNumberSchemes[4];

				switch(noteNumberScheme[noteData % noteNumberScheme.length]) {
					case Left:
						for (b in boyfriends) b.playAnim("singLEFT", true);
					case Down:
						for (b in boyfriends) b.playAnim("singDOWN", true);
					case Up:
						for (b in boyfriends) b.playAnim("singUP", true);
					case Right:
						for (b in boyfriends) b.playAnim("singRIGHT", true);
				}
			});
			script.setVariable("onMiss", function(noteData) {
				var noteNumberScheme:Array<NoteDirection> = Note.noteNumberSchemes[PlayState.SONG.keyNumber];
				if (noteNumberScheme == null) noteNumberScheme = Note.noteNumberSchemes[4];

				switch(noteNumberScheme[noteData % noteNumberScheme.length]) {
					case Left:
						for (b in boyfriends) b.playAnim("singLEFTmiss", true);
					case Down:
						for (b in boyfriends) b.playAnim("singDOWNmiss", true);
					case Up:
						for (b in boyfriends) b.playAnim("singUPmiss", true);
					case Right:
						for (b in boyfriends) b.playAnim("singRIGHTmiss", true);
				}
				noteMiss(noteData);
				health -= script.getVariable("note").isSustainNote ? 0.03125 : 0.125;
			});
			// script.execute(ModSupport.getExpressionFromPath(Paths.modsPath + '/$noteScriptMod/notes/$noteScriptName.hx', true));
			ModSupport.setScriptDefaultVars(script, noteScriptMod, {});
			script.loadFile(p);
			noteScripts.push(script);
		}

		for (section in noteData)
		{
			if (section == null) continue;
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				if (songNotes[0] < startTime && startTime > 0) continue;
				if (songNotes[1] < 0) {
					if (songNotes.length == 5 && Std.isOfType(songNotes[2], String) && Std.isOfType(songNotes[3], String) && Std.isOfType(songNotes[4], String)) {
						// psych engine event for yall psych people who want to port their chart easily
						psychEvents.push({
							time: songNotes[0],
							name: songNotes[2],
							value1: songNotes[3],
							value2: songNotes[4]
						});
					}
					continue;
				}
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

				var prevSusNote = swagNote;
				// if (!engineSettings.downscroll) unspawnNotes.push(swagNote);

				// naaaaah i'm not adding this in
				// for (susNote in 0...Math.floor(susLength > 0 ? susLength + 1 : susLength))
				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * (susNote)), daNoteData, oldNote, true, gottaHitNote, section.altAnim);
					sustainNote.scrollFactor.set();
					sustainNote.noteOffset.y -= Note.swagWidth / 2;
					sustainNote.alpha *= (engineSettings.transparentSubstains) ? 0.6 : 1;
					sustainNote.prevSusNote = prevSusNote;
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += guiSize.x / 2; // general offset
					}

					prevSusNote = sustainNote;
				}

				// if (engineSettings.downscroll) ;
				unspawnNotes.push(swagNote);

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += guiSize.x / 2; // general offset
				}
				else {}

				
			}
			daBeats += 1;
		}

		for (e in _SONG.events) {
			if (e.time < startTime && startTime > 0) continue;
			events.push({name: e.name, time: e.time, parameters: e.parameters});
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
			var babyArrow:StrumNote = new StrumNote(0, strumLine.y);
			var colors = player == 0 && !engineSettings.customArrowColors_allChars ? dad.getColors() : boyfriend.getColors();
			var strumColor = colors[(i % (colors.length - 1)) + 1];
			babyArrow.shader = new ColoredNoteShader(strumColor.red, strumColor.green, strumColor.blue, false);
			babyArrow.toggleColor(false);
			
			// switch (curStage)
			// {
			// 	case 'school' | 'schoolEvil':
					

			// 	default:
					
				
			// }
			noteScripts[0].executeFunc("generateStaticArrow", [babyArrow, i, player]);
			scripts.executeFunc("onGenerateStaticArrow", [babyArrow, i, player]);
			babyArrow.x += Note.swagWidth * i;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (popupArrows)
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
				babyArrow.isCpu = true;
				cpuStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			if (engineSettings.centerStrums) {
				babyArrow.x = (guiSize.x / 4) - (PlayState.SONG.keyNumber / 2 * Note.swagWidth) + (Note.swagWidth * i);
				babyArrow.x += ((guiSize.x / 2) * player);
			} else {
				if 		  (PlayState.SONG.keyNumber <= 4) {
					babyArrow.x += 50;
				} else if (PlayState.SONG.keyNumber == 5) {
					babyArrow.x += 30;
				} else if (PlayState.SONG.keyNumber >= 6) {
					babyArrow.x += 10;
				}
				babyArrow.x += ((guiSize.x / 2) * player);
			}
			
			babyArrow.scale.x *= Note.widthRatio;
			babyArrow.scale.y *= Note.widthRatio;

			if (engineSettings.middleScroll) {
				if (player == 0) {
					babyArrow.x = -Note.swagWidth;
					babyArrow.visible = false;
					babyArrow.notes_alpha = 0;
				}
				if (player == 1) {
					babyArrow.x = Std.int(PlayState.current.guiSize.x / 2) + ((i - (SONG.keyNumber / 2)) * Note.swagWidth);
				}
			}

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		scripts.executeFunc("onOpenSubstate", [SubState]);
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

			if (startTimer != null) {
				if (!startTimer.finished)
					startTimer.active = true;
				paused = false;
	
				#if desktop
				if (startTimer.finished)
				{
					DiscordClient.changePresence(detailsText, '$songMod - ${CoolUtil.prettySong(song.song)} ($storyDifficultyText)', iconRPC, true, songLength - Conductor.songPosition);
				}
				else
				{
					DiscordClient.changePresence(detailsText, '$songMod - ${CoolUtil.prettySong(song.song)} ($storyDifficultyText)', iconRPC);
				}
			}
				
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		scripts.executeFunc("onFocus", []);
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, '$songMod - ${CoolUtil.prettySong(song.song)} ($storyDifficultyText)', iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, '$songMod - ${CoolUtil.prettySong(song.song)} ($storyDifficultyText)', iconRPC);
			}
		}
		#end

		super.onFocus();
		scripts.executeFunc("onFocusPost", []);
	}
	
	override public function onFocusLost():Void
	{
		scripts.executeFunc("onFocusLost", []);
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, '$songMod - ${CoolUtil.prettySong(song.song)} ($storyDifficultyText)', iconRPC);
		}
		#end

		super.onFocusLost();
		scripts.executeFunc("onFocusLostPost", []);
	}

	function resyncVocals():Void
	{
		scripts.executeFunc("onResyncVocals", []);
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time + Settings.engineSettings.data.noteOffset;
		vocals.time = Conductor.songPosition;
		vocals.play();
		scripts.executeFunc("onResyncVocalsPost", []);
	}
	var discordTimer:Float = 0;
	override public function update(elapsed:Float)
	{
		FlxG.camera.followLerp = camFollowLerp;
		#if profiler cpp.vm.Profiler.start("log.txt"); #end
		if (inCutscene) {
			(endCutscene ? end_cutscene : cutscene).executeFunc("preUpdate", [elapsed]);
		} else {
			scripts.executeFunc("preUpdate", [elapsed]);
		}
		#if !debug
		perfectMode = false;
		#end

		

		if (msScoreLabel != null && engineSettings.animateMsLabel) {
			msScoreLabel.offset.y = FlxMath.lerp(msScoreLabel.offset.y, 0, CoolUtil.wrapFloat(0.25 * 60 * elapsed, 0, 1));
		}
		
		if (!validScore) {
			scoreWarning.visible = true;
			scoreWarningAlphaRot = (scoreWarningAlphaRot + (elapsed * Math.PI * 0.75)) % (Math.PI * 2);
			scoreWarning.alpha = (2 / 3) + (Math.sin(scoreWarningAlphaRot) / 3);
		} else {
			scoreWarning.visible = false;
		}
		
		

		if (FlxControls.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		
		
		if (!inCutscene && !blockPlayerInput) {
			keyShit(elapsed);

			for(e in currentSustains) {
				if (e.time + Conductor.stepCrochet > Conductor.songPosition) {
					health += e.healthVal / (Conductor.stepCrochet / 1000) * elapsed;
				} else {
					currentSustains.remove(e);
				}
			}
		}

		super.update(elapsed);

		// scoreTxt.text = "Score:" + songScore + " | Misses:" + Std.string(misses) + " | Accuracy:" + (numberOfNotes == 0 ? "0%" : Std.string((Math.round(accuracy * 10000 / numberOfNotes) / 10000) * 100) + "%");
		scoreTxt.text = ScoreText.generate(this);
		#if desktop
		if (isStoryMode)
		{
			detailsText = 'Story Mode: $songMod\r\n${scoreTxt.text.replace(" | ", "\r\n")}';
		}
		else
		{
			detailsText = 'Freeplay\r\n${ScoreText.generateAccuracy(this).replace(" | ", "")}';
		}
		discordTimer += elapsed;
		if (discordTimer > 2) {
			DiscordClient.changePresence(detailsText, '$songMod - ${CoolUtil.prettySong(song.song)} ($storyDifficultyText)', iconRPC);
			discordTimer -= 2;
			scripts.executeFunc("onUpdatePresence", []);
		}
		#end


		if (hitCounter != null) {
			var hitsText = "";
			var hitIterator = hits.keys();
			while(true) {
				var it = hitIterator.next();
				if (it != "Misses") {
					var amount = Std.string(hits[it]);
					hitsText = '\r\n$it: $amount' + hitsText;
				}
				if (!hitIterator.hasNext()) break;
			}
			hitCounter.text = hitsText;
			hitCounter.y = (guiSize.y / 2) - (hitCounter.height / 2);
		}

		if (FlxControls.justPressed.ENTER && startedCountdown && canPause)
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
			DiscordClient.changePresence(detailsPausedText, '$songMod - ${CoolUtil.prettySong(song.song)} ($storyDifficultyText)', iconRPC);
			#end
		}
		if (FlxControls.justPressed.SEVEN)
		{
			if (FlxG.sound.music != null) FlxG.sound.music.pause();
			
			if (Settings.engineSettings.data.yoshiCrafterEngineCharter)
				FlxG.switchState(new YoshiCrafterCharter());
			else
				FlxG.switchState(new ChartingState_New());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		if (scripts.executeFuncMultiple("onHealthUpdate", [elapsed], [true, null]) != false) {
			var playerOffset:Int = 0;
			var opponentOffset:Int = 0;
			for (s in members) {
				if (Std.isOfType(s, HealthIcon)) {
					var icon:HealthIcon = cast(s, HealthIcon);
					if (!icon.visible || !icon.auto) continue;
					var iconlerp = 1.15 - (FlxEase.cubeOut(((Conductor.songPosition + (Conductor.crochet * 5)) / Conductor.crochet) % 1) * 0.15);
					icon.scale.set(iconlerp, iconlerp);
					icon.scale.set(iconlerp, iconlerp);
			
					// iconP1.updateHitbox();
					// iconP2.updateHitbox();
			
					var iconOffset:Int = 26;
			
					icon.offset.x = -75;
					icon.offset.x = -75;
					// iconP1.offset.y = -iconOffset;
					if (maxHealth == 0) {
						if (icon.isPlayer) {
							icon.x = Std.int(PlayState.current.guiSize.x / 2) - iconOffset + icon.offset.x + (playerOffset * 100);
						}
						else {
							icon.x = Std.int(PlayState.current.guiSize.x / 2) - (icon.width - iconOffset) + icon.offset.x - (opponentOffset * 100);
						}
					} else {
						
						if (icon.isPlayer) {
							icon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset) + icon.offset.x + (icon.width * (icon.scale.x - 1) / 4) + (playerOffset * 85 * icon.scale.x);
						} else {
							icon.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (icon.width - iconOffset) + icon.offset.x - (icon.width * (icon.scale.x - 1) / 2) - (opponentOffset * 85 * icon.scale.x);
						}
						
					}
					if (icon.isPlayer) {
						icon.health = (healthBar.percent / 100);
						playerOffset++;
					} else {
						icon.health = 1 - (healthBar.percent / 100);
						opponentOffset++;
					}
					icon.y = healthBar.y + (healthBar.height / 2) - (icon.height / 2);
					icon.cameras = [camHUD];
				}
			}
			
		}

		if (health > maxHealth)
			health = maxHealth;

		/*
		for (frameIndex in iconP2.frameIndexes) {
			if (frameIndex.length == 2) {
				if ((100 - healthBar.percent) >= frameIndex[0]) {
					iconP2.animation.curAnim.curFrame = frameIndex[1];
					break;
				}
			}
		}
		*/

		/* if (FlxControls.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxControls.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		Conductor.songPosition += Settings.engineSettings.data.noteOffset;
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= startTime)
					startSong();
			}
		}
		else
		{
			if (Conductor.songPosition < startTime) {
				FlxG.sound.music.time = vocals.time = Conductor.songPosition = startTime;
			}
			if (FlxG.sound.music.time == Conductor.songPositionOld) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				vocalsOffsetInfraction -= elapsed / 3;
				if (vocalsOffsetInfraction < 0) vocalsOffsetInfraction = 0;
			} else {
				// sync
				Conductor.songPosition = Conductor.songPositionOld = FlxG.sound.music.time;
				if (vocals.time != Conductor.songPosition) {
					vocalsOffsetInfraction += elapsed;
					if (vocalsOffsetInfraction > 0.03) { // 30ms of delay
						vocals.time = Conductor.songPosition;
						vocalsOffsetInfraction = 0;
					}
				}
			}
				
			

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
		
		Conductor.songPosition -= Settings.engineSettings.data.noteOffset;

		if (timerText != null) {
			scripts.executeFunc("onPreTimerUpdate", []);
			var pos = Math.max(Conductor.songPosition, 0);
			var timeNow = '${Math.floor(pos / 60000)}:${CoolUtil.addZeros(Std.string(Math.floor(pos / 1000) % 60), 2)}';
			var length = '${Math.floor(inst.length / 60000)}:${CoolUtil.addZeros(Std.string(Math.floor(inst.length / 1000) % 60), 2)}';
			// timerText.text = '${CoolUtil.prettySong(SONG.song)}';
			// timerText.screenCenter(X);
			timerText.x = (guiSize.x / 2) - (timerText.width / 2);
			
			var x = -10 + (timerText.width > timerBG.width ? timerText.x : timerBG.x);
			timerNow.text = timeNow;
			timerNow.x = x - timerNow.width;

			timerFinal.text = length;
			timerFinal.x = 10 + (timerText.width > timerBG.width ? timerText.x + timerText.width: timerBG.x + timerBG.width);

			timerFinal.y = timerBG.y + (timerBG.height / 2) - (timerFinal.height / 2);
			timerNow.y = timerBG.y + (timerBG.height / 2) - (timerNow.height / 2);
			timerText.y = timerBG.y + (timerBG.height / 2) - (timerText.height / 2);
			scripts.executeFunc("onTimerUpdate", []);
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			var sexion = PlayState.SONG.notes[Std.int(curStep / 16)];
			if (sexion.duetCamera == true) {
				if (sexion.duetCameraSlide == null) sexion.duetCameraSlide = 0.5;
				var bfPos = [boyfriend.getMidpoint().x - 100 + boyfriend.camOffset.x, boyfriend.getMidpoint().y - 100 + boyfriend.camOffset.y];
				var dadPos = [dad.getMidpoint().x + 150 + dad.camOffset.x, dad.getMidpoint().y - 100 + dad.camOffset.y];
				camFollow.setPosition((bfPos[0] * sexion.duetCameraSlide) + (dadPos[0] * (1 - sexion.duetCameraSlide)), (bfPos[1] * sexion.duetCameraSlide) + (dadPos[1] * (1 - sexion.duetCameraSlide)));
			} else if (sexion.mustHitSection == true)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + boyfriend.camOffset.x, boyfriend.getMidpoint().y - 100 + boyfriend.camOffset.y);

				if (camFollow.x != boyfriend.getMidpoint().x - 100) {
					if (SONG.song.toLowerCase() == 'tutorial')
					{
						FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
					}
				}
			}
			else
			{
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
			FlxG.camera.zoom = FlxMath.lerp(FlxG.camera.zoom, defaultCamZoom, 0.05 * 60 * elapsed);
			camHUD.zoom = FlxMath.lerp(1 * camHUD.zoom, engineSettings.noteScale, 0.05 * 60 * elapsed);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET && engineSettings.resetButton)
		{
			scripts.executeFunc("onResetButton", []);
			health = -1;
			trace("oh no he died");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			// i dont even know how tf you can trigger this but anyways
			scripts.executeFunc("onCheatButton", []);
			health += 1;
			trace("User is cheating!");
			scripts.executeFunc("onCheatButtonPost", []);
		}

		if (health < 0)
		{
			scripts.executeFunc("onPreDeath");
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			if (FlxG.sound.music != null) FlxG.sound.music.stop();
			scripts.executeFunc("onDeath");

			openSubState(new GameOverSubstate(boyfriend.x - boyfriend.charGlobalOffset.x, boyfriend.y - boyfriend.charGlobalOffset.y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			
			#if desktop
			// Game Over doesn't get his own variable because it's only used here
			DiscordClient.changePresence("Game Over - " + detailsText, '$songMod - ${CoolUtil.prettySong(song.song)} ($storyDifficultyText)', iconRPC);
			#end
			return;
			scripts.executeFunc("onPostDeath");
		}

		while (true && unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			} else {
				break;
			}
		}

		if (inCutscene) {
			(endCutscene ? end_cutscene : cutscene).executeFunc("update", [elapsed]);
		} else {
			scripts.executeFunc("update", [elapsed]);
		}

			if (generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote == null) return;
					
					scripts.executeFunc("onNoteUpdate", [daNote]);
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

					// note velocity had no effect lmfao stop trying to cancel the engine cause of it
					
					if (daNote.tooLate && daNote.mustPress && (!daNote.isSustainNote || daNote.prevSusNote == null || daNote.prevSusNote.isSustainNote || (!daNote.prevSusNote.isSustainNote && !daNote.prevSusNote.wasGoodHit)))
					{
						daNote.script.setVariable("note", daNote);
						daNote.script.executeFunc("onMiss", [daNote.noteData % PlayState.SONG.keyNumber]);
						scripts.executeFunc("onMiss", [daNote]);
						// ModSupport.executeFunc(daNote.script, "onMiss", [Note.noteNumberScheme[daNote.noteData % PlayState.SONG.keyNumber]]);
						// noteMiss((daNote.noteData % _SONG.keyNumber) % SONG.keyNumber);
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
						return;
					}

					var pos:FlxPoint = new FlxPoint(-(daNote.noteOffset.x + ((daNote.isSustainNote ? daNote.width / 2 : 0) * (engineSettings.downscroll ? 1 : -1))),(daNote.noteOffset.y));
					var strum = (daNote.mustPress ? playerStrums.members : cpuStrums.members)[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber];
					if (strum.getAngle() == 0) {

						pos.y = (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(strum.getScrollSpeed(), 2)) + (daNote.noteOffset.y);

						// daNote.velocity.y = (0 - 1000) * (0.45 * FlxMath.roundDecimal(strum.getScrollSpeed(), 2));
					} else {
						pos.x = Math.sin((strum.getAngle() + 180) * Math.PI / 180) * ((Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(strum.getScrollSpeed(), 2)));
						pos.x += Math.sin((strum.getAngle() + (engineSettings.downscroll ? 90 : 270)) * Math.PI / 180) * ((daNote.noteOffset.x));
						pos.y = Math.cos((strum.getAngle()) * Math.PI / 180) * (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(strum.getScrollSpeed(), 2));
						pos.y += Math.cos((strum.getAngle() + (engineSettings.downscroll ? 270 : 90)) * Math.PI / 180) * ((daNote.noteOffset.y));
						// daNote.velocity.y = 0;
					}

					daNote.antialiasing = daNote.antialiasing && engineSettings.noteAntialiasing;
					daNote.alpha = strum.getAlpha() * (daNote.isSustainNote && engineSettings.transparentSubstains ? 0.6 : 1);
					// daNote.cameras = strum.cameras;
					// if (daNote.isLongSustain) {
						// daNote.scale.y = (Note.swagWidth / Note._swagWidth) * (Conductor.stepCrochet / 100 * 1.5 * (strum.getScrollSpeed()));
					// }

					if (engineSettings.downscroll) {
						// daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(engineSettings.customScrollSpeed ? engineSettings.scrollSpeed : SONG.speed, 2)));
						// Code above not modchart proof
						// daNote.velocity.x = -daNote.velocity.x;
						// daNote.velocity.y = -daNote.velocity.y;

						daNote.y = (strum.y + pos.y - (daNote.noteOffset.y * 2));
						if (strum.getAngle() == 0)
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
					daNote.angle = daNote.isSustainNote ? strum.getAngle() : strum.angle;


					if ((!daNote.mustPress || daNote.wasGoodHit) && Conductor.songPosition > daNote.strumTime - (Note.swagWidth / (0.45 * FlxMath.roundDecimal(strum.getScrollSpeed(), 2)) / 2)) {
						var t = FlxMath.bound((Conductor.songPosition - daNote.strumTime) / (daNote.height / (0.45 * FlxMath.roundDecimal(strum.getScrollSpeed(), 2))), 0, 1);
						var swagRect = new FlxRect(0, t * daNote.frameHeight, daNote.frameWidth, daNote.frameHeight);

						daNote.clipRect = swagRect;
					}
					
					if (!daNote.mustPress && daNote.wasGoodHit && (!daNote.isSustainNote || (daNote.isSustainNote && daNote.strumTime + Conductor.stepCrochet < Conductor.songPosition)))
					{
						// if (SONG.song != 'Tutorial')
							camZooming = true;
	
						daNote.script.setVariable("note", daNote);
						scripts.executeFunc("onDadHit", [daNote]);
						try {
							var script = daNote.script;
							daNote.script.executeFunc("onDadHit", [daNote.noteData % PlayState.SONG.keyNumber]);
						} catch(e) {
							trace(e);
						}
						
	
	
						dad.holdTimer = 0;
	
						if (SONG.needsVoices)
							vocals.volume = 1;

						if (engineSettings.glowCPUStrums) {
							var strum = cpuStrums.members[daNote.noteData % _SONG.keyNumber % SONG.keyNumber];
							strum.cpuRemainingGlowTime = Conductor.stepCrochet * 1.5 / 1000;
							if (Std.isOfType(strum.shader, ColoredNoteShader)) cast(strum.shader, ColoredNoteShader).setColors(daNote.splashColor.red, daNote.splashColor.green, daNote.splashColor.blue);
							strum.animation.play("confirm", true);
							strum.centerOffsets();
							strum.centerOrigin();
							strum.toggleColor(strum.colored);
						}
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
							daNote.script.setVariable("note", daNote);
							daNote.script.executeFunc("onMiss", [daNote.noteData % PlayState.SONG.keyNumber]);
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
					
					if (Std.isOfType(daNote.shader, ColoredNoteShader)) {
						var shader = cast(daNote.shader, ColoredNoteShader);
						var baseVal:Float = daNote.pixels.height / 1024;
						var angle:Float = (daNote.isSustainNote ? strum.getAngle() : strum.angle);
						if (angle == 0 || angle == 180) {
							shader.x.value = [0];
							shader.y.value = [baseVal * strum.getScrollSpeed() * engineSettings.noteMotionBlurMultiplier / daNote.scale.y];
						} else {
							var scrollSpeed = baseVal * strum.getScrollSpeed();
							shader.x.value = [Math.sin(angle / 180 * Math.PI) * scrollSpeed * engineSettings.noteMotionBlurMultiplier / ((daNote.scale.x + daNote.scale.y) / 2)];
							shader.y.value = [Math.cos(angle / 180 * Math.PI) * scrollSpeed * engineSettings.noteMotionBlurMultiplier / ((daNote.scale.x + daNote.scale.y) / 2)];
						}
					}
					
					scripts.executeFunc("onNoteUpdate", [daNote]);
				});
			}

			// if (!inCutscene && !blockPlayerInput) {
			// 	keyShit(elapsed);

			// 	for(e in currentSustains) {
			// 		if (e.time + Conductor.stepCrochet > Conductor.songPosition) {
			// 			health += e.healthVal / (Conductor.stepCrochet / 1000) * elapsed;
			// 		} else {
			// 			currentSustains.remove(e);
			// 		}
			// 	}
			// }
				

			
			var noteColors:Array<FlxColor> = boyfriend.getColors();
			for (strum in playerStrums) {
				strum.toggleColor(strum.colored && strum.getAnimName() != "static");
			}

		#if debug
		if (FlxControls.justPressed.ONE)
			endSong();
		#end

		for(e in psychEvents) {
			if (e.time < Conductor.songPosition) {
				// please dont kill me shadowmario literally everyone asked for it
				scripts.executeFunc("onPsychEvent", [e.name, e.value1, e.value2]);
				psychEvents.remove(e);
			}
		}

		for(e in events) {
			if (e.time < Conductor.songPosition) {
				// trace('doing event');
				// trace(e);
				var params:Array<Any> = [];
				for(p in e.parameters) params.push(p);
				scripts.executeFunc(e.name, params);
				scripts.executeFunc("onEvent", [e.name, params]); // for ppl that can't understand and wanna use spaces
				events.remove(e);
			}
		}
		
		while (optimizedTweenSet.length > engineSettings.maxRatingsAllowed && engineSettings.maxRatingsAllowed > -1) {
			var tweens = optimizedTweenSet.shift();
			for(t in tweens) {
				var callbackFunc = t.onComplete;
				t.cancel();
				if (callbackFunc != null) callbackFunc(t);
			}
		}
		
		
		if (inCutscene) {
			(endCutscene ? end_cutscene : cutscene).executeFunc("postUpdate", [elapsed]);
			(endCutscene ? end_cutscene : cutscene).executeFunc("updatePost", [elapsed]);
		} else {
			scripts.executeFunc("postUpdate", [elapsed]);
			scripts.executeFunc("updatePost", [elapsed]);
		}
		
	}

	function endSong():Void
	{
		scripts.executeFunc("onPreEndSong", []);
		canPause = false;
		if (FlxG.sound.music == null) return;
		FlxG.sound.music.volume = 0;
		FlxG.sound.music.pause();
		vocals.volume = 0;
		vocals.pause();
		if (validScore)
		{
			#if !switch
				if (Highscore.saveScore(songMod, SONG.song, songScore, storyDifficulty)) {
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
				}

				
			#end
		}

		endCutscene = true;
		inCutscene = true;
		end_cutscene.executeFunc("create");
		scripts.executeFunc("onPostEndSong", []);
	}

	public function endSong2() {
		if (fromCharter) {
			if (Settings.engineSettings.data.yoshiCrafterEngineCharter)
				FlxG.switchState(new YoshiCrafterCharter());
			else
				FlxG.switchState(new ChartingState_New());
			return;
		}
		if (isStoryMode)
			{
				campaignScore += songScore;
	
				storyPlaylist.remove(storyPlaylist[0]);
	
	
				if (storyPlaylist.length <= 0)
				{
					CoolUtil.playMenuMusic();
	
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
	
					
					// if (cutscene != null) cutscene.executeFunc("onSongEnd");
	
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
		coolText.x = 1280 * 0.55;
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
			if (engineSettings.animateMsLabel) msScoreLabel.offset.y = msScoreLabel.height / 3;
			if (msScoreLabelTween != null) {
				msScoreLabelTween.cancel();
				msScoreLabelTween.destroy();
			}
			msScoreLabel.color = daRating.color;
			msScoreLabel.scale.x = 1;
			msScoreLabel.scale.y = 1;
			msScoreLabelTween = FlxTween.tween(msScoreLabel, {alpha: 0, "scale.x" : 0.8, "scale.y" : 0.8}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					msScoreLabelTween = null;
				},
				startDelay: 0.75
			});
		}

		numberOfNotes++;
		songScore += daRating.score;

		rating.loadGraphic(daRating.bitmap);
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
		if (combo >= 10) add(comboSpr);

		
		comboSpr.scale.set(0.7, 0.7);
		comboSpr.antialiasing = true;
		rating.scale.x = rating.scale.y = daRating.scale * 0.7;

		comboSpr.updateHitbox();
		rating.updateHitbox();

		hits[daRating.name] += 1;

		var tweens:Array<VarTween> = [];

		if (scripts.executeFuncMultiple("onShowCombo", [combo, coolText], [true, null]) != false) {
			var seperatedScore:Array<Int> = [];
			var stringCombo = Std.string(combo);
			for(i in 0...stringCombo.length) {
				seperatedScore.push(Std.parseInt(stringCombo.charAt(i)));
			}

			while(seperatedScore.length < 3) seperatedScore.insert(0, 0);
	
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
	
				tweens.push(FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.002
				}));
	
				daLoop++;
			}
			
			coolText.text = Std.string(seperatedScore);
		}
		
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		// add(coolText);
		tweens.push(FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		}));

		tweens.push(FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		}));

		optimizedTweenSet.push(tweens);

		
		if (engineSettings.animateInfoBar) {
			if (scoreTxtTween != null) {
				scoreTxtTween.cancel();
				scoreTxtTween.destroy();
			}
			// scoreTxt.scale.x = 1.15;
			// scoreTxt.scale.y = 1.5;
			// var nS = ((scoreTxt.height * 1.5) - scoreTxt.width) / scoreTxt.width;
			// trace(nS);

			// var oldOffset = new FlxPoint(scoreTxt.offset.x, scoreTxt.offset.y);
			scoreTxt.setGraphicSize(Std.int((scoreTxt.width / scoreTxt.scale.x) + 100));
			// scoreTxt.scale.x = 1.25;
			// scoreTxt.scale.set(1 + (2 * (scoreTxt.height / scoreTxt.width)), 1.5);

			// scoreTxt.scale.x = nS;
			scoreTxtTween = FlxTween.tween(scoreTxt, {"scale.x" : 1, "scale.y" : 1}, 0.25, {ease : FlxEase.cubeOut, onComplete: function(tween:FlxTween) {
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
	// 		msScoreLabel.scale.x = 1;
	// 		msScoreLabel.scale.y = 1;
	// 		msScoreLabelTween = FlxTween.tween(msScoreLabel, {alpha: 0, "scale.x" : 0.8, "scale.y" : 0.8}, 0.2, {
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
	// 		scoreTxt.scale.x = 1.15;
	// 		scoreTxt.scale.y = 1.15;
	// 		scoreTxtTween = FlxTween.tween(scoreTxt, {"scale.x" : 1, "scale.y" : 1}, 0.25, {ease : FlxEase.cubeOut, onComplete: function(tween:FlxTween) {
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
	public var lastKeys:{pressedArray:Array<Bool>, justPressedArray:Array<Bool>, justReleasedArray:Array<Bool>} = {
		pressedArray: [],
		justPressedArray: [],
		justReleasedArray: []
	};
	public var optimizedTweenSet:Array<Array<VarTween>> = [];
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
		
		// var pressedArray:Array<Bool> = [FlxControls.pressed.W, FlxControls.pressed.X, FlxControls.pressed.C, FlxControls.pressed.NUMPADONE, FlxControls.pressed.NUMPADTWO, FlxControls.pressed.NUMPADTHREE];
		// var justPressedArray:Array<Bool> = [FlxControls.justPressed.W, FlxControls.justPressed.X, FlxControls.justPressed.C, FlxControls.justPressed.NUMPADONE, FlxControls.justPressed.NUMPADTWO, FlxControls.justPressed.NUMPADTHREE];
		// var justReleasedArray:Array<Bool> = [FlxControls.justReleased.W, FlxControls.justReleased.X, FlxControls.justReleased.C, FlxControls.justReleased.NUMPADONE, FlxControls.justReleased.NUMPADTWO, FlxControls.justReleased.NUMPADTHREE];
		var kNum = Std.string(SONG.keyNumber);
		var pressedArray:Array<Bool> = [];
		var justPressedArray:Array<Bool> = [];
		var justReleasedArray:Array<Bool> = [];
		
		scripts.executeFunc("onKeyShit", [pressedArray, justPressedArray, justReleasedArray]);

		lastKeys = {
			justPressedArray: justPressedArray,
			justReleasedArray: justReleasedArray,
			pressedArray: pressedArray
		};
		
		if (!engineSettings.botplay) {
			#if mobile
			justPressedArray = [for (i in 0...SONG.keyNumber) false];
			justReleasedArray = [for (i in 0...SONG.keyNumber) false];
			pressedArray = [for (i in 0...SONG.keyNumber) false];
			for (t in FlxG.touches.list) {
				var id = Math.floor(t.getScreenPosition().x / FlxG.width * SONG.keyNumber);
				justPressedArray[id] = t.justPressed;
				justReleasedArray[id] = t.justReleased;
				pressedArray[id] = t.pressed;
			}
			#else
			for (i in 0...SONG.keyNumber) {
				var key:FlxKey = cast(Reflect.field(engineSettings, 'control_' + kNum + '_$i'), FlxKey);
				pressedArray.push(FlxControls.anyPressed([key])); // Should prob fix this
				justPressedArray.push(FlxControls.anyJustPressed([key])); // Should prob fix this
				justReleasedArray.push(FlxControls.anyJustReleased([key])); // Should prob fix this
			}
			#end
		} else {
			// BOTPLAY CODE
			justPressedArray = [for (i in 0...SONG.keyNumber) false];
			notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.hitOnBotplay && daNote.strumTime < Conductor.songPosition)
					{
						if (daNote.isSustainNote) {
							botplayNoteHitMoment[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] = Math.max(Conductor.songPosition + Conductor.stepCrochet, botplayNoteHitMoment[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber]);
							pressedArray[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] = true; // (Math.abs(daNote.strumTime - Conductor.songPosition) < elapsed * 1000) || 
						} else {
							botplayNoteHitMoment[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] = Math.max(Conductor.songPosition, botplayNoteHitMoment[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber]);
							// botplayHitNotes.push(daNote);
							justPressedArray[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] = true; // (Math.abs(daNote.strumTime - Conductor.songPosition) < elapsed * 1000) || 
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

			var notesToHit:Array<Note> = [for (i in 0...SONG.keyNumber) null];

			var additionalNotesToHit:Array<Note> = [];
			var sus:Array<Bool> = [for (i in 0...SONG.keyNumber) false];
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
				{
					if (daNote.isSustainNote) {
						if (justPressedArray[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber]) {
							sus[daNote.noteData % _SONG.keyNumber] = true;
						}
					} else {
						if (justPressedArray[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] && !daNote.wasGoodHit) {
							var can = false;
							if (notesToHit[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] != null) {
								if (notesToHit[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber].strumTime > daNote.strumTime)
									can = true;
								if (notesToHit[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber].strumTime == daNote.strumTime) {
									additionalNotesToHit.push(daNote);
								}
							} else {
								can = true;
							}
							if (can) notesToHit[(daNote.noteData % _SONG.keyNumber) % SONG.keyNumber] = daNote;
						}
					}
				}
			});
			for (k=>note in notesToHit) {
				if (note == null) {
					if (!engineSettings.ghostTapping) {
						if (justPressedArray[k] && !sus[k]) {
							noteMiss(k);
							health -= tapMissHealth;
						}
					}
				} else {
					goodNoteHit(note);
				}
			}
			for(n in additionalNotesToHit) goodNoteHit(n);
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

		

		
		for (bf in members) {
			if (Std.isOfType(bf, Boyfriend)) {
				var bf2 = cast(bf, Boyfriend);
				if (bf2.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (pressedArray.indexOf(true) == -1 || bf != boyfriend))
				{
					if (bf2.animation.curAnim.name.startsWith('sing') && !bf2.animation.curAnim.name.endsWith('miss'))
					{
						// bf.playAnim('idle');
						bf2.dance();
					}
				}
			}
		}
		
		playerStrums.forEach(function(spr:StrumNote)
		{
			if (spr == null) return;
			if (justPressedArray[spr.ID % SONG.keyNumber] && spr.getAnimName() != 'confirm')
				spr.animation.play('pressed');
			if (justReleasedArray[spr.ID % SONG.keyNumber])
				spr.animation.play('static');
			if (spr.getAnimName() == 'pressed') {
				var customColors = PlayState.current.boyfriend.getColors(false);
				var c = customColors[(spr.ID % (customColors.length - 1)) + 1];
				if (Std.isOfType(spr.shader, ColoredNoteShader)) cast(spr.shader, ColoredNoteShader).setColors(c.red, c.green, c.blue);
			}
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
						if (spr.getAnimName() == 'confirm' && !curStage.startsWith('school'))
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
			numberOfArrowNotes++;
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
						if (rating.showSplashes) {
							spawnSplashOnStrum(note.splashColor, note.splash, note.noteData, 0);
						}
					}
				} else {
					// smooth
					currentSustains.push({
						time: note.strumTime,
						healthVal: note.sustainHealth
					});
				}
			}

			// if (note.noteData >= 0)
			// 	health += 0.023;
			// else
			// 	health += 0.004;

			note.script.setVariable("note", note);
			note.script.executeFunc("onPlayerHit", [note.noteData % PlayState.SONG.keyNumber]);
			scripts.executeFunc("onPlayerHit", [note]);

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs((note.noteData % _SONG.keyNumber) % SONG.keyNumber) == spr.ID)
				{
					if (Std.isOfType(spr.shader, ColoredNoteShader)) cast(spr.shader, ColoredNoteShader).setColors(note.splashColor.red, note.splashColor.green, note.splashColor.blue);
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;
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
		scripts.executeFunc("stepHit", [curStep]);
		
		super.stepHit();
		// songEvents.stepHit(curStep);

		Conductor.songPosition += Settings.engineSettings.data.noteOffset;
		if (FlxG.sound.music != null && !startingSong && startedCountdown) {
			if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			{
				if (Conductor.songPosition > startTime && FlxG.sound.music.time > startTime) resyncVocals();
			}
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
		

		Conductor.songPosition -= Settings.engineSettings.data.noteOffset;
	}

	override function beatHit()
	{
		super.beatHit();
		scripts.executeFunc("beatHit", [curBeat]);
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
			
			
			for (d in members) {
				if (Std.isOfType(d, Character) && !Std.isOfType(d, Boyfriend) && d != gf) {
					cast(d, Character).dance();
				}
			}
			// if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			// 	dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (camZooming)
		{
			if (autoCamZooming && curBeat % 4 == 0) {
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		// iconP1.scale.x = iconP2.scale.x = iconP1.scale.y = iconP2.scale.y = 1.2;

		// iconP1.updateHitbox();
		// iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		for (bf2 in members) {
			if (Std.isOfType(bf2, Boyfriend)) {
				var bf = cast(bf2, Boyfriend);
				if (bf == null) continue;
				if (bf.animation.curAnim == null) continue;
				if (!bf.animation.curAnim.name.startsWith("sing"))
				{
					// bf.playAnim('idle');
					bf.dance();
				}
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