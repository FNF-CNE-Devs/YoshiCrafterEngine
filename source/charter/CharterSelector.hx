package charter;

class CharterSelector extends FlxSprite {
    public var time:Float = 0;
    public function new() {
        super();
        loadGraphic(Paths.image("charter_selector", "preload"));
        antialiasing = true;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        time = (time + elapsed) % 2;
    }

    private var __oldAlpha:Float = 0;
    private var __oldScaleX:Float = 0;
    private var __oldScaleY:Float = 0;
    private var __drawRatio:Float = 0;
    public override function draw() {
        // stores old variables (not defining new variables so that the garbage collector doesnt go nuts)
        __oldAlpha = alpha;
        __oldScaleX = scale.x;
        __oldScaleY = scale.y;
        __drawRatio = Math.sin(time * Math.PI);

        // applying ratio
        alpha -= __drawRatio / 3;
        scale.x += 0.05 + (__drawRatio * 0.05);
        scale.y += 0.05 + (__drawRatio * 0.05);

        // drawing
        super.draw();

        // reapplying old variables
        alpha = __oldAlpha;
        scale.x = __oldScaleX;
        scale.y = __oldScaleY;
    }
}