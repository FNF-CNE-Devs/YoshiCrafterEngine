package;

import flixel.math.FlxMath;
import flixel.FlxCamera;
import lime.utils.Assets;
import dev_toolbox.ToolboxHome;
import dev_toolbox.stage_editor.StageEditor;
import ControlsSettingsSubState;
import EngineSettings.Settings;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import Script.HScript;

class PauseSubState extends MusicBeatSubstate
{
	public var grpMenuShit:FlxTypedGroup<Alphabet>;
	public var items(get, set):FlxTypedGroup<Alphabet>;
	function get_items() {return grpMenuShit;}
	function set_items(i) {return grpMenuShit = i;}

	public var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Keybinds', 'Options'];
	public var devMenuItems:Array<String> = ['Logs', 'Edit Opponent', 'Edit Player', 'Edit Stage'];
	public var curSelected:Int = 0;

	public var pauseMusic:FlxSound;
	public var script:Script;
	
	public var pauseMenuScript:Script = null;
	public var levelInfo:FlxText;
	public var levelDifficulty:FlxText;

	public var cam:FlxCamera;

	public var alpha:Float = 0;

	public function new(x:Float, y:Float)
	{
		super();
		
		cam = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);
		cam.bgColor = 0;
		FlxG.cameras.add(cam);
		var valid = true;
		script = Script.create('${Paths.modsPath}/${PlayState.songMod}/ui/PauseSubState');
		if (script == null) {
			valid = false;
			script = new HScript();
		}
		ModSupport.setScriptDefaultVars(script, PlayState.songMod, {});
		script.setVariable("preCreate", function() {});
		script.setVariable("create", function() {});
		script.setVariable("postCreate", function() {});
		script.setVariable("createPost", function() {});
		script.setVariable("preUpdate", function(elapsed) {});
		script.setVariable("update", function(elapsed) {});
		script.setVariable("postUpdate", function(elapsed) {});
		script.setVariable("onSelect", function(name) {}); // return false to cancel default
		script.setVariable("state", this); // return false to cancel default
		if (valid) script.loadFile('${Paths.modsPath}/${PlayState.songMod}/ui/PauseSubState');
		script.executeFunc("preCreate");
		

		var p = Paths.music('breakfast', 'mods/${PlayState.songMod}');
		if (!Assets.exists(p)) p = Paths.music('breakfast');
		pauseMusic = new FlxSound().loadEmbedded(p, true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);


		levelInfo = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		levelDifficulty = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = Std.int(1280) - (levelInfo.width + 20);
		levelDifficulty.x = Std.int(1280) - (levelDifficulty.width + 20);

		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		if (CoolUtil.isDevMode()) {
			for (d in devMenuItems) menuItems.push(d);
			if (PlayState.current.devStage == null) menuItems.remove("Edit Stage");
		}
		menuItems.push("Exit to menu");
		
		script.executeFunc("create");
		
		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [cam];
		script.executeFunc("postCreate");
		script.executeFunc("createPost");
	}

	override function update(elapsed:Float)
	{
		
		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		alpha = FlxMath.lerp(alpha, 0.6, 0.125 * elapsed * 60);

		cam.bgColor = FlxColor.fromRGBFloat(0, 0, 0, alpha);
		script.executeFunc("preUpdate", [elapsed]);
		cam.setSize(FlxG.width, FlxG.height);
		cam.scroll.x = -(FlxG.width - 1280) / 2;
		cam.scroll.y = -(FlxG.height - 720) / 2;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		script.executeFunc("update", [elapsed]);
		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			if (script.executeFunc("onSelect", [daSelected]) != false) {
				switch (daSelected)
				{
					case "Resume":
						close();
					case "Restart Song":
						FlxG.resetState();
					case "Change Keybinds":
						// var oldZoom = PlayState.current.camHUD.zoom;
						var s = new ControlsSettingsSubState(PlayState.SONG.keyNumber, cam);
						// FlxTween.tween(PlayState.current.camHUD, {zoom : 1}, 0.2, {ease : FlxEase.smoothStepInOut});
						// s.closeCallback = function() {
						// 	FlxTween.tween(PlayState.current.camHUD, {zoom : oldZoom}, 0.2, {ease : FlxEase.smoothStepInOut});
						// };
						openSubState(s);
					case "Logs":
						Main.logsOverlay.visible = !Main.logsOverlay.visible;
					case "Edit Player":
						var split = PlayState.SONG.player1.split(":");
						dev_toolbox.character_editor.CharacterEditor.fromFreeplay = true;
						dev_toolbox.ToolboxHome.selectedMod = split[0];
						FlxG.switchState(new dev_toolbox.character_editor.CharacterEditor(split[1]));
					case "Edit Opponent":
						var split = PlayState.SONG.player2.split(":");
						dev_toolbox.character_editor.CharacterEditor.fromFreeplay = true;
						dev_toolbox.ToolboxHome.selectedMod = split[0];
						FlxG.switchState(new dev_toolbox.character_editor.CharacterEditor(split[1]));
					case "Edit Stage":
						var devStageSplit = PlayState.current.devStage.split(":");
						ToolboxHome.selectedMod = devStageSplit[0];
						StageEditor.fromFreeplay = true;
						FlxG.switchState(new StageEditor(devStageSplit[1]));
					case "Options":
						OptionsMenu.fromFreeplay = true;
						FlxG.switchState(new OptionsMenu(0, 0));
					case "Exit to menu":
						FlxG.switchState(new MainMenuState());
				}
			}
			
		}

		if (FlxControls.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
		script.executeFunc("updatePost", [elapsed]);
		script.executeFunc("postUpdate", [elapsed]);
	}

	override function destroy()
	{
		pauseMusic.destroy();
		FlxG.cameras.remove(cam);
		cam.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		var oldSelected = curSelected;
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		if (script.executeFunc("onChangeSelected", [curSelected]) != false) {		
			var bullShit:Int = 0;

			for (item in grpMenuShit.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.alpha = 0.6;
				// item.setGraphicSize(Std.int(item.width * 0.8));

				if (item.targetY == 0)
				{
					item.alpha = 1;
					// item.setGraphicSize(Std.int(item.width));
				}
			}	
		} else {
			curSelected = oldSelected;
		}
	}
}
