import openfl.text.TextField;
import openfl.text.TextFormat;
import EngineSettings.Settings;
import flixel.FlxG;
import openfl.display.Sprite;

class LogsOverlay extends Sprite {
    var logsText:TextField;
    var titleText:TextField;
    var legend:TextField;

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
        }

        if (visible) {
            titleText.x = (lime.app.Application.current.window.width - titleText.width) / 2;
            legend.x = (lime.app.Application.current.window.width - legend.width) / 2;
            logsText.y = 42;
            logsText.width = lime.app.Application.current.window.width;
            logsText.height = lime.app.Application.current.window.height - 42;
            legend.y = 22;

            var oldMaxScroll = logsText.maxScrollV;
            if (logsText.text != (logsText.text = PlayState.log.join("\n"))) {
                logsText.scrollV = logsText.scrollV - oldMaxScroll + logsText.maxScrollV;
            };

            if (FlxG.keys.pressed.F7) {
                while(PlayState.log.length > 0) PlayState.log.pop();
            }
        }
    }
}