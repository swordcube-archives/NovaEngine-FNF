package states;

import flixel.addons.ui.FlxUISubState;
import flixel.addons.ui.FlxUIState;

class MusicBeatState extends FlxUIState implements MusicHandler {
    public var controls(get, never):Controls;
    function get_controls() return SettingsAPI.controls;

    public var curBeat(get, never):Int;
    private function get_curBeat() return Conductor.curBeat;

    public var preciseBeat(get, never):Float;
    private function get_preciseBeat() return Conductor.preciseBeat;

    public var curStep(get, never):Int;
    private function get_curStep() return Conductor.curStep;

    public var preciseStep(get, never):Float;
    private function get_preciseStep() return Conductor.preciseStep;

    public var curSection(get, never):Int;
    private function get_curSection() return Conductor.curSection;

    override function create() {
        super.create();

        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

        Conductor.onBeatHit.add(beatHit);
        Conductor.onStepHit.add(stepHit);
        Conductor.onSectionHit.add(sectionHit);
    }

	public function beatHit(value:Int) {
        for(m in members) {
            if(m != null && m is MusicHandler)
                cast(m, MusicHandler).beatHit(value);
        }
    }

	public function stepHit(value:Int) {
        for(m in members) {
            if(m != null && m is MusicHandler)
                cast(m, MusicHandler).stepHit(value);
        }
    }

	public function sectionHit(value:Int) {
        for(m in members) {
            if(m != null && m is MusicHandler)
                cast(m, MusicHandler).sectionHit(value);
        }
    }
}

// fuck you
typedef MusicBeatSubState = MusicBeatSubstate;

class MusicBeatSubstate extends FlxUISubState implements MusicHandler {
    public var controls(get, never):Controls;
    private function get_controls() return SettingsAPI.controls;

    public var curBeat(get, never):Int;
    private function get_curBeat() return Conductor.curBeat;

    public var preciseBeat(get, never):Float;
    private function get_preciseBeat() return Conductor.preciseBeat;

    public var curStep(get, never):Int;
    private function get_curStep() return Conductor.curStep;

    public var preciseStep(get, never):Float;
    private function get_preciseStep() return Conductor.preciseStep;

    public var curSection(get, never):Int;
    private function get_curSection() return Conductor.curSection;

    override function create() {
        super.create();

        Conductor.onBeatHit.add(beatHit);
        Conductor.onStepHit.add(stepHit);
        Conductor.onSectionHit.add(sectionHit);
    }

	public function beatHit(value:Int) {
        for(m in members) {
            if(m != null && m is MusicHandler)
                cast(m, MusicHandler).beatHit(value);
        }
    }

	public function stepHit(value:Int) {
        for(m in members) {
            if(m != null && m is MusicHandler)
                cast(m, MusicHandler).stepHit(value);
        }
    }

	public function sectionHit(value:Int) {
        for(m in members) {
            if(m != null && m is MusicHandler)
                cast(m, MusicHandler).sectionHit(value);
        }
    }
}