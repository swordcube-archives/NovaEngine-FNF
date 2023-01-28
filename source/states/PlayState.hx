package states;

import states.MusicBeat.MusicBeatState;
import objects.ui.*;
import core.song.SongFormat.SongData;

class PlayState extends MusicBeatState {
	public static var current:PlayState;
	public static var SONG:SongData;

	public static var assetModifier:String = "base";

	public static function resetStatics() {
		assetModifier = "base";
	}
	
	override public function create() {
		super.create();

		resetStatics();

		current = this;
		FlxG.sound.music.stop();

		// VVV -- PRELOADING -----------------------------------------------------------

		var note = new Note();
		add(note);

		// ^^^ -- END OF PRELOADING ----------------------------------------------------
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	override public function destroy() {
		current = null;
		super.destroy();
	}
}
