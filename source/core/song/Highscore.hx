package core.song;

class Highscore {
    public static var songScores:Map<String, Int> = [];

    public static function init() {
        if(FlxG.save.data.songScores != null)
            songScores = FlxG.save.data.songScores;
        else {
            FlxG.save.data.songScores = songScores;
            FlxG.save.flush();
        }
    }

    public static function getScore(name:String, diff:String) {
        var formatted:String = '$name-$diff';
        if(!songScores.exists(formatted)) return 0;
        return songScores.get(formatted);
    }

    public static function setScore(name:String, diff:String, ?score:Int = 0) {
        songScores.set('$name-$diff', score);
        FlxG.save.data.songScores = songScores;
        FlxG.save.flush();
    }
}