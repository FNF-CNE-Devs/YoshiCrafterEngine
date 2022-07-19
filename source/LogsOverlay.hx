import hscript.*;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;
import openfl.display.Sprite;

using StringTools;

class LogsOverlay extends Sprite {
    public static var logsText:TextField;
    public static var titleText:TextField;
    public static var legend:TextField;
    public static var command:TextField;
    public static var commandLabel:TextField;
    public static var hscript:Interp;
    
    public static var lastPos:Int = 0;
    public static var tracedShit:Int = 0;
    public static var errors:Int = 0;
    public static var lastErrors:Int = 0;
    public static var oldLogsText:String = "";
    public static var lastCommands:Array<String> = [];

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
        for(e in thing.split("\n")) {
            tracedShit++;
            logsText.appendText(e + "\n");
        }
        var splitShit = logsText.text.split("\n");
        if (splitShit.length > Settings.engineSettings.data.logLimit) {
            while(splitShit.length > Settings.engineSettings.data.logLimit) {
                splitShit.pop();
            }
            logsText.text = splitShit.join("\n");
        }
	}
    public function new() {
        super();
        x = 0;
        y = 0;

        hscript = new Interp();
        hscript.errorHandler = function(e) {
            error(e);
        };
        hscript.variables.set("trace", LogsOverlay.trace);

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

        command = new TextField();
        command.selectable = true;
        command.type = INPUT;
        command.text = "";
        command.textColor = 0xFFFFFFFF;
        command.defaultTextFormat = new TextFormat("Pixel Arial 11 Bold", 12);
        command.height = 22;

        commandLabel = new TextField();
        commandLabel.selectable = true;
        commandLabel.text = "Enter command here:";
        commandLabel.textColor = 0xDDDDDD;
        commandLabel.defaultTextFormat = new TextFormat("Pixel Arial 11 Bold", 6);
        commandLabel.height = 11;
        // command.ed
        addChild(titleText);
        addChild(logsText);
        addChild(legend);
        addChild(commandLabel);
        addChild(command);

        FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent)
            {
                if (CoolUtil.isDevMode()) {
                    if (e.keyCode == Keyboard.F6) {
                        switchState();
                    }
                    if (visible) {
                        if (e.keyCode == Keyboard.F7) {
                            logsText.text = "";
                            tracedShit = lastPos = errors = lastErrors = 0;
                        }
                        if (FlxG.stage.focus == command) {
                            if (e.keyCode == Keyboard.ENTER && command.text.trim() != "") { // COMMAND!
                                var e = new Parser();
                                e.allowJSON = true;
                                e.allowMetadata = true;
                                e.allowTypes = true;
                                try {
                                    var expr = e.parseString(command.text);
                                    @:privateAccess
                                    LogsOverlay.trace(hscript.exprReturn(expr));
                                } catch(e) {
                                    error(e);
                                }
                                lastCommands.push(command.text);
                                while(lastCommands.length > 10) {
                                    lastCommands.pop();
                                }
                                command.text = "";
                            }
                        }
                    }
                    
                }
                
            });

        visible = false;
    }

    function switchState() {
        FlxG.mouse.useSystemCursor = (visible = !visible);
        FlxG.mouse.enabled = !FlxG.mouse.useSystemCursor;
    }
    public override function __enterFrame(deltaTime:Int) {
        super.__enterFrame(deltaTime);
        
        graphics.clear();
        graphics.beginFill(0x000000, 0.5);
        graphics.drawRect(0, 0, lime.app.Application.current.window.width, lime.app.Application.current.window.height);
        graphics.endFill();

        if (!CoolUtil.isDevMode() && visible) {
            switchState();
        }

        if (visible) {
            titleText.x = (lime.app.Application.current.window.width - titleText.width) / 2;
            legend.x = (lime.app.Application.current.window.width - legend.width) / 2;
            logsText.y = 42;
            command.width = logsText.width = lime.app.Application.current.window.width;
            logsText.height = lime.app.Application.current.window.height - 42 - command.height - commandLabel.height;
            legend.y = 22;
            command.y = lime.app.Application.current.window.height - command.height;
            commandLabel.y = command.y - 11;

            FlxG.keys.enabled = FlxG.stage.focus != command;
            var oldMaxScroll = logsText.maxScrollV;
            if (logsText.text != (oldLogsText)) {
                oldLogsText = logsText.text;
                logsText.scrollV = logsText.scrollV - oldMaxScroll + logsText.maxScrollV;
            }
            lastPos = tracedShit;
            lastErrors = errors;
        } else {
            FlxG.keys.enabled = true;
            if (FlxG.stage.focus == command) {
                FlxG.stage.focus = null;
            }
            // logsText.text = "";
        }
    }
}