package funkin.system;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import funkin.interfaces.IBeatReciever;

class MusicBeatState extends FlxUIState implements IBeatReciever {
    public var controls:Controls = new Controls();

    override function create() {
        super.create();

        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

        persistentUpdate = false;
        persistentDraw = true;

        Conductor.onBeat.add(beatHit);
        Conductor.onStep.add(stepHit);
        Conductor.onSection.add(sectionHit);
    }

	public function beatHit(beat:Int) {}
	public function stepHit(step:Int) {}
	public function sectionHit(section:Int) {}
}