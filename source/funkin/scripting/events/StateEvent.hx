package funkin.scripting.events;

import flixel.FlxState;

class StateEvent extends CancellableEvent {
    /**
     * State that is about to be created
     */
    public var state:FlxState;

    public function new(state:FlxState) {
        super();
        this.state = state;
    }
}