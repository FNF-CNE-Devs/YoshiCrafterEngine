
import openfl.display.StageQuality;
import flixel.text.FlxText;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

@:keep class SuperCoolSettings {
	// Left arrow color
	@:keep public static var arrowColor0:Int = 0xFFC24B99;

	// Down arrow color
	@:keep public static var arrowColor1:Int = 0xFF00FFFF;

	// Up arrow color
	@:keep public static var arrowColor2:Int = 0xFF12FA05;

	// Right arrow color
	@:keep public static var arrowColor3:Int = 0xFFF9393F;

	// Whenever the engine will apply your arrow colors to every character, or only you.
	@:keep public static var customArrowColors_allChars:Bool = false;

	// If true, will enable arrow colors;
	@:keep public static var customArrowColors:Bool = true;

	// Unused for now
	@:keep public static var smoothHealthbar:Bool = true;

	// If true, will set camHUD's bgColor to #FF00FF00
	@:keep public static var greenScreenMode:Bool = false;

	// If true, will show rating in the bottom score bar.
	@:keep public static var showRating:Bool = true;

	// If true, will show player's press delay above the strums.
	@:keep public static var showPressDelay:Bool = true;

	// If true, will do the little bumping animation on the press delay label above the strums.
	@:keep public static var animateMsLabel:Bool = true;

	// If true, will show player's average delay in the info bar. (Average: 15ms)
	@:keep public static var showAverageDelay:Bool = true;

	// If true, will show player's accuracy in the info bar. (Accuracy: 100%)
	@:keep public static var showAccuracy:Bool = true;

	// If true, will show player's misses in the info bar. (Misses: 2)
	@:keep public static var showMisses:Bool = true;

	// If true, will make sustains arrows transparent. Currently doesn't work with custom arrow colors.
	// don't mind the spelling mistake lmao
	@:keep public static var transparentSubstains:Bool = true;

	// If true, the info bar will do an animation whenever you hit a note.
	@:keep public static var animateInfoBar:Bool = true;
	
	// If true, player's custom scroll speed will be used instead of the chart's scroll speed.
	@:keep public static var customScrollSpeed:Bool = false;
	
	// Self explanatory
	@:keep public static var ghostTapping:Bool = true;
	
	// Player's custom scroll speed
	@:keep public static var scrollSpeed:Float = 2.5;
	
	// If true, will show the timer at the top of the screen.
	@:keep public static var showTimer:Bool = true;
	
	// If true, will show the timer at the top of the screen.
	@:keep public static var watermark:Bool = false;
	
	// Player's custom arrow skin. Set to "default" to disable it.
	@:keep public static var customArrowSkin:String = "default";
	
	// If true, downscroll is enabled.
	// Setting this in the middle of a song wont change the strums position.
	// Use PlayState.setDownscroll(true, true) to enable downscroll and reposition the strums.
	@:keep public static var downscroll:Bool = false;
	
	// If true, middlescroll is enabled. Doesn't have an effect after the song started.
	@:keep public static var middleScroll:Bool = false;
	
	
	// Current accuracy mode.
	// 0 : Complex (C)
	// 1 : Simple (S)
	@:keep public static var accuracyMode:Int = 1;
	
	// Player's custom Boyfriend skin. Set to "default" to disable it.
	@:keep public static var customBFSkin:String = "default";
	
	// Player's custom Girlfriend skin. Set to "default" to disable it.
	@:keep public static var customGFSkin:String = "default";
	
	// If true, botplay is on. Can be enabled mid song without disabling saving score.
	@:keep public static var botplay:Bool = false;
	
	// If true, video will have an antialiasing effect applied.
	@:keep public static var videoAntialiasing:Bool = true;
	
	// If true, player will be able to press R to reset.
	@:keep public static var resetButton:Bool = true;
	
	// Note offset
	@:keep public static var noteOffset:Float = 0;

	// Enable Motion Blur on notes.
	@:keep public static var noteMotionBlurEnabled:Bool = false;

	// Note motion blur multiplier
	@:keep public static var noteMotionBlurMultiplier:Float = 1;

	// Center the strums instead of keeping them like the original game.
	@:keep public static var centerStrums:Bool = true;

	
	// If true, will show the ratings at the bottom left of the screen like this :
	// Sick: 0
	// Good: 0
	// Bad: 0
	// Shit: 0
	@:keep public static var showRatingTotal:Bool = false;

	// Whenever the score text is minimized, check options for more info
	@:keep public static var minimizedMode:Bool = false;


	// If true, will glow CPU strums like the player's strums when they press a note.
	@:keep public static var glowCPUStrums:Bool = true;

	// If false, will disable antialiasing on notes.
	#if android
	@:keep public static var noteAntialiasing:Bool = false;
	#else
	@:keep public static var noteAntialiasing:Bool = true;
	#end
	
	// String that separates, for example, Accuracy: 100% from Misses: 0
	@:keep public static var scoreJoinString:String = " | ";

	// Score text size, use scoreTxt.size instead of this, since it only applies at start
	@:keep public static var scoreTextSize:Int = 18; // ayyyy
	
	/**
	 * Sets the GUI scale. Defaults to 1
	 */
	 @:keep public static var noteScale:Float = 1;


	
	// USELESS IN SCRIPTS
	@:keep public static var antialiasing:Bool = true;
	@:keep public static var autopause:Bool = true;
	@:keep public static var autoplayInFreeplay:Bool = false;
	@:keep public static var freeplayCooldown:Float = 2;
	@:keep public static var fpsCap:Int = 120;
	@:keep public static var emptySkinCache:Bool = false;
	@:keep public static var rainbowNotes:Bool = false; //Unused
	@:keep public static var memoryOptimization:Bool = true;
	@:keep public static var blammedEffect:Bool = true;
	@:keep public static var yoshiEngineCharter:Bool = true;
	@:keep public static var developerMode:Bool = false;
	@:keep public static var hideOriginalGame:Bool = false;
	@:keep public static var showAccuracyMode:Bool = false;
	@:keep public static var lastSelectedSong:String = "Friday Night Funkin':tutorial";
	@:keep public static var lastSelectedSongDifficulty:Int = 1; // Normal
	@:keep public static var charEditor_showDadAndBF:Bool = true;
	@:keep public static var combineNoteTypes:Bool = true;
	@:keep public static var selectedMod:String = "Friday Night Funkin'"; // for ui stuff
	@:keep public static var freeplayShowAll:Bool = false;
	@:keep public static var autoSwitchToLastInstalledMod:Bool = true;
	@:keep public static var stageQuality:StageQuality = HIGH;
	@:keep public static var alwaysCheckForMods:Bool = true;
	@:keep public static var fps_showFPS:Bool = true;
	@:keep public static var fps_showMemory:Bool = true;
	@:keep public static var fps_showMemoryPeak:Bool = true;
	@:keep public static var charter_showStrums:Bool = true;
	@:keep public static var charter_hitsoundsEnabled:Bool = false;
	@:keep public static var charter_topView:Bool = false;
	@:keep public static var lastInstalledMods:Array<String> = ["Friday Night Funkin'", "YoshiEngine"];
	
	// @:keep public static var moveCameraInStageEditor:Bool = true;

	// ========================================================
	// PER KEY SET CONTROLS
	// SYNTAX = control_(NUMBER OF KEYS)_(NOTE INDEX)
	//
	// IF YOU'RE ADDING NEW KEYS SHIT, ADD DEFAULT VALUES HERE, OR IN THE MODCHART, OR THE GAME ISNT GOING TO LIKE IT THAT MUCH.
	// CHECK : https://api.haxeflixel.com/flixel/input/keyboard/FlxKey.html
	//
	@:keep public static var control_1_0:FlxKey = FlxKey.UP;

	@:keep public static var control_2_0:FlxKey = FlxKey.LEFT;
	@:keep public static var control_2_1:FlxKey = FlxKey.RIGHT;

	@:keep public static var control_3_0:FlxKey = FlxKey.LEFT;
	@:keep public static var control_3_1:FlxKey = FlxKey.UP;
	@:keep public static var control_3_2:FlxKey = FlxKey.RIGHT;

	@:keep public static var control_4_0:FlxKey = FlxKey.LEFT;
	@:keep public static var control_4_1:FlxKey = FlxKey.DOWN;
	@:keep public static var control_4_2:FlxKey = FlxKey.UP;
	@:keep public static var control_4_3:FlxKey = FlxKey.RIGHT;

	@:keep public static var control_5_0:FlxKey = FlxKey.LEFT;
	@:keep public static var control_5_1:FlxKey = FlxKey.DOWN;
	@:keep public static var control_5_2:FlxKey = FlxKey.SPACE;
	@:keep public static var control_5_3:FlxKey = FlxKey.UP;
	@:keep public static var control_5_4:FlxKey = FlxKey.RIGHT;

	@:keep public static var control_6_0:FlxKey = FlxKey.S;
	@:keep public static var control_6_1:FlxKey = FlxKey.D;
	@:keep public static var control_6_2:FlxKey = FlxKey.F;
	@:keep public static var control_6_3:FlxKey = FlxKey.J;
	@:keep public static var control_6_4:FlxKey = FlxKey.K;
	@:keep public static var control_6_5:FlxKey = FlxKey.L;

	@:keep public static var control_7_0:FlxKey = FlxKey.S;
	@:keep public static var control_7_1:FlxKey = FlxKey.D;
	@:keep public static var control_7_2:FlxKey = FlxKey.F;
	@:keep public static var control_7_3:FlxKey = FlxKey.SPACE;
	@:keep public static var control_7_4:FlxKey = FlxKey.J;
	@:keep public static var control_7_5:FlxKey = FlxKey.K;
	@:keep public static var control_7_6:FlxKey = FlxKey.L;

	@:keep public static var control_8_0:FlxKey = FlxKey.A;
	@:keep public static var control_8_1:FlxKey = FlxKey.S;
	@:keep public static var control_8_2:FlxKey = FlxKey.D;
	@:keep public static var control_8_3:FlxKey = FlxKey.F;
	@:keep public static var control_8_4:FlxKey = FlxKey.H;
	@:keep public static var control_8_5:FlxKey = FlxKey.J;
	@:keep public static var control_8_6:FlxKey = FlxKey.K;
	@:keep public static var control_8_7:FlxKey = FlxKey.L;

	@:keep public static var control_9_0:FlxKey = FlxKey.A;
	@:keep public static var control_9_1:FlxKey = FlxKey.S;
	@:keep public static var control_9_2:FlxKey = FlxKey.D;
	@:keep public static var control_9_3:FlxKey = FlxKey.F;
	@:keep public static var control_9_4:FlxKey = FlxKey.SPACE;
	@:keep public static var control_9_5:FlxKey = FlxKey.H;
	@:keep public static var control_9_6:FlxKey = FlxKey.J;
	@:keep public static var control_9_7:FlxKey = FlxKey.K;
	@:keep public static var control_9_8:FlxKey = FlxKey.L;
	// ========================================================
}

class Settings {
	@:keep public static var save_bind_name:String = "Save";
	@:keep public static var save_bind_path:String = "";




	/**
	 * `FlxSave` that contains all of the engine settings.
	 */
	@:keep public static var engineSettings:FlxSave;

	


	// public static function save(bind:Bool = true) {
	// 	if (bind) FlxG.save.bind("Settings", "YoshiCrafter29/Yoshi Engine");

	// 	for(k in Type.getClassFields(Settings)) {
	// 		if (k != "save_bind_name" && k != "save_bind_path") {
	// 			std.Reflect.setField(config, k, std.Reflect.field(Settings, k));
	// 		}
	// 	}

	// 	if (bind) FlxG.save.bind(save_bind_name, save_bind_path);
	// }

		/**
	 * Load the engine's settings. Use `EngineSettings` in your modcharts to get access to values
	 */
    public static function loadDefault() {
		engineSettings = new FlxSave();

		engineSettings.bind("Settings");
		for(k in Type.getClassFields(SuperCoolSettings)) {
			var ogVal:Dynamic = std.Reflect.field(engineSettings.data, k);
			if (ogVal == null) {
				std.Reflect.setField(engineSettings.data, k, std.Reflect.field(SuperCoolSettings, k));
				
			}
			// var thingy:Dynamic = std.Reflect.field(engineSettings, k);
			// if (thingy == null) {
			// 	std.Reflect.setField(Settings, k, thingy);
			// }
		}
		engineSettings.flush();
		
		hscriptCache = new FlxSave();
		hscriptCache.bind("_hscriptCache");
		
		hscriptCache.flush();
    }
	
	public static var hscriptCache:FlxSave = null;

    // public static function load(bind:Bool = true) {
	// 	if (bind) FlxG.save.bind("Settings", "YoshiCrafter29/Yoshi Engine");

	// 	for(k in Type.getClassFields(Settings)) {
	// 		if (k != "save_bind_name" && k != "save_bind_path") {
	// 			var thingy:Dynamic = std.Reflect.field(config, k);
	// 			if (thingy != null) {
	// 				std.Reflect.setField(Settings, k, thingy);
	// 			}
	// 		}
	// 	}
		
	// 	if (bind) FlxG.save.bind(save_bind_name, save_bind_path);
    // }
}