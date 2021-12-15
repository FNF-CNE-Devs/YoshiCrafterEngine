import LoadSettings.Settings;
import flixel.FlxG;
import flixel.math.FlxMath;


class ScoreText {
    public static var accuracyTypesText:Array<String> = ["Complex", "Simple"];
    public static function generate(ps:PlayState):String {
        return generateScore(ps) + generateMisses(ps) + generateAccuracy(ps) + generateAverageDelay(ps) + generateRating(ps);
    }

    public static function generateScore(ps:PlayState) {
        return "Score:" + ps.songScore;
    }

    public static function generateMisses(ps:PlayState) {
        return Settings.engineSettings.data.showMisses ? " | Misses:" + ps.misses : "";
    }

    public static function generateAccuracy(ps:PlayState) {
        switch(Settings.engineSettings.data.accuracyMode) {
            default:
                return Settings.engineSettings.data.showAccuracy ? (" | Accuracy:" + (ps.numberOfNotes == 0 ? "0%" : Std.string(FlxMath.roundDecimal(ps.accuracy / ps.numberOfNotes * 100, 2)) + "%") + " (" + accuracyTypesText[Settings.engineSettings.data.accuracyMode].charAt(0) + ")") : "";
            case 1:
                var accuracyFloat:Float = 0;

                for(rat in PlayState.current.ratings) {
                    accuracyFloat += PlayState.current.hits[rat.name] * rat.accuracy;
                }

                return Settings.engineSettings.data.showAccuracy ? (" | Accuracy:" + (ps.numberOfNotes == 0 ? "0%" : Std.string(FlxMath.roundDecimal(ps.accuracy / ps.numberOfNotes * 100, 2)) + "%") + " (" + accuracyTypesText[Settings.engineSettings.data.accuracyMode].charAt(0) + ")") : "";
        }
        
    }

    public static function generateAverageDelay(ps:PlayState) {
        return Settings.engineSettings.data.showAverageDelay ? (" | Average:" + ((ps.numberOfArrowNotes == 0) ? "0ms" : Std.string(FlxMath.roundDecimal(ps.delayTotal / ps.numberOfArrowNotes, 2)) + "ms")) : "";
    }

    public static function generateRating(ps:PlayState) {
        if (Settings.engineSettings.data.showRating && ps.numberOfNotes != 0) {
            var rating = getRating(ps.accuracy / ps.numberOfNotes);

            var advancedRating = "";
            if (ps.numberOfArrowNotes > 0) {
                if (ps.misses == 0) advancedRating = "FC"
                else if (ps.misses < 10) advancedRating = "SDCB"
                else if (ps.numberOfArrowNotes > 0 ) advancedRating = "Clear"   ;
            }
            
            return (Settings.engineSettings.data.showRating && ps.numberOfNotes != 0) ? (" | " + rating + (advancedRating == "" ? "" : " (" + advancedRating + ")")) : "";
        } else {
            return "";
        }
    }

    public static function getRating(accuracy:Float) {
        var rating:String = "None";
        if (accuracy == 1) rating = "Perfect"
        else if (accuracy >= 0.9) rating = "S"
        else if (accuracy >= 0.8) rating = "A"
        else if (accuracy >= 0.7) rating = "B"
        else if (accuracy >= 0.6) rating = "C"
        else if (accuracy >= 0.5) rating = "D"
        else if (accuracy >= 0.4) rating = "E"
        else rating = "F";
        return rating;
    }
}