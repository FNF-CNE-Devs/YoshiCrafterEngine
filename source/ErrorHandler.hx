import sys.io.File;
import openfl.Lib;
import openfl.events.ErrorEvent;
import openfl.errors.Error;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
using StringTools;

class ErrorHandler {
    @:unreflective
    private static var __superCoolErrorMessagesArray:Array<String> = [
        "A fatal error has occ- wait what?",
        "missigno.",
        "oopsie daisies!! you did a fucky wucky!!",
        "i think you fogot a semicolon",
        "null balls reference",
        "get friday night funkd'",
        "engine skipped a heartbeat",
        "Impossible...",
        "Patience is key for success... Don't give up.",
        "It's no longer in its early stages... is it?",
        "It took me half a day to code that in",
        "You should make an issue... NOW!!",
        "> Crash Handler written by: yoshicrafter29",
        "{0}... wait what are we talking about",
        "could not access variable you.dad",
        "What have you done...",
        "THERE ARENT COUGARS IN SCRIPTING!!! I HEARD IT!!",
        "no, thats not from system.windows.forms",
        "you better link a screenshot if you make an issue, or at least the crash.txt",
        "stack trace more like dunno i dont have any jokes",
        "oh the misery. everybody wants to be my enemy",
        "have you heard of soulles dx",
        "i thought it was invincible",
        "did you deleted coconut.png",
        "have you heard of {0}'s cousin null function reference",
        "sad that linux users wont see this banger of a crash handler",
        "thats a nice {0} you got there, can i have it?",
        "wikihow: how to fix {0}",
        "{0}... {0}...",
        "woopsie",
        "oopsie",
        "woops",
        "silly me",
        "my bad",
        "i cant believe this isn't a message box anymore",
        "first time, huh?",
        "did somebody say yoga",
        "we forget a thousand things everyday... make sure this is one of them.",
        "SAY GOODBYE TO YOUR KNEECAPS, CHUCKLEHEAD",
        "motherfucking ordinal 344 (TaskDialog) forcing me to create a even fancier window",
        "Died due to missing a sawblade. (Press Space to dodge!)",
        "yes rico, kaboom.",
        "goofy ahh engine",
        "debug7 in options have you heard of that",
        "this crash handler is sponsored by rai-",
        "",
        "did you know a jiffy is an actual measurement of time",
        "how many hurt notes did you put",
        "FPS: 0",
        "\r\ni am a secret message",
        "this is garnet",
        "{0}: Sorry i already have a boyfriend",
        "did you know theres a total of {1} silly messages",
        "{0} | {0} | {0} | {0} | {0} | {0} | {0} | {0} | {0}",
        "Game used {0}. It's super effective!"
    ];

    public static function assignErrorHandler() {
        lime.utils.Log.throwErrors = false;
        Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
    }

    public static function onError(e:UncaughtErrorEvent) {
        var m:String = e.error;
        if (Std.isOfType(e.error, Error)) {
            var err = cast(e.error, Error);
            m = '${err.message}';
        } else if (Std.isOfType(e.error, ErrorEvent)) {
            var err = cast(e.error, ErrorEvent);
            m = '${err.text}';
        }
        var stack = CallStack.exceptionStack();
        var stackLabel:String = "";
        for(e in stack) {
            switch(e) {
                case CFunction: stackLabel += "- Non-Haxe (C) Function";
                case Module(c): stackLabel += '- Module ${c}';
                case FilePos(parent, file, line, col):
                    switch(parent) {
                        case Method(cla, func):
                            stackLabel += '- (${file}) ${CoolUtil.getLastOfArray(cla.split("."))}.$func() - line $line';
                        case _:
                            stackLabel += '- (${file}) - line $line';
                    }
                case LocalFunction(v):
                    stackLabel += '- Local Function ${v}';
                case Method(cl, m):
                    stackLabel += '- ${cl} - ${m}';
            }
            stackLabel += "\r\n";
        }
        var text = "";

        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();

        File.saveContent('crash.txt', text);

        try {
            #if windows
                var silly = Std.string(__superCoolErrorMessagesArray[FlxG.random.int(0, __superCoolErrorMessagesArray.length)].replace("{0}", m).replace("{1}", Std.string(__superCoolErrorMessagesArray.length)));
                HeaderCompilationBypass.showErrorHandler('YoshiCrafter Engine ${Main.engineVer} - Crash Handler', silly, m, stackLabel);
            #else
                text = (
                    'A fatal error occured !\r\nYoshiCrafter Engine ver. ${Main.engineVer} ${Main.buildVer}\r\n\r\n${m}\r\n${stackLabel}\r\nThe engine is still in it\'s early stages, so if you want to report that bug, go ahead and create an Issue on the GitHub page !');
                    HeaderCompilationBypass.showMessagePopup(text, e.error == null ? Std.string(e) : Std.string(e.error), MSG_ERROR);
                System.exit(1);
            #end
        } catch(e) {

        }
        trace(text);
            
        
        
    }
}