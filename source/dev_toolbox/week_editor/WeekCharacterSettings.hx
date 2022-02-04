package dev_toolbox.week_editor;

import dev_toolbox.toolbox_tabs.WeeksTab;
import flixel.tweens.FlxTween;
import openfl.desktop.ClipboardFormats;
import openfl.desktop.ClipboardTransferMode;
import openfl.desktop.Clipboard;
import dev_toolbox.file_explorer.FileExplorer;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.ui.*;

class WeekCharacterSettings extends MusicBeatSubstate {
    var state:WeeksTab;

    public var offsetX:FlxUINumericStepperPlus;
    public var offsetY:FlxUINumericStepperPlus;
    public var scale:FlxUINumericStepperPlus;

    public var flipX:FlxUICheckBox;

    public override function new(state:WeeksTab) {
        super();
        // state = cast(FlxG.state, ToolboxHome);
        this.state = state;

        var bg = new FlxSprite(0, state.yellowBG.y + state.yellowBG.height).makeGraphic(1280, Std.int(720 - state.yellowBG.y + state.yellowBG.height), 0x88000000);
        add(bg);

        var tabs = new FlxUITabMenu(null, [{
            name: 'tab',
            label: "Character settings"
        }], true);
        tabs.resize(640, 720 - bg.y);
        tabs.screenCenter(X);

        var tab = new FlxUI(null, tabs);
        tab.name = "tab";

        var labels = [];
        var label = new FlxUIText(10, 10, 620, "Character File Path");
        labels.push(label);
        var browseButton:FlxUIButton = null;
        browseButton = new FlxUIButton(10, label.y + label.height, '(Browse...) ${state.selectedWeek.dad.file}', function() {
            openSubState(new FileExplorer(ToolboxHome.selectedMod, FileExplorerType.SparrowAtlas, "", function(path) {
                state.selectedWeek.dad.file = path;
                browseButton.label.text = '(Browse...) $path';
            }));
        });
        browseButton.label.alignment = LEFT;
        browseButton.resize(620, 20);

        var label = new FlxUIText(10, browseButton.y + browseButton.height + 10, 620, "Character File Path");
        labels.push(label);
        var charAnim:FlxUIInputText = null;
        charAnim = new FlxUIInputText(10, label.y + label.height, 530, state.selectedWeek.dad.animation);
        var redFlickerAnim:FlxTween = null;
        var pasteButton:FlxUIButton = null;
        pasteButton = new FlxUIButton(charAnim.x + charAnim.width + 10, charAnim.y, "Paste", function() {
            var c = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT, ClipboardTransferMode.CLONE_PREFERRED);
            if (c == null) {
                if (redFlickerAnim != null) redFlickerAnim.destroy();
                redFlickerAnim = FlxTween.color(pasteButton, 1, 0xFFFF4444, 0xFFFFFFFF);
            } else {
                charAnim.text = c;
            }
        });

        var label = new FlxUIText(10, charAnim.y + charAnim.height + 10, 620, "Character Offset");
        labels.push(label);
        var x:Float = 0;
        var y:Float = 0;
        if (state.selectedWeek.dad.offset == null) state.selectedWeek.dad.offset = [];
        for (k=>i in state.selectedWeek.dad.offset) {
            if (k == 0) {
                x = i;
            } else {
                y = i;
            }
        }
        offsetX = new FlxUINumericStepperPlus(10, label.y + label.height, 5, x, -999, 999, 0);
        offsetY = new FlxUINumericStepperPlus(offsetX.x + offsetX.width + 10, label.y + label.height, 5, y, -999, 999, 0);
        
        var label = new FlxUIText(10, offsetX.y + offsetX.height + 10, 620, "Character Scale");
        labels.push(label);
        scale = new FlxUINumericStepperPlus(10, label.y + label.height, 0.05, state.selectedWeek.dad.scale, 0.05, 10, 2);
        
        var label = new FlxUIText(10, scale.y + scale.height + 10, 620, "Flip Character");
        labels.push(label);
        flipX = new FlxUICheckBox(10, label.y + label.height, null, state.selectedWeek.dad.flipX == true, "Flip character", 100, null, function() {
            state.menuCharacter.flipX = flipX.checked;
        });

        var updateButton:FlxUIButton = new FlxUIButton(10, scale.y + scale.height + 10, "Apply Changes & Update", function() {
            state.selectedWeek.dad.animation = charAnim.text;
            state.updateWeekInfo();
        });
        updateButton.resize(150, 20);



        for(l in labels) tab.add(l);
        tab.add(browseButton);
        tab.add(charAnim);
        tab.add(pasteButton);
        tab.add(offsetX);
        tab.add(offsetY);
        tab.add(scale);
        tab.add(updateButton);

        
        tabs.addGroup(tab);
        add(tabs);
        tabs.y = bg.y;

        var closeButton = new FlxUIButton(tabs.x + tabs.width - 23, tabs.y + 3, "X", function() {
            close();
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = 0xFFFFFFFF;
        closeButton.scrollFactor.set();
        add(closeButton);
    }

    public override function update(elapsed) {
        offsetX.stepSize = (FlxControls.pressed.SHIFT ? 30 : 10);
        offsetY.stepSize = (FlxControls.pressed.SHIFT ? 30 : 10);

        super.update(elapsed);
        state.menuCharacter.scale.x = state.menuCharacter.scale.y = scale.value;
        state.menuCharacter.updateHitbox();
        state.menuCharacter.offset.x = offsetX.value;
        state.menuCharacter.offset.y = offsetY.value;

        state.selectedWeek.dad.offset = [offsetX.value, offsetY.value];
        state.selectedWeek.dad.scale = scale.value;
        state.selectedWeek.dad.flipX = flipX.checked;
    }
}