import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import sys.thread.Thread;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;

class FunkinLoadState extends MusicBeatState {
    // LOADING STUFF
    public var nextState:FlxState;
    public var done:Bool = false;
    public var doingTrans:Bool = false;

    // TIME ELAPSED
    public var time:Float = 0;

    // VISUALS (art by gray shes amazing)
    public var loadingText:AlphabetOptimized;
    public var bg:FlxSpriteGroup;
    public var w:Float = 775;
    public var h:Float = 550;

    // CAMERA MANAGEMENT WITHOUT FUCKING EVERYTHING UP
    public var curCamera:FlxCamera;

    public function new(state:FlxState) {
        super();
        nextState = state;
    }

    public override function create() {
        FlxTransitionableState.skipNextTransIn = true;
        super.create();
        
        bg = new FlxSpriteGroup();
        bg.x = 0;
        bg.y = 0;

        for(x in 0...Math.ceil(FlxG.width / w)+1) {
            for(y in 0...(Math.ceil(FlxG.height / h)+1)) {
                // bg pattern
                var pattern = new FlxSprite(x * w, y * h);
                pattern.loadGraphic(Paths.image("loading/bgpattern", "preload"));
                pattern.antialiasing = true;
                bg.add(pattern);
            }
        }
        add(bg);

        MusicBeatState.doCachingShitNextTime = false;
        
        loadingText = new AlphabetOptimized(0, 0, "Loading...", false, 0.5);
        loadingText.x = FlxG.width - 25 - loadingText.width;
        loadingText.y = FlxG.height - 25 - loadingText.height;
        add(loadingText);

        curCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);

        cameras = bg.cameras = [curCamera];

        load();

        for(e in members)
            if (e is FlxSprite)
                cast(e, FlxSprite).cameras = [curCamera];

    }

    public function load() {
        doingTrans = false;
        done = false;
        time = 0;
        
        FlxG.cameras.add(curCamera, false);
        FlxG.cameras.cameraAdded.add(onCameraAdded);
        FlxG.cameras.cameraReset.add(onCameraReset);
        FlxG.cameras.cameraResetPost.add(onCameraResetPost);

        persistentUpdate = true;
        persistentDraw = true;

        Thread.runWithEventLoop(function() {
            FlxTransitionableState.skipNextTransIn = true;
            nextState.create();
            done = true;
        });
    }
    
    public function onCameraReset(c:FlxCamera) {
        FlxG.cameras.remove(curCamera, false);
    }
    public function onCameraResetPost(c:FlxCamera) {
        FlxG.cameras.add(curCamera, false);
    }
    public function onCameraAdded(c:FlxCamera) {
        if (c != curCamera && curCamera.flashSprite != null) {
            FlxG.cameras.remove(curCamera, false);
            FlxG.cameras.add(curCamera, false);
        }
    }
    private function postStateSwitch() {
        FlxG.cameras.remove(curCamera, false);
        FlxG.signals.postStateSwitch.remove(postStateSwitch);
    }

    
    public override function update(elapsed:Float) {
        super.update(elapsed);
        time += elapsed;

        bg.x -= w * elapsed / 4;
        bg.x %= w;
        bg.y -= h * elapsed / 4;
        bg.y %= h;

        loadingText.text = "Loading" + [for(i in 0...(1+(Std.int(time * 1.5) % 3))) "."].join("");

        if (done && !doingTrans) {
            doingTrans = true;
            FlxG.signals.postStateSwitch.add(postStateSwitch);
            curCamera.fade(0xFF000000, 0.25, false, function() {
                FlxG.game.resetStuffOnSwitch = false;
                FlxG.cameras.cameraAdded.remove(onCameraAdded);
                FlxG.cameras.cameraReset.remove(onCameraReset);
                FlxG.cameras.cameraResetPost.remove(onCameraResetPost);
                FlxG.switchState(nextState);
            });
        }
    }
}