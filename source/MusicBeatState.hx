package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

class MusicBeatState extends FlxUIState {
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public var curBeat(get, never):Int;

	function get_curBeat():Int {
		return Conductor.curBeat;
	}

	public var curStep(get, never):Int;

	function get_curStep():Int {
		return Conductor.curStep;
	}

	public var curDecBeat(get, never):Float;

	function get_curDecBeat():Float {
		return Conductor.curDecBeat;
	}

	public var curDecStep(get, never):Float;

	function get_curDecStep():Float {
		return Conductor.curDecStep;
	}

	public var curSection(get, never):Int;

	function get_curSection():Int {
		return Conductor.curSection;
	}

	override function create() {
		super.create();

		Conductor.onBeat.add(beatHit);
		Conductor.onStep.add(stepHit);
		Conductor.onSection.add(sectionHit);
	}

	override function destroy() {
		super.destroy();
	}

	public function beatHit(beat:Int):Void {}

	public function stepHit(step:Int):Void {}

	public function sectionHit(section:Int):Void {}
}
