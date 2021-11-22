// import flixel.util.FlxSave;
// import flixel.FlxG;

// class Settings {
// 	public static var config:FlxSave;
// 	public static var save_bind_name:String;
// 	public static var save_bind_path:String;

//     public static function configure() {
// 		config = new FlxSave();
// 		config.bind("Settings", "YoshiCrafter29/Yoshi Engine");

// 		if (config.blammedEffect == null)
// 			config.blammedEffect = true;
		
// 		if (config.memoryOptimization == null)
// 			config.memoryOptimization = true;

// 		if (config.textQualityLevel == null)
// 			config.textQualityLevel = 1;
		
// 		if (config.customGFSkin == null)
// 			config.customGFSkin = "default";

// 		if (config.customBFSkin == null)
// 			config.customBFSkin = "default";

// 		if (config.accuracyMode == null)
// 			config.accuracyMode = 0;

// 		if (config.downscroll == null)
// 			config.downscroll = false;

// 		if (config.rainbowNotes == null)
// 			config.rainbowNotes = false;

// 		if (config.emptySkinCache == null)
// 			config.emptySkinCache = true;

// 		if (config.customArrowSkin == null)
// 			config.customArrowSkin = "default";

// 		if (config.scrollSpeed == null)
// 			config.scrollSpeed = 2.5;

// 		if (config.customScrollSpeed == null)
// 			config.customScrollSpeed = false;

// 		if (config.animateInfoBar == null)
// 			config.animateInfoBar = true;

// 		if (config.transparentSubstains == null)
// 			config.transparentSubstains = true;

// 		if (config.showMisses == null)
// 			config.showMisses = true;

// 		if (config.showAccuracy == null)
// 			config.showAccuracy = true;

// 		if (config.showAverageDelay == null)
// 			config.showAverageDelay = false;

// 		if (config.showPressDelay == null)
// 			config.showPressDelay = true;

// 		if (config.showRating == null)
// 			config.showRating = true;

// 		if (config.greenScreenMode == null)
// 			config.greenScreenMode = false;

// 		if (config.smoothHealthbar == null)
// 			config.smoothHealthbar = true;

// 		if (config.customArrowColors == null)
// 			config.customArrowColors = false;

// 		if (config.customArrowColors_allChars == null)
// 			config.customArrowColors_allChars = false;

// 		if (config.arrowColor0 == null)
// 			config.arrowColor0 = 0xFFC24B99;

// 		if (config.arrowColor1 == null)
// 			config.arrowColor1 = 0xFF00FFFF;

// 		if (config.arrowColor2 == null)
// 			config.arrowColor2 = 0xFF12FA05;

// 		if (config.arrowColor3 == null)
// 			config.arrowColor3 = 0xFFF9393F;
//     }
// }



// import std.Reflect;
import flixel.text.FlxText;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

class Settings {
	/**
	* Save bind name.
	* The file will be located in `%AppData%\save_bind_path\save_bind_name.sol`
	*/
	@:keep public static var save_bind_name:String = "Save";
	/**
	* Save bind location.
	* The file will be located in `%AppData%\save_bind_path\save_bind_name.sol`
	*/
	@:keep public static var save_bind_path:String = "YoshiCrafter29/Yoshi Engine";

	/**
	 * `FlxSave` that contains all of the engine settings.
	 */
	@:keep public static var engineSettings:FlxSave;

	@:keep public static var arrowColor0:Int = 0xFFC24B99;
	@:keep public static var arrowColor1:Int = 0xFF00FFFF;
	@:keep public static var arrowColor2:Int = 0xFF12FA05;
	@:keep public static var arrowColor3:Int = 0xFFF9393F;
	@:keep public static var customArrowColors_allChars:Bool = false;
	@:keep public static var customArrowColors:Bool = false;
	@:keep public static var smoothHealthbar:Bool = true;
	@:keep public static var greenScreenMode:Bool = false;
	@:keep public static var showRating:Bool = true;
	@:keep public static var showPressDelay:Bool = true;
	@:keep public static var showAverageDelay:Bool = true;
	@:keep public static var showAccuracy:Bool = true;
	@:keep public static var showMisses:Bool = true;
	@:keep public static var transparentSubstains:Bool = true;
	@:keep public static var animateInfoBar:Bool = true;
	@:keep public static var customScrollSpeed:Bool = false;
	@:keep public static var scrollSpeed:Float = 2.5;
	@:keep public static var customArrowSkin:String = "default";
	@:keep public static var emptySkinCache:Bool = false;
	@:keep public static var rainbowNotes:Bool = false; //Unused
	@:keep public static var downscroll:Bool = false;
	@:keep public static var accuracyMode:Int = 0;
	@:keep public static var customBFSkin:String = "default";
	@:keep public static var customGFSkin:String = "default";
	@:keep public static var textQualityLevel:Int = 1;
	@:keep public static var memoryOptimization:Bool = true;
	@:keep public static var blammedEffect:Bool = true;
	@:keep public static var control_LEFT:FlxKey = FlxKey.LEFT;
	@:keep public static var control_LEFT_alt:FlxKey = FlxKey.A;
	@:keep public static var control_UP:FlxKey = FlxKey.UP;
	@:keep public static var control_UP_alt:FlxKey = FlxKey.W;
	@:keep public static var control_DOWN:FlxKey = FlxKey.DOWN;
	@:keep public static var control_DOWN_alt:FlxKey = FlxKey.S;
	@:keep public static var control_RIGHT:FlxKey = FlxKey.RIGHT;
	@:keep public static var control_RIGHT_alt:FlxKey = FlxKey.D;
	@:keep public static var noteScale:Float = 1;

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
	 * Load the engine's settings. Use `engineSettings.data` to get access to values
	 */
    public static function loadDefault() {
		engineSettings = new FlxSave();
		#if sys
			engineSettings.bind("Settings", "../../YoshiCrafter29/Yoshi Engine"); // Not sure about this but it should work
		#else
			engineSettings.bind("Settings", "YoshiCrafter29/Yoshi Engine");
		#end

		for(k in Type.getClassFields(Settings)) {
			var bannedEntries:Array<String> = ["save_bind_name", "save_bind_path", "engineSettings", "loadDefault"];
			if (!bannedEntries.contains(k)) {
				var ogVal:Dynamic = std.Reflect.field(engineSettings.data, k);
				if (ogVal == null) {
					std.Reflect.setField(engineSettings.data, k, std.Reflect.field(Settings, k));
					
				}
				// var thingy:Dynamic = std.Reflect.field(engineSettings, k);
				// if (thingy == null) {
				// 	std.Reflect.setField(Settings, k, thingy);
				// }
			}
		}
		engineSettings.flush();
    }

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