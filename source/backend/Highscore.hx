package backend;

class Highscore {
    /**
     * A map of all of your highscores.
     */
    public static var songScores:Map<String, Int> = [];

    /**
     * Loads all of your highscores.
     */
    public static function init() {
        if(FlxG.save.data.songScores != null)
            songScores = FlxG.save.data.songScores;
        else {
            FlxG.save.data.songScores = songScores;
            FlxG.save.flush();
        }
    }

    /**
     * Gets a score from a song/week and difficulty of your choice.
     * @param name The song/week
     * @param diff The difficulty
     */
    public static function getScore(name:String, diff:String) {
        var formatted:String = '$name-$diff';
        if(!songScores.exists(formatted)) return 0;
        return songScores.get(formatted);
    }

    /**
     * Sets a score from a song/week and difficulty of your choice to any number.
     * @param name The song/week
     * @param diff The difficulty
     * @param score The score to save. (Optional, Defaults to `0`)
     */
    public static function setScore(name:String, diff:String, ?score:Int = 0) {
        songScores.set('$name-$diff', score);
        FlxG.save.data.songScores = songScores;
        FlxG.save.flush();
    }
}