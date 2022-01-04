package;

import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.app.Application;
import lime.graphics.Image;
import lime.media.AudioContext;
import lime.media.AudioManager;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.geom.Matrix;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetManifest;
import openfl.utils.AssetType;
import openfl.display.PNGEncoderOptions;

using StringTools;

#if windows
import Discord.DiscordClient;
#end
#if desktop
import Sys;
import sys.FileSystem;
#end

class FNFStage
{
	public var curBeat:Int = 0;

	public var bfOffset:FlxPoint = new FlxPoint(0, 0);
	public var gfOffset:FlxPoint = new FlxPoint(0, 0);
	public var dadOffset:FlxPoint = new FlxPoint(0, 0);

	public function new() {}

	public function createAfterGf() {}
	
	public function start() {}

	public function createAfterChars() {}

	public function createInFront() {
	}

	public function create()
	{
	}

	public function update(elapsed) {}

	public function beatHit(curBeat)
	{
		this.curBeat = curBeat;
	}

	public function stepHit(curStep) {}

	public function destroy() {

	}
}
class Philly extends FNFStage
{
	public var curLight:Int = 0;
	public var phillyTrain:FlxSprite;
	public var bg:FlxSprite;
	public var city:FlxSprite;
	public var street:FlxSprite;
	public var streetBehind:FlxSprite;
	public var trainSound:FlxSound;
	public var light:FlxSprite;
	public var phillyCityLights:Array<Int> = [
		0xFF31A2FD,
		0xFF31FD8C,
		0xFFFB33F5,
		0xFFFD4531,
		0xFFFBA633,
	];

	public var trainMoving:Bool = false;
	public var trainFrameTiming:Float = 0;

	public var trainCars:Int = 8;
	public var trainFinishing:Bool = false;
	public var trainCooldown:Int = 0;
	public var startedMoving:Bool = false;
	public var triggeredAlready:Bool = false;

	override function update(elapsed)
	{
		super.update(elapsed);
		if (trainMoving)
		{
			trainFrameTiming += elapsed;

			if (trainFrameTiming >= 1 / 24)
			{
				updateTrainPos();
				trainFrameTiming = 0;
			}
		}

		// General duration of the song
		if (curBeat < 250)
		{
			// Beats to skip or to stop GF from cheering
			if (curBeat != 184 && curBeat != 216)
			{
				if (curBeat % 16 == 8)
				{
					// Just a garantee that it'll trigger just once
					if (!triggeredAlready)
					{
						PlayState.current.gf.playAnim('cheer');
						triggeredAlready = true;
					}
				}
				else
					triggeredAlready = false;
			}
		}
	}

	override function destroy() {

	}

	override function beatHit(curBeat)
	{
		super.beatHit(curBeat);

		if (curBeat % 4 == 0)
		{
			var c = phillyCityLights[FlxG.random.int(0, phillyCityLights.length - 1)];
			light.color = c;
		}

		if (!trainMoving)
			trainCooldown += 1;

		

		if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
		{
			trainCooldown = FlxG.random.int(-4, 0);
			trainStart();
		}
	}

	override function createInFront() {
		super.createInFront();
	}

	override function create()
	{
		super.create();
		bg = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		bg.scrollFactor.set(0.1, 0.1);
		PlayState.current.add(bg);

		city = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		city.scrollFactor.set(0.3, 0.3);
		city.setGraphicSize(Std.int(city.width * 0.85));
		city.updateHitbox();
		PlayState.current.add(city);

		light = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win'));
		light.scrollFactor.set(0.3, 0.3);
		light.setGraphicSize(Std.int(light.width * 0.85));
		light.updateHitbox();
		light.antialiasing = true;
		PlayState.current.add(light);

		streetBehind = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		PlayState.current.add(streetBehind);

		phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		PlayState.current.add(phillyTrain);

		trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		FlxG.sound.list.add(trainSound);

		// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		street = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
		PlayState.current.add(street);
	}

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			PlayState.current.gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		PlayState.current.gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}
}
class Limo extends FNFStage
{
	
}
class DefaultStage extends FNFStage
{
	public override function create()
	{
		PlayState.current.defaultCamZoom = 0.9;

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		PlayState.current.add(bg);

		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		PlayState.current.add(stageFront);

		var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set(1.3, 1.3);
		stageCurtains.active = false;

		PlayState.current.add(stageCurtains);
	}
}
class Mall extends FNFStage
{
	
}
class MallEvil extends FNFStage
{
	
}
class School extends FNFStage
{
	var bgGirls:BackgroundGirls;

	public override function create()
	{
		super.create();
		bfOffset = new FlxPoint(200, 220);
		gfOffset = new FlxPoint(180, 300);
		// defaultCamZoom = 0.9;

		var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		bgSky.scrollFactor.set(0.1, 0.1);
		PlayState.current.add(bgSky);

		var repositionShit = -200;

		var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		bgSchool.scrollFactor.set(0.6, 0.90);
		PlayState.current.add(bgSchool);

		var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		bgStreet.scrollFactor.set(0.95, 0.95);
		PlayState.current.add(bgStreet);

		var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		fgTrees.scrollFactor.set(0.9, 0.9);
		PlayState.current.add(fgTrees);

		var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		bgTrees.frames = treetex;
		bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		bgTrees.animation.play('treeLoop');
		bgTrees.scrollFactor.set(0.85, 0.85);
		PlayState.current.add(bgTrees);

		var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		treeLeaves.animation.play('leaves');
		treeLeaves.scrollFactor.set(0.85, 0.85);
		PlayState.current.add(treeLeaves);

		var widShit = Std.int(bgSky.width * 6);

		bgSky.setGraphicSize(widShit);
		bgSchool.setGraphicSize(widShit);
		bgStreet.setGraphicSize(widShit);
		bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		treeLeaves.setGraphicSize(widShit);

		fgTrees.updateHitbox();
		bgSky.updateHitbox();
		bgSchool.updateHitbox();
		bgStreet.updateHitbox();
		bgTrees.updateHitbox();
		treeLeaves.updateHitbox();

		bgGirls = new BackgroundGirls(-100, 190);
		bgGirls.scrollFactor.set(0.9, 0.9);

		if (PlayState.SONG.song.toLowerCase() == 'roses')
		{
			bgGirls.getScared();
		}

		bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
		bgGirls.updateHitbox();
		PlayState.current.add(bgGirls);
	}

	public override function beatHit(curBeat:Int) {
		super.beatHit(curBeat);
		bgGirls.dance();
	}
}
class SchoolEvil extends FNFStage
{
	public override function create() {

		var posX = 400;
		var posY = 200;

		bfOffset = new FlxPoint(200, 220);
		gfOffset = new FlxPoint(180, 300);

		var bg:FlxSprite = new FlxSprite(posX, posY);
		bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		bg.animation.addByPrefix('idle', 'background 2', 24);
		bg.animation.play('idle');
		bg.scrollFactor.set(0.8, 0.9);
		bg.scale.set(6, 6);
		PlayState.current.add(bg);

		/* 
			var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolBG'));
			bg.scale.set(6, 6);
			// bg.setGraphicSize(Std.int(bg.width * 6));
			// bg.updateHitbox();
			add(bg);
			var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.image('weeb/evilSchoolFG'));
			fg.scale.set(6, 6);
			// fg.setGraphicSize(Std.int(fg.width * 6));
			// fg.updateHitbox();
			add(fg);
			wiggleShit.effectType = WiggleEffectType.DREAMY;
			wiggleShit.waveAmplitude = 0.01;
			wiggleShit.waveFrequency = 60;
			wiggleShit.waveSpeed = 0.8;
		 */

		// bg.shader = wiggleShit.shader;
		// fg.shader = wiggleShit.shader;

		/* 
			var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
			var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
			// Using scale since setGraphicSize() doesnt work???
			waveSprite.scale.set(6, 6);
			waveSpriteFG.scale.set(6, 6);
			waveSprite.setPosition(posX, posY);
			waveSpriteFG.setPosition(posX, posY);
			waveSprite.scrollFactor.set(0.7, 0.8);
			waveSpriteFG.scrollFactor.set(0.9, 0.8);
			// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
			// waveSprite.updateHitbox();
			// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
			// waveSpriteFG.updateHitbox();
			add(waveSprite);
			add(waveSpriteFG);
		 */
	}
}
class KapiExpurgation extends FNFStage
{
	public var nyawBeats:Array<Int> = [31, 135, 363, 203];
	public override function create() {
		super.create();

		PlayState.current.defaultCamZoom = 0.5;
		bfOffset = new FlxPoint(350, -160);
		dadOffset = new FlxPoint(0, -160);
		gfOffset = new FlxPoint(0, -160);

		var bg:FlxSprite = new FlxSprite(-10, -10).loadGraphic(Paths.image('kapiexpurgation/bg', 'yoshistuff'));
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		bg.setGraphicSize(Std.int(bg.width * 4));
		PlayState.current.add(bg);

		var energyWall:FlxSprite = new FlxSprite(1350, -690).loadGraphic(Paths.image("kapiexpurgation/Energywall", "yoshistuff"));
		energyWall.antialiasing = true;
		energyWall.scrollFactor.set(0.9, 0.9);
		PlayState.current.add(energyWall);

		var stageFront:FlxSprite = new FlxSprite(-350, -355).loadGraphic(Paths.image('kapiexpurgation/daBackground', 'yoshistuff'));
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.55));
		PlayState.current.add(stageFront);

		var cover:FlxSprite = new FlxSprite(-180, 755).loadGraphic(Paths.image('kapiexpurgation/cover', 'yoshistuff'));
		cover.antialiasing = true;
		cover.scrollFactor.set(0.9, 0.9);
		cover.setGraphicSize(Std.int(cover.width * 1.55));
		PlayState.current.add(cover);
	}

	public override function beatHit(b) {
		super.beatHit(b);
		if (nyawBeats.contains(b)) PlayState.current.dad.playAnim('meow', true);
		if (FlxG.camera.zoom < 1.35 && curBeat % 1 == 0 && curBeat != 283 && curBeat != 282) {
			FlxG.camera.zoom += 0.02;
			PlayState.current.camHUD.zoom += 0.022;
		}
		if (curBeat == 283)
		{
			PlayState.current.boyfriend.playAnim('hey', true);
		}
	}
}
class Tank extends FNFStage
{
	private var bfAscendMinPos:Float;
	private var tankmanAscendThing:FlxSprite;
	private var bfAscendThing:FlxSprite;

	public override function create() {
		super.create();
		PlayState.current.defaultCamZoom = 0.90;
		bfOffset = new FlxPoint(40, 0);
		dadOffset = new FlxPoint(-80, 60);
		gfOffset = new FlxPoint(-170, -75);
		
		var tankBg:FlxSprite = new FlxSprite(-500, 0).loadGraphic(Paths.image('tank/tankBg', 'yoshistuff'));
		tankBg.scrollFactor.set(0, 0);
		tankBg.setGraphicSize(2560, 1920);
		tankBg.updateHitbox();
		// tankBg.antialiasing = true;
		PlayState.current.add(tankBg);

		var tankSky:FlxSprite = new FlxSprite(-400, -600).loadGraphic(Paths.image('tank/tankSky', 'yoshistuff'));
		tankSky.scrollFactor.set(0, 0);
		tankSky.antialiasing = true;
		PlayState.current.add(tankSky);

		var tankClouds:FlxSprite = new FlxSprite(FlxG.random.int(-700, -100), FlxG.random.int(-20, 20)).loadGraphic(Paths.image('tank/tankClouds', 'yoshistuff'));
		tankClouds.scrollFactor.set(0.1, 0.1);
		tankClouds.antialiasing = true;
		tankClouds.velocity.x = FlxG.random.float(5, 15);
		PlayState.current.add(tankClouds);

		var tankMountains:FlxSprite = new FlxSprite(-300, -20).loadGraphic(Paths.image('tank/tankMountains', 'yoshistuff'));
		tankMountains.setGraphicSize(Std.int(tankMountains.width * 1.2));
		tankMountains.scrollFactor.set(0.2, 0.2);
		tankMountains.updateHitbox();
		tankMountains.antialiasing = true;
		PlayState.current.add(tankMountains);

		var tankBuildings:FlxSprite = new FlxSprite(-300, -20).loadGraphic(Paths.image('tank/tankBuildings', 'yoshistuff'));
		tankBuildings.setGraphicSize(Std.int(tankBuildings.width * 1.1));
		tankBuildings.scrollFactor.set(0.3, 0.3);
		tankBuildings.updateHitbox();
		tankBuildings.antialiasing = true;
		PlayState.current.add(tankBuildings);

		var tankRuins:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('tank/tankRuins', 'yoshistuff'));
		tankRuins.setGraphicSize(Std.int(tankRuins.width * 1.1));
		tankRuins.scrollFactor.set(0.35, 0.35);
		tankRuins.updateHitbox();
		tankRuins.antialiasing = true;
		PlayState.current.add(tankRuins);

		var smokeLeftTex = Paths.getSparrowAtlas('tank/smokeLeft', 'yoshistuff');
		var smokeLeft = new FlxSprite(-200, -100);
		smokeLeft.scrollFactor.set(0.4, 0.4);
		smokeLeft.frames = smokeLeftTex;
		smokeLeft.animation.addByPrefix('SmokeBlurLeft', "SmokeBlurLeft", 24);
		smokeLeft.animation.play('SmokeBlurLeft');
		smokeLeft.antialiasing = true;
		PlayState.current.add(smokeLeft);

		var smokeRightTex = Paths.getSparrowAtlas('tank/smokeRight', 'yoshistuff');
		var smokeRight = new FlxSprite(1100, -100);
		smokeRight.scrollFactor.set(0.4, 0.4);
		smokeRight.frames = smokeRightTex;
		smokeRight.animation.addByPrefix('SmokeRight', "SmokeRight", 24);
		smokeRight.animation.play('SmokeRight');
		smokeRight.antialiasing = true;
		PlayState.current.add(smokeRight);

		var tankWatchtowerTex = Paths.getSparrowAtlas('tank/tankWatchtower', 'yoshistuff');
		var tankWatchtower = new FlxSprite(100, 50);
		tankWatchtower.scrollFactor.set(0.5, 0.5);
		tankWatchtower.frames = tankWatchtowerTex;
		tankWatchtower.animation.addByPrefix('watchtower gradient color', "watchtower gradient color", 24);
		tankWatchtower.animation.play('watchtower gradient color');
		tankWatchtower.antialiasing = true;
		PlayState.current.add(tankWatchtower);

		// var tankRollingTex = Paths.getSparrowAtlas('tank/tankRolling', 'yoshistuff');
		// tankRolling = new FlxSprite(300, 300);
		// tankRolling.scrollFactor.set(0.5, 0.5);
		// tankRolling.frames = tankRollingTex;
		// tankRolling.animation.addByPrefix('BG tank w lighting instance 1', "BG tank w lighting instance 1", 24);
		// tankRolling.animation.play('BG tank w lighting instance 1');
		// tankRolling.antialiasing = true;
		// #if debug
		// FlxG.watch.add(tankRolling, 'x');
		// FlxG.watch.add(tankRolling, 'y');
		// FlxG.watch.add(this, 'tankAngle');
		// FlxG.watch.add(this, 'tankSpeed');
		// #end
		// PlayState.current.add(tankRolling);

		var tankGround:FlxSprite = new FlxSprite(-420, -150).loadGraphic(Paths.image('tank/tankGround', 'yoshistuff'));
		// tankRuins.scrollFactor.set(,0.35);
		tankGround.setGraphicSize(Std.int(tankGround.width * 1.15));
		tankGround.updateHitbox();
		tankGround.antialiasing = true;
		PlayState.current.add(tankGround);
	}

	public override function createInFront() {
		tankmanAscendThing = new FlxSprite().loadGraphic(Paths.image('tank/ascends/damnHeAscends', 'yoshistuff'));
		tankmanAscendThing.setGraphicSize(Std.int(tankmanAscendThing.width * 3));
		tankmanAscendThing.updateHitbox();
		tankmanAscendThing.x = PlayState.current.dad.x - 150;
		tankmanAscendThing.y = PlayState.current.dad.y - 100;
		tankmanAscendThing.angularVelocity = 45;
		tankmanAscendThing.alpha = 0;
		PlayState.current.remove(PlayState.current.dad);
		PlayState.current.add(tankmanAscendThing);
		PlayState.current.add(PlayState.current.dad);

		bfAscendThing = new FlxSprite().loadGraphic(Paths.image('tank/ascends/damnHeAscends', 'yoshistuff'));
		bfAscendThing.setGraphicSize(Std.int(bfAscendThing.width * 3));
		bfAscendThing.updateHitbox();
		bfAscendThing.x = PlayState.current.boyfriend.x - 150;
		bfAscendThing.y = PlayState.current.boyfriend.y - 200;
		bfAscendThing.angularVelocity = 45;
		bfAscendThing.alpha = 0;
		PlayState.current.remove(PlayState.current.boyfriend);
		PlayState.current.add(bfAscendThing);
		PlayState.current.add(PlayState.current.boyfriend);

		var tank0Tex = Paths.getSparrowAtlas('tank/tank0', 'yoshistuff');
		var tank0 = new FlxSprite(-500, 650);
		tank0.scrollFactor.set(1.7, 1.5);
		tank0.frames = tank0Tex;
		tank0.animation.addByPrefix('fg', "fg", 24);
		tank0.animation.play('fg');
		tank0.antialiasing = true;
		PlayState.current.add(tank0);

		var tank1Tex = Paths.getSparrowAtlas('tank/tank1', 'yoshistuff');
		var tank1 = new FlxSprite(-300, 750);
		tank1.scrollFactor.set(2, 0.2);
		tank1.frames = tank1Tex;
		tank1.animation.addByPrefix('fg', "fg", 24);
		tank1.animation.play('fg');
		tank1.antialiasing = true;
		PlayState.current.add(tank1);

		var tank2Tex = Paths.getSparrowAtlas('tank/tank2', 'yoshistuff');
		var tank2 = new FlxSprite(450, 940);
		tank2.scrollFactor.set(1.5, 1.5);
		tank2.frames = tank2Tex;
		tank2.animation.addByPrefix('foreground', "foreground", 24);
		tank2.animation.play('foreground');
		tank2.antialiasing = true;
		PlayState.current.add(tank2);

		var tank4Tex = Paths.getSparrowAtlas('tank/tank4', 'yoshistuff');
		var tank4 = new FlxSprite(1300, 900);
		tank4.scrollFactor.set(1.5, 1.5);
		tank4.frames = tank4Tex;
		tank4.animation.addByPrefix('fg', "fg", 24);
		tank4.animation.play('fg');
		tank4.antialiasing = true;
		PlayState.current.add(tank4);

		var tank5Tex = Paths.getSparrowAtlas('tank/tank5', 'yoshistuff');
		var tank5 = new FlxSprite(1620, 700);
		tank5.scrollFactor.set(1.5, 1.5);
		tank5.frames = tank5Tex;
		tank5.animation.addByPrefix('fg', "fg", 24);
		tank5.animation.play('fg');
		tank5.antialiasing = true;
		PlayState.current.add(tank5);

		var tank3Tex = Paths.getSparrowAtlas('tank/tank3', 'yoshistuff');
		var tank3 = new FlxSprite(1300, 1200);
		tank3.scrollFactor.set(3.5, 2.5);
		tank3.frames = tank3Tex;
		tank3.animation.addByPrefix('fg', "fg", 24);
		tank3.animation.play('fg');
		tank3.antialiasing = true;
		PlayState.current.add(tank3);
	}

	public override function update(elapsed) {
		super.update(elapsed);
		if (curBeat >= 224) {
			var newAlpha:Float = tankmanAscendThing.alpha + (elapsed / 3);
			if (newAlpha > 1)
				newAlpha = 1;
			tankmanAscendThing.alpha = newAlpha;
		}
		if (curBeat >= 256)
		{
			var newAlpha:Float = bfAscendThing.alpha + (elapsed / 3);
			if (newAlpha > 1)
				newAlpha = 1;
			bfAscendThing.alpha = newAlpha;
		}
	}

	public override function beatHit(b) {
		super.beatHit(b);
		if (curBeat == 224)
		{
			PlayState.current.dad.velocity.y = -100;
			PlayState.current.camFollow.velocity.y = -100;

			tankmanAscendThing.velocity.y = -100;
		}
		if (curBeat == 256)
		{
			PlayState.current.dad.velocity.y = 0;
			PlayState.current.boyfriend.velocity.y = -100;

			tankmanAscendThing.velocity.y = 0;
			bfAscendThing.velocity.y = -100;
		}
		if (curBeat == 288)
		{
			PlayState.current.dad.velocity.y = -100;
			PlayState.current.boyfriend.velocity.y = 0;

			tankmanAscendThing.velocity.y = -100;
			bfAscendThing.velocity.y = 0;
		}
		if (curBeat == 320)
		{
			PlayState.current.dad.velocity.y = 0;
			PlayState.current.boyfriend.velocity.y = -100;

			tankmanAscendThing.velocity.y = 0;
			bfAscendThing.velocity.y = -100;
		}
		if (curBeat == 352)
		{
			PlayState.current.dad.velocity.y = 0;
			PlayState.current.boyfriend.velocity.y = 0;
			PlayState.current.camFollow.velocity.y = 0;
			tankmanAscendThing.velocity.y = 0;
			bfAscendThing.velocity.y = 0;
		}
	}
}