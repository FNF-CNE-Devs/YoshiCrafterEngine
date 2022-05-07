package;

import haxe.io.Input;
import haxe.io.Eof;
import haxe.io.BytesBuffer;
import openfl.text.TextFormat;
import lime.ui.Window;
import sys.io.Process;
import lime.system.System;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import lime.utils.Log;
import haxe.CallStack;
import openfl.events.ErrorEvent;
import haxe.Exception;
import openfl.errors.Error;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import flixel.FlxGame;
import flixel.FlxState;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.display.FPS;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets
	public static var logsOverlay:LogsOverlay;

	public static function readLine(buff:Input, l:Int):String {
		var line:Int = 0;
		while(true) {
			var buf = new BytesBuffer();
			var last:Int = 0;
			var s = "";

			trace(line);
			// try {
				while ((last = buff.readByte()) != 10)
					buf.addByte(last);
				s = buf.getBytes().toString();
				if (s.charCodeAt(s.length - 1) == 13)
					s = s.substr(0, -1);
				if (line >= l) {
					return s;
				} else {
					line++;
				}
			// } catch (e:Eof) {
			// 	s = buf.getBytes().toString();
			// 	if (s.length == 0)
			// 		#if neko neko.Lib.rethrow #else throw #end (e);
			// 	break;
			// }
		}
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
	public static var engineVer:String = "1.9.1";
	public static var buildVer:String = "";
	public static var fps:GameStats;

	public static var supportedFileTypes = [
		#if ENABLE_LUA "lua", #end
		"hx",
		"hscript",
		"hsc"];


	// You can pretty much ignore everything from here on - your code should go in your states.
	// HAHA no.

	public static function main():Void
	{
		var args = Sys.args();
		if (args.contains('update')) {
			// copy
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
							Application.current.window.alert('Could not copy $path/$f, press OK to skip.', 'Error');
						}
					}
				}
			}
			copyFolder('./_cache', '.');
			CoolUtil.deleteFolder('./_cache/');
			FileSystem.deleteDirectory('./_cache/');
			new Process('start /B YoshiCrafterEngine.exe', null);
			System.exit(0);
		} else {
			try {
				// in case to prevent crashes
				if (FileSystem.exists("temp.exe")) FileSystem.deleteFile('temp.exe');
			} catch(e) {

			}
			try {
				// in case to prevent crashes
				if (FileSystem.exists("YoshiEngine.exe")) FileSystem.deleteFile('YoshiEngine.exe');
			} catch(e) {

			}
			#if cpp
			cpp.Lib.print("main");
			Lib.current.addChild(new Main());
			#else
			trace("main");
			Lib.current.addChild(new Main());
			#end
		}

		getMemoryAmount();
	}

	public function new()
	{
		super();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(e:UncaughtErrorEvent) {
			var m:String = e.error;
			if (Std.isOfType(e.error, Error)) {
				var err = cast(e.error, Error);
				m = '${err.message}';
			} else if (Std.isOfType(e.error, ErrorEvent)) {
				var err = cast(e.error, ErrorEvent);
				m = '${err.text}';
			}
			m += '\r\n ${CallStack.toString(CallStack.exceptionStack())}';
			trace('An error occured !\r\nYoshiCrafter Engine ver. ${engineVer} $buildVer\r\n\r\n${m}\r\n\r\nThe engine is still in it\'s early stages, so if you want to report that bug, go ahead and create an Issue on the GitHub page !');
 			Application.current.window.alert('An error occured !\r\nYoshiCrafter Engine ver. ${engineVer} $buildVer\r\n\r\n${m}\r\n\r\nThe engine is still in it\'s early stages, so if you want to report that bug, go ahead and create an Issue on the GitHub page !', e.error);
			e.stopPropagation();
			e.stopImmediatePropagation();
		});

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
		lime.utils.Log.throwErrors = false;
		stage.window.onDropFile.add(function(path:String) {
			if (Std.isOfType(FlxG.state, MusicBeatState)) {
				var checkSubstate:FlxState->Void = function(state) {
					if (Std.isOfType(state, MusicBeatState)) {
						var state = cast(state, MusicBeatState);
						if (Std.isOfType(state.subState, MusicBeatSubstate)) {
		
						} else {
							state.onDropFile(path);
						}
					} else if (Std.isOfType(state, MusicBeatSubstate)) {
						var state = cast(state, MusicBeatSubstate);
						if (Std.isOfType(state.subState, MusicBeatSubstate)) {
		
						} else {
							state.onDropFile(path);
						}
					}
				};
				var state = cast(FlxG.state, MusicBeatState);
				checkSubstate(state);
			}
		});
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
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

		addChild(new FlxGame(gameWidth, gameHeight, initialState, zoom, framerate, framerate, skipSplash, startFullscreen));

		
		#if !mobile
		fps = new GameStats(10, 3, 0xFFFFFF);

		logsOverlay = new LogsOverlay();
		// fps.setTextFormat(new TextFormat(Assets.getFont(Paths.font("vcr.ttf")).fontName, 12, 0xFFFFFFFF, false, false, false, null, null, null, null, null, null, null));

		addChild(fps);
		addChild(logsOverlay);
		#end
	}
}
