package ;
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
	public function new(baseURL:String = "http://raw.githubusercontent.com/YoshiCrafter29/YC29Engine-Latest/main/", fileList:Array<String>) 
	{
		super();
		this.baseURL = baseURL;
		this.fileList = fileList;
	}
	
	public override function create() {
		super.create();
		CoolUtil.addBG(this);
		
		var downloadBar = new FlxBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.75), 30, this, "downloadedFiles", 0, fileList.length);
		downloadBar.screenCenter(X);
		downloadBar.y = FlxG.height * 0.75;
		downloadBar.scrollFactor.set(0, 0);
		add(downloadBar);
		
	
		
		//Thread.create(function() {
			try {
				// download stuff
				for (k => f in fileList) {
					/*
					var downloadStream = new URLStream();
					var request = new URLRequest('$baseURL/$f');
					//request.data.token = "";
					downloadStream.load(request);
					var array = [];
					var dir = [for (k => e in (array = f.replace("\\", "/").split("/"))) if (k < array.length - 1) e].join("/");
					FileSystem.createDirectory('./_cache/$dir');
					var fileOutput:FileOutput = File.write('./_cache/$f', false);
					var am = 0;
					//downloadStream.
					@:privateAccess
					while (downloadStream.__loader.bytesLoaded < downloadStream.__loader.bytesTotal) {
						var data = new ByteArray();
						@:privateAccess
						downloadStream.readBytes(data, am, downloadStream.__loader.bytesLoaded - am);
						if (downloadStream.__loader.bytesLoaded - am > 0) fileOutput.writeString(data.toString());
						am = downloadStream.__loader.bytesLoaded;
						
						trace('bytesAvailable: ${downloadStream.bytesAvailable} - am: $am');
						//fileOutput.
					}
					trace('disconnected');
					fileOutput.close();
					//downloadStream.readBytes(
					downloadedFiles = k + 1;
					*/
					
					var request = new URLRequest('$baseURL/$f');
					var loader = new URLLoader();
					loader.dataFormat = URLLoaderDataFormat.BINARY;
					var completed = false;
					
					loader.addEventListener(flash.events.Event.COMPLETE, function(e) {completed = true;});
					loader.load(request);
					
					var array = [];
					var dir = [for (k => e in (array = f.replace("\\", "/").split("/"))) if (k < array.length - 1) e].join("/");
					FileSystem.createDirectory('./_cache/$dir');
					var fileOutput:FileOutput = File.write('./_cache/$f', false);
					var am = 0;
					
					//loader.load(loader);
					@:privateAccess
					while (!completed) {
						trace(loader.bytesLoaded);
						trace(loader.bytesTotal);
					}
					fileOutput.writeString(loader.data.toString());
				}
			} catch (e) {
				trace(e.details());
			}
		//});
	}
	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}