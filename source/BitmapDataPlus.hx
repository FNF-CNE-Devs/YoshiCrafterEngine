import openfl.geom.Rectangle;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import openfl.display.BitmapData;

class BitmapDataPlus extends BitmapData {
    public function drawLine(beginPos:FlxPoint, endPos:FlxPoint, color:FlxColor, thickness:Float = 2) {
        var loopLength = Math.ceil(Math.sqrt(Math.pow(beginPos.x - endPos.x, 2) + Math.pow(beginPos.y - endPos.y, 2)) * 1.5);
        if (thickness <= 0) return;
        for (i in 0...loopLength) {
            fillRect(new Rectangle(
                beginPos.x + ((beginPos.x - endPos.x) * (i / loopLength)) - Math.floor(thickness / 2),
                beginPos.y + ((beginPos.y - endPos.y) * (i / loopLength)) - Math.floor(thickness / 2),
                Math.ceil(thickness / 2),
                Math.ceil(thickness / 2)
            ), color);
        }
    }
    public function drawLineReplacing(beginPos:FlxPoint, endPos:FlxPoint, color:FlxColor, replaces:FlxColor, thickness:Float = 2) {
        var loopLength = Math.ceil(Math.sqrt(Math.pow(beginPos.x - endPos.x, 2) + Math.pow(beginPos.y - endPos.y, 2)) * 1.5);
        if (thickness <= 0) return;
        for (i in 0...loopLength) {
            var pos = new FlxPoint(
                beginPos.x + ((beginPos.x - endPos.x) * (i / loopLength)) - Math.floor(thickness / 2),
                beginPos.y + ((beginPos.y - endPos.y) * (i / loopLength)) - Math.floor(thickness / 2)
            );
            if (getPixel32(Std.int(pos.x + (thickness / 2)), Std.int(pos.y + (thickness / 2))) != replaces) continue;
            fillRect(new Rectangle(
                pos.x, pos.y,
                Math.ceil(thickness),
                Math.ceil(thickness)
            ), color);
        }
    }
    public function drawLineExceptOn(beginPos:FlxPoint, endPos:FlxPoint, color:FlxColor, replaces:FlxColor, thickness:Float = 2) {
        var loopLength = Math.ceil(Math.sqrt(Math.pow(beginPos.x - endPos.x, 2) + Math.pow(beginPos.y - endPos.y, 2)) * 1.5);
        if (thickness <= 0) return;
        for (i in 0...loopLength) {
            var pos = new FlxPoint(
                beginPos.x + ((beginPos.x - endPos.x) * (i / loopLength)) - Math.floor(thickness / 2),
                beginPos.y + ((beginPos.y - endPos.y) * (i / loopLength)) - Math.floor(thickness / 2)
            );
            if (getPixel32(Std.int(pos.x), Std.int(pos.y)) == replaces) continue;
            fillRect(new Rectangle(
                pos.x, pos.y,
                Math.ceil(thickness / 2),
                Math.ceil(thickness / 2)
            ), color);
        }
    }

    public function drawCircle(centerPoint:FlxPoint, radius:Float, color:FlxColor, fill:Bool = false, thickness:Float = 2, step:Int = 360) {
        drawEllipse(centerPoint, radius * 2, radius * 2, color, fill, thickness, step);
    }

    public function drawEllipse(centerPoint:FlxPoint, width:Float, height:Float, color:FlxColor, fill:Bool = false, thickness:Float = 2, step:Int = 360) {
        var circleVal = Math.PI * 2;
        if (step <= 0) return;
        for (i in 0...step) {
            fillRect(new Rectangle(
                centerPoint.x + (Math.sin(i / step * circleVal) * (width / 2)) - Math.floor(thickness / 2),
                centerPoint.y + (Math.cos(i / step * circleVal) * (height / 2)) - Math.floor(thickness / 2),
                Math.ceil(thickness / 2),
                Math.ceil(thickness / 2)
            ), color);
        }
    }
}