package music.events;

import music.EventManager.EventList;
import states.PlayState;

class SongEvent {
    public var parameters:Array<Dynamic> = [];

    public var group:EventList;
    public var game:PlayState = PlayState.current;

    public var name:String;
    public var fired:Bool = false;

    public function new(name:String = "Generic Song Event") {
        this.name = name;
    }

    public function fire() {
        fired = true;

        var eventScript = game.eventScripts.get(name);
        if(eventScript != null) {
            // call onEvent for event script
            eventScript.call("onEvent", [name, parameters]);
        } else
            Logs.trace('Event called "$name" doesn\'t exist!', ERROR);

        // call onEvent for every other script
        game.scripts.call("onEvent", [name, parameters]);
    }
}