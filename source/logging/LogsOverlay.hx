package logging;

import flixel.math.FlxMath;
import openfl.geom.Rectangle;
import WindowsAPI.ConsoleColor;
import hscript.*;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import openfl.text.TextField;
import openfl.text.TextFormat;
import flixel.FlxG;
import openfl.display.Sprite;

using StringTools;

class LogsOverlay extends Sprite {
    
    public static var consoleOpened:Bool = false;
    public static var consoleVisible:Bool = false;

    public static var logsText:Sprite;
    public static var titleText:TextField;
    public static var legend:TextField;
    public static var command:TextField;
    public static var dummyText:TextField;
    public static var commandLabel:TextField;
    public static var hscript:Interp;
    
    public static var lastPos:Int = 0;
    public static var tracedShit:Int = 0;
    public static var errors:Int = 0;
    public static var lastErrors:Int = 0;
    public static var oldLogsText:String = "";
    public static var lastCommands:Array<String> = [];

	public static var messages:Array<LogMessage> = [];

    public var wheel:Float = 0;

    public static function error(thing:Dynamic, color:ConsoleColor = RED) {
        LogsOverlay.trace(thing, color);
        errors++;
    }
	public static function trace(thing2:Dynamic, color:ConsoleColor = WHITE) {
        var thing = "";
        if (Std.isOfType(thing2, String)) {
            thing = thing2;
        } else {
            thing = Std.string(thing2);
        }
        if (consoleOpened && consoleVisible) {
            // logsText.text = "Logs are redirected in detached console.\nPress F8 to reattach the logs to the game.";

            WindowsAPI.setConsoleColors(color, BLACK);
            var out = Sys.stdout(); // using stdout so that it doesnt show LogsOverlay.hx:43: at the beginning
            for(e in thing.split("\n")) {
                tracedShit++;
                out.writeString('[YCE LOGS] $e\n'); 
            }
        } else {
            if (logsText == null) return;
            if (messages.length > 0) {
                var msg = messages[messages.length - 1];
                if (msg != null && msg.message == thing) {
                    msg.messageCount++;
                    return;
                }
            }
            var e = new LogMessage(0, 0, thing, color);
            messages.push(e);
            logsText.addChild(e);
            while(messages.length > Settings.engineSettings.data.logLimit)
                logsText.removeChild(messages.shift());
            tracedShit++;
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

        logsText = new Sprite();

        legend = new TextField();
        legend.autoSize = LEFT;
        legend.selectable = false;
        legend.textColor = 0xDDDDDD;
        legend.defaultTextFormat = new TextFormat("Pixel Arial 11 Bold", 12);
        #if windows
            legend.text = "[F6] Close | [F7] Clear | [F8] Detach";
        #else
            legend.text = "[F6] Close | [F7] Clear";
        #end

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

        dummyText = new TextField();
        dummyText.selectable = true;
        dummyText.text = "";
        dummyText.width = 2;
        dummyText.x = -5000;

        
        // command.ed
        addChild(titleText);
        addChild(logsText);
        addChild(legend);
        addChild(commandLabel);
        addChild(command);
        addChild(dummyText);

        FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent)
        {
            if (CoolUtil.isDevMode()) {
                if (e.keyCode == Keyboard.F6) {
                    switchState();
                }
                if (visible) {
                    switch(e.keyCode) {
                        case Keyboard.F7:
                            if (consoleOpened && consoleVisible)
                                WindowsAPI.clearScreen();
                            else {
                                for(e in messages) {
                                    logsText.removeChild(e);
                                }
                                messages = [];
                            }
                            tracedShit = lastPos = errors = lastErrors = 0;
                        case Keyboard.F8:
                            if (consoleOpened) {
                                WindowsAPI.showConsole(!consoleVisible);
                                // logsText.text = consoleVisible ? "Logs are redirected in detached console.\nPress F8 to reattach the logs to the game." : "";
                            } else {
                                WindowsAPI.allocConsole();
                            }
                            WindowsAPI.clearScreen();
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
        // cant import mouseEvent cause hxcpp is going to fuck itself
        FlxG.stage.addEventListener("mouseWheel", function(event:Dynamic) {
            wheel = event.delta;
        });
        visible = true;
        switchState();
    }

    function switchState() {
        FlxG.mouse.useSystemCursor = (visible = !visible);
        FlxG.mouse.enabled = !FlxG.mouse.useSystemCursor;
        FlxG.keys.enabled = true;
    }
    var messagesHeight:Float = 0;
    var scrollYOffset:Float = 0;
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
            command.width = lime.app.Application.current.window.width;
            // logsText.height = lime.app.Application.current.window.height - 42 - command.height - commandLabel.height;
            legend.y = 22;
            command.y = lime.app.Application.current.window.height - command.height;
            commandLabel.y = command.y - 11;

            FlxG.keys.enabled = FlxG.stage.focus != command;
            lastPos = tracedShit;
            lastErrors = errors;
            if (FlxG.stage.focus != dummyText && FlxG.stage.focus != command)
                FlxG.stage.focus = dummyText;
        } else {
            FlxG.stage.focus = dummyText;
        }

        var oldMesHeight = messagesHeight;
        messagesHeight = 0;
        for(e in messages)
            messagesHeight = e.updateY(messagesHeight);

        var messagesDisplayHeight = lime.app.Application.current.window.height - 42 - command.height - commandLabel.height;
        
        scrollYOffset = FlxMath.bound(scrollYOffset - (wheel * 50) + (messagesHeight - oldMesHeight), 0, messagesHeight - messagesDisplayHeight);
        var oldY:Null<Float> = null;
        if (logsText.scrollRect != null) {
            oldY = logsText.scrollRect.y;
        }
        logsText.scrollRect = new Rectangle(0,
            oldY == null ? Math.max(scrollYOffset, 0) : FlxMath.lerp(oldY, Math.max(scrollYOffset, 0), 0.25 * (deltaTime / 1000) * 60),
            lime.app.Application.current.window.width, messagesDisplayHeight);
        wheel = 0;
    }
}