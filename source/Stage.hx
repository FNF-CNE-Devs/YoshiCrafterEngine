package;

import lime.utils.Assets;
import dev_toolbox.stage_editor.FlxStageSprite;
import flixel.math.FlxPoint;
import haxe.io.Path;
import haxe.Json;
import flixel.FlxSprite;
import sys.FileSystem;

typedef StageJSON = {
	var defaultCamZoom:Null<Float>;	
	var bfOffset:Array<Float>;	
	var gfOffset:Array<Float>;	
	var dadOffset:Array<Float>;
	var sprites:Array<StageSprite>;
}

typedef StageSprite = {
	var name:String;
	var type:String;
	@:optional var animation:StageAnim;
	@:optional var src:String;
	@:optional var pos:Array<Float>;
	@:optional var antialiasing:Null<Bool>;
	var scrollFactor:Array<Float>;
	@:optional var scale:Null<Float>;
}

typedef StageAnim = {
	var name:String;
	var fps:Null<Int>;
	var type:String;
}

typedef OnBeatAnimSprite = {
	var anim:String;
	var sprite:FlxSprite;
}

class Stage {
	public static var templateStage:StageJSON = {
		defaultCamZoom: 1,
		bfOffset: [0, 0],
		gfOffset: [0, 0],
		dadOffset: [0, 0],
		sprites: [
			{
				name: "Girlfriend",
				type: "GF",
				scrollFactor: [0.95, 0.95]
			},
			{
				name: "Boyfriend",
				type: "BF",
				scrollFactor: [1, 1]
			},
			{
				name: "Dad",
				type: "Dad",
				scrollFactor: [1, 1]
			}
		]
	};
	public var sprites:Map<String, FlxSprite> = [];
	public var onBeatAnimSprites:Array<OnBeatAnimSprite> = [];
	public var onBeatForceAnimSprites:Array<OnBeatAnimSprite> = [];
	public function getSprite(name:String) {
		return sprites[name];
	}
	public function onBeat() {
		for (s in onBeatAnimSprites) {
			s.sprite.animation.play(s.anim);
		}
		for (s in onBeatForceAnimSprites) {
			s.sprite.animation.play(s.anim, true);
		}
	}
	public function new(path:String, mod:String) {
		var splitPath = path.split(":");
		if (splitPath.length < 2) {
			if (FileSystem.exists('${Paths.modsPath}/${mod}/stages/${Path.withoutExtension(splitPath[0])}.json')) {
				splitPath.insert(0, mod);
			} else if (FileSystem.exists('${Paths.modsPath}/Friday Night Funkin\'/stages/${Path.withoutExtension(splitPath[0])}.json')) {
				splitPath.insert(0, "Friday Night Funkin'");
			}
		}
		if (splitPath.length < 2) {
			PlayState.trace('Stage not found for $path in $mod');
			return;
		}
		var json:StageJSON = null;
		try {
			json = Json.parse(Assets.getText(Paths.stage(Path.withoutExtension(splitPath[1]), 'mods/$mod')));
		} catch(e) {
			PlayState.trace('Failed to parse JSON data at $path in $mod : $e');
		}
		PlayState.current.devStage = splitPath.join(":");
		var PlayState = PlayState.current;
		if (json.defaultCamZoom != null) PlayState.defaultCamZoom = json.defaultCamZoom;
		if (json.bfOffset != null) {
			if (json.bfOffset.length > 0) {
				PlayState.boyfriend.x += json.bfOffset[0];
			}
			if (json.bfOffset.length > 1) {
				PlayState.boyfriend.y += json.bfOffset[1];
			}
		}
		if (json.dadOffset != null) {
			if (json.dadOffset.length > 0) {
				PlayState.dad.x += json.dadOffset[0];
			}
			if (json.dadOffset.length > 1) {
				PlayState.dad.y += json.dadOffset[1];
			}
		}
		if (json.gfOffset != null) {
			if (json.gfOffset.length > 0) {
				PlayState.gf.x += json.gfOffset[0];
			}
			if (json.gfOffset.length > 1) {
				PlayState.gf.y += json.gfOffset[1];
			}
		}

		if (json.sprites != null) {
			for(s in json.sprites) {
				switch(s.type) {
					case "SparrowAtlas":
						var sAtlas = generateSparrowAtlas(s, splitPath[0]);
						PlayState.add(sAtlas);
						if (s.name != null) sprites[s.name] = sAtlas;


						if (s.animation != null) {
							if (s.animation.type.toLowerCase() == "onbeat") {
								onBeatAnimSprites.push({
									anim: s.animation.name,
									sprite: sAtlas
								});
							} else if (s.animation.type.toLowerCase() == "onbeatforce") {
								onBeatForceAnimSprites.push({
									anim: s.animation.name,
									sprite: sAtlas
								});
							}
						}
					case "Bitmap":
						var bmap = generateBitmap(s, splitPath[0]);
						if (s.name != null) sprites[s.name] = bmap;
						PlayState.add(bmap);
					case "BF":
						doTheChar(PlayState.boyfriend, s);
						PlayState.add(PlayState.boyfriend);
					case "GF":
						doTheChar(PlayState.gf, s);
						PlayState.add(PlayState.gf);
					case "Dad":
						doTheChar(PlayState.dad, s);
						PlayState.add(PlayState.dad);
				}
			}
		}
	}

	function doTheChar(char:Character, s:StageSprite) {
		var scrollFactor = s.scrollFactor;
		if (scrollFactor == null) scrollFactor = [1, 1];
		while (scrollFactor.length < 2) scrollFactor.push(1);
		char.scrollFactor.set(scrollFactor[0], scrollFactor[1]);
		char.updateHitbox();

		// if (s.scale == null) s.scale = 1;

		// char.scale.set(s.scale, s.scale);
		// char.x += (char.charGlobalOffset.x * (s.scale - 1));
		// char.y += (char.charGlobalOffset.y * (s.scale - 1));
	}
	public static function generateSparrowAtlas(s:StageSprite, mod:String) {
		var pos:FlxPoint = new FlxPoint(0, 0);
		if (s.pos != null) {
			if (s.pos.length > 0) pos.x = s.pos[0];
			if (s.pos.length > 1) pos.y = s.pos[1];
		}
		var sprite = new FlxStageSprite(pos.x, pos.y);
		sprite.antialiasing = s.antialiasing != null ? s.antialiasing : true;

		sprite.name = s.name;
		sprite.type = "SparrowAtlas";

		var sf = new FlxPoint(1, 1);
		if (s.scrollFactor != null) {
			if (s.scrollFactor.length > 0) sf.x = s.scrollFactor[0];
			if (s.scrollFactor.length > 1) sf.y = s.scrollFactor[1];
		}
		sprite.scrollFactor.set(sf.x, sf.y);

		sprite.spritePath = s.src;
		if (s.src != null) {
			var sparrowAtlas = Paths.getSparrowAtlas(s.src, 'mods/$mod');
			// var sparrowAtlas = Paths.getSparrowAtlas_Custom('${Paths.modsPath}/${mod}/images/${s.src}');
			if (sparrowAtlas != null) {
				sprite.frames = sparrowAtlas;

				if (s.animation != null) {
					var animName = "anim";
					var framerate = 24;
					var animType = "";
					if (s.animation.name != null) animName = s.animation.name;
					if (s.animation.fps != null) framerate = s.animation.fps;
					if (s.animation.type != null) animType = s.animation.type.toLowerCase();
					sprite.animType = animType;

					sprite.animation.addByPrefix(animName, animName, framerate, animType == "loop");
					sprite.animation.play(animName);
					sprite.anim = s.animation;
				}
			}
		}
		if (s.scale != null) {
			sprite.scale.set(s.scale, s.scale);
			sprite.updateHitbox();
		}

		// if (s.name != null) sprites[s.name] = sprite;
		return sprite;
	}

	public static function generateBitmap(s:StageSprite, mod:String) {
		var pos:FlxPoint = new FlxPoint(0, 0);
		if (s.pos != null) {
			if (s.pos.length > 0) pos.x = s.pos[0];
			if (s.pos.length > 1) pos.y = s.pos[1];
		}
		var sprite = new FlxStageSprite(pos.x, pos.y);
		sprite.name = s.name;
		sprite.type = "Bitmap";
		sprite.antialiasing = s.antialiasing != null ? s.antialiasing : true;

		var sf = new FlxPoint(1, 1);
		if (s.scrollFactor != null) {
			if (s.scrollFactor.length > 0) sf.x = s.scrollFactor[0];
			if (s.scrollFactor.length > 1) sf.y = s.scrollFactor[1];
		}
		sprite.scrollFactor.set(sf.x, sf.y);

		sprite.spritePath = s.src;
		if (s.src != null) {
			var bitmap = Paths.image(s.src, 'mods/$mod');
			// var bitmap = Paths.getBitmapOutsideAssets('${Paths.modsPath}/${mod}/images/${s.src}.png');
			if (Assets.exists(bitmap)) sprite.loadGraphic(bitmap);
		}
		if (s.scale != null) {
			sprite.scale.set(s.scale, s.scale);
			sprite.updateHitbox();
		}
		return sprite;
	}

	public function destroy() {
		for(s in sprites) {
			s.destroy();
			PlayState.current.remove(s);
		}
		sprites = [];
		onBeatAnimSprites = [];
		onBeatForceAnimSprites = [];
	}
	
	public function update(elapsed:Float) {
		// useless for now, but may add stuff
	}
}