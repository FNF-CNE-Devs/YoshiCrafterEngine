package dev_toolbox.toolbox_tabs;

import dev_toolbox.stage_editor.StageEditor;
import flixel.FlxG;
import flixel.addons.ui.*;
import haxe.io.Path;
import sys.FileSystem;

class StagesTab extends ToolboxTab {
    var stageList:Array<String> = [];
    var stageRadioList:FlxUIRadioGroup;
    var selectedStage:String = null;
    public function new(x:Float, y:Float, home:ToolboxHome) {
        super(x, y, "stages", home);
        // Creates a stages folder in case it doesn't exists.
        FileSystem.createDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/');
        stageRadioList = new FlxUIRadioGroup(10, 10, stageList, stageList, function(stage) {
            selectedStage = stage;
        });
        updateRadioList();
        var selectStageButton = new FlxUIButton(0, FlxG.height - y - 10, "Edit", function() {
            if (selectedStage != null) {
                FlxG.switchState(new StageEditor(selectedStage));
            }
        });
        selectStageButton.y -= selectStageButton.height;
        selectStageButton.screenCenter(X);


        add(stageRadioList);
        add(selectStageButton);
    }

    function updateRadioList() {
        stageList = [];
        for(f in FileSystem.readDirectory('${Paths.modsPath}/${ToolboxHome.selectedMod}/stages/')) {
            if (Path.extension(f).toLowerCase() == 'json') {
                // is a json stage
                stageList.push(Path.withoutExtension(f));
            }
        }
        stageRadioList.updateRadios(stageList, stageList);
        stageRadioList.screenCenter(X);
    }
    public override function tabUpdate(elapsed) {
        super.tabUpdate(elapsed);

    }
}