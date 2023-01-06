package funkin.game;

import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

class InputSystem implements IFlxDestroyable {
    public var parent:StrumLine;

    public function new(parent:StrumLine) {
        this.parent = parent;
        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
    }

    public function onKeyPress(event:KeyboardEvent) {
        var data:Int = directionFromEvent(event);
        trace("DIRECTION PRESSED: "+data);
    }

    public function directionFromEvent(event:KeyboardEvent) {
        var keyList:Array<FlxKey> = cast Reflect.field(Preferences.save.GAME_controls, parent.keyAmount+"K");
        for(i => _key in keyList) {
            var key:Int = cast _key; // Having to cast because it doesn't work otherwise
            trace("EVENT KEYCODE: "+event.keyCode);
            trace("OUR KEY CODE: "+key);
            if(event.keyCode == key) return i;
        }
        return -1;
    }

	public function destroy() {
        FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
    }
}