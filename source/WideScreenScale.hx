import flixel.addons.transition.FlxTransitionableState;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.FlxG;

class WideScreenScale extends BaseScaleMode
{
    public var width(default, set):Int = 1280;
    public var height(default, set):Int = 720;
    public var isWidescreen(default, set):Bool = true;

    private function set_width(v:Int) {
        width = v;
        @:privateAccess
        FlxG.game.onResize(null);
        return width;
    }
    private function set_height(v:Int) {
        height = v;
        @:privateAccess
        FlxG.game.onResize(null);
        return height;
    }
    private function set_isWidescreen(v:Bool) {
        isWidescreen = v;
        @:privateAccess
        FlxG.game.onResize(null);
        return isWidescreen;
    }
	public function new()
	{
		super();
	}

	override function updateGameSize(Width:Int, Height:Int):Void
    {
        if (isWidescreen) {
            var scale = (Width / Height) / (width / height);
            if (scale < 1) {
                @:privateAccess
                FlxG.width = width;
                @:privateAccess
                FlxG.height = Std.int(height / scale);
            } else {
                @:privateAccess
                FlxG.width = Std.int(width * scale);
                @:privateAccess
                FlxG.height = height;
            }
            gameSize.x = Width;
            gameSize.y = Height;
            updatePlayStateHUD(width, height);
        } else {
            @:privateAccess
            FlxG.width = width;
            @:privateAccess
            FlxG.height = height;
            
            var ratio:Float = width / height;
            var realRatio:Float = Width / Height;

            var scaleY:Bool = realRatio < ratio;
            if (scaleY)
            {
                gameSize.x = Width;
                gameSize.y = Math.floor(gameSize.x / ratio);
            }
            else
            {
                gameSize.y = Height;
                gameSize.x = Math.floor(gameSize.y * ratio);
            }
            updatePlayStateHUD(width, height);
        }
        
        FlxTransitionableState.defaultTransOut.region.width = FlxTransitionableState.defaultTransIn.region.width = FlxG.width;
        FlxTransitionableState.defaultTransOut.region.height = FlxTransitionableState.defaultTransIn.region.height = FlxG.height;
    }

    public static function updatePlayStateHUD(width:Int = 1280, height:Int = 720) {
        FlxG.camera.width = FlxG.width;
        FlxG.camera.height = FlxG.height;
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
        if (PlayState.current != null) {
            if (PlayState.current.camHUD != null) {
                var oldScroll = -(PlayState.current.camHUD.width - width) / 2;
                PlayState.current.camHUD.width = Std.int(FlxG.width);
                PlayState.current.camHUD.height = Std.int(FlxG.height);
                PlayState.current.camHUD.x = PlayState.current.camHUD.y = 0;
                PlayState.current.camHUD.follow(PlayState.current.camFollowHud, LOCKON, 1);
            }
            if (PlayState.current.camGame != null) {
                PlayState.current.camGame.width = FlxG.width;
                PlayState.current.camGame.height = FlxG.height;
            }
        }
        if (FlxG.camera.target != null) FlxG.camera.follow(FlxG.camera.target, LOCKON, FlxG.camera.followLerp);
    }

    override function updateGamePosition():Void
    {
        if (isWidescreen) {
            FlxG.game.x = FlxG.game.y = 0;
        } else {
            super.updateGamePosition();
        }
        updatePlayStateHUD();
    }

    public function setSize(width:Int, height:Int) {
        this.width = width;
        this.height = height;
    }
}