package funkin.ui;

import flixel.effects.FlxFlicker;
import flixel.util.FlxSignal.FlxTypedSignal;

class TextMenuItem extends Alphabet {
    public var isSelecting:Bool = false;
    public var flicker:Bool = true;
    public var onSelect = new FlxTypedSignal<Void->Void>();

    public function select() {
        if(isSelecting) return;

        if(flicker) {
            isSelecting = true;
            FlxFlicker.flicker(this, 0.7, 0.1, true, false, (flicker:FlxFlicker) -> {
                onSelect.dispatch();
                isSelecting = false;
            });
        } else
            onSelect.dispatch();
    }
}