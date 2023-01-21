package funkin.menus;

import funkin.system.MusicBeatState;

class OptionsMenuState extends MusicBeatState {
    override function create() {
        super.create();

        if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			CoolUtil.playMusic(Paths.music("freakyMenu"));

		if (!runDefaultCode) return;
    }
}