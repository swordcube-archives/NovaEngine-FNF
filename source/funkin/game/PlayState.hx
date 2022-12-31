package funkin.game;

import funkin.system.MusicBeatState;
import funkin.system.Song;

class PlayState extends MusicBeatState {
	public static var SONG:Song = ChartLoader.load(FNF, Paths.chart("tutorial"));
	public static var current:PlayState;

	// Stage
	public var stage:Stage;
	public var defaultCamZoom:Float = 1.05;

	override function create() {
		super.create();
		
		current = this;

		FlxG.sound.music.stop();

		add(stage = new Stage("default"));
		for(layer in [stage.dadLayer, stage.gfLayer, stage.bfLayer])
			add(layer);
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	override function destroy() {
		current = null;
		super.destroy();
	}
}
