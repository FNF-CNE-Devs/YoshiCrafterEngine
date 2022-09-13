package mod_support_stuff;

import lime.app.Application;
import haxe.zip.Reader;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.ui.*;
import flixel.text.FlxText;
import ZipUtils.ZipProgress;

class InstallModSubstate extends MusicBeatSubstate {

    // UNCOMPRESSING STUFF
    public var zip:Reader;
    public var prefix:String;
    public var prog:ZipProgress;
    
    // UI STUFF
    var currentFileLabel:FlxText;
    var percentLabel:FlxText;
    var downloadBar:FlxBar;

    public function new(zip:Reader, ?prefix:String) {
        this.zip = zip;
        this.prefix = prefix;
        super();
    }

    public override function create() {
        super.create();
        prog = ZipUtils.uncompressZipAsync(zip, Paths.modsPath, prefix);

        downloadBar = new FlxBar(0, 0, LEFT_TO_RIGHT, Std.int(FlxG.width * 0.75), 30, prog, "percentage", 0, 1);
		downloadBar.createGradientBar([0x88222222], [0xFF7163F1, 0xFFD15CF8], 1, 90, true, 0xFF000000);
		downloadBar.screenCenter(X);
		downloadBar.y = FlxG.height - 45;
		downloadBar.scrollFactor.set();
		add(downloadBar);
		
		percentLabel = new FlxText(downloadBar.x, downloadBar.y + (downloadBar.height / 2), downloadBar.width, "0%");
		percentLabel.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
		percentLabel.y -= percentLabel.height / 2;
		percentLabel.scrollFactor.set();
		add(percentLabel);
		
		currentFileLabel = new FlxText(0, downloadBar.y - 10, FlxG.width, "");
		currentFileLabel.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, OUTLINE, 0xFF000000);
		currentFileLabel.y -= percentLabel.height * 2;
		currentFileLabel.scrollFactor.set();
		add(currentFileLabel);
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        percentLabel.text = '${Math.round(prog.percentage * 100)}%';
        if (prog.done) {
            if (prog.error != null) {
                Application.current.window.alert(prog.error.details());
            }
            FlxG.switchState(new TitleState());
        }
    }
}