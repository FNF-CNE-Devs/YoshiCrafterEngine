import Stage.StageJSON;

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
};';

    public static var stageTemplate:StageJSON = {
        defaultCamZoom: 1,
        sprites: [
            {
                type: "GF",
                name: "Girlfriend",
                scrollFactor: [0.95, 0.95]
            },
            {
                type: "Dad",
                name: "Dad",
                scrollFactor: [1, 1]
            },
            {
                type: "BF",
                name: "Boyfriend",
                scrollFactor: [1, 1]
            }
        ],
        bfOffset: [0, 0],
        gfOffset: [0, 0],
        dadOffset: [0, 0]
    };
}