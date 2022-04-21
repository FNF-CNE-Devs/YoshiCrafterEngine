import flixel.FlxObject;
import flixel.util.FlxAxes;

class FlxSpriteCenterFix {
    public static function cameraCenter(f:FlxObject, ?axes:FlxAxes):FlxObject
    {
        if (axes == null)
            axes = FlxAxes.XY;

        if (axes != FlxAxes.Y)
            f.x = (f.camera.width / 2) - (f.width / 2);
        if (axes != FlxAxes.X)
            f.y = (f.camera.height / 2) - (f.height / 2);

        return f;
    }
}