class Templates {
    public static var stageScriptTemplate = '// Stage element
var stage:Stage = null;
function create() {
    // Loads the stage. Can be called in any scripts
    stage = loadStage("tank");
}

function beatHit(curBeat) {
    // Does the OnBeat event to animate stage sprites.
    stage.onBeat();
};'
}