package states;

import states.MusicBeat.MusicBeatState;
import objects.ui.*;
import core.song.SongFormat.SongData;

class PlayState extends MusicBeatState {
	public static var current:PlayState;
	public static var SONG:SongData;

	public var cpuStrums:StrumLine;
	public var playerStrums:StrumLine;

	public static var assetModifier:String = "base";
	public static var changeableSkin:String = "default";

	public static function resetStatics() {
		assetModifier = "base";
		changeableSkin = "default";
	}
	
	override public function create() {
		super.create();

		resetStatics();

		current = this;
		FlxG.sound.music.stop();

		// VVV -- PRELOADING -----------------------------------------------------------

		// ^^^ -- END OF PRELOADING ----------------------------------------------------

		var receptorSpacing:Float = FlxG.width / 4;

		add(cpuStrums = new StrumLine(0, 45, false, changeableSkin));
		cpuStrums.screenCenter(X);
		cpuStrums.x -= receptorSpacing;

		add(playerStrums = new StrumLine(0, 45, false, changeableSkin));
		playerStrums.screenCenter(X);
		playerStrums.x += receptorSpacing;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
	}

	override public function destroy() {
		current = null;
		super.destroy();
	}
}
