package ;
import openfl.events.IOErrorEvent;
import openfl.events.ErrorEvent;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import openfl.system.System;
import sys.io.Process;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import sys.Http;
import cpp.vm.Thread;
import flixel.ui.FlxBar;
import flixel.FlxG;
import openfl.net.URLLoader;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLStream;
import openfl.net.URLRequest;
import openfl.utils.ByteArray;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

using StringTools;
/**
 * ...
 * @author YoshiCrafter29
 */
class UpdateState extends MusicBeatState
{
	public var fileList:Array<String> = [];
	public var baseURL:String;
	public var downloadedFiles:Int = 0;
	public var percentLabel:FlxText;
	public var currentFileLabel:FlxText;
	public var totalFiles:Int = 0;

	var error:Bool = false;
	public function new(baseURL:String = "http://raw.githubusercontent.com/YoshiCrafter29/YC29Engine-Latest/main/", fileList:Array<String>) 
	{
		super();
		this.baseURL = baseURL;
		this.fileList = fileList;
		totalFiles = fileList.length;
	}

	var currentLoadedStream:URLLoader = null;
	var currentFile:String;

	function alright() {
		downloadedFiles++;
		percentLabel.text = '${Math.floor(downloadedFiles / totalFiles * 100)}%';
		if (fileList.length > 0) {
			doFile();
		} else {
			applyUpdate();
		}
	}

	function doFile() {
		var f = fileList.shift();
		currentFile = f;
		if (f == null) {
			applyUpdate();
			return;
		};
		if (FileSystem.exists('./_cache/$f') && FileSystem.stat('./_cache/$f').size > 0) { // prevents redownloading of the entire thing after it failed
			alright();
			return;
		}
		var downloadStream = new URLLoader();
		currentLoadedStream = downloadStream;
		downloadStream.dataFormat = BINARY;

		//dumbass
		var request = new URLRequest('$baseURL/$f'.replace(" ", "%20"));

		
		
		
		var good = true;

		var label1 = '(${totalFiles - fileList.length}/${totalFiles})';
		var label2 = '( - / - )';
		var maxLength:Int = Std.int(Math.max(label1.length, label2.length));
		while(label1.length < maxLength) label1 = " " + label1;
		while(label2.length < maxLength) label2 += " ";
		currentFileLabel.text = 'Downloading File: $f\n$label1 | $label2';
		
		// downloadStream.addEventListener(Event.OPEN, function(e) {trace("Opened");good = true;});
		downloadStream.addEventListener(IOErrorEvent.IO_ERROR, function(e) {
			if (e.text.contains("404")) {
				
				trace('File not found: $f');
				alright();
			} else {
				openSubState(new MenuMessage('Failed to download $f. Make sure you have a working internet connection, and try again.\n\nError ID: ${e.errorID}\n${e.text}', function() {
					FlxG.switchState(new MainMenuState());
				}));
				persistentUpdate = false;
			}
		});
		downloadStream.addEventListener(Event.COMPLETE, function(e) {
			var array = [];
			var dir = [for (k => e in (array = f.replace("\\", "/").split("/"))) if (k < array.length - 1) e].join("/");
			FileSystem.createDirectory('./_cache/$dir');
			var fileOutput:FileOutput = File.write('./_cache/$f', true);

			var data:ByteArray = new ByteArray();
			downloadStream.data.readBytes(data, 0, downloadStream.data.length - downloadStream.data.position);
			fileOutput.writeBytes(data, 0, data.length);
			fileOutput.flush();

			fileOutput.close();
			alright();
		});
		downloadStream.addEventListener(ProgressEvent.PROGRESS, function(e) {
			var label1 = '(${totalFiles - fileList.length}/${totalFiles})';
			var label2 = '(${CoolUtil.getSizeLabel(Std.int(e.bytesLoaded))} / ${CoolUtil.getSizeLabel(Std.int(e.bytesTotal))})';
			var maxLength:Int = Std.int(Math.max(label1.length, label2.length));
			while(label1.length < maxLength) label1 = " " + label1;
			while(label2.length < maxLength) label2 += " ";
			currentFileLabel.text = 'Downloading File: $f\n$label1 | $label2';
			/*
			// if (good) {
				if (downloadStream.data == null) {
					// trace("data is null");
					return;
				}
				var data:ByteArray = new ByteArray();
				downloadStream.data.readBytes(data, 0, downloadStream.data.length - downloadStream.data.position);
				trace(data.length);
				fileOutput.writeBytes(data, 0, data.length);
				fileOutput.flush();
			// } else {
			// 	trace("Isn't good yet");
			// }
			*/
		});


		downloadStream.load(request);

		
	}

	public function applyUpdate() {
		// apply update

		// copy file to prevent overriding issues
		File.copy('YoshiCrafterEngine.exe', 'temp.exe');

		// launch that file
		new Process('start /B temp.exe update', null);
		System.exit(0);
	}
	public override function create() {
		super.create();
		FlxG.autoPause = false;
		CoolUtil.addUpdateBG(this);
		
		var downloadBar = new FlxBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.75), 30, this, "downloadedFiles", 0, fileList.length);
		downloadBar.createGradientBar([0x88222222], [0xFF7163F1, 0xFFD15CF8], 1, 90, true, 0xFF000000);
		downloadBar.screenCenter(X);
		downloadBar.y = FlxG.height - 45;
		downloadBar.scrollFactor.set(0, 0);
		add(downloadBar);
		
		percentLabel = new FlxText(downloadBar.x, downloadBar.y + (downloadBar.height / 2), downloadBar.width, "0%");
		percentLabel.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
		percentLabel.y -= percentLabel.height / 2;
		add(percentLabel);
		
		currentFileLabel = new FlxText(0, downloadBar.y - 10, FlxG.width, "");
		currentFileLabel.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
		currentFileLabel.y -= percentLabel.height * 2;
		add(currentFileLabel);
	
		doFile();
		/*
		//Thread.create(function() {
			try {
				// download stuff
				for (k => f in fileList) {
					var downloadStream = new URLStream();
					var request = new URLRequest('$baseURL/$f');
					//request.data.token = "";
					downloadStream.load(request);
					var array = [];
					var dir = [for (k => e in (array = f.replace("\\", "/").split("/"))) if (k < array.length - 1) e].join("/");
					FileSystem.createDirectory('./_cache/$dir');
					var fileOutput:FileOutput = File.write('./_cache/$f', false);
					var am = 0;
					var done = false;
					var progress = false;
					//downloadStream.
					downloadStream.addEventListener(Event.COMPLETE, function(e) {done = true;});
					downloadStream.addEventListener(ProgressEvent.PROGRESS, function(e) {progress = true;});
					@:privateAccess
					while (!done) {
						if (progress) {
							progress = false;
							trace('bytesAvailable: ${downloadStream.bytesAvailable} - am: $am');
							var data = new ByteArray();
							@:privateAccess
							downloadStream.readBytes(data, 0, downloadStream.bytesAvailable);
							fileOutput.writeBytes(data, 0, data.length);
						}
						
						//fileOutput.
					}
					trace('disconnected');
					fileOutput.close();
					//downloadStream.readBytes(
					downloadedFiles = k + 1;
					
					var request = new URLRequest('$baseURL/$f');
					var loader = new URLLoader();
					loader.dataFormat = URLLoaderDataFormat.BINARY;
					var completed = false;
					
					loader.addEventListener(flash.events.Event.COMPLETE, function(e) {completed = true;});
					loader.load(request);

					/*
					var array = [];
					var dir = [for (k => e in (array = f.replace("\\", "/").split("/"))) if (k < array.length - 1) e].join("/");
					FileSystem.createDirectory('./_cache/$dir');
					var fileOutput:FileOutput = File.write('./_cache/$f', false);
					
					trace('$baseURL/$f');
					fileOutput.writeString(Http.requestUrl('$baseURL/$f'));
					fileOutput.flush();
					fileOutput.close();
				}
			} catch (e) {
				trace(e.details());
			}
		//});
		*/
	}
	public override function update(elapsed:Float) {
		// if (currentFile != null && currentLoadedStream != null) {
		// 	currentFileLabel.text = 'Downloading File: $currentFile';
		// }
		super.update(elapsed);
	}
}