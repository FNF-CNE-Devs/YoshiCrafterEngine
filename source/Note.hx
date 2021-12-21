package;

import flixel.math.FlxPoint;
import LoadSettings.Settings;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxG;
import openfl.display.BitmapData;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

enum NoteType {
	Normal;
}

enum abstract NoteDirection(Int) {
	var Left = 0;
	var Down = 1;
	var Up = 2;
	var Right = 3;
}
class Note extends FlxSprite
{
	public var strumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;

	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;

	public var noteScore:Float = 1;

	public var noteType:Int = 0;
	// #if secret
	// 	var c:FlxColor = new FlxColor(0xFFFF0000);
	// 	c.hue = (strumTime / 100) % 359;
	// 	this.color = c;
	// #else
	// 	color = colors[(noteData % 4) + 1];
	// #end

	// public static var skinBitmap:FlxAtlasFrames = null;

	public static var swagWidth(get, null):Float;
	public static function get_swagWidth():Float {
		return _swagWidth * widthRatio;
		// return _swagWidth * (4 / (PlayState.SONG.keyNumber == null ? 4 : PlayState.SONG.keyNumber));
	}
	public static var widthRatio(get, null):Float;
	static function get_widthRatio():Float {
		return Math.min(1, 5 / (PlayState.SONG.keyNumber == null ? 5 : PlayState.SONG.keyNumber));
	}
	public static var _swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public static var noteTypes:Array<hscript.Expr> = [];
	// public var script:hscript.Interp;
	public var script(get, null):hscript.Interp;
	public function get_script():hscript.Interp {
		return PlayState.current.noteScripts[noteType % PlayState.current.noteScripts.length];
	}

	public static var noteNumberSchemes:Map<Int, Array<NoteDirection>> = [
		1 => [Up],
		4 => [Left, Down, Up, Right],
		// 4 => [Down, Left, Right, Up], // lol
		6 => [Left, Down, Right, Left, Up, Right],
		9 => [Left, Down, Up, Right, Up, Left, Down, Up, Right]
	];

	public static var noteNumberScheme(get, null):Array<NoteDirection>;
	public static function get_noteNumberScheme():Array<NoteDirection> {
		var noteNumberScheme:Array<NoteDirection> = noteNumberSchemes[PlayState.SONG.keyNumber];
		if (noteNumberScheme == null) noteNumberScheme = noteNumberSchemes[4];
		return noteNumberScheme;
	}

	public function createNote() {
		// switch(noteType) {
		// 	default:
		// 		if (PlayState.curStage.startsWith('school')) {
		// 			if (engineSettings.customArrowColors) {
		// 				var colors:Array<FlxColor> = (mustPress || engineSettings.customArrowColors_allChars) ? PlayState.current.boyfriend.getColors(false) : PlayState.current.boyfriend.getColors(false);
		// 				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels-colored', 'week6'), true, 17, 17);
		// 				#if secret
		// 					var c:FlxColor = new FlxColor(0xFFFF0000);
		// 					c.hue = (strumTime / 100) % 359;
		// 					this.color = c;
		// 				#else
		// 					color = colors[(noteData % 4) + 1];
		// 				#end
		// 			} else {
		// 				loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
		// 			}
	
		// 			animation.add('greenScroll', [6]);
		// 			animation.add('redScroll', [7]);
		// 			animation.add('blueScroll', [5]);
		// 			animation.add('purpleScroll', [4]);
	
		// 			if (isSustainNote)
		// 			{
		// 				if (engineSettings.customArrowColors) {
		// 					var colors:Array<FlxColor> = (mustPress || engineSettings.customArrowColors_allChars) ? PlayState.current.boyfriend.getColors(false) : PlayState.current.boyfriend.getColors(false);
		// 					// loadGraphic(Paths.image('weeb/pixelUI/arrowEnds-colored', 'week6'), true, 17, 17);
		// 					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds-colored', 'week6'), true, 7, 6);
		// 					#if secret
		// 						var c:FlxColor = new FlxColor(0xFFFF0000);
		// 						c.hue = (strumTime / 100) % 359;
		// 						this.color = c;
		// 					#else
		// 						color = colors[noteData % 4];
		// 					#end
		// 				} else {
		// 					loadGraphic(Paths.image('weeb/pixelUI/arrowEnds', 'week6'), true, 7, 6);
		// 				}
	
		// 				animation.add('purpleholdend', [4]);
		// 				animation.add('greenholdend', [6]);
		// 				animation.add('redholdend', [7]);
		// 				animation.add('blueholdend', [5]);
	
		// 				animation.add('purplehold', [0]);
		// 				animation.add('greenhold', [2]);
		// 				animation.add('redhold', [3]);
		// 				animation.add('bluehold', [1]);
		// 			}
	
		// 			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		// 			updateHitbox();
		// 		} else {
		// 			if (engineSettings.customArrowColors) {
		// 				var colors:Array<FlxColor> = (mustPress || engineSettings.customArrowColors_allChars) ? PlayState.current.boyfriend.getColors(false) : PlayState.current.boyfriend.getColors(false);
		// 				frames = (engineSettings.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets_colored') : Paths.getSparrowAtlas_Custom((Paths.getSkinsPath() + "notes/" + engineSettings.customArrowSkin.toLowerCase()).replace("/", "\\").replace("\r", ""));
						
		// 			} else {
		// 				frames = (engineSettings.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets') : Paths.getSparrowAtlas_Custom((Paths.getSkinsPath() + "notes/" + engineSettings.customArrowSkin.toLowerCase()).replace("/", "\\").replace("\r", ""));
		// 			}
	
		// 			animation.addByPrefix('greenScroll', 'green0');
		// 			animation.addByPrefix('redScroll', 'red0');
		// 			animation.addByPrefix('blueScroll', 'blue0');
		// 			animation.addByPrefix('purpleScroll', 'purple0');
	
		// 			animation.addByPrefix('purpleholdend', 'pruple end hold');
		// 			animation.addByPrefix('greenholdend', 'green hold end');
		// 			animation.addByPrefix('redholdend', 'red hold end');
		// 			animation.addByPrefix('blueholdend', 'blue hold end');
	
		// 			animation.addByPrefix('purplehold', 'purple hold piece');
		// 			animation.addByPrefix('greenhold', 'green hold piece');
		// 			animation.addByPrefix('redhold', 'red hold piece');
		// 			animation.addByPrefix('bluehold', 'blue hold piece');
	
		// 			setGraphicSize(Std.int(width * 0.7));
		// 			updateHitbox();
		// 			antialiasing = true;
		// 		}
		// }
		scale.x *= swagWidth / _swagWidth;
		if (!isSustainNote) {
			scale.y *= swagWidth / _swagWidth;
		}
	}
	public var noteOffset:FlxPoint = new FlxPoint(0,0);
	public var enableRating:Bool = true;
	public var engineSettings:Dynamic;
	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?mustHit = true)
	{
		super();
		engineSettings = Settings.engineSettings.data;
		if (PlayState.current != null) engineSettings = PlayState.current.engineSettings;

		var noteNumberScheme:Array<NoteDirection> = noteNumberSchemes[PlayState.SONG.keyNumber];
		if (noteNumberScheme == null) noteNumberScheme = noteNumberSchemes[4];

		

		// if (prevNote == null)
		// 	prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		if 		  (PlayState.SONG.keyNumber <= 4) {
			x += 50;
		} else if (PlayState.SONG.keyNumber == 5) {
			x += 30;
		} else if (PlayState.SONG.keyNumber >= 6) {
			x += 10;
		}
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;
		noteType = Math.floor(noteData / (PlayState.SONG.keyNumber * 2));

		var daStage:String = PlayState.curStage;

		// createNote();
		script.variables.set("note", this);
		ModSupport.executeFunc(script, "create");

		scale.x *= swagWidth / _swagWidth;
		if (!isSustainNote) {
			scale.y *= swagWidth / _swagWidth;
		}

		x += swagWidth * (noteData % PlayState.SONG.keyNumber);
		// switch (noteData % 4)
		// {
		// 	case 0:
		// 		animation.play('purpleScroll');
		// 	case 1:
		// 		animation.play('blueScroll');
		// 	case 2:
		// 		animation.play('greenScroll');
		// 	case 3:
		// 		animation.play('redScroll');
		// }
		
		// switch (noteNumberScheme[noteData % noteNumberScheme.length])
		// {
		// 	case Left:
		// 		animation.play('purpleScroll');
		// 	case Down:
		// 		animation.play('blueScroll');
		// 	case Up:
		// 		animation.play('greenScroll');
		// 	case Right:
		// 		animation.play('redScroll');
		// }

		// trace(prevNote);

		if (isSustainNote)
		{
			noteScore * 0.2;
			alpha = engineSettings.transparentSubstains ? 0.6 : 1;

			noteOffset.x += width / 2;

			// flipY = engineSettings.downscroll;
			// switch (noteData)
			// {
			// 	case 2:
			// 		animation.play('greenholdend');
			// 	case 3:
			// 		animation.play('redholdend');
			// 	case 1:
			// 		animation.play('blueholdend');
			// 	case 0:
			// 		animation.play('purpleholdend');
			// }
			// switch (noteNumberScheme[noteData % noteNumberScheme.length])
			// {
			// 	case Left:
			// 		animation.play('purpleholdend');
			// 	case Down:
			// 		animation.play('blueholdend');
			// 	case Up:
			// 		animation.play('greenholdend');
			// 	case Right:
			// 		animation.play('redholdend');
			// }

			updateHitbox();

			// x -= width / 2;

			
			flipY = engineSettings.downscroll;
			if (prevNote != null) {
				if (prevNote.isSustainNote)
				{
					prevNote.flipY = false;
					// switch (noteNumberScheme[prevNote.noteData % noteNumberScheme.length])
					// {
					// 	case Left:
					// 		prevNote.animation.play('purplehold');
					// 	case Down:
					// 		prevNote.animation.play('bluehold');
					// 	case Up:
					// 		prevNote.animation.play('greenhold');
					// 	case Right:
					// 		prevNote.animation.play('redhold');
					// }

					prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * (engineSettings.customScrollSpeed ? engineSettings.scrollSpeed : PlayState.SONG.speed);
					prevNote.updateHitbox();
			
					if (engineSettings.downscroll) {
						prevNote.offset.y = prevNote.height / 2;
					}
					// prevNote.setGraphicSize();
				}
			}
			offset.y = height / 2;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		ModSupport.executeFunc(script, "update", [elapsed]);
		script.variables.set("note", this);
		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
