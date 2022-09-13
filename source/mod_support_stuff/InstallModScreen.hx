package mod_support_stuff;

import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxObject;
import haxe.zip.Reader;

class InstallModScreen extends MusicBeatState {
    public static var path:String;
    public static var backState:Class<MusicBeatState> = TitleState;

    // UNCOMPRESSING STUFF
    public var zip:Reader;

    // UI STUFF
    var modCards:Array<ModCard> = [];
    var curSelected:Int = 0;
    var camFollow:FlxObject;
    var errorText:FlxText;
    var errorTextTime:Float = 0;

    public override function create() {
        super.create();
        zip = ZipUtils.openZip(path);

        var bg = CoolUtil.addModInstallBG(this);
        bg.scale.x *= 1.05;
        bg.scale.y *= 1.05;

        
        
        camFollow = new FlxObject(0, 0, 2, 2);

        var mods = ZipUtils.getModsFromZip(zip);
        for(k=>m in mods) {
            var mCard = new ModCard(m.name, m.config);
            if (m.icon != null) {
                mCard.mod_icon.loadGraphic(m.icon);
                mCard.mod_icon.setGraphicSize(150, 150);
                mCard.mod_icon.updateHitbox();
                mCard.mod_icon.scale.set(Math.min(mCard.mod_icon.scale.x, mCard.mod_icon.scale.y), Math.min(mCard.mod_icon.scale.x, mCard.mod_icon.scale.y));
            }
            mCard.x = (mCard.width + 50) * k;
            mCard.screenCenter(Y);
            mCard.y -= mCard.y % 1;
            modCards.push(mCard);
            add(mCard);
        }
        camFollow.screenCenter();
        if (modCards.length > 0) {
            var midpoint = modCards[0].getMidpoint();
            camFollow.setPosition(midpoint.x, midpoint.y);
        }
        var title = new AlphabetOptimized(0, 15, modCards.length > 1 ? "Select mod to install..." : "Press ENTER to install.", true, 0.75);
        title.scrollFactor.set();
        title.screenCenter(X);

        var bg = new FlxSprite(-1, -1).makeGraphic(FlxG.width + 2, Std.int(45 + (title.y * 2)) + 1, 0xFF000000);
        bg.alpha = 0.75;
        bg.scrollFactor.set();
        add(bg);
        add(title);
        FlxG.camera.follow(camFollow, LOCKON, 0.25);

        if (modCards.length <= 0) {
            errorText = new FlxText(0, 0, FlxG.width * 0.75, "There isn't any mods in the .ycemod file or the file is corrupted.\nPress Backspace to exit.");
            errorText.setFormat(Paths.font("vcr.ttf"), Std.int(24), 0xFFFF4444, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
            errorText.borderSize = 1.75;
            errorText.screenCenter();
            add(errorText);
        }
    }

    public override function update(elapsed:Float) {
        super.update(elapsed);
        var osel = curSelected;
        
        if (controls.RIGHT_P)
            curSelected++;
        if (controls.LEFT_P)
            curSelected--;
        if (osel != curSelected) {
            CoolUtil.playMenuSFX(0);
        }

        curSelected = CoolUtil.wrapInt(curSelected, 0, modCards.length);

        if (controls.BACK)
            FlxG.switchState(Type.createInstance(backState, []));

        var curCard = modCards[curSelected];
        if (curCard != null) {
            var midpoint = modCards[curSelected].getMidpoint();
            camFollow.setPosition(midpoint.x, midpoint.y);
            camFollow.y -= camFollow.y % 1;
            
            if (controls.ACCEPT) {
                persistentUpdate = false;
                persistentDraw = true;
                openSubState(new InstallModSubstate(zip, modCards[curSelected].mod));
            }
        } else {
            if (errorText != null) {
                errorTextTime += elapsed;
                errorText.alpha = 0.75 + (Math.sin(errorTextTime * 2) * 0.25);
            }
        }
    }
}