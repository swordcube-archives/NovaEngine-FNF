package states;

import flixel.system.FlxSound;
import objects.FNFCamera;
import flixel.util.FlxSort;
import states.MusicBeat.MusicBeatState;
import objects.ui.*;
import core.song.SongFormat.SongData;

class PlayState extends MusicBeatState {
	public static var current:PlayState;
	public static var SONG:SongData;

	public static var storyDifficulty:String = "hard";

	public static var assetModifier:String = "base";
	public static var changeableSkin:String = "default";

	public var vocals:FlxSound;

	public var camGame:FNFCamera;
	public var camHUD:FNFCamera;
	public var camOther:FNFCamera;

	public var cpuStrums:StrumLine;
	public var playerStrums:StrumLine;

	public var unspawnNotes:Array<Note> = [];
	public var notes:NoteField;

	public var inCutscene:Bool = false;
	public var startingSong:Bool = true;
	public var endingSong:Bool = false;

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

		// VVV -- PRELOADING -----------------------------------------------------------

		SONG.setFieldDefault("keyCount", 4);

		FlxG.sound.playMusic(Paths.songInst(SONG.song, storyDifficulty), 0);
		FlxG.sound.list.add(vocals = new FlxSound());

		if(SONG.needsVoices && FileSystem.exists(Paths.songVoices(SONG.song, storyDifficulty, true)))
			vocals.loadEmbedded(Paths.songVoices(SONG.song, storyDifficulty));

		FlxG.cameras.reset(camGame = new FNFCamera());
		FlxG.cameras.add(camHUD = new FNFCamera(), false);
		FlxG.cameras.add(camOther = new FNFCamera(), false);

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
		if(Conductor.position >= 0 && startingSong)
			startSong();
	}

	override public function fixedUpdate(elapsed:Float) {
		super.fixedUpdate(elapsed);

		if(unspawnNotes.length > 0 && unspawnNotes[0] != null && unspawnNotes[0].strumTime <= Conductor.position + (3500 / Math.abs(unspawnNotes[0].scrollSpeed))) {
			while(unspawnNotes.length > 0 && unspawnNotes[0] != null && unspawnNotes[0].strumTime <= Conductor.position + (3500 / Math.abs(unspawnNotes[0].scrollSpeed)))
				notes.add(unspawnNotes.shift());
		}
	}

	override public function stepHit(value:Int) {
		var resyncMS:Float = 20;

		@:privateAccess
		if (Math.abs(FlxG.sound.music.time - Conductor.songPosition) > resyncMS
			|| (vocals._sound != null && Math.abs(vocals.time - Conductor.songPosition) > resyncMS))
		{
			resyncVocals();
		}
	}

	public function resyncVocals() {
		if(startingSong || endingSong) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.position = FlxG.sound.music.time;
		if (Conductor.position <= vocals.length)
			vocals.time = Conductor.position;
		
		vocals.play();
	}

	public function startSong() {
		startingSong = false;

		FlxG.sound.music.pause();
		FlxG.sound.music.volume = 1;
		FlxG.sound.music.time = vocals.time = Conductor.position = 0;
		FlxG.sound.music.play();
		vocals.play();

		resyncVocals();
	}

	override public function destroy() {
		current = null;
		super.destroy();
	}
}