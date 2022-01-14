import ControlsSettingsSubState.ControlsSettingsSub;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxBasic;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import Note.NoteDirection;
import flixel.input.keyboard.FlxKey;
import EngineSettings.Settings;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;

class ControlsSettings extends MusicBeatState {
    var sub:ControlsSettingsSub;
    var arrowNumber:Int;
    public function new(arrowNumber:Int)
    {
        this.arrowNumber = arrowNumber;
        super();
    }
    
	override function create() {
		super.create();
        
        // var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		// menuBG.color = 0x88888888;
		// menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		// menuBG.updateHitbox();
		// menuBG.screenCenter();
        // add(menuBG);

        sub = new ControlsSettingsSub(arrowNumber, FlxG.camera);
        sub.closeCallback = function() {
            FlxG.switchState(new OptionsMenu(0, 0));
        };
        openSubState(sub);
    }

    override function update(elapsed:Float) {
        sub.update(elapsed);
        super.update(elapsed);
    }
}