package states;

import core.song.SongFormat.SongData;
import flixel.FlxState;

class PlayState extends FlxState {
	public static var current:PlayState;
	public static var SONG:SongData;
	
	override public function create() {
		super.create();

		current = this;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	override public function destroy() {
		current = null;
		super.destroy();
	}
}
