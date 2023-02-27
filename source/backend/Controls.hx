package backend;

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
        // Game controls
        "NOTE_LEFT" => [A, LEFT],
        "NOTE_DOWN" => [S, DOWN],
        "NOTE_UP" => [W, UP],
        "NOTE_RIGHT" => [D, RIGHT],

        // UI controls
        "UI_UP" => [W, UP],
        "UI_DOWN" => [S, DOWN],
        "UI_LEFT" => [A, LEFT],
        "UI_RIGHT" => [D, RIGHT],
        "ACCEPT" => [ENTER, SPACE],
        "PAUSE" => [ENTER, NONE],
        "BACK" => [BACKSPACE, ESCAPE],
        "RESET" => [R, NONE],

        // Volume controls
        "VOLUME_MUTE" => [ZERO, NUMPADZERO],
        "VOLUME_UP" => [PLUS, NUMPADPLUS],
        "VOLUME_DOWN" => [MINUS, NUMPADMINUS],

        // Engine controls
        "CHARTER" => [SEVEN, NUMPADSEVEN],
        "SWITCH_MOD" => [TAB, NONE],
		"GAMEPLAY_MODIFIERS" => [SHIFT, NONE]
    ];

    public static var controlsList:Map<String, KeyList> = [];

    /**
     * Initializes the save data for your controls.
     */
    public static function init() {
        __save = new FlxSave();
        __save.bind("controls", CoolUtil.getSavePath());
        __save.flush();
    }

    /**
     * Loads all of your saved controls.
     */
    public static function load() {

        for(name => keys in __defaultControls) {
            var savedKeys:KeyList = Reflect.field(__save.data, 'CONTROLS_$name');

            if(savedKeys != null)
                controlsList.set(name, savedKeys);
            else {
                Reflect.setField(__save.data, 'CONTROLS_$name', keys);
                controlsList.set(name, keys);
            }
        }
    }

    /**
     * Saves all of your controls.
     */
    public static function save() {
        for(name => keys in controlsList)
            Reflect.setField(__save.data, 'CONTROLS_$name', keys);
        
        __save.flush();
    }

    public function new() {}

    // -- NON-STATIC VARIABLES & FUNCTIONS --------------------------------------------

    // ui directional controls (just pressed)
    public var UI_LEFT_P(get, never):Bool;
    private function get_UI_LEFT_P() return __checkKeys(controlsList["UI_LEFT"], JUST_PRESSED);

    public var UI_DOWN_P(get, never):Bool;
    private function get_UI_DOWN_P() return __checkKeys(controlsList["UI_DOWN"], JUST_PRESSED);

    public var UI_UP_P(get, never):Bool;
    private function get_UI_UP_P() return __checkKeys(controlsList["UI_UP"], JUST_PRESSED);

    public var UI_RIGHT_P(get, never):Bool;
    private function get_UI_RIGHT_P() return __checkKeys(controlsList["UI_RIGHT"], JUST_PRESSED);

    // ui directional controls (pressed)
    public var UI_LEFT(get, never):Bool;
    private function get_UI_LEFT() return __checkKeys(controlsList["UI_LEFT"], PRESSED);

    public var UI_DOWN(get, never):Bool;
    private function get_UI_DOWN() return __checkKeys(controlsList["UI_DOWN"], PRESSED);

    public var UI_UP(get, never):Bool;
    private function get_UI_UP() return __checkKeys(controlsList["UI_UP"], PRESSED);

    public var UI_RIGHT(get, never):Bool;
    private function get_UI_RIGHT() return __checkKeys(controlsList["UI_RIGHT"], PRESSED);

    // ui directional controls (just released)
    public var UI_LEFT_R(get, never):Bool;
    private function get_UI_LEFT_R() return __checkKeys(controlsList["UI_LEFT"], JUST_RELEASED);

    public var UI_DOWN_R(get, never):Bool;
    private function get_UI_DOWN_R() return __checkKeys(controlsList["UI_DOWN"], JUST_RELEASED);

    public var UI_UP_R(get, never):Bool;
    private function get_UI_UP_R() return __checkKeys(controlsList["UI_UP"], JUST_RELEASED);

    public var UI_RIGHT_R(get, never):Bool;
    private function get_UI_RIGHT_R() return __checkKeys(controlsList["UI_RIGHT"], JUST_RELEASED);

    // volume controls
    public var VOLUME_MUTE(get, never):Bool;
    private function get_VOLUME_MUTE() return __checkKeys(controlsList["VOLUME_MUTE"], JUST_PRESSED);

    public var VOLUME_UP(get, never):Bool;
    private function get_VOLUME_UP() return __checkKeys(controlsList["VOLUME_UP"], JUST_PRESSED);

    public var VOLUME_DOWN(get, never):Bool;
    private function get_VOLUME_DOWN() return __checkKeys(controlsList["VOLUME_DOWN"], JUST_PRESSED);

    // debug menus
    public var CHARTER(get, never):Bool;
    private function get_CHARTER() return __checkKeys(controlsList["CHARTER"], JUST_PRESSED);

    // ui controls for anything else
    public var ACCEPT(get, never):Bool;
    private function get_ACCEPT() return __checkKeys(controlsList["ACCEPT"], JUST_PRESSED);

    public var PAUSE(get, never):Bool;
    private function get_PAUSE() return __checkKeys(controlsList["PAUSE"], JUST_PRESSED);

    public var BACK(get, never):Bool;
    private function get_BACK() return __checkKeys(controlsList["BACK"], JUST_PRESSED);

    public var SWITCH_MOD(get, never):Bool;
    private function get_SWITCH_MOD() return __checkKeys(controlsList["SWITCH_MOD"], JUST_PRESSED);

    public var RESET(get, never):Bool;
    private function get_RESET() return __checkKeys(controlsList["RESET"], JUST_PRESSED);

	public var GAMEPLAY_MODIFIERS(get, never):Bool;
	private function get_GAMEPLAY_MODIFIERS() return __checkKeys(controlsList["GAMEPLAY_MODIFIERS"], JUST_PRESSED);

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