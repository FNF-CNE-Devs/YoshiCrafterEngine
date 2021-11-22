package;

import LoadSettings.Settings;
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

typedef CameraZooms = {
	var hud:Float;
	var game:Float;
}
class Modchart {
    public function new() {

    }

    public function start() {

    }

	/*
	* @param curStep Step
	* @param curBeat Beat
	*/
	public function getCameraZoom(curStep:Int, curBeat:Int):CameraZooms {
		if (curBeat % 4 == 0) {
			return {
				hud : 0.03,
				game : 0.015
			};
		} else {
			return {
				hud : 0,
				game : 0
			};
		}
	}

    public function create() {
        
    }

    public function update(elapsed:Float) {

    }

    public function stepHit(curStep:Int) {
        
    }

    public function beatHit(curBeat:Int) {
        
    }
}

class Test extends Modchart {
	public var rot:Float = 0;
	public var centerPos:FlxPoint = new FlxPoint(0,0);
	public var started:Bool = false;
	public override function create() {
		for(i in 1...10) {
			var b:Boyfriend = new Boyfriend(770 + (i * 400), 100, PlayState.SONG.player1);
			PlayState.current.add(b);
			PlayState.current.boyfriends.push(b);
		}
	}
	public override function start() {
		centerPos.x = (PlayState.current.playerStrums.members[0].x + PlayState.current.playerStrums.members[PlayState.current.playerStrums.members.length - 1].x) / 2;
		centerPos.y = (PlayState.current.playerStrums.members[0].y + PlayState.current.playerStrums.members[PlayState.current.playerStrums.members.length - 1].y) / 2;
		started = true;
	}
	public override function update(elapsed:Float) {
		if (!started) return;
		rot += elapsed * 100;
		for (k=>strum in PlayState.current.playerStrums.members) {
			var r:Float = Math.sin(rot * Math.PI / 180) * 15;
			strum.x = centerPos.x + (Math.cos(r * Math.PI / 180) * (strum.ID - ((PlayState.current.playerStrums.length - 1) / 2)) * Note.swagWidth);
			strum.y = centerPos.y + (Math.sin(r * Math.PI / 180) * (strum.ID - ((PlayState.current.playerStrums.length - 1) / 2)) * Note.swagWidth);
			// strum.x = centerPos.x + (Math.sin(r) * (strum.ID - 3) * Note.swagWidth);
			// strum.y = centerPos.y + (Math.cos(r) * (strum.ID - 3) * Note.swagWidth);
			strum.angle = r;
		}
		// for (k=>strum in PlayState.current.playerStrums.members) {
		// 	strum.y = PlayState.current.strumLine.y + 25 + (Math.sin((rot + 45 * k) * Math.PI / 180) * 50);
		// }
	}

	public override function beatHit(curBeat:Int) {
		if (curBeat % 4 == 0) {
			PlayState.current.currentBoyfriend = (PlayState.current.currentBoyfriend + 1) % PlayState.current.boyfriends.length;
		}
	}
}

class Milf extends Modchart {
	public override function getCameraZoom(curStep:Int, curBeat:Int):CameraZooms {
		var hud:Float = 0;
		var game:Float = 0;
		if (curBeat % 4 == 0) {
			hud += 0.03;
			game += 0.015;
		}
		
		
		if (curBeat >= 168 && curBeat < 200 && FlxG.camera.zoom < 1.35)
		{
			game += 0.015;
			hud += 0.03;
		}

		return {
			hud : hud,
			game : game
		};
	}
}

class Fresh extends Modchart {
	public override function beatHit(curBeat:Int) {
		switch (curBeat)
		{
			case 16:
				PlayState.current.camZooming = true;
				PlayState.current.gfSpeed = 2;
			case 48:
				PlayState.current.gfSpeed = 1;
			case 80:
				PlayState.current.gfSpeed = 2;
			case 112:
				PlayState.current.gfSpeed = 1;
			case 163:
				// FlxG.sound.music.stop();
				// FlxG.switchState(new TitleState());
		}
	}
}

class Blammed extends Modchart {
    public var stage:Stage.Philly;

	public var bfDarkMode:BitmapData;
	public var picoDarkMode:BitmapData;
	public var gfDarkMode:BitmapData;
	public var ogBF:BitmapData;
	public var ogPico:BitmapData;
	public var ogGF:BitmapData;
	public var blackScreen:FlxSprite;

	public var bfDark:Boyfriend;
	public var dadDark:Character;
	public var gfDark:Character;

    public override function create() {
        stage = cast(PlayState.current.songEvents.stage, Stage.Philly);
        #if sys
        if (Settings.engineSettings.data.blammedEffect) {
			var cBF = Settings.engineSettings.data.customBFSkin;
			if (!sys.FileSystem.exists(Paths.getSkinsPath() + '/bf/$cBF/blammed.png')) {
				bfDarkMode = new BitmapData(PlayState.current.boyfriend.pixels.image.width, PlayState.current.boyfriend.pixels.image.height, true, 0xFF000000);
				bfDarkMode.lock();
				var bfBitmap:BitmapData = PlayState.current.boyfriend.pixels;
				for(x in 0...bfBitmap.width) {
					for (y in 0...bfBitmap.height) {
						var color = new FlxColor(bfBitmap.getPixel32(x, y));
						var average = (color.red + color.green + color.blue) / 3;
						if (average < 50) {
							var newColor:Float = (1 - (average / 50)) * color.alphaFloat;
							var c = new FlxColor(0xFFFFFFFF);
							c.alphaFloat = newColor;
							bfDarkMode.setPixel32(x, y, c);
						}
					}
				}
				bfDarkMode.unlock();
				sys.io.File.saveBytes(Paths.getSkinsPath() + '/bf/$cBF/blammed.png', bfDarkMode.encode(bfDarkMode.rect, new PNGEncoderOptions(true)));
			}

			if (!sys.FileSystem.exists(Paths.getSkinsPath() + '/bf/$cBF/blammed.xml')) sys.io.File.copy(Paths.getSkinsPath() + '/bf/$cBF/spritesheet.xml', Paths.getSkinsPath() + '/bf/$cBF/blammed.xml');
			
			


			var cGF = Settings.engineSettings.data.customGFSkin;
			if (!sys.FileSystem.exists(Paths.getSkinsPath() + '/gf/$cGF/blammed.png')) {
				gfDarkMode = new BitmapData(PlayState.current.gf.pixels.image.width, PlayState.current.gf.pixels.image.height, true, 0xFF000000);
				gfDarkMode.lock();
				var gfBitmap:BitmapData = PlayState.current.gf.pixels;
				for(x in 0...gfBitmap.width) {
					for (y in 0...gfBitmap.height) {
						var color = new FlxColor(gfBitmap.getPixel32(x, y));
						var average = (color.red + color.green + color.blue) / 3;
						if (average < 50) {
							var newColor:Float = (1 - (average / 50)) * color.alphaFloat;
							var c = new FlxColor(0xFFFFFFFF);
							c.alphaFloat = newColor;
							gfDarkMode.setPixel32(x, y, c);
						}
					}
				}
				gfDarkMode.unlock();
				sys.io.File.saveBytes(Paths.getSkinsPath() + '/gf/$cGF/blammed.png', gfDarkMode.encode(gfDarkMode.rect, new PNGEncoderOptions(true)));
			}
			if (!sys.FileSystem.exists(Paths.getSkinsPath() + '/gf/$cGF/blammed.xml')) sys.io.File.copy(Paths.getSkinsPath() + '/gf/$cGF/spritesheet.xml', Paths.getSkinsPath() + '/gf/$cGF/blammed.xml');

			gfDark = new Character(400, 130, PlayState.current.gf.curCharacter, false, "blammed");
			gfDark.visible = false;
			PlayState.current.add(gfDark);

			bfDark = new Boyfriend(770, 100, PlayState.SONG.player1, Settings.engineSettings.data.customBFSkin == "default" ? "BF_blammed" : "blammed");
			bfDark.visible = false;
			PlayState.current.add(bfDark);
			PlayState.current.boyfriends.push(bfDark);

			dadDark = new Character(100, 100, "pico", false, "PICO_blammed");
			dadDark.visible = false;
			PlayState.current.dads.push(dadDark);
			PlayState.current.add(dadDark);
			

			// picoDarkMode = Paths.getBitmapOutsideAssets('assets/characters/PICO_blammed.png');
			// ogPico = PlayState.current.dad.pixels.clone();
			// ogBF = PlayState.current.boyfriend.pixels.clone();
			// ogGF = PlayState.current.gf.pixels.clone();
	
			blackScreen = new FlxSprite(0, 0).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
			blackScreen.cameras = [PlayState.current.camHUD];
			blackScreen.alpha = 0;
			PlayState.current.add(blackScreen);
		}
        #end
    }

    public override function beatHit(curBeat:Int) {
		if (gfDark != null) gfDark.dance();
        #if sys
		if (Settings.engineSettings.data.blammedEffect) {
			if (curBeat == 128) {
				// switchBF(bfDarkMode);
				// switchGF(gfDarkMode);
				// switchPico(picoDarkMode);
				PlayState.current.currentBoyfriend = 1;
				PlayState.current.boyfriends[0].visible = false;
				PlayState.current.boyfriends[1].visible = true;
				PlayState.current.currentDad = 1;
				PlayState.current.dads[0].visible = false;
				PlayState.current.dads[1].visible = true;
				PlayState.current.gf.visible = false;
				gfDark.visible = true;

				blackScreen.alpha = 1;
				blackScreen.color = 0xFFFFFFFF;
				FlxTween.tween(blackScreen, {alpha : 0}, 2);
				stage.phillyTrain.visible = false;
				stage.bg.visible = false;
				stage.city.visible = false;
				stage.streetBehind.visible = false;
				stage.street.visible = false;
			}
			if (curBeat == 192) {
				// switchBF(ogBF);
				// switchGF(ogGF);
				// switchPico(ogPico);
				PlayState.current.currentBoyfriend = 0;
				PlayState.current.boyfriends[1].visible = false;
				PlayState.current.boyfriends[0].visible = true;
				PlayState.current.currentDad = 0;
				PlayState.current.dads[0].visible = true;
				PlayState.current.dads[1].visible = false;
				PlayState.current.gf.visible = true;
				gfDark.visible = false;
				
				blackScreen.alpha = 1;
				blackScreen.color = 0xFF000000;
				FlxTween.tween(blackScreen, {alpha : 0}, 2);
				stage.phillyTrain.visible = true;
				stage.bg.visible = true;
				stage.city.visible = true;
				stage.streetBehind.visible = true;
				stage.street.visible = true;
				PlayState.current.boyfriend.color = 0xFFFFFFFF;
				PlayState.current.dad.color = 0xFFFFFFFF;
				PlayState.current.gf.color = 0xFFFFFFFF;

				// picoDarkMode.dispose();
				// picoDarkMode.disposeImage();

				// bfDarkMode.dispose();
				// bfDarkMode.disposeImage();
			}
		}
		#end
		
        if (curBeat % 4 == 0) {
            if (curBeat >= 128 && curBeat < 192 && Settings.engineSettings.data.blammedEffect) {
                PlayState.current.boyfriend.color = stage.light.color;
				PlayState.current.dad.color = stage.light.color;
				gfDark.color = stage.light.color;
				// PlayState.current.gf.color = stage.light.color;
            } else {
                PlayState.current.boyfriend.color = -1;
				PlayState.current.dad.color = -1;
				// PlayState.current.gf.color = -1;
            }
        }
    }
    public override function update(elapsed:Float) {
        
    }

    #if sys
	public function switchBF(newBitmap:BitmapData) {
		var cBF = Settings.engineSettings.data.customBFSkin;
		var oldAnim = PlayState.current.boyfriend.animation.curAnim.name;
		PlayState.current.boyfriend.frames = FlxAtlasFrames.fromSparrow(newBitmap, Paths.getTextOutsideAssets('skins/bf/$cBF/spritesheet.xml'));
		// PlayState.current.boyfriend.pixels = bfDarkMode;
		
		PlayState.current.boyfriend.configureAnims();
		PlayState.current.boyfriend.playAnim(oldAnim);
	}
	public function switchGF(newBitmap:BitmapData) {
		var cGF = Settings.engineSettings.data.customGFSkin;
		var oldAnim = PlayState.current.gf.animation.curAnim.name;
		PlayState.current.gf.frames = FlxAtlasFrames.fromSparrow(newBitmap, Paths.getTextOutsideAssets('skins/gf/$cGF/spritesheet.xml'));
		// PlayState.current.gf.pixels = bfDarkMode;
		
		PlayState.current.gf.configureAnims();
		PlayState.current.gf.playAnim(oldAnim);
	}
	
	public function switchPico(newBitmap:BitmapData) {
		var oldAnim = PlayState.current.dad.animation.curAnim.name;
		PlayState.current.dad.frames = FlxAtlasFrames.fromSparrow(newBitmap, Assets.getText("characters:assets/characters/Pico_FNF_assetss.xml"));
		PlayState.current.dad.animation.addByPrefix('idle', "Pico Idle Dance", 24);
		PlayState.current.dad.animation.addByPrefix('singUP', 'pico Up note0', 24, false);
		PlayState.current.dad.animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
		PlayState.current.dad.animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
		PlayState.current.dad.animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
		PlayState.current.dad.animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
		PlayState.current.dad.animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
		PlayState.current.dad.animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
		PlayState.current.dad.animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);
		PlayState.current.dad.playAnim(oldAnim);
	}
	#end
}