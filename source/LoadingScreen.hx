import LoadSettings.Settings;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

typedef LoadingShit = {
    var name:String;
    var func:Void->Void; 
}

class LoadingScreen extends FlxState {
    var loadSections:Array<LoadingShit> = [
    ];
    var step:Int = 0;
    var loadingText:FlxText;
    var switchin:Bool = false;

    public override function create() {
        super.create();
        var loadingThingy = new FlxSprite(0, 0).makeGraphic(1280, 720, FlxColor.BLACK);
        loadingThingy.pixels.lock();
        var color1 = FlxColor.fromRGB(0, 66, 119);
        var color2 = FlxColor.fromRGB(86, 0, 151);
        for(x in 0...loadingThingy.pixels.width) {
            for(y in 0...loadingThingy.pixels.height) {
                loadingThingy.pixels.setPixel32(x, y, FlxColor.fromRGB(
                    Std.int(FlxMath.remapToRange(((x / loadingThingy.pixels.width) * 0.5) + ((y / loadingThingy.pixels.height) * 0.5), 0, 1, color1.red, color2.red)),
                    Std.int(FlxMath.remapToRange(((x / loadingThingy.pixels.width) * 0.5) + ((y / loadingThingy.pixels.height) * 0.5), 0, 1, color1.green, color2.green)),
                    Std.int(FlxMath.remapToRange(((x / loadingThingy.pixels.width) * 0.5) + ((y / loadingThingy.pixels.height) * 0.5), 0, 1, color1.blue, color2.blue))
                ));
            }
        }
        loadingThingy.pixels.unlock();
        add(loadingThingy);

        loadingText = new FlxText(0, 0, 0, "Loading...", 48);
        loadingText.setFormat(Paths.font("vcr.ttf"), Std.int(48), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        loadingText.y = FlxG.height - (loadingText.height * 1.5);
        loadingText.screenCenter(X);
        add(loadingText);

        var logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
        logoBl.screenCenter(X);
        add(logoBl);

        loadSections.push({
                "name" : "Save Data",
                "func" : saveData
            });
        loadSections.push({
                "name" : "Story Weeks",
                "func" : storyModeShit
            });
        loadSections.push({
                "name" : "Freeplay Songs",
                "func" : freeplayShit
            });

        FlxG.autoPause = false;
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);

        if (step < 0) {
            loadingText.text = "Loading " + loadSections[0].name + "... (0%)";
            step = 0;
            return;
        }
        if (step >= loadSections.length) {
            if (!switchin) {
                switchin = true;
                FlxG.switchState(new TitleState());
                FlxG.autoPause = true;
            }
        } else {
            loadSections[step].func();
            step++;
            if (step >= loadSections.length) {
                loadingText.text = "Loading Complete ! (100%)";
            } else {
                loadingText.text = "Loading " + loadSections[step].name + "... (" + Std.string(Math.round((step / loadSections.length) * 100)) + "%)";
            }
            loadingText.screenCenter(X);
        }

    }

    public function storyModeShit() {
        StoryMenuState.loadWeeks();
    }
    public function freeplayShit() {
        FreeplayState.loadFreeplaySongs();
    }
    public function saveData() {
		// ╔═══════════════════════════════════════════════════╗
		// ║ /!\ WARNING !                                     ║
		// ╟───────────────────────────────────────────────────╢
		// ║ I bet you guys have enough of having to redo your ║
		// ║ keybinds everytime you load a new mod. The line   ║
		// ║ below assure synchronisation between EVERY mods   ║
		// ║ that uses Yoshi Engine. For god's sake, DO NOT    ║
		// ║ edit the function, or remove this line. People    ║
		// ║ have enough of having to do their keybinds        ║
		// ║ everytime they download a new mod. If you wanna   ║
		// ║ set your own bind path, uses the fields :         ║
		// ║   - Settings.save_bind_name                       ║
		// ║   - Settings.save_bind_path                       ║
		// ║ In the LoadSettings.hx file.                      ║
		// ╚═══════════════════════════════════════════════════╝
		   FlxG.save.bind(Settings.save_bind_name, Settings.save_bind_path); // Binds to your mod data
		   Settings.loadDefault();  // Binds another instance of FlxSave to the engine's settings, allowing synchronisation between mods
		// -------------------------------------------

        
        var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;


        FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
            new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
        FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
            {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

        // transIn = FlxTransitionableState.defaultTransIn;
        // transOut = FlxTransitionableState.defaultTransOut;

    }
}