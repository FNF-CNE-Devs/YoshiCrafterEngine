typedef SongConfJson = {
    var songs:Array<SongConfSong>;
}

typedef SongConfSong = {
    var name:String;
    var scripts:Array<String>;
    var difficulties:Array<SongConfSong>;
}

class SongConf {
    public static function parse(mod:String) {
        // TODO : gotta finish stage editor first
    }
}