package ;
import cpp.vm.Thread;
import flixel.ui.FlxBar;
import flixel.FlxG;
import openfl.net.URLStream;
import openfl.net.URLRequest;

/**
 * ...
 * @author YoshiCrafter29
 */
class UpdateState extends MusicBeatState
{
	public var fileList:Array<String> = [];
	public var baseURL:String;
	public var downloadedFiles:Int = 0;
	public function new(baseURL:String = "https://raw.githubusercontent.com/YoshiCrafter29/YC29Engine-Latest/main/", fileList:Array<String>) 
	{
		super();
		this.baseURL = baseURL;
		this.fileList = fileList;
	}
	
	public function create() {
		super();
		CoolUtil.addBG(this);
		
		var downloadBar = new FlxBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.75), 30, this, "downloadedFiles", 0, fileList.length);
		downloadBar.screenCenter(X);
		downloadBar.y = FlxG.height * 0.75;
		downloadBar.scrollFactor.set(0, 0);
		add(downloadBar);
		
	
		
		Thread.create(function() {
			// download stuff
			for (k => f in fileList) {
				var downloadStream = new URLStream();
				var request = new URLRequest('$baseURL/$f');
				//request.data.token = "";
				downloadStream.load(request);
				var array = 
				downloadStream.readBytes(
				downloadedFiles = k + 1;
			}
		});
	}
	public override function update(elapsed:Float) {
		super.update(elapsed);
	}
}