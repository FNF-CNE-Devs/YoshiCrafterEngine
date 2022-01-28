import flixel.system.scaleModes.BaseScaleMode;
import flixel.FlxG;

class WideScreenScale extends BaseScaleMode
{
	public function new()
	{
		super();
	}

	override function updateGameSize(Width:Int, Height:Int):Void
    {
        // gameSize.x = Std.int(Width * _widthScale);
        // gameSize.y = Std.int(Height * _heightScale);
        var scale = (Width / Height) / (1280 / 720);
        if (scale < 1) {
            @:privateAccess
            FlxG.width = 1280;
            @:privateAccess
            FlxG.height = Std.int(720 / scale);
        } else {
            @:privateAccess
            FlxG.width = Std.int(1280 * scale);
            @:privateAccess
            FlxG.height = 720;
        }
        gameSize.x = Width;
        gameSize.y = Height;
        updatePlayStateHUD();
    }

    public static function updatePlayStateHUD() {
        FlxG.camera.width = FlxG.width;
        FlxG.camera.height = FlxG.height;
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
        if (PlayState.current != null) {
            if (PlayState.current.camHUD != null) {
                PlayState.current.camHUD.width = Std.int(PlayState.current.guiSize.x);
                PlayState.current.camHUD.height = Std.int(PlayState.current.guiSize.y);
                PlayState.current.camHUD.x = (FlxG.width - 1280) / 2;
                PlayState.current.camHUD.y = (FlxG.height - 720) / 2;
                // PlayState.current.camHUD.setScale(Math.min(FlxG.width / 1280, 1), Math.min(FlxG.width / 1280, 1));
            }
            if (PlayState.current.camGame != null) {
                PlayState.current.camGame.width = FlxG.width;
                PlayState.current.camGame.height = FlxG.height;
            }
            // if (PlayState.current.camFollow != null) {
            //     FlxG.camera.follow(PlayState.current.camFollow, LOCKON, 0.04);
            // }
        }
        if (FlxG.camera.target != null) FlxG.camera.follow(FlxG.camera.target, LOCKON, FlxG.camera.followLerp);
        // FlxG.camera.
    }

    override function updateGamePosition():Void
    {
        FlxG.game.x = FlxG.game.y = 0;
        updatePlayStateHUD();
    }
}