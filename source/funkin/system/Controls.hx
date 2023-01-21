package funkin.system;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;

class Controls {
    public function new() {}

    // Pressed
    public var UI_UP(get, never):Bool;
    function get_UI_UP() return pressed("UI_UP");

    public var UI_DOWN(get, never):Bool;
    function get_UI_DOWN() return pressed("UI_DOWN");

    public var UI_LEFT(get, never):Bool;
    function get_UI_LEFT() return pressed("UI_LEFT");

    public var UI_RIGHT(get, never):Bool;
    function get_UI_RIGHT() return pressed("UI_RIGHT");

    // Pressed (others)
    public var ACCEPT(get, never):Bool;
    function get_ACCEPT() return justPressed("UI_ACCEPT");

    public var BACK(get, never):Bool;
    function get_BACK() return justPressed("UI_BACK");

    public var PAUSE(get, never):Bool;
    function get_PAUSE() return justPressed("UI_PAUSE");

    // Just pressed
    public var UI_UP_P(get, never):Bool;
    function get_UI_UP_P() return justPressed("UI_UP");

    public var UI_DOWN_P(get, never):Bool;
    function get_UI_DOWN_P() return justPressed("UI_DOWN");

    public var UI_LEFT_P(get, never):Bool;
    function get_UI_LEFT_P() return justPressed("UI_LEFT");

    public var UI_RIGHT_P(get, never):Bool;
    function get_UI_RIGHT_P() return justPressed("UI_RIGHT");

    // Released
    public var UI_UP_R(get, never):Bool;
    function get_UI_UP_R() return justReleased("UI_UP");

    public var UI_DOWN_R(get, never):Bool;
    function get_UI_DOWN_R() return justReleased("UI_DOWN");

    public var UI_LEFT_R(get, never):Bool;
    function get_UI_LEFT_R() return justReleased("UI_LEFT");

    public var UI_RIGHT_R(get, never):Bool;
    function get_UI_RIGHT_R() return justReleased("UI_RIGHT");

    /**
     * Saves your controls to the filesystem.
     */
    public function flush() {
        OptionsAPI.flush();
    }

    // internal functions
    function checkKeys(keys:Array<Null<FlxKey>>, status:FlxInputState) {
        for(key in keys) {
            if(checkKey(key, status))
                return true;
        }
        return false;
    }

    function checkKey(key:Null<FlxKey>, status:FlxInputState) {
        if(key == null || key == NONE) return false;
        return FlxG.keys.checkStatus(key, status);
    }

    public function justPressed(control:String) {
        return checkKeys(Reflect.field(OptionsAPI.save.data, "CONTROLS_"+control), JUST_PRESSED);
    }

    public function pressed(control:String) {
        return checkKeys(Reflect.field(OptionsAPI.save.data, "CONTROLS_"+control), PRESSED);
    }

    public function justReleased(control:String) {
        return checkKeys(Reflect.field(OptionsAPI.save.data, "CONTROLS_"+control), JUST_RELEASED);
    }
}