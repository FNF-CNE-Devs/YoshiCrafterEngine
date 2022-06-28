package;

import flixel.graphics.FlxGraphic;
import flixel.addons.transition.Transition;
import flixel.FlxSubState;
import dev_toolbox.ToolboxMessage;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.FlxSprite;
import lime.graphics.Image;
import lime.utils.Assets;
import lime.app.Application;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.addons.transition.TransitionData;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;

typedef FlxSpriteTypedGroup = FlxTypedGroup<FlxSprite>;
typedef FlxSpriteArray = Array<FlxSprite>;


@:allow(mod_support_stuff.SwitchModSubstate)
class MusicBeatState extends FlxUIState
{
	public static var medalOverlay:Array<MedalsOverlay> = [];
	private var reloadModsState:Bool = false;

	private static var doCachingShitNextTime:Bool = true;
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	public static var defaultIcon:Image = null;

	public var lastElapsed:Float = 0;

	public override function onFocus() {
		if (reloadModsState) {
			super.onFocus();
			if (Settings.engineSettings.data.alwaysCheckForMods) if (ModSupport.reloadModsConfig(false, false)) FlxG.resetState();	
		}
	}

	public override function destroy() {
		// remove(medalOverlay);
		super.destroy();
	}

	var oldPersistStuff:Map<FlxGraphic, Bool> = [];
	public function new(?transIn:TransitionData, ?transOut:TransitionData) {
		ModSupport.updateTitleBar();
		ModSupport.refreshDiscordRpc();
		ModSupport.reloadModsConfig(CoolUtil.isDevMode());
		Settings.engineSettings.flush();

		LimeAssets.loggedRequests = [];

		if (doCachingShitNextTime) {
			LimeAssets.logRequests = true;

			@:privateAccess
			if (FlxG.bitmap._cache != null)
				for(e in FlxG.bitmap._cache) {
					// old opti be like "lets cache non assets shit like texts" no you fucking idiot
					if (e.assetsKey != null) {
						oldPersistStuff[e] = e.persist;
						e.persist = true;
					} else {
						// e._useCount = 0;
					}
				}
		} else {
			doCachingShitNextTime = true;
		}
		#if !android
			@:privateAccess
			FlxG.width = 1280;
			@:privateAccess
			FlxG.height = 720;
		#end
		
		FlxG.scaleMode = new RatioScaleMode();
		super(transIn, transOut);
	}

	override function createPost() {
		super.createPost();
		if (LimeAssets.logRequests) {
			try {
				Assets.cache.clearExceptArray(LimeAssets.loggedRequests);
			} catch(e) {
				trace(e);
			}
			
			LimeAssets.logRequests = false;

			for(k=>e in oldPersistStuff) {
				k.persist = e;
			}
			oldPersistStuff = [];
			
			FlxG.bitmap.clearCache();

			LimeAssets.loggedRequests = [];
		}
	}

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		// if (transIn != null)
		// 	trace('reg ' + transIn.region);

		super.create();
		if (Settings.engineSettings != null) {
			FlxG.drawFramerate = Settings.engineSettings.data.fpsCap;
			FlxG.updateFramerate = Settings.engineSettings.data.fpsCap;
		}
	}
	
	override function draw() {
		super.draw();
		if (!Std.isOfType(subState, MusicBeatSubstate)) {
			for(k=>m in MusicBeatState.medalOverlay) {
				m.y = 110 * k;
				m.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
				m.draw();
			}
		}
	}

	override function update(elapsed:Float)
	{
		lastElapsed = elapsed;
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();
		
		if (oldStep < curStep && curStep > 0)
			stepHit();
		// if (oldStep < curStep)

		super.update(elapsed);
		
		if (MusicBeatState.medalOverlay != null) {
			for(k=>m in MusicBeatState.medalOverlay) {
				m.y = 110 * k;
				m.cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
				m.update(elapsed);
			}
		}
	}

	private function updateBeat():Void
	{
		curBeat = Std.int(Math.floor(curStep / 4));
	}

	private function updateCurStep():Void
	{
		var lastChange = getLastChange();

		curStep = Std.int(lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet));
	}

	private function getLastChange() {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}
		return lastChange;
	}
	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}

	public function onDropFile(path:String) {
		
	}

    public function showMessage(title:String, text:String) {
        var m = ToolboxMessage.showMessage(title, text);
        m.cameras = cameras;
        openSubState(m);
    }

	public override function openSubState(state:FlxSubState) {
		if (subState != null) {
			if (Std.isOfType(subState, Transition))  {
				closeSubState();
			}
		}
		persistentUpdate = false;
		super.openSubState(state);
	}
}
