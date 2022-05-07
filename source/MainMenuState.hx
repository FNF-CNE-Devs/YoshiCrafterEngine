package;

import mod_support_stuff.SwitchModSubstate;
import Script.HScript;
import dev_toolbox.ToolboxMain;
import mod_support_stuff.MenuOptions;
import dev_toolbox.ToolboxMessage;
import flixel.input.keyboard.FlxKey;
import flixel.addons.ui.FlxUIButton;
import lime.utils.Assets;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircle;
import EngineSettings.Settings;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
#if newgrounds
import io.newgrounds.NG;
import io.newgrounds.components.MedalComponent;
#end
import flixel.math.FlxPoint;
import lime.app.Application;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public var mainMenuScript:Script = null;

	public var curSelected:Int = 0;

	public var menuItems:FlxTypedGroup<FlxSprite>;

	// imagine yoshiCrafter engine on switch lmfao
	#if !switch
	// var optionShit:Array<String> = ['story mode', 'freeplay', 'mods', 'donate', 'credits', 'options'];
	#else
	// var optionShit:Array<String> = ['story mode', 'freeplay', 'options'];
	#end
	public var optionShit:MenuOptions = new MenuOptions();
	public var options(get, set):MenuOptions;
	function get_options() {return optionShit;};
	function set_options(o) {return optionShit = o;};

	public var magenta:FlxSprite;
	public var camFollow:FlxObject;
	public var backButton:FlxClickableSprite;
	public var fallBackBG:FlxSprite;
	public var bg:FlxSprite;
	public var mouseControls:Bool = true;

	public var factor(get, never):Float;

	function get_factor() {
		return Math.min(650 / optionShit.length, 100);
	}

	override function create()
	{
		reloadModsState = true;
		
		optionShit.add('story mode', function() {
			FlxG.switchState(new StoryMenuState());
		}, Paths.getCustomizableSparrowAtlas('FNF_main_menu_assets'), 'story mode basic', 'story mode white');
		optionShit.add('freeplay', function() {
			// FlxTransitionableState.skipNextTransIn = true;
			// FlxTransitionableState.skipNextTransOut = true;
			FlxG.switchState(new FreeplayState());
		}, Paths.getCustomizableSparrowAtlas('FNF_main_menu_assets'), 'freeplay basic', 'freeplay white');
		optionShit.add('mods', function() {
			FlxG.switchState(new ModMenuState());
		}, Paths.getCustomizableSparrowAtlas('FNF_main_menu_assets'), 'mods basic', 'mods white');
		optionShit.add('donate', function() {
			#if linux
				Sys.command('/usr/bin/xdg-open', ["https://ninja-muffin24.itch.io/funkin", "&"]);
			#else
				FlxG.openURL('https://ninja-muffin24.itch.io/funkin');
			#end
		}, Paths.getCustomizableSparrowAtlas('FNF_main_menu_assets'), 'donate basic', 'donate white').direct = true;
		optionShit.add('credits', function() {
			FlxG.switchState(new CreditsState());
		}, Paths.getCustomizableSparrowAtlas('FNF_main_menu_assets'), 'credits basic', 'credits white');
		optionShit.add('options', function() {
			// FlxTransitionableState.skipNextTransIn = true;
			// FlxTransitionableState.skipNextTransOut = true;
			OptionsMenu.fromFreeplay = false;
			// smooth af transition
			FlxG.switchState(new OptionsMenu(0, -FlxG.camera.scroll.y * 0.18));
		}, Paths.getCustomizableSparrowAtlas('FNF_main_menu_assets'), 'options basic', 'options white');

        // persistentUpdate = false;
		if (Settings.engineSettings.data.developerMode) {
			optionShit.insert(4, 'toolbox', function() {
				FlxG.switchState(new ToolboxMain());
			}, Paths.getCustomizableSparrowAtlas('FNF_main_menu_assets'), 'toolbox basic', 'toolbox white');
		}
			
		mainMenuScript = Script.create('${Paths.modsPath}/${Settings.engineSettings.data.selectedMod}/ui/MainMenuState');
		var valid = true;
		if (mainMenuScript == null) {
			valid = false;
			mainMenuScript = new HScript();
		}
		mainMenuScript.setVariable("create", function() {});
		mainMenuScript.setVariable("update", function(elapsed:Float) {});
		mainMenuScript.setVariable("beatHit", function(curBeat:Int) {});
		mainMenuScript.setVariable("stepHit", function(curStep:Int) {});
		mainMenuScript.setVariable("onSelect", function(obj:MenuOption) {});
		mainMenuScript.setVariable("onSelectEnd", function(obj:MenuOption) {});
		mainMenuScript.setVariable("state", this);
		ModSupport.setScriptDefaultVars(mainMenuScript, Settings.engineSettings.data.selectedMod, {});
		if (valid) mainMenuScript.loadFile('${Paths.modsPath}/${Settings.engineSettings.data.selectedMod}/ui/MainMenuState');
		mainMenuScript.executeFunc("create");
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Main Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		CoolUtil.playMenuMusic();

		// if (FlxG.sound.music != null)
		// {
		// 	if (!FlxG.sound.music.playing)
		// 	{
		// 		FlxG.sound.playMusic(daFunkyMusicPath);
		// 	}
		// } else {
		// 	FlxG.sound.playMusic(daFunkyMusicPath);
		// }

		// persistentUpdate = persistentDraw = true;

		fallBackBG = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
		fallBackBG.color = 0xFFFDE871;
		fallBackBG.scrollFactor.set();
		add(fallBackBG);

		var menuBGPath = Paths.image('menuBG');
		if (Assets.exists(Paths.image('menuBG', 'mods/${Settings.engineSettings.data.selectedMod}'))) {
			menuBGPath = Paths.image('menuBG', 'mods/${Settings.engineSettings.data.selectedMod}');
		}
		var menuDesatPath = Paths.image('menuDesat');
		if (Assets.exists(Paths.image('menuDesat', 'mods/${Settings.engineSettings.data.selectedMod}'))) {
			menuDesatPath = Paths.image('menuDesat', 'mods/${Settings.engineSettings.data.selectedMod}');
		}
		bg = new FlxSprite(-80).loadGraphic(menuBGPath);
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);
		

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(menuDesatPath);
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.2));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);


		// troll
		for (i=>option in optionShit.members)
		{
			// var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			var menuItem:FlxSprite = new FlxSprite(0, (FlxG.height / optionShit.length * i) + (FlxG.height / (optionShit.length * 2)));
			menuItem.frames = option.frames;
			menuItem.animation.addByPrefix('idle', option.idle, option.idleFPS == null ? 24 : option.idleFPS);
			menuItem.animation.addByPrefix('selected', option.selected, option.selectedFPS == null ? 24 : option.selectedFPS);
			menuItem.animation.play('idle');
			menuItem.updateHitbox();
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.scrollFactor.set(0, 1 / (optionShit.length));
			menuItem.setGraphicSize(Std.int(factor / menuItem.height * menuItem.width), Std.int(factor));
			menuItem.y -= menuItem.height / 2;
			menuItem.antialiasing = true;
			menuItems.add(menuItem);
		}

		FlxG.camera.follow(camFollow, null, 0.06);

		var fnfVer = Application.current.meta.get('version');
		var yoshiCrafterEngineVer = Main.engineVer;
		var buildVer = Main.buildVer;
		if (buildVer.trim() != "") buildVer = " " + buildVer.trim();
		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, 'YoshiCrafter Engine v$yoshiCrafterEngineVer$buildVer - FNF v$fnfVer - Selected Mod: ${ModSupport.getModName(Settings.engineSettings.data.selectedMod)} (Press TAB to switch)', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if MOBILE_UI
		backButton = new FlxClickableSprite(10, versionShit.y, function() {
			FlxG.switchState(new TitleState());
		});
		backButton.frames = Paths.getSparrowAtlas("ui_buttons", "preload");
		backButton.animation.addByPrefix("button", "exit button");
		backButton.animation.play("button");
		// backButton.scale.x = backButton.scale.y = 0.7;
		backButton.updateHitbox();
		backButton.y -= 10 + backButton.height;
		backButton.scrollFactor.set(0, 0);
		backButton.antialiasing = true;
		backButton.hoverColor = 0xFF66CAFF;
		add(backButton);
		#end

		super.create();
		mainMenuScript.executeFunc("postCreate");
		mainMenuScript.executeFunc("createPost");

		// closeSubState();
	}

	var selectedSomethin:Bool = false;
	var oldPos = FlxG.mouse.getScreenPosition();
	// static function calculatePos() {
	// 	return new FlxPoint(FlxG.game.mouseX / FlxG.scaleMode.gameSize.x * 1280, FlxG.game.mouseY / FlxG.scaleMode.gameSize.y * 720);
	// }
	override function update(elapsed:Float)
	{
		
		mainMenuScript.executeFunc("update", [elapsed]);
		super.update(elapsed);
		// if (subState != null) return;

		if (FlxControls.justPressed.F5) FlxG.resetState();
		if (FlxControls.justPressed.TAB) openSubState(new SwitchModSubstate());

		if (FlxControls.justPressed.SEVEN) {
			persistentUpdate = false;
			if (Settings.engineSettings.data.developerMode) {
				// psych engine shortcut lol
				FlxG.switchState(new dev_toolbox.ToolboxMain());
			} else {
				openSubState(new ThisAintPsych());
			}
		}
		if (mouseControls) {
			if ((FlxG.mouse.getScreenPosition().x != oldPos.x || FlxG.mouse.getScreenPosition().y != oldPos.y) && !selectedSomethin){
				oldPos = FlxG.mouse.getScreenPosition();
				for (i in 0...menuItems.length) {
					// if (FlxG.mouse.overlaps(menuItems.members[i])) {
					var pos = FlxG.mouse.getPositionInCameraView(FlxG.camera);
					if (pos.y > i / menuItems.length * FlxG.height && pos.y < (i + 1) / menuItems.length * FlxG.height && curSelected != i) {
						curSelected = i;
						changeItem();
						break;
					}
				}
			}
		}
			if (FlxG.mouse.pressed && !selectedSomethin
				#if MOBILE_UI
				&& !backButton.hovering
				#end
				)
				select();
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_P)
			{
				CoolUtil.playMenuSFX(0);
				changeItem(-1);
			}

			if (controls.DOWN_P)
			{
				CoolUtil.playMenuSFX(0);
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				select();
			}
		}


		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
		mainMenuScript.executeFunc("postUpdate", [elapsed]);
		mainMenuScript.executeFunc("updatePost", [elapsed]);
	}

	function select() {
		var option = optionShit.members[curSelected];
		mainMenuScript.executeFunc("onSelect", [option]);
		if (option.direct == true)
		{
			mainMenuScript.executeFunc("onSelectEnd", [option]);
			if (option.onSelect != null) option.onSelect();
		}
		else
		{
			selectedSomethin = true;
			CoolUtil.playMenuSFX(1);

			FlxFlicker.flicker(magenta, 1.1, 0.15, false);

			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
					{
						mainMenuScript.executeFunc("onSelectEnd", [option]);
						if (option.onSelect != null) option.onSelect();
					});
				}
			});
		}
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.set(0,0);

			if (spr.ID == curSelected)
			{
				// spr.offset.set(0,-(Math.max(0, spr.height - spr.frames.getByIndex(spr.animation.getByName("idle").frames[0]).sourceSize.y)) / FlxG.height * spr.y);
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
