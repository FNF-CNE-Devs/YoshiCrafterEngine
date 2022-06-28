import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;
import openfl.display.Sprite;

using StringTools;

class LogsOverlay extends Sprite {
    var logsText:TextField;
    var titleText:TextField;
    var legend:TextField;
    
    public static var lastPos:Int = 0;
    public static var errors:Int = 0;
    public static var lastErrors:Int = 0;
    public static var log:Array<String> = [];
    public static function error(thing:Dynamic) {
        LogsOverlay.trace(thing);
        errors++;
    }
	public static function trace(thing2:Dynamic) {
        var thing = "";
        if (Std.isOfType(thing2, String)) {
            thing = thing2;
        } else {
            thing = Std.string(thing2);
        }
        thing = thing.replace("\r", "");
		for (e in thing.split("\n")) log.push(e);
		trace(thing);
		var limit = 256;
		if (Settings.engineSettings != null) limit = Settings.engineSettings.data.logLimit;
		while(log.length > limit) log.shift();
	}
    public function new() {
        super();
        x = 0;
        y = 0;

        titleText = new TextField();
        titleText.autoSize = LEFT;
        titleText.selectable = false;
        titleText.textColor = 0xFFFFFFFF;
        titleText.defaultTextFormat = new TextFormat("Pixel Arial 11 Bold", 16);
        titleText.text = 'YoshiCrafter Engine ${Main.engineVer}';

        logsText = new TextField();
        logsText.multiline = true;
        logsText.selectable = true;
        logsText.textColor = 0xFFFFFFFF;
        logsText.defaultTextFormat = new TextFormat("Pixel Arial 11 Bold", 12);

        legend = new TextField();
        legend.autoSize = LEFT;
        legend.selectable = false;
        legend.textColor = 0xDDDDDD;
        legend.defaultTextFormat = new TextFormat("Pixel Arial 11 Bold", 12);
        legend.text = "[F6] Close | [F7] Clear";
        addChild(titleText);
        addChild(logsText);
        addChild(legend);

        visible = false;
    }

    var wasPressed:Bool = false;
    public override function __enterFrame(deltaTime:Int) {
        super.__enterFrame(deltaTime);
        
        graphics.clear();
        graphics.beginFill(0x000000, 0.5);
        graphics.drawRect(0, 0, lime.app.Application.current.window.width, lime.app.Application.current.window.height);
        graphics.endFill();

        if (CoolUtil.isDevMode()) {
            if (!wasPressed && (wasPressed = FlxG.keys.pressed.F6)) {
                visible = !visible;
            } else
                wasPressed = FlxG.keys.pressed.F6;
            if (visible && FlxG.keys.justPressed.ESCAPE) visible = false;
        } else {
            visible = false;
        }

        if (visible) {
            titleText.x = (lime.app.Application.current.window.width - titleText.width) / 2;
            legend.x = (lime.app.Application.current.window.width - legend.width) / 2;
            logsText.y = 42;
            logsText.width = lime.app.Application.current.window.width;
            logsText.height = lime.app.Application.current.window.height - 42;
            legend.y = 22;

            var oldMaxScroll = logsText.maxScrollV;
            if (logsText.text != (logsText.text = log.join("\n"))) {
                logsText.scrollV = logsText.scrollV - oldMaxScroll + logsText.maxScrollV;
            };

            if (FlxG.keys.pressed.F7) {
                while(log.length > 0) log.pop();
                lastPos = errors = lastErrors = 0;
            }
            lastPos = log.length;
            lastErrors = errors;
        } else {
            logsText.text = "";
        }
    }
}