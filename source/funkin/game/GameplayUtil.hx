package funkin.game;

/**
 * A class full of utilities for gameplay.
 */
class GameplayUtil {
    public static function generateNote(strumTime:Float = 0, keyAmount:Int = 4, noteData:Int = 0, skin:String = "Default", mustPress:Bool, altAnim:Bool, strumLine:StrumLine, noteType:String = "Default") {
        var realNote:Note = new Note(-10000, -10000, keyAmount, noteData % keyAmount, skin);
        realNote.strumTime = strumTime;
        realNote.mustPress = mustPress;
        realNote.altAnim = altAnim;
        realNote.strumLine = strumLine;
        realNote.noteType = noteType;
        return realNote;
    }
}