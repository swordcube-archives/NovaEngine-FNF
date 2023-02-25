package game.cutscenes;

import states.PlayState;
import states.MusicBeat.MusicBeatSubstate;

class Cutscene extends MusicBeatSubstate {
    var __callback:Void->Void;
    var game:PlayState = PlayState.current;

    public function new(callback:Void->Void) {
        super();
        __callback = callback;
    }

    override function close() {
        __callback();
        super.close();
    }
}