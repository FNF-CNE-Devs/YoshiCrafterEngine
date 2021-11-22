import LoadSettings.Settings;
import flixel.FlxG;


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
        return Settings.engineSettings.data.showAccuracy ? (" | Accuracy:" + (ps.numberOfNotes == 0 ? "0%" : Std.string((Math.round(ps.accuracy * 10000 / ps.numberOfNotes) / 10000) * 100) + "%") + " (" + accuracyTypesText[Settings.engineSettings.data.accuracyMode].charAt(0) + ")") : "";
    }

    public static function generateAverageDelay(ps:PlayState) {
        return Settings.engineSettings.data.showAverageDelay ? (" | Average:" + ((ps.numberOfArrowNotes == 0) ? "0ms" : Std.string(Math.floor((ps.delayTotal / ps.numberOfArrowNotes) * 100) / 100) + "ms")) : "";
    }

    public static function generateRating(ps:PlayState) {
        if (Settings.engineSettings.data.showRating && ps.numberOfNotes != 0) {
            var accuracy:Float = (ps.accuracy / ps.numberOfNotes) * 100;
            var rating:String = "None";
            if (accuracy == 100) rating = "S+"
            else if (accuracy >= 90) rating = "S"
            else if (accuracy >= 80) rating = "A"
            else if (accuracy >= 70) rating = "B"
            else if (accuracy >= 60) rating = "C"
            else if (accuracy >= 50) rating = "D"
            else if (accuracy >= 40) rating = "E"
            else rating = "F";

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
}