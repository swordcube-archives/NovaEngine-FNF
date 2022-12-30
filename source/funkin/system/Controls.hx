package funkin.system;

class Controls {
    public function new() {}

    public var UI_UP(get, never):Bool;

    function get_UI_UP():Bool {
        return FlxG.keys.anyPressed([W, UP]);
    }

    public var UI_UP_P(get, never):Bool;

    function get_UI_UP_P():Bool {
        return FlxG.keys.anyJustPressed([W, UP]);
    }

    public var UI_DOWN(get, never):Bool;

    function get_UI_DOWN():Bool {
        return FlxG.keys.anyPressed([S, DOWN]);
    }

    public var UI_DOWN_P(get, never):Bool;

    function get_UI_DOWN_P():Bool {
        return FlxG.keys.anyJustPressed([S, DOWN]);
    }

    public var UI_LEFT(get, never):Bool;

    function get_UI_LEFT():Bool {
        return FlxG.keys.anyPressed([A, LEFT]);
    }

    public var UI_LEFT_P(get, never):Bool;

    function get_UI_LEFT_P():Bool {
        return FlxG.keys.anyJustPressed([A, LEFT]);
    }

    public var UI_RIGHT(get, never):Bool;

    function get_UI_RIGHT():Bool {
        return FlxG.keys.anyPressed([D, RIGHT]);
    }

    public var UI_RIGHT_P(get, never):Bool;

    function get_UI_RIGHT_P():Bool {
        return FlxG.keys.anyJustPressed([D, RIGHT]);
    }

    public var ACCEPT(get, never):Bool;

    function get_ACCEPT():Bool {
        return FlxG.keys.anyJustPressed([ENTER, SPACE]);
    }

    public var BACK(get, never):Bool;

    function get_BACK():Bool {
        return FlxG.keys.anyJustPressed([BACKSPACE, ESCAPE]);
    }
}