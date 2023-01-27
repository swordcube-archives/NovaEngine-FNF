package core;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;

typedef KeyList = Array<Null<FlxKey>>;

enum abstract KeyState(Int) to Int from Int {
    var JUST_PRESSED = 0;
    var PRESSED = 1;
    var JUST_RELEASED = 2;
    var RELEASED = 3;
}

class Controls {
    // -- INTERNAL VARIABLES & FUNCTIONS ----------------------------------------------

    static var __save:FlxSave;

    static var __defaultControls:Map<String, KeyList> = [
        // UI controls
        "UI_UP" => [W, UP],
        "UI_DOWN" => [S, DOWN],
        "UI_LEFT" => [A, LEFT],
        "UI_RIGHT" => [D, RIGHT],

        "ACCEPT" => [ENTER, SPACE],
        "PAUSE" => [ENTER, NONE],
        "BACK" => [BACKSPACE, ESCAPE],

        // Game controls
        "NOTE_0" => [A, LEFT],
        "NOTE_1" => [S, DOWN],
        "NOTE_2" => [W, UP],
        "NOTE_3" => [D, RIGHT],

        // Debug controls
        "CHARTER" => [SEVEN, NUMPADSEVEN]
    ];

    public static var controlsList:Map<String, KeyList> = [];

    /**
     * Initializes the save data for your controls.
     */
     public static function init() {
        __save = new FlxSave();
        __save.bind("controls", "NovaEngine");
    }

    /**
     * Loads all of your saved controls.
     */
    public static function load() {
        for(name => keys in __defaultControls) {
            var savedKeys:KeyList = Reflect.field(FlxG.save.data, 'CONTROLS_$name');

            if(savedKeys != null)
                controlsList.set(name, savedKeys);
            else {
                Reflect.setField(FlxG.save.data, 'CONTROLS_$name', keys);
                controlsList.set(name, keys);
            }
        }
    }

    /**
     * Saves all of your controls.
     */
    public static function save() {

    }

    public function new() {}

    // -- NON-STATIC VARIABLES & FUNCTIONS --------------------------------------------

    public var ACCEPT(get, never):Bool;
    private function get_ACCEPT() return __checkKeys(controlsList["ACCEPT"], JUST_PRESSED);

    // -- HELPER VARIABLES & FUNCTIONS ------------------------------------------------

    private function __checkKeys(list:KeyList, ?state:KeyState = PRESSED) {
        return __checkKey(list[1], state) || __checkKey(list[0], state);
    }

    private function __checkKey(key:Null<FlxKey>, ?state:KeyState = PRESSED) {
        return isKeyInvalid(key) ? false : switch(state) {
            case JUST_PRESSED:  FlxG.keys.checkStatus(key, JUST_PRESSED);
            case PRESSED:       FlxG.keys.checkStatus(key, PRESSED);
            case JUST_RELEASED: FlxG.keys.checkStatus(key, JUST_RELEASED);
            case RELEASED:      FlxG.keys.checkStatus(key, RELEASED);
            default:            false;
        };
    }

    public static function isKeyInvalid(key:Null<FlxKey>) {
        return (key == null || key == 0 || key == NONE);
    }
}