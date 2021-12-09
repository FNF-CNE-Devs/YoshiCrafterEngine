import flixel.math.FlxPoint;
import openfl.display.BitmapData;
import flixel.util.FlxColor;

typedef GraphData = {
    var number:Float;
    var color:FlxColor;
}

class FreeplayGraph {
    public static function generate(data:Array<GraphData>, width:Int = 305, height:Int = 100, thickness:Int = 10) {
        var total:Float = 0;
        for (g in data) total += g.number;

        var maxAngle = Math.PI * 2;
        var bData = new BitmapDataPlus(width, height + thickness, true, 0x00000000);
        var center = new FlxPoint((width / 2) + 1, (height / 2) + 1);
        bData.drawEllipse(center, width - 2, height - 2, FlxColor.BLACK, false, 2);
        var current:Float = 0;
        for (g in data) {
            var pos = new FlxPoint(center.x + (Math.sin(current / total * maxAngle) * (width / 2)), center.y + (Math.sin(current / total * maxAngle) * (height / 2)));
            bData.drawLine(center, pos, FlxColor.BLACK, 1.5);
            current += g.number;
        }
        current = 0;
        for (g in data) {
            if (g.number / total < 0.05) continue;
            var pos = new FlxPoint(center.x + (Math.sin((current + g.number) / total * maxAngle) * (height / 4)), center.y + (Math.sin((current + g.number)/ total * maxAngle) * (height / 4)));
            bData.floodFill(Std.int(pos.x), Std.int(pos.y), g.color);
            current += g.number;
        }
        return bData;
    }
}