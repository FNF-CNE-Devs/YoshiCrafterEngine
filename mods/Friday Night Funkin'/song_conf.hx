//stage shit
var perSongConfiguration:Map<String, Array<String>> = [
    "fresh" => ["default_stage", "fresh", ""],

    "spookeez" => ["halloween", "", ""],
    "south" => ["halloween", "", ""],
    "monster" => ["halloween", "", ""],

    "pico" => ["halloween", "", ""],
    "philly" => ["halloween", "", ""],
    "blammed" => ["halloween", "blammed", ""],

    "satin-panties" => ["limo", "", ""],
    "high" => ["limo", "", ""],
    "milf" => ["limo", "milf", ""],

    "cocoa" => ["mall", "", ""],
    "eggnog" => ["mall", "", ""],
    "winter-horrorland" => ["mallEvil", "milf", "monster-week5-cutscene"],
];
if (song == "fresh") {
    modchart = "fresh";
}

switch(song) {
    // WEEK 1
    case "fresh":
        modchart = "fresh";

    // WEEK 2
    case "spookeez":
        stage = "halloween";
    case "south":
        stage = "halloween";
    case "monster":
        stage = "halloween";

    // WEEK 3
    case "pico":
        stage = "philly";
    case "philly":
        stage = "philly";
    case "blammed":
        stage = "philly";
        modchart = "blammed";

    // WEEK 4
    case "satin-panties":
        stage = "limo";
    case "high":
        stage = "limo";
    case "milf":
        stage = "limo";
        modchart = "milf";

    // WEEK 5
    case "cocoa":
        stage = "mall";
    case "eggnog":
        stage = "mall";
    case "winter-horrorland":
        stage = "mall-evil";
        cutscene = "week5-monster";

    // WEEK 6
    case "senpai":
        stage = "school";
        cutscene = "dialogue";
    case "roses":
        stage = "school";
        cutscene = "angry-dialogue";
    case "thorns":
        stage = "school-evil";
        cutscene = "evil-dialogue";

    // WEEK 7
    case "ugh":
        stage = "tank";
        cutscene = "ugh";
    case "guns":
        stage = "tank";
        cutscene = "guns";
    case "stress":
        stage = "tank";
        cutscene = "stress";
}