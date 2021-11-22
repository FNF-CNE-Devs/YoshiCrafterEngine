package;

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

	// public static var skinBitmap:FlxAtlasFrames = null;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public function createNote() {
		switch(noteType) {
			default:
				if (PlayState.curStage.startsWith('school')) {
					if (Settings.engineSettings.data.customArrowColors) {
						var colors:Array<FlxColor> = (mustPress || Settings.engineSettings.data.customArrowColors_allChars) ? Character.getNoteColors(PlayState.SONG.player1) : Character.getNoteColors(PlayState.SONG.player2);
						loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels-colored', 'week6'), true, 17, 17);
						#if secret
							var c:FlxColor = new FlxColor(0xFFFF0000);
							c.hue = (strumTime / 100) % 359;
							this.color = c;
						#else
							color = colors[noteData % 4];
						#end
					} else {
						loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
					}
	
					animation.add('greenScroll', [6]);
					animation.add('redScroll', [7]);
					animation.add('blueScroll', [5]);
					animation.add('purpleScroll', [4]);
	
					if (isSustainNote)
					{
						if (Settings.engineSettings.data.customArrowColors) {
							var colors:Array<FlxColor> = (mustPress || Settings.engineSettings.data.customArrowColors_allChars) ? Character.getNoteColors(PlayState.SONG.player1) : Character.getNoteColors(PlayState.SONG.player2);
							// loadGraphic(Paths.image('weeb/pixelUI/arrowEnds-colored', 'week6'), true, 17, 17);
							loadGraphic(Paths.image('weeb/pixelUI/arrowEnds-colored', 'week6'), true, 7, 6);
							#if secret
								var c:FlxColor = new FlxColor(0xFFFF0000);
								c.hue = (strumTime / 100) % 359;
								this.color = c;
							#else
								color = colors[noteData % 4];
							#end
						} else {
							loadGraphic(Paths.image('weeb/pixelUI/arrowEnds', 'week6'), true, 7, 6);
						}
	
						animation.add('purpleholdend', [4]);
						animation.add('greenholdend', [6]);
						animation.add('redholdend', [7]);
						animation.add('blueholdend', [5]);
	
						animation.add('purplehold', [0]);
						animation.add('greenhold', [2]);
						animation.add('redhold', [3]);
						animation.add('bluehold', [1]);
					}
	
					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
				} else {
					if (Settings.engineSettings.data.customArrowColors) {
						var colors:Array<FlxColor> = (mustPress || Settings.engineSettings.data.customArrowColors_allChars) ? Character.getNoteColors(PlayState.SONG.player1) : Character.getNoteColors(PlayState.SONG.player2);
						frames = (Settings.engineSettings.data.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets_colored') : Paths.getSparrowAtlas_Custom((Paths.getSkinsPath() + "notes/" + Settings.engineSettings.data.customArrowSkin.toLowerCase()).replace("/", "\\").replace("\r", ""));
						#if secret
							var c:FlxColor = new FlxColor(0xFFFF0000);
							c.hue = (strumTime / 100) % 359;
							this.color = c;
						#else
							color = colors[noteData % 4];
						#end
					} else {
						frames = (Settings.engineSettings.data.customArrowSkin == "default") ? Paths.getSparrowAtlas('NOTE_assets') : Paths.getSparrowAtlas_Custom((Paths.getSkinsPath() + "notes/" + Settings.engineSettings.data.customArrowSkin.toLowerCase()).replace("/", "\\").replace("\r", ""));
					}
	
					animation.addByPrefix('greenScroll', 'green0');
					animation.addByPrefix('redScroll', 'red0');
					animation.addByPrefix('blueScroll', 'blue0');
					animation.addByPrefix('purpleScroll', 'purple0');
	
					animation.addByPrefix('purpleholdend', 'pruple end hold');
					animation.addByPrefix('greenholdend', 'green hold end');
					animation.addByPrefix('redholdend', 'red hold end');
					animation.addByPrefix('blueholdend', 'blue hold end');
	
					animation.addByPrefix('purplehold', 'purple hold piece');
					animation.addByPrefix('greenhold', 'green hold piece');
					animation.addByPrefix('redhold', 'red hold piece');
					animation.addByPrefix('bluehold', 'blue hold piece');
	
					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();
					antialiasing = true;
				}
		}
	}
	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?mustHit = true)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;
		this.strumTime = strumTime;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		createNote();

		x += swagWidth * noteData;
		switch (noteData % 4)
		{
			case 0:
				animation.play('purpleScroll');
			case 1:
				animation.play('blueScroll');
			case 2:
				animation.play('greenScroll');
			case 3:
				animation.play('redScroll');
		}

		// trace(prevNote);

		if (isSustainNote && prevNote != null)
		{
			noteScore * 0.2;
			alpha = Settings.engineSettings.data.transparentSubstains ? 1 : 0.6;

			x += width / 2;

			// flipY = Settings.engineSettings.data.downscroll;
			switch (noteData)
			{
				case 2:
					animation.play('greenholdend');
				case 3:
					animation.play('redholdend');
				case 1:
					animation.play('blueholdend');
				case 0:
					animation.play('purpleholdend');
			}

			updateHitbox();

			x -= width / 2;

			if (PlayState.curStage.startsWith('school'))
				x += 30;

			if (prevNote.isSustainNote)
			{
				flipY = Settings.engineSettings.data.downscroll;
				switch (prevNote.noteData)
				{
					case 0:
						prevNote.animation.play('purplehold');
					case 1:
						prevNote.animation.play('bluehold');
					case 2:
						prevNote.animation.play('greenhold');
					case 3:
						prevNote.animation.play('redhold');
				}

				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * (Settings.engineSettings.data.customScrollSpeed ? Settings.engineSettings.data.scrollSpeed : PlayState.SONG.speed);
				prevNote.updateHitbox();
				// prevNote.setGraphicSize();
			}
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (mustPress)
		{
			// The * 0.5 is so that it's easier to hit them too late, instead of too early
			if (isSustainNote) {
				canBeHit = (strumTime - (Conductor.stepCrochet * 0.6) < Conductor.songPosition) && (strumTime + (Conductor.stepCrochet) > Conductor.songPosition);
			} else {
				canBeHit = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset && strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5));
			}
			if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
				tooLate = true;
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
