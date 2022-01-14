package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class OutdatedSubState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var data:YoshiEngineVersion;
	public function new(data:YoshiEngineVersion) {
		this.data = data;
		super();
	}
	override function create()
	{
		super.create();
		var bg:FlxSprite = new FlxSprite();
		bg.loadGraphic(Paths.image('menuBGYoshi', 'preload'));
		bg.scale.set(1.2, 1.2);
		bg.screenCenter();
		add(bg);

		var anims = ['enter to update', 'backspace to skip'];
		// var xOffset:Float = 10;

		for (i in 0...anims.length) {
			var b = new FlxSprite(10, 0);
			b.frames = Paths.getSparrowAtlas("outdatedAssets", "preload");
			b.animation.addByPrefix("anim", anims[i]);
			b.animation.play("anim");
			b.setGraphicSize(Std.int(b.width * 0.75));
			b.y = 710 - b.height;
			if (i == 1) {
				b.x = 1270 - b.width;
			}
			b.antialiasing = true;
			add(b);
			// xOffset += 25 + b.width;
		}


		var localVer = Main.engineVer.join(".");
		var latestVer = data.version.join(".");

		var txt:FlxText = new FlxText(0, 10, FlxG.width,
			"HEY ! Your Yoshi Engine is outdated !\n"
			+ 'v$localVer < v$latestVer\n'
			,32);
		txt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		txt.screenCenter(X);
		add(txt);

		var changelog = new FlxText(100, txt.y + txt.height + 20, 1080, data.updateLog.join("\n"), 16);
		changelog.setFormat(Paths.font("vcr.ttf"), Std.int(16), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(changelog);
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			FlxG.openURL(data.url);
		}
		if (controls.BACK)
		{
			leftState = true;
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}
