package logging;

import openfl.text.TextFormat;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.utils.Assets;
import openfl.display.Bitmap;
import WindowsAPI.ConsoleColor;
import openfl.display.Sprite;

class LogMessage extends Sprite {
    public var icon:Sprite;
    public var text:TextField;
    public var count:TextField;
    public var iconInnerSprite:Bitmap;

    public var curColor:Int;
    public var actualHeight:Float = 0;

    public var messageCount:Int = 1;
    public var message:String;
    public function new(x:Float, y:Float, text:String, color:ConsoleColor) {
        super();

        var iconID = switch(color) {
            case RED | DARKRED:     0;
            case YELLOW:            1;
            case GREEN | DARKGREEN: 2;
            case _:                 3;
        }

        icon = new Sprite();
        icon.x = 2;
        icon.scrollRect = new Rectangle(iconID * 16, 0, 16, 16);

        iconInnerSprite = new Bitmap(Assets.getBitmapData(Paths.image('ui/logs-icons', 'shared')));

        curColor = WindowsAPI.consoleColorToOpenFL(color);
        switch(color) {
            case WHITE | YELLOW:
                // make them look darker so that the text is readable
                curColor = CoolUtil.multiplyColors(curColor, 0xAAAAAAAA);
            case _:
                // nothing
        }

        
        this.text = new TextField();
        this.text.x = 20;
        this.text.text = '${message = text}\r\n'; // dumbass openfl
        this.text.autoSize = LEFT;
        this.text.selectable = true;
        this.text.multiline = true;
        this.text.wordWrap = true;

        count = new TextField();
        count.text = '(x12)';
        count.autoSize = RIGHT;

        for(e in [this.text, this.count]) {
            e.textColor = 0xFFFFFFFF;
            e.defaultTextFormat = new TextFormat("Pixel Arial 11 Bold", 11);
        }

        addChild(icon);
        icon.addChild(iconInnerSprite);
        addChild(this.text);
        addChild(count);

        this.x = x;
        this.y = y;
    }

    public function updateY(lastY:Float) {
        y = lastY;
        return lastY + actualHeight;
    }

    public override function __enterFrame(deltaTime:Int) {
        super.__enterFrame(deltaTime);
        var width = lime.app.Application.current.window.width;
        actualHeight = (this.text.height / this.text.numLines * (this.text.numLines - 2)) + 5;

        if (count.visible = (messageCount > 1)) {
            count.text = '(x${messageCount})';
            count.x = width - count.width - 5;
            
            this.text.width = width - 35 - count.width;

        } else {
            this.text.width = width - 20;
        }
        icon.y = (actualHeight - 16) / 2;
        count.y = (actualHeight - count.height) / 2;

        graphics.clear();

        // bg
        graphics.beginFill(curColor, 2 / 3);
        graphics.drawRect(0, 0, width, actualHeight);
        graphics.endFill();

        // top separator bar
        graphics.beginFill(CoolUtil.multiplyColors(curColor, 0x88888888), 1);
        graphics.drawRect(0, 0, width, 1);
        graphics.endFill();
    }
}