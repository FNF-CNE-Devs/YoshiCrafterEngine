import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;

class Notes extends FlxTypedGroup<Note> {
    #if note_opti
        public var settingUp:Bool = true;
        public var noteSprites:Array<Note> = [];

        public var currentNotes:Array<OptiNote> = [];
        
        public override function draw() {
            @:privateAccess
            var oldDefaultCameras = FlxCamera._defaultCameras;
            if (cameras != null)
            {
                @:privateAccess
                FlxCamera._defaultCameras = cameras;
            }

            for(n in currentNotes) {
                if (n == null) continue;
                if (n.active && n.visible) {
                    var cNoteSprite = noteSprites[((n.noteData % (PlayState._SONG.keyNumber * 2)) + (n.noteType * PlayState._SONG.keyNumber * 2)) % noteSprites.length];
                    cNoteSprite.x = n.x;
                    cNoteSprite.y = n.y;
                    cNoteSprite.noteOffset = n.noteOffset;
                    cNoteSprite.scale.set(n.scale.x, n.scale.y);
                    cNoteSprite.alpha = n.alpha;
                    cNoteSprite.shader = n.shader;

                    cNoteSprite.draw();
                }
            }
            @:privateAccess
            FlxCamera._defaultCameras = oldDefaultCameras;
        }


        public override function add(e:Note) {
            if (settingUp) {
                noteSprites.push(e);
                return super.add(e);
            } else {
                if (Std.isOfType(e, OptiNote)) currentNotes.push(cast e);
                return e;
            }
        }
        
        public override function remove(e:Note, splice:Bool = true) {
            if (settingUp) {
                noteSprites.push(e);
                return super.remove(e, splice);
            } else {
                if (Std.isOfType(e, OptiNote)) currentNotes.remove(cast e);
                return e;
            }
        }
        
        public override function insert(pos:Int, e:Note) {
            if (settingUp) {
                noteSprites.push(e);
                return super.insert(pos, e);
            } else {
                if (Std.isOfType(e, OptiNote)) currentNotes.insert(pos, cast e);
                return e;
            }
        }

        public override function forEachAlive(func:Note->Void, Recurse:Bool = false) {
            for(n in currentNotes) {
                if (n != null && n.exists && n.alive) {
                    func(n);
                }
            }
        }
        
        public override function forEach(func:Note->Void, Recurse:Bool = false) {
            for(n in currentNotes) {
                func(n);
            }
        }
        
        public override function forEachDead(func:Note->Void, Recurse:Bool = false) {
            for(n in currentNotes) {
                if (n != null && n.exists && !n.alive) {
                    func(n);
                }
            }
        }


    #else
        public var currentNotes(get, null):Array<Note>;
        public function get_currentNotes() {
            return members;
        }
    #end
    public override function update(elapsed:Float) {
        for(n in #if note_opti currentNotes #else members #end) {
            n.active = n.visible = (n.strumTime - Conductor.songPosition < 1500);
            if (n.active) {
                // daNote.script.setVariable("note", this);
                // daNote.script.executeFunc("update");

                var daNote = n;
                var pos:FlxPoint = new FlxPoint(-(daNote.noteOffset.x + ((daNote.isSustainNote ? daNote.width / 2 : 0) * (PlayState.instance.engineSettings.downscroll ? 1 : -1))),(daNote.noteOffset.y));
                var strum = daNote.strum;
                if (strum == null) strum = (daNote.mustPress ? PlayState.instance.playerStrums.members : PlayState.instance.cpuStrums.members)[(daNote.noteData % PlayState._SONG.keyNumber) % PlayState.SONG.keyNumber];

                if (strum.getAngle() == 0) {

                    pos.y = (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(strum.getScrollSpeed(), 2)) + (daNote.noteOffset.y);

                    // daNote.velocity.y = (0 - 1000) * (0.45 * FlxMath.roundDecimal(strum.getScrollSpeed(), 2));
                } else {
                    pos.x = Math.sin((strum.getAngle() + 180) * Math.PI / 180) * ((Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(strum.getScrollSpeed(), 2)));
                    pos.x += Math.sin((strum.getAngle() + (PlayState.instance.engineSettings.downscroll ? 90 : 270)) * Math.PI / 180) * ((daNote.noteOffset.x));
                    pos.y = Math.cos((strum.getAngle()) * Math.PI / 180) * (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(strum.getScrollSpeed(), 2));
                    pos.y += Math.cos((strum.getAngle() + (PlayState.instance.engineSettings.downscroll ? 270 : 90)) * Math.PI / 180) * ((daNote.noteOffset.y));
                    // daNote.velocity.y = 0;
                }

                daNote.antialiasing = daNote.antialiasing && PlayState.instance.engineSettings.noteAntialiasing;
                daNote.alpha = strum.getAlpha() * (daNote.isSustainNote && PlayState.instance.engineSettings.transparentSubstains ? 0.6 : 1);
                // daNote.cameras = strum.cameras;
                // if (daNote.isLongSustain) {
                    // daNote.scale.y = (Note.swagWidth / Note._swagWidth) * (Conductor.stepCrochet / 100 * 1.5 * (strum.getScrollSpeed()));
                // }

                if (PlayState.instance.engineSettings.downscroll) {
                    // daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(engineSettings.customScrollSpeed ? engineSettings.scrollSpeed : SONG.speed, 2)));
                    // Code above not modchart proof
                    // daNote.velocity.x = -daNote.velocity.x;
                    // daNote.velocity.y = -daNote.velocity.y;

                    daNote.y = (strum.y + pos.y - (daNote.noteOffset.y * 2));
                    if (strum.getAngle() == 0)
                        daNote.x = (strum.x - pos.x);
                    else
                        daNote.x = (strum.x + pos.x);

                    if (daNote.isSustainNote) {
                        daNote.x -= daNote.width;
                        daNote.flipY = true;
                    }
                } else {
                    daNote.y = (strum.y - pos.y);
                    daNote.x = (strum.x - pos.x);
                }
                daNote.angle = daNote.isSustainNote ? strum.getAngle() : strum.angle;

                daNote.update(elapsed);
            }
        }
        super.update(elapsed);
    }
}


#if note_opti
class OptiNote extends Note {
    public static var swagWidth(get, null):Float;
	public static function get_swagWidth():Float {
		return _swagWidth * widthRatio;
		// return _swagWidth * (4 / (PlayState.SONG.keyNumber == null ? 4 : PlayState.SONG.keyNumber));
	}
	public static var widthRatio(get, null):Float;
	static function get_widthRatio():Float {
		var nScale = 1;
		var middlescroll = false;
		if (PlayState.current != null) {
			nScale = PlayState.current.engineSettings.noteScale;
			middlescroll = PlayState.current.engineSettings.middleScroll;
		}
		return Math.min(1, (middlescroll ? 10 : 5) / ((PlayState.SONG.keyNumber == null ? (middlescroll ? 10 : 5) : PlayState.SONG.keyNumber) * nScale));
	}
	public static var _swagWidth:Float = 160 * 0.7;

    public override function doesScripts() {return false;}

}
#else
    typedef OptiNote = Note;
#end