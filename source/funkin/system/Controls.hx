package funkin.system;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;

// TO-DO: MAKE THIS USE SAVE DATA!

class Controls {
    public function new() {}

    public var UI_UP(get, never):Bool;

    function get_UI_UP():Bool {
        return checkKeys([W, UP], PRESSED);
    }

    public var UI_UP_P(get, never):Bool;

    function get_UI_UP_P():Bool {
        return checkKeys([W, UP], JUST_PRESSED);
    }

    public var UI_DOWN(get, never):Bool;

    function get_UI_DOWN():Bool {
        return checkKeys([S, DOWN], PRESSED);
    }

    public var UI_DOWN_P(get, never):Bool;

    function get_UI_DOWN_P():Bool {
        return checkKeys([S, DOWN], JUST_PRESSED);
    }

    public var UI_LEFT(get, never):Bool;

    function get_UI_LEFT():Bool {
        return checkKeys([A, LEFT], PRESSED);
    }

    public var UI_LEFT_P(get, never):Bool;

    function get_UI_LEFT_P():Bool {
        return checkKeys([A, LEFT], JUST_PRESSED);
    }

    public var UI_RIGHT(get, never):Bool;

    function get_UI_RIGHT():Bool {
        return checkKeys([D, RIGHT], PRESSED);
    }

    public var UI_RIGHT_P(get, never):Bool;

    function get_UI_RIGHT_P():Bool {
        return checkKeys([D, RIGHT], JUST_PRESSED);
    }

    public var ACCEPT(get, never):Bool;

    function get_ACCEPT():Bool {
        return checkKeys([ENTER, SPACE], JUST_PRESSED);
    }

    public var BACK(get, never):Bool;

    function get_BACK():Bool {
        return checkKeys([BACKSPACE, ESCAPE], JUST_PRESSED);
    }

    public var PAUSE(get, never):Bool;

    function get_PAUSE():Bool {
        return checkKeys([ENTER, NONE], JUST_PRESSED);
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
}