package;

import mod_support_stuff.InstallModScreen;
import logging.LogsOverlay;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import WindowsAPI.ConsoleColor;
import flixel.system.debug.log.LogStyle;
import haxe.io.Input;
import haxe.io.BytesBuffer;
import openfl.text.TextFormat;
import sys.io.Process;
import lime.system.System;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import haxe.Exception;
import flixel.FlxState;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

using StringTools;

// *makes a fnf engine*
// Why is it taking so long?
// I should have been famous a minute ago.

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var baseTrace = haxe.Log.trace;

	public static var logsOverlay:LogsOverlay;

	public static function readLine(buff:Input, l:Int):String {
		var line:Int = 0;
		var fuck = 0;
		while(fuck < l + 1) {
			var buf = new BytesBuffer();
			var last:Int = 0;
			var s = "";

			trace(line);
			while ((last = buff.readByte()) != 10) {
				buf.addByte(last);
			}
			s = buf.getBytes().toString();
			if (s.charCodeAt(s.length - 1) == 13)
				s = s.substr(0, -1);
			if (line >= l) {
				return s;
			} else {
				line++;
			}
		}
		return "";
	}

	public static function getMemoryAmount():Float {
		#if windows
			try {
				var process = new Process('wmic ComputerSystem get TotalPhysicalMemory').stdout;
				var amount:Float = Std.parseFloat(readLine(process, 1));
				return amount;
			} catch(e) {
				return Math.pow(2, 32);
			}
		#else 
			return Math.pow(2, 32); // 4gb
		#end
	}
	// YOSHI ENGINE STUFF
	public static var engineVer:String = "2.3.1";
	public static var buildVer:String = #if ycebeta "BETA" #elseif official "" #else "Custom Build" #end;
	public static var fps:GameStats;

	public static var supportedFileTypes = [
		#if ENABLE_LUA "lua", #end
		"hhx",
		"hx",
		"hscript",
		"hsc"];


	// You can pretty much ignore everything from here on - your code should go in your states.
	// HAHA no.

	public static function main():Void
	{
		#if !YOSHMAN_FLIXEL
		#error "You need to use YoshiCrafter29's flixel fork in order to build this project.\nRun config.bat or type this in cmd -> haxelib git flixel-yc29 https://github.com/YoshiCrafter29/flixel.\nIf it's installed and this error still appears, please update it."
		#end
		flixel.system.frontEnds.LogFrontEnd.onLogs = function(Data, Style, FireOnce) {
			if (CoolUtil.isDevMode()) {
				var prefix = "[FLIXEL]";
				var color:ConsoleColor = WHITE;
				if (Style == LogStyle.CONSOLE)  {prefix = "> ";					color = WHITE;	}
				if (Style == LogStyle.ERROR)    {prefix = "[FLIXEL ERROR]";		color = RED;	}
				if (Style == LogStyle.NORMAL)   {prefix = "[FLIXEL]";			color = WHITE;	}
				if (Style == LogStyle.NOTICE)   {prefix = "[FLIXEL NOTICE]";	color = GREEN;	}
				if (Style == LogStyle.WARNING)  {prefix = "[FLIXEL WARNING]";	color = YELLOW;	}

				var d:Dynamic = Data;
				if (!(d is Array))
					d = [d];
				var a:Array<Dynamic> = d;
				var strs = [for(e in a) Std.string(e)];
				for(e in strs) {
					(Style == LogStyle.ERROR ? LogsOverlay.error : LogsOverlay.trace)('$prefix $e', color);
				}
			}
		};
		
		var args = [for (arg in Sys.args()) if (arg.startsWith("/")) '-${arg.substr(1)}' else arg];
		
		if (!parseArgs(args)) {
			System.exit(0);
			return;
		}

		// UPDATE PROCESS
		if (args.contains('update')) {
			var copyFolder:String->String->Void = null;
			copyFolder = function(path, destPath) {
				FileSystem.createDirectory(path);
				FileSystem.createDirectory(destPath);
				for (f in FileSystem.readDirectory(path)) {
					if (FileSystem.isDirectory('$path/$f')) {
						copyFolder('$path/$f', '$destPath/$f');
					} else {
						try {
							File.copy('$path/$f', '$destPath/$f');
						} catch(e) {
							HeaderCompilationBypass.showMessagePopup('Could not copy $path/$f, press OK to skip.', 'Error', MSG_ERROR);
						}
					}
				}
			}
			copyFolder('./_cache', '.');
			CoolUtil.deleteFolder('./_cache/');
			FileSystem.deleteDirectory('./_cache/');
			new Process('start /B YoshiCrafterEngine.exe', null);
			System.exit(0);
			return;
		}
		
		try {
			// in case to prevent crashes
			if (FileSystem.exists("temp.exe")) FileSystem.deleteFile('temp.exe');
		} catch(e) {}
		try {
			if (FileSystem.exists("YoshiEngine.exe")) FileSystem.deleteFile('YoshiEngine.exe');
		} catch(e) {}

		#if cpp
		trace("main");
		Lib.current.addChild(new Main());
		#else
		Lib.current.addChild(new Main());
		#end
	}

	public static function fixWorkingDirectory() {
		var curDir = Sys.getCwd();
		var execPath = Sys.programPath();
		var p = execPath.replace("\\", "/").split("/");
		var execName = p.pop(); // interesting
		Sys.setCwd(p.join("\\") + "\\");

		HeaderCompilationBypass.enableVisualStyles();
	}

	public static final commandPromptArgs:Array<String> = [
		"",
		"YoshiCrafter Engine - Command Prompt arguments",
		"",
		"-help / -? - Show this help",
		"-mod <mod> - Start the engine with a specific mod",
		"-install-mod <path> - Opens the \"Install Mod\" wizard and installs the mod(s) at the selected path (.ycemod file, must be absolute)",
		"-forcedevmode - Forces developer mode, even if the mod is locked"
	];

	public static function parseArgs(args:Array<String>) {
		var i:Int = 0;
		while(i < args.length) {
			var a = args[i].toLowerCase();
			switch(a) {
				case "-mod":
					i++;
					TitleState.startMod = args[i];
				case "-install-mod":
					i++;
					InstallModScreen.path = args[i];
				case "-?" | "-help":
					trace(commandPromptArgs.join("\n"));
					return false;
				case "-forcedevmode" | "-livereload": // livereload cause its the argument sent after compilation
					ModSupport.forceDevMode = true;
				default:
					trace('Unknown arg: ${a}');
			}
			i++;
		}
		return true;
	}

	public function new()
	{
		super();

		#if !noHandler
		ErrorHandler.assignErrorHandler();
		#end

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		stage.window.onDropFile.add(function(path:String) {
			if (Std.isOfType(FlxG.state, MusicBeatState)) {
				var checkSubstate:FlxState->Void = function(state) {
					if (Std.isOfType(state, MusicBeatState)) {
						var state = cast(state, MusicBeatState);
						if (!Std.isOfType(state.subState, MusicBeatSubstate))
							state.onDropFile(path);
					} else if (Std.isOfType(state, MusicBeatSubstate)) {
						var state = cast(state, MusicBeatSubstate);
						if (!Std.isOfType(state.subState, MusicBeatSubstate))
							state.onDropFile(path);
					}
				};
				var state = cast(FlxG.state, MusicBeatState);
				checkSubstate(state);
			}
		});
		if (hasEventListener(Event.ADDED_TO_STAGE)) removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();

		addEventListener(KeyboardEvent.KEY_DOWN, function(e:KeyboardEvent) {
			switch(e.keyCode) {
				case Keyboard.F11:
					FlxG.fullscreen = !FlxG.fullscreen;
			}
		});
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		#if !debug
			initialState = TitleState;
		#end
		initialState = LoadingScreen;
		#if clipRectTest
		initialState = ClipRectTest;
		#end
		#if mod_test
		initialState = ModTest;
		#end
		#if animate_test
		initialState = AnimateTest;
		#end
		#if lua_test
		initialState = LuaTest;
		#end
		#if android_input_test
		initialState = AndroidInputTest;
		#end

		addChild(new FnfGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		
		fps = new GameStats(10, 3, 0xFFFFFF);

		logsOverlay = new LogsOverlay();

		addChild(fps);
		addChild(logsOverlay);
	}
}
