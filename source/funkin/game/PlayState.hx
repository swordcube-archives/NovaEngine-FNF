package funkin.game;

import flixel.FlxCamera;
import flixel.system.FlxSound;
import funkin.system.Conductor;
import funkin.system.FunkinAssets;
import flixel.graphics.FlxGraphic;
import funkin.system.MusicBeatState;
import funkin.scripting.ScriptHandler;
import funkin.scripting.ScriptPack;
import funkin.system.Song;

class PlayState extends MusicBeatState {
	public static var SONG:Song;
	public static var current:PlayState;

	// Stage
	public var stage:Stage;
	public var defaultCamZoom:Float = 1.05;

	public var inCutscene:Bool = false;

	// UI
	/**
	 * Camera for the game (stages, characters)
	 */
	public var camGame:FlxCamera;

	/**
	 * Camera for the HUD (notes, misses).
	 */
	public var camHUD:HUDCamera;
	
	public var cachedCountdownImages:Map<String, FlxGraphic> = [];

	// Gameplay
	/**
	 * The vocals for the song. (WARNING: Can be `null`)
	 */
	public var vocals:FlxSound;

	/**
	 * Controls if the camera zooms in every 4 beats or not.
	 */
	public var camBumping:Bool = true;

	/**
	 * Controls if the camera zooms back to normal after a camera bump.
	 */
	public var camZooming:Bool = true;

	/**
	 * Interval of cam zooming (beats).
	 * For example: if set to 4, the camera will zoom every 4 beats.
	 */
	public var camZoomingInterval:Int = 4;

	/**
	 * Whenever the song is currently being started.
	 */
	public var startingSong:Bool = true;

	// Misc
	/**
	 * Script Pack of all the scripts being ran.
	 */
	public var scripts:ScriptPack;

	override function create() {
		super.create();
		
		current = this;
		(scripts = new ScriptPack("PlayState")).setParent(this);

		camGame = FlxG.camera;
		camHUD = new HUDCamera();
		FlxG.cameras.add(camHUD, false);

		// CACHING & LOADING SHIT IN!!

		if(SONG == null)
			SONG = ChartLoader.load(FNF, Paths.chart("tutorial"));

		FlxG.sound.playMusic(Paths.inst(SONG.name), 0, false);
		FlxG.sound.music.stop();
		FlxG.sound.music.time = 0;

		if(Paths.exists(Paths.voices(SONG.name)))
			FlxG.sound.list.add(vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.name), false));

		cachedCountdownImages = FunkinAssets.generateCountdownAssets(SONG.uiSkin);

		add(stage = new Stage("default"));
		add(stage.dadLayer);
		add(stage.gfLayer);
		add(stage.bfLayer);

		camGame.zoom = defaultCamZoom;

		Conductor.bpm = SONG.bpm;
		Conductor.mapBPMChanges(SONG);
		Conductor.position = Conductor.crochet * -5;
		
		// END OF CACHING & LOADING SHIT IN!!

		scripts.call("onCreate");
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		vocals.pitch = FlxG.sound.music.pitch;
		Conductor.position += (elapsed * 1000) * (startingSong ? Conductor.rate : FlxG.sound.music.pitch);

		if(Conductor.position >= 0 && startingSong)
			startSong();

		var shouldNotResync:Bool = vocals != null ? Conductor.isAudioSynced(vocals) : Conductor.isAudioSynced(FlxG.sound.music);
		if(!shouldNotResync) 
			resyncVocals();

		if(camZooming) {
			camGame.zoom = MathUtil.fixedLerp(camGame.zoom, defaultCamZoom, 0.05);
			camHUD.zoom = MathUtil.fixedLerp(camHUD.zoom, camHUD.initialZoom, 0.05);
		}
	}

	public function startSong() {
		startingSong = false;
		Conductor.position = 0;

		FlxG.sound.music.pitch = Conductor.rate;
		FlxG.sound.music.time = 0;

		FlxG.sound.music.play();

		if(vocals != null) {
			vocals.time = 0;
			vocals.pitch = FlxG.sound.music.pitch;
			vocals.play();
		}
	}

	public function resyncVocals():Void {
		if(vocals != null)
			vocals.pause();

		FlxG.sound.music.play();
		Conductor.position = FlxG.sound.music.time;
		if(vocals != null) {
			vocals.time = Conductor.position;
			vocals.play();
		}
		scripts.call("onResyncVocals");
	}

	override function sectionHit(curSection:Int) {
		if(SONG.sections[curSection].changeBPM)
			Conductor.bpm = SONG.sections[curSection].bpm;
		
		super.sectionHit(curSection);
	}

	override function beatHit(curBeat:Int) {
		if(Preferences.save.cameraZoomsOnBeat && camZoomingInterval > 0 && camBumping && FlxG.camera.zoom < 1.35 && curBeat % camZoomingInterval == 0) {
			camGame.zoom += 0.015;
			camHUD.zoom = 0.03;
		}
		super.beatHit(curBeat);
	}

	override function destroy() {
		current = null;
		super.destroy();
	}
}
