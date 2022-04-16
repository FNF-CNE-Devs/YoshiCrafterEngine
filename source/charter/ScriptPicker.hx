package charter;

import haxe.io.Path;
import dev_toolbox.file_explorer.FileExplorer;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.*;
import flixel.*;

class ScriptPicker extends MusicBeatSubstate {
    public var scripts:Array<String> = [];
    public var elements:Array<FlxSprite> = [];

    public var UI:FlxUITabMenu;
    public var tab:FlxUI;
    public var buttonY:Float = 0;
    public function new(?scripts:Array<String>, ?label:String = "Edit Scripts") {
        super();
        if (scripts == null) scripts = [];
        this.scripts = scripts;

        var bg:FlxSprite;
        (bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0x88000000)).scrollFactor.set();
        add(bg);

        UI = new FlxUITabMenu(null, [
            {
                name: "scripts",
                label: label
            }
        ], true);
        UI.scrollFactor.set();
        UI.resize(400, FlxG.height - 100);
        UI.screenCenter();
        add(UI);

        tab = new FlxUI(null, UI);
        tab.name = "scripts";

        var label = new FlxUIText(10, 10, 380, "Click on the \"Add Script\" button at the bottom of this window to add a script, or remove added scripts by clicking the bin button next to the script names. Please note that this list and the one from the song configuration tab have different values (this one is chart only, song conf is for the entire song), and that scripts from both lists will add up. That means if a script is added on both lists, it'll be ran two times.");
        buttonY = label.y + label.height + 10;
        tab.add(label);

        tab.add(new FlxSprite(10, buttonY).loadGraphic(FlxGridOverlay.createGrid(380, 20, 380, 480, true, 0xFFA0A0A0, 0xFF7A7A7A)));

        var addScriptButton = new FlxUIButton(10, FlxG.height - 150, "Add Script", function() {
            // todo
            openSubState(new FileExplorer(PlayState.songMod, FileExplorerType.Script, "", function(path) {
                scripts.push('${PlayState.songMod}:${Path.withoutExtension(path)}');
                refreshElements();
            }));
        });
        tab.add(addScriptButton);
        UI.addGroup(tab);

        var closeButton = new FlxUIButton(UI.x + UI.width - 20, UI.y, "X", function() {
            close();
        });
        closeButton.resize(20, 20);
        closeButton.label.color = 0xFFFFFFFF;
        closeButton.color = 0xFFFF4444;
        closeButton.scrollFactor.set();
        add(closeButton);

        refreshElements();
    }

    public function clearElements() {
        for(e in elements) {
            tab.remove(e);
            remove(e);
            e.destroy();
        }
        elements = [];
    }

    public function refreshElements() {
        clearElements();
        for(i=>s in scripts) {
            var button = new FlxUIButton(370, buttonY + (20 * i), "", function() {
                scripts.remove(s);
                refreshElements();
            });
            button.resize(20, 20);
            button.color = 0xFFFF4444;
            var buttonImage = new FlxSprite(button.x + 2, button.y + 2);
            CoolUtil.loadUIStuff(buttonImage, "delete");

            var label = new FlxUIText(10, buttonY + (20 * (i + 0.5)), 340, s);
            label.y -= label.height / 2;
            for(e in [label, button, buttonImage]) {
                tab.add(e);
                elements.push(e);
            }
        }
    }
    public override function update(elapsed:Float) {
        super.update(elapsed);
    }
}