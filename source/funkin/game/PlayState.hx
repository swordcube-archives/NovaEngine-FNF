package funkin.game;

import funkin.system.Song;
import flixel.FlxState;

class PlayState extends FlxState {
	public static var SONG:Song;
	public static var current:PlayState;

	override function create() {
		super.create();
		
		current = this;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	override function destroy() {
		current = null;
		super.destroy();
	}
}
