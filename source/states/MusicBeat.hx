package states;

import flixel.addons.ui.FlxUISubState;
import flixel.addons.ui.FlxUIState;

class MusicBeatState extends FlxUIState implements MusicHandler {
    public var controls(get, never):Controls;
    function get_controls() return SettingsAPI.controls;

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

// fuck you
typedef MusicBeatSubState = MusicBeatSubstate;

class MusicBeatSubstate extends FlxUISubState implements MusicHandler {
    public var controls(get, never):Controls;
    function get_controls() return SettingsAPI.controls;

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