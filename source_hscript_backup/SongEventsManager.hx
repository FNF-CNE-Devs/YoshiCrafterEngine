class SongEventsManager {
    public var stage:Stage.FNFStage;
    public var hardcodedModchart:Modcharts.Modchart;

    public function new() {
        cModchart();
        cStage();
    }

    public function cModchart() {
        switch(PlayState.SONG.song.toLowerCase()) {
            default:
                hardcodedModchart = new Modcharts.Modchart();
            case "blammed":
                hardcodedModchart = new Modcharts.Blammed();
            case "milf":
                hardcodedModchart = new Modcharts.Milf();
            case "fresh":
                hardcodedModchart = new Modcharts.Fresh();
            case "why-do-you-hate-me" | "final-destination" | "god-eater":
                hardcodedModchart = new Modcharts.Test();
        }
    }
    public function cStage() {
        switch (PlayState.SONG.song.toLowerCase())
		{
            case 'spookeez' | 'monster' | 'south': 
            {
                PlayState.curStage = 'spooky';
                stage = new Stage.Spooky();
            }
            case 'pico' | 'blammed' | 'philly': 
            {
                PlayState.curStage = 'philly';
                stage = new Stage.Philly();
            }
            case 'milf' | 'satin-panties' | 'high':
            {
                PlayState.curStage = 'limo';
                stage = new Stage.Limo();
            }
            case 'cocoa' | 'eggnog':
            {
                PlayState.curStage = 'mall';
                stage = new Stage.Mall();
            }
            case 'winter-horrorland':
            {
                PlayState.curStage = 'mallEvil';
                stage = new Stage.MallEvil();
            }
            case 'senpai' | 'roses':
            {
                    
                PlayState.curStage = 'school';
                stage = new Stage.School();
            }
            case 'thorns':
            {
                PlayState.curStage = 'schoolEvil';
                stage = new Stage.SchoolEvil();
            }
            default:
            {
                PlayState.curStage = 'stage';
                stage = new Stage.DefaultStage();
            }
        }
    }
    public function create() {
        stage.create();
    }
    public function createAfterChars() {
        stage.createAfterChars();
    }
    public function createAfterGf() {
        stage.createAfterGf();
    }
    public function createInFront() {
        stage.createAfterGf();
        hardcodedModchart.create();
    }
    public function start() {
        stage.start();
        hardcodedModchart.start();
    }
    public function update(elapsed:Float) {
        stage.update(elapsed);
        hardcodedModchart.update(elapsed);
    }
    public function stepHit(curStep:Int) {
        stage.stepHit(curStep);
        hardcodedModchart.stepHit(curStep);
    }
    public function beatHit(curBeat:Int) {
        stage.beatHit(curBeat);
        hardcodedModchart.beatHit(curBeat);
    }
}