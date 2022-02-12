import flixel.math.FlxPoint;
import openfl.net.FileReference;
import flixel.addons.ui.FlxUIButton;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.FlxSubState;

class LogSubState extends MusicBeatSubstate {
    var text:FlxText;
    var released:Bool;
    var scrollSprite:FlxSprite;
    var size:FlxPoint;
    public override function create() {
        var list = PlayState.log.copy();
        size = new FlxPoint(FlxG.width, FlxG.height);
        if (PlayState.current != null) {
            size.set(PlayState.current.guiSize.x, PlayState.current.guiSize.y);
        }
        var maxLength = Std.int(16777215 / (size.x) / 30);

        trace(maxLength);
        if (list.length > maxLength) {
            list = ["... /!/ Due to OpenFL's bitmap limitations (16777215 pixels per bitmap), use the Save button to export and read the file yourself."];
            for (i in (PlayState.log.length - maxLength + 1)...PlayState.log.length) {
                list.push(PlayState.log[i]);
            }
        }
        var t = list.join("\r\n");
        text = new FlxText(0, 0, Std.int(size.x), t, 12);
        text.setFormat(Paths.font("vcr.ttf"), Std.int(16), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);


        var bg = new FlxSprite(0, 0).makeGraphic(Std.int(size.x), Std.int(size.y), FlxColor.fromRGBFloat(0, 0, 0, 0.65));
        // var bg = new FlxSprite(-PlayState.current.guiOffset.x / 2, -PlayState.current.guiOffset.y / 2).makeGraphic(Math.ceil(1280 + PlayState.current.guiOffset.x), Math.ceil(720 + PlayState.current.guiOffset.y), FlxColor.fromRGBFloat(0, 0, 0, 0.65));
        

        scrollSprite = new FlxSprite(Std.int(size.x) - 10, 0).makeGraphic(10, Std.int((Std.int(size.y) / text.height) * Std.int(size.y)), 0x88FFFFFF);
        
        var clearButton:FlxUIButton = new FlxUIButton(scrollSprite.x - 10, 10, "Clear", function() {
            text.text = "";
            PlayState.log = [];
        });
        clearButton.x -= clearButton.width;
        
        var saveButton:FlxUIButton = new FlxUIButton(clearButton.x, clearButton.y + 10 + clearButton.height, "Save", function() {
            var _file = new FileReference();
            var date = Date.now();
            var y = CoolUtil.addZeros(Std.string(date.getFullYear()), 4);
            var m = CoolUtil.addZeros(Std.string(date.getMonth() + 1), 2);
            var d = CoolUtil.addZeros(Std.string(date.getDate()), 2);
            var H = CoolUtil.addZeros(Std.string(date.getHours()), 2);
            var M = CoolUtil.addZeros(Std.string(date.getMinutes()), 2);
            var S = CoolUtil.addZeros(Std.string(date.getSeconds()), 2);
            _file.save(PlayState.log.join("\r\n"), '$y-$m-$d-$H-$M-$S.log');
        });

        if (PlayState.current != null) {
            bg.cameras = [PlayState.current.camHUD];
            text.cameras = [PlayState.current.camHUD];
            scrollSprite.cameras = [PlayState.current.camHUD];
            saveButton.cameras = [PlayState.current.camHUD];
            clearButton.cameras = [PlayState.current.camHUD];
        }
        add(bg);
        add(text);
        add(scrollSprite);
        add(clearButton);
        add(saveButton);

        text.y = -Math.max(0, text.height - Std.int(size.y));
        released = controls.ACCEPT || controls.BACK;

        bg.scrollFactor.set();
        text.scrollFactor.set();
        scrollSprite.scrollFactor.set();
        clearButton.scrollFactor.set();
        saveButton.scrollFactor.set();
        super.create();
    }

    public override function update(elapsed) {
        super.update(elapsed);
        var up = controls.UP;
		var down = controls.DOWN;
		var back = (controls.ACCEPT || controls.BACK) && !released;
        if (released) released = controls.ACCEPT || controls.BACK;
        
        var maxDist = Math.max(0, text.height - size.y);
        if (up) {
            text.y += elapsed * (FlxControls.pressed.SHIFT ? 800 : 300);
        }
        if (down) {
            text.y -= elapsed * (FlxControls.pressed.SHIFT ? 800 : 300);
        }
        if (FlxG.mouse.wheel != 0) {
            text.y += FlxG.mouse.wheel * 100;
        }

        if (text.y > 0) text.y = 0;
        if (text.y < -maxDist) text.y = -maxDist;

        if (back) {
            close();
        }
        // scrollSprite.y = (-PlayState.current.guiOffset.y / 2) + (((text.y - text.height) / text.height) * (720 + PlayState.current.guiOffset.y));
        scrollSprite.y = (-text.y / text.height * size.y);
        // trace(scrollSprite.y);
    }
}