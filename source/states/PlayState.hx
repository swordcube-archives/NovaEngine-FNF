package states;

import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import objects.*;
import objects.fonts.*;
import objects.ui.*;
import flixel.system.FlxSound;
import states.MusicBeat.MusicBeatState;
import core.song.SongFormat.SongData;

class PlayState extends MusicBeatState {
	public static var current:PlayState;
	public static var SONG:SongData;

	public static var storyDifficulty:String = "hard";

	public static var assetModifier:String = "base";
	public static var changeableSkin:String = "default";

	public var vocals:FlxSound;

	public var defaultCamZoom:Float = 1.05;

	public var camGame:FNFCamera;
	public var camHUD:FNFCamera;
	public var camOther:FNFCamera;

	public var cpuStrums:StrumLine;
	public var playerStrums:StrumLine;

	public var unspawnNotes:Array<Note> = [];
	public var notes:NoteField;

	public var healthBarBG:TrackingSprite;
	public var healthBar:FlxBar;

	public var health(default, set):Float = 1;
	private function set_health(value:Float):Float {
		return health = FlxMath.bound(value, 0, maxHealth);
	}

	public var maxHealth(default, set):Float = 2;
	private function set_maxHealth(value:Float):Float {
		if(healthBar != null)
			healthBar.setRange(0, value);

		return maxHealth = value;
	}

	public var camBumpingInterval:Int = 4;

	public var camBumping:Bool = true;
	public var camZooming:Bool = true;

	public var inCutscene:Bool = false;
	public var startingSong:Bool = true;
	public var endingSong:Bool = false;

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

		FlxG.sound.playMusic(Paths.songInst(SONG.song, storyDifficulty), 0, false);
		FlxG.sound.list.add(vocals = new FlxSound());

		if(SONG.needsVoices && FileSystem.exists(Paths.songVoices(SONG.song, storyDifficulty, true)))
			vocals.loadEmbedded(Paths.songVoices(SONG.song, storyDifficulty), false);

		FlxG.cameras.reset(camGame = new FNFCamera());
		FlxG.cameras.add(camHUD = new FNFCamera(), false);
		FlxG.cameras.add(camOther = new FNFCamera(), false);

		camGame.bgColor = FlxColor.WHITE; // placeholder

		var receptorSpacing:Float = FlxG.width / 4;
		var strumY:Float = SettingsAPI.downscroll ? FlxG.height - 160 : 50;

		add(cpuStrums = new StrumLine(0, strumY, SettingsAPI.downscroll, true, changeableSkin, SONG.keyCount));
		cpuStrums.screenCenter(X);
		cpuStrums.x -= receptorSpacing;

		add(playerStrums = new StrumLine(0, strumY, SettingsAPI.downscroll, false, changeableSkin, SONG.keyCount));
		playerStrums.screenCenter(X);
		playerStrums.x += receptorSpacing;

		add(notes = new NoteField());
		unspawnNotes = ChartParser.parseChart(SONG);

		healthBarBG = new TrackingSprite(0, FlxG.height * (SettingsAPI.downscroll ? 0.1 : 0.9)).loadGraphic(Paths.image("UI/base/healthBar"));
		healthBarBG.screenCenter(X);
		healthBarBG.trackingOffset.set(-4, -4);

		add(healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, maxHealth));
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);

		add(healthBarBG);

		healthBarBG.trackingMode = LEFT;
		healthBarBG.tracked = healthBar;

		for(obj in [cpuStrums, playerStrums, notes, healthBarBG, healthBar])
			obj.cameras = [camHUD];

		Conductor.bpm = SONG.bpm;
		Conductor.position = Conductor.crochet * -5;

		// ^^^ -- END OF PRELOADING ----------------------------------------------------
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if(camZooming) {
			var zoomSpeed:Float = Main.framerateAdjust(0.05);	
			camGame.zoom = FlxMath.lerp(camGame.zoom, defaultCamZoom, zoomSpeed);
			camHUD.zoom = FlxMath.lerp(camHUD.zoom, camHUD.initialZoom, zoomSpeed);
		}

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

	override public function beatHit(value:Int) {
		if(camBumping && camBumpingInterval > 0 && camGame.zoom < 1.35) {
			camGame.zoom += 0.015;
			camHUD.zoom += 0.03;
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