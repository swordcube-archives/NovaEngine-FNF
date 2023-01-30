package states;

import objects.FNFCamera;
import flixel.util.FlxSort;
import states.MusicBeat.MusicBeatState;
import objects.ui.*;
import core.song.SongFormat.SongData;

class PlayState extends MusicBeatState {
	public static var current:PlayState;
	public static var SONG:SongData;

	public static var assetModifier:String = "base";
	public static var changeableSkin:String = "default";

	public var camGame:FNFCamera;
	public var camHUD:FNFCamera;
	public var camOther:FNFCamera;

	public var cpuStrums:StrumLine;
	public var playerStrums:StrumLine;

	public var unspawnNotes:Array<Note> = [];
	public var notes:NoteField;

	// NEED TO FIX NEGATIVE SCROLL SPEEDS LATER!!!!
	public var scrollSpeed:Float = 3.4;

	public static function resetStatics() {
		assetModifier = "base";
		changeableSkin = "default";
	}
	
	override public function create() {
		super.create();

		resetStatics();

		current = this;
		FlxG.sound.music.stop();

		FlxG.cameras.reset(camGame = new FNFCamera());
		FlxG.cameras.add(camHUD = new FNFCamera(), false);
		FlxG.cameras.add(camOther = new FNFCamera(), false);

		// VVV -- PRELOADING -----------------------------------------------------------

		SONG.setFieldDefault("keyCount", 4);

		var receptorSpacing:Float = FlxG.width / 4;

		add(cpuStrums = new StrumLine(0, FlxG.height - 160, true, true, changeableSkin, SONG.keyCount));
		cpuStrums.screenCenter(X);
		cpuStrums.x -= receptorSpacing;

		add(playerStrums = new StrumLine(0, FlxG.height - 160, true, false, changeableSkin, SONG.keyCount));
		playerStrums.screenCenter(X);
		playerStrums.x += receptorSpacing;

		add(notes = new NoteField());

		unspawnNotes = ChartParser.parseChart(SONG);

		for(obj in [cpuStrums, playerStrums, notes])
			obj.cameras = [camHUD];

		Conductor.bpm = SONG.bpm;
		Conductor.position = Conductor.crochet * -5;

		// ^^^ -- END OF PRELOADING ----------------------------------------------------
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		Conductor.position += elapsed * 1000;

		if(unspawnNotes.length > 0 && unspawnNotes[0] != null && unspawnNotes[0].strumTime <= Conductor.position + (3500 / Math.abs(unspawnNotes[0].scrollSpeed))) {
			while(unspawnNotes.length > 0 && unspawnNotes[0] != null && unspawnNotes[0].strumTime <= Conductor.position + (3500 / Math.abs(unspawnNotes[0].scrollSpeed)))
				notes.add(unspawnNotes.shift());
		}
	}

	override public function destroy() {
		current = null;
		super.destroy();
	}
}