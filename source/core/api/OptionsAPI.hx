package core.api;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

typedef ControlsList = Map<String, Array<FlxKey>>;

enum abstract OptionType(Int) to Int from Int {
    var BOOL = 0;
    var STRING = 1;
    var LIST = 2;
    var NUMBER = 3;
}

class Option {
    public var type:OptionType = BOOL;
    public var value:Dynamic = false;

    public function new(type:OptionType, value:Dynamic) {
        this.type = type;
        this.value = value;
    }
}

class OptionsAPI {
    public static var defaultOptions:Map<String, Option> = [
        // GAMEPLAY
        "Downscroll"      => new Option(BOOL, true),
        "Middlescroll"    => new Option(BOOL, false),
        "Ghost Tapping"   => new Option(BOOL, false),
        "Miss Sounds"     => new Option(BOOL, true),
        "Note Offset"     => new Option(NUMBER, 70.0),

        // ACCESSIBILITY
        "Flashing Lights" => new Option(BOOL, true),
        "Antialiasing"    => new Option(BOOL, true),
        "Auto Pause"      => new Option(BOOL, true),
        "FPS Cap"         => new Option(NUMBER, 240),
    ];

    public static var defaultControls:Map<String, ControlsList> = [
        "UI" => [
            "UP" => [W, UP],
            "DOWN" => [S, DOWN],
            "LEFT" => [A, LEFT],
            "RIGHT" => [D, RIGHT],

            "ACCEPT" => [ENTER, SPACE],
            "BACK" => [BACKSPACE, ESCAPE],
            "PAUSE" => [ENTER, NONE],
        ],

        "GAME" => [
            "4K" => [S, D, K, L],
        ],
    ];

    public static var save:FlxSave;

    public static function init() {
        save = new FlxSave();
        save.bind("preferencesSave", "NovaEngine");

        var doFlush:Bool = false;

        for(name => option in defaultOptions) {
            if(get(name) == null) {
                set(name, option.value);
                doFlush = true;
            }
        }

        for(listName => list in defaultControls) {
            for(name => keys in list) {
                if(get("CONTROLS_"+listName+"_"+name) == null) {
                    set("CONTROLS_"+listName+"_"+name, keys);
                    doFlush = true;
                }
            }
        }

        if(doFlush) flush();
    }

    public static function get(name:String):Dynamic {
        return Reflect.field(save.data, name);
    }

    public static function set(name:String, value:Dynamic):Dynamic {
        Reflect.setField(save.data, name, value);
        return value;
    }

    /**
     * Saves your options to the filesystem.
     */
    public static function flush() {
        save.flush();
    }
}