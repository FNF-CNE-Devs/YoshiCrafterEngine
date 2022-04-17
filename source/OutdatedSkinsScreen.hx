import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
using StringTools;

class OutdatedSkinsScreen extends MusicBeatState {

    public static var code_template_bf =
"function create() {
    character.frames = Paths.getCharacter(\"~:bf/{0}\");
    character.longAnims = [\"dodge\"];
{1}

    character.playAnim('idle');
    character.charGlobalOffset.y = 350;
    character.flipX = true;
}

function dance() {
    if (character.lastHit <= Conductor.songPosition - 500 || character.lastHit == 0) {
        character.playAnim('idle');
    }
}

function getColors(altAnim) {
    return [
        0xFF31B0D1,
        EngineSettings.arrowColor0,
        EngineSettings.arrowColor1,
        EngineSettings.arrowColor2,
        EngineSettings.arrowColor3
    ];
}";

    public static var code_template_gf =
"function create() {
    var tex = Paths.getCharacter(\"~:gf/{0}\");
    character.frames = tex;

{1}

    character.playAnim('danceRight');
}

danced = false;
function dance() {
    if (character.animation.name == \"hairBlow\" || (character.animation.name == \"hairFall\" && !character.animation.finished)) {
        danced = false;
        return;
    }
    if (danced)
        character.playAnim(\"danceLeft\");
    else
        character.playAnim(\"danceRight\");
    danced = !danced;
}

function getColors(altAnim) {
    return [
        0xFFA5004D,
        0xFFA5004D,
        0xFFA5004D,
        0xFFA5004D,
        0xFFA5004D
    ];
}";
    public static var code_anim_template = "    character.animation.addByPrefix('{0}', '{1}', 24, {2});";
    public static var code_offset_template = "    character.addOffset('{0}', {1}, {2});";
    public static var code_anim_indices_template = "    character.animation.addByIndices('{0}', '{1}', [{2}], \"\", 24, false);";

    
    var yes:FlxText;
    var no:FlxText;
    var curSelected:Int;
    public override function create() {
        super.create();

        var bg = new FlxSprite(0,0).loadGraphic(Paths.image("menuBGYoshiCrafter", "preload"));
		bg.scale.x = bg.scale.y = 1.25;
		bg.antialiasing = true;
		bg.screenCenter();
		bg.scrollFactor.set();
        add(bg);

        var name = new FlxText(0, 200, 0, "OUTDATED SKINS");
        name.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        name.screenCenter(X);
        var t = [
            "Skins used by the old system were found.",
            "These skins aren't supported anymore and can't be used.",
            "Do you want the engine to convert them to the new system ?"
        ];
        for (k=>e in t) {
            var text = new FlxText(0, 275 + (k * 30), 0, e);
            text.setFormat(Paths.font("vcr.ttf"), Std.int(18), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            text.screenCenter(X);
            add(text);
        }
        // versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        yes = new FlxText(0, 450, 0, "YES");
        yes.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        no = new FlxText(0, 450, 0, "NO");
        no.setFormat("VCR OSD Mono", 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        
        add(name);
        add(yes);
        add(no);
    }

    public override function update(elapsed) {
        super.update(elapsed);
        yes.text = curSelected == 0 ? "> YES <" : "YES";
        no.text = curSelected == 1 ? "> NO <" : "NO";

        yes.x = 320 - (yes.width / 2);
        no.x = 960 - (no.width / 2);

        if (controls.LEFT_P || controls.RIGHT_P) {
            curSelected = (curSelected + 1) % 2;
        }

        if (controls.ACCEPT) {
            if (curSelected == 0) {
                beginTransition();
            }
            TitleState.skipOldSkinCheck = true;
            FlxG.switchState(new TitleState());
        }
    }

    public function beginTransition() {
        var bfSkinsPath = '${Paths.getOldSkinsPath()}/bf/';
        if (FileSystem.exists(bfSkinsPath)) {
            for (skin in FileSystem.readDirectory(bfSkinsPath)) {
                if (skin.toLowerCase() == "default" || skin.toLowerCase() == "template") continue;
                if (FileSystem.isDirectory('$bfSkinsPath/$skin')) {
                    trace('=======================');
                    trace('Converting $skin');
                    var requiredFiles = ["spritesheet.xml", "spritesheet.png", "icon.png", "anim_names.txt", "offsets.txt"];
                    var canConvert = true;
                    for (r in requiredFiles) {
                        if (!FileSystem.exists('$bfSkinsPath/$skin/$r')) {
                            canConvert = false;
                            break;
                        }
                    }
                    if (!canConvert) {
                        trace('Could not convert $skin. Not all of the required files are there.');
                        continue;
                    }
                    FileSystem.createDirectory('${Paths.getSkinsPath()}/bf/$skin/');
    
                    trace("Copying spritesheet...");
                    File.copy('$bfSkinsPath/$skin/spritesheet.xml', '${Paths.getSkinsPath()}/bf/$skin/spritesheet.xml');
                    File.copy('$bfSkinsPath/$skin/spritesheet.png', '${Paths.getSkinsPath()}/bf/$skin/spritesheet.png');
    
                    trace("Copying icon...");
                    File.copy('$bfSkinsPath/$skin/icon.png', '${Paths.getSkinsPath()}/bf/$skin/icon.png');
    
                    trace("Loading animations...");
                    var animsFile = File.getContent('$bfSkinsPath/$skin/anim_names.txt').replace("\r", "").trim();
                    var splitAnims = animsFile.split("\n");
    
                    trace("Loading offsets...");
                    var offsetFile = File.getContent('$bfSkinsPath/$skin/offsets.txt');
                    while(offsetFile.contains("  ")) {
                        offsetFile.replace("  ", " ");
                    }
                    var splitOffsets = offsetFile.trim().split("\n");
                    for(k=>e in splitOffsets) {
                        splitOffsets[k] = e.replace("\r", "").trim();
                    }
    
                    trace("Creating a new Character.hx...");
                    var charCode = code_template_bf.replace("{0}", skin);
                    var additionalCode = "";
    
                    trace("Setting up animations...");
                    for (anim in splitAnims) {
                        var split = anim.split(":");
                        if (split.length > 1) {
                            if (split[0] == "singDODGE") split[0] = "dodge";
                            additionalCode += code_anim_template
                                .replace("{0}", split[0].replace("'", "\\'"))
                                .replace("{1}", split[1].replace("'", "\\'"))
                                .replace("{2}", split[0] == "deathLoop" ? "true" : "false") + "\r\n";
                        }
                    }
                    additionalCode += "\r\n";
                    trace("Setting up offsets...");
                    for (offset in splitOffsets) {
                        var split = offset.split(" ");
                        if (split.length > 2) {
                            if (split[0] == "singDODGE") split[0] = "dodge";
                            additionalCode += code_offset_template
                                .replace("{0}", split[0].replace("'", "\\'"))
                                .replace("{1}", split[1])
                                .replace("{2}", split[2]) + "\r\n";
                        }
                    }
    
                    trace("Saving Character.hx...");
                    charCode = charCode.replace("{1}", additionalCode);
                    File.saveContent('${Paths.getSkinsPath()}/bf/$skin/Character.hx', charCode);
                }
            }
        }

        var gfSkinsPath = '${Paths.getOldSkinsPath()}/gf/';
        if (FileSystem.exists(gfSkinsPath)) {
            for (skin in FileSystem.readDirectory(gfSkinsPath)) {
                if (skin.toLowerCase() == "default" || skin.toLowerCase() == "template") continue;
                if (FileSystem.isDirectory('$gfSkinsPath/$skin')) {
                    trace('=======================');
                    trace('Converting $skin');
                    var requiredFiles = ["spritesheet.xml", "spritesheet.png", "icon.png", "anim_names.txt", "offsets.txt"];
                    var canConvert = true;
                    for (r in requiredFiles) {
                        if (!FileSystem.exists('$gfSkinsPath/$skin/$r')) {
                            canConvert = false;
                            break;
                        }
                    }
                    if (!canConvert) {
                        trace('Could not convert $skin. Not all of the required files are there.');
                        continue;
                    }
                    FileSystem.createDirectory('${Paths.getSkinsPath()}/gf/$skin/');
    
                    trace("Copying spritesheet...");
                    File.copy('$gfSkinsPath/$skin/spritesheet.xml', '${Paths.getSkinsPath()}/gf/$skin/spritesheet.xml');
                    File.copy('$gfSkinsPath/$skin/spritesheet.png', '${Paths.getSkinsPath()}/gf/$skin/spritesheet.png');
    
                    trace("Copying icon...");
                    File.copy('$gfSkinsPath/$skin/icon.png', '${Paths.getSkinsPath()}/gf/$skin/icon.png');
    
                    trace("Loading animations...");
                    var animsFile = File.getContent('$gfSkinsPath/$skin/anim_names.txt').replace("\r", "").trim();
                    var splitAnims = animsFile.split("\n");
    
                    trace("Loading offsets...");
                    var offsetFile = File.getContent('$gfSkinsPath/$skin/offsets.txt');
                    while(offsetFile.contains("  ")) {
                        offsetFile.replace("  ", " ");
                    }
                    var splitOffsets = offsetFile.trim().split("\n");
                    for(k=>e in splitOffsets) {
                        splitOffsets[k] = e.replace("\r", "").trim();
                    }
    
                    trace("Creating a new Character.hx...");
                    var charCode = code_template_gf.replace("{0}", skin);
                    var additionalCode = "";
    
                    trace("Setting up animations...");
                    var indices:Map<String, Array<Int>> = [
                        "danceLeft" => [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
                        "danceRight" => [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29],
                        "sad" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                        "hairBlow" => [0, 1, 2, 3],
                        "hairFall" => [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
                    ];
                    var loopingAnims = ["scared", "hairBlow"];
                    for (anim in splitAnims) {
                        var split = anim.split(":");
                        if (split.length > 1) {
                            if (split[0] == "dance") {
                                additionalCode += code_anim_indices_template.replace("{0}", "danceLeft").replace("{1}", split[1].replace("'", "\\'")).replace("{2}", indices["danceLeft"].join(", ")) + "\r\n";
                                additionalCode += code_anim_indices_template.replace("{0}", "danceRight").replace("{1}", split[1].replace("'", "\\'")).replace("{2}", indices["danceRight"].join(", ")) + "\r\n";
                            } else if (indices[split[0]] != null) {
                                additionalCode += code_anim_indices_template.replace("{0}", split[0].replace("'", "\\'")).replace("{1}", split[1].replace("'", "\\'")).replace("{2}", indices[split[0]].join(", ")) + "\r\n";
                            } else {
                                additionalCode += code_anim_template
                                    .replace("{0}", split[0].replace("'", "\\'"))
                                    .replace("{1}", split[1].replace("'", "\\'"))
                                    .replace("{2}", loopingAnims.contains(split[0]) ? "true" : "false") + "\r\n";
                            }
                        }
                    }
                    additionalCode += "\r\n";
                    trace("Setting up offsets...");
                    for (offset in splitOffsets) {
                        var split = offset.split(" ");
                        if (split.length > 2) {
                            additionalCode += code_offset_template
                                .replace("{0}", split[0].replace("'", "\\'"))
                                .replace("{1}", split[1])
                                .replace("{2}", split[2]) + "\r\n";
                        }
                    }
    
                    trace("Saving Character.hx...");
                    charCode = charCode.replace("{1}", additionalCode);
                    File.saveContent('${Paths.getSkinsPath()}/gf/$skin/Character.hx', charCode);
                }
            }
        }

        var noteSkinsPath = '${Paths.getOldSkinsPath()}/notes/';
        var exts = ["png", "xml"];
        if (FileSystem.exists(noteSkinsPath))
            for (skin in FileSystem.readDirectory(noteSkinsPath))
                for (ext in exts)
                    if (Path.extension(skin).toLowerCase() == ext)
                        File.copy('$noteSkinsPath/$skin', '${Paths.getSkinsPath()}/notes/$skin');
        var file = Paths.getOldSkinsPath().replace("/", "/");
        trace(file);
        CoolUtil.deleteFolder(file);
        FileSystem.deleteDirectory(file);
    }
}