package backend.scripting.helperClasses;

using StringTools;

class StringHelper {
    public static function split(string:String, delimiter:String) {
        return string.split(delimiter);
    }
    
    public static function trim(string:String) {
        return string.trim();
    }

    public static function startsWith(string:String, delimiter:String) {
        return string.startsWith(delimiter);
    }

    public static function endsWith(string:String, delimiter:String) {
        return string.endsWith(delimiter);
    }

    public static function contains(string:String, delimiter:String) {
        return string.contains(delimiter);
    }

    public static function substr(string:String, pos:Int, ?len:Null<Int>) {
        return string.substr(pos, len);
    }

    public static function substring(string:String, pos:Int, ?len:Null<Int>) {
        return string.substring(pos, len);
    }

    public static function toUpperCase(string:String) {
        return string.toUpperCase();
    }

    public static function toLowerCase(string:String) {
        return string.toLowerCase();
    }

    public static function charAt(string:String, char:Int) {
        return string.charAt(char);
    }
}
