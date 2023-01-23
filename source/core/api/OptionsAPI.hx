package core.api;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

typedef ControlsList = Map<String, Array<FlxKey>>;

enum abstract OptionType(Int) to Int from Int {
    var BOOL = 0;
    var LIST = 1;
    var NUMBER = 2;
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
        // PREFERENCES
        "Downscroll"         => new Option(BOOL, false),
        "Centered Notefield" => new Option(BOOL, false),
        "Ghost Tapping"      => new Option(BOOL, true),
        "Miss Sounds"        => new Option(BOOL, true),
        #if windows
        "Dark Titlebar"      => new Option(BOOL, true),
        #end
        "Note Offset"        => new Option(NUMBER, 0.0),
        "Scroll Speed"       => new Option(NUMBER, 0.0),
        "Scroll Type"        => new Option(LIST, "Multiplier"),
        "Show Cutscenes"     => new Option(LIST, "Story Mode"),
        "Display Accuracy"   => new Option(BOOL, true),
        "Auto Pause"         => new Option(BOOL, true),
        "FPS Counter"        => new Option(BOOL, true),
        "Memory Counter"     => new Option(BOOL, true),

        // APPEARANCE
        "Judgement Camera"   => new Option(LIST, "World"),
        "Judgement Counter"  => new Option(LIST, "Left"),
        "Sustain Layer"      => new Option(LIST, "Front"),
        "Note Splashes"      => new Option(BOOL, true),

        // ACCESSIBILITY
        "Flashing Lights"    => new Option(BOOL, true),
        "Antialiasing"       => new Option(BOOL, true),
        "FPS Cap"            => new Option(NUMBER, 120),
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
        
        try {
            while(true) {
                if(!Paths.exists(Paths.json("data/optionsSaveData"))) break;

                var options:Array<Dynamic> = Json.parse(Assets.getText(Paths.json("data/optionsSaveData"))).options;
                for(option in options) {
                    var swagName:String = '${Paths.currentMod}:${option.name}';
                    if(get(swagName) == null) {
                        set(swagName, option.value);
                        doFlush = true;
                    }
                }
                break;
            }
        } catch(e) {
            Console.error(e.details());
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