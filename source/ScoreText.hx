import EngineSettings.Settings;
import flixel.FlxG;
import flixel.math.FlxMath;


class ScoreText {
    public static var accuracyTypesText:Array<String> = ["Complex", "Simple"];
    public static function generate(ps:PlayState):String {
        var arrayData = [generateScore(ps)];
        if (Settings.engineSettings.data.showMisses) arrayData.push(generateMisses(ps));
        if (Settings.engineSettings.data.showAccuracy) arrayData.push(generateAccuracy(ps));
        if (Settings.engineSettings.data.showAverageDelay) arrayData.push(generateAverageDelay(ps));
        if (Settings.engineSettings.data.showRating) arrayData.push(generateRating(ps));
		
		var joinString = " | ";
		if (PlayState.current != null)
			joinString = PlayState.current.engineSettings.scoreJoinString;
		else
			joinString = Settings.engineSettings.data.scoreJoinString;

        return arrayData.join(joinString);
    }

    public static function generateScore(ps:PlayState) {
        return "Score:" + ps.songScore;
    }

    public static function generateMisses(ps:PlayState) {
        return "Misses:" + ps.misses;
    }

    public static function generateAccuracy(ps:PlayState) {
        switch(Settings.engineSettings.data.accuracyMode) {
            default:
                return "Accuracy:" + (ps.numberOfNotes == 0 ? "0%" : Std.string(FlxMath.roundDecimal(ps.accuracy / ps.numberOfNotes * 100, 2)) + "%") + (Settings.engineSettings.data.showAccuracyMode ? " (" + accuracyTypesText[Settings.engineSettings.data.accuracyMode] + ")" : "");
            case 1:
                var accuracyFloat:Float = 0;

                for(rat in PlayState.current.ratings) {
                    accuracyFloat += PlayState.current.hits[rat.name] * rat.accuracy;
                }

                return "Accuracy:" + (ps.numberOfNotes == 0 ? "0%" : Std.string(FlxMath.roundDecimal(accuracyFloat / ps.numberOfArrowNotes * 100, 2)) + "%") + " (" + accuracyTypesText[Settings.engineSettings.data.accuracyMode] + ")";
        }
        
    }

    public static function generateAverageDelay(ps:PlayState) {
        return "Average:" + ((ps.numberOfArrowNotes - ps.misses == 0) ? "0ms" : Std.string(FlxMath.roundDecimal(ps.delayTotal / (ps.numberOfArrowNotes - ps.misses), 2)) + "ms");
    }

    public static function generateRating(ps:PlayState) {
        if (ps.engineSettings.botplay) return "BOTPLAY";

        if (ps.numberOfNotes != 0) {
            var rating = getRating(ps.accuracy / ps.numberOfNotes);

            var advancedRating = "";
            if (ps.numberOfArrowNotes > 0) {
                if (ps.misses == 0) 
                {
                    var t:String = "FC";
                    for (r in ps.ratings) {
                        if (ps.hits[r.name] > 0) {
                            t = r.fcRating;
                        }
                    }
                    advancedRating = t;
                }
                else if (ps.misses < 10) advancedRating = "SDCB"
                else if (ps.numberOfArrowNotes > 0 ) advancedRating = "Clear";
            }
            
            return rating + (advancedRating == "" ? "" : " (" + advancedRating + ")");
        } else {
            return "N/A";
        }
    }

    public static function getRating(accuracy:Float) {
        var rating:String = "how are you this bad";

        if (accuracy == 1) rating = "Perfect"
        else if (accuracy >= 0.9) rating = "S"
        else if (accuracy >= 0.8) rating = "A"
        else if (accuracy >= 0.7) rating = "B"
        else if (accuracy >= 0.6) rating = "C"
        else if (accuracy >= 0.5) rating = "D"
        else if (accuracy >= 0.4) rating = "E"
        else if (accuracy == 0) rating = "..."
        else rating = "F";

        return rating;
    }
}