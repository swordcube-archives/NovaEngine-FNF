package funkin.game;

import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.system.FlxSound;
import funkin.system.Conductor;
import funkin.system.FunkinAssets;
import flixel.graphics.FlxGraphic;
import funkin.system.MusicBeatState;
import funkin.scripting.ScriptHandler;
import funkin.scripting.ScriptPack;
import funkin.system.Song;

using StringTools;

class PlayState extends MusicBeatState {
	public static var SONG:Song;
	public static var current:PlayState;

	// Stage
	/**
	 * The stage.
	 */
	public var stage:Stage;

	/**
	 * The default zoom for the game camera.
	 */
	public var defaultCamZoom:Float = 1.05;

	// Game
	/**
	 * Controls whether or not we are in a cutscene.
	 */
	public var inCutscene:Bool = false;

	/**
	 * A pack of scripts for the stage and song
	 */
	public var scripts:ScriptPack;

	/**
	 * Whenever the game is in downscroll or not. (Can be set)
	 */
	 public var downscroll(get, set):Bool;

	 @:dox(hide) private function set_downscroll(v:Bool) {return camHUD.downscroll = v;}
	 @:dox(hide) private function get_downscroll():Bool  {return camHUD.downscroll;}
	
	/**
	 * The camera for the UI (score, notes, time, etc)
	 */
	public var camHUD:HUDCamera;

	/**
	 * Vocals sound (Voices.ogg).
	 */
	public var vocals:FlxSound;

	/**
	 * Whether or not the song is starting.
	 */
	public var startingSong:Bool = true;

	/**
	 * Whether or not the song is ending.
	 */
	public var endingSong:Bool = false;

	override function create() {
		super.create();
		
		current = this;

		(scripts = new ScriptPack()).setParent(this);

		// CACHING && LOADING!!!

		add(camHUD = new HUDCamera());
		downscroll = Preferences.save.downscroll;

		if(SONG == null)
			SONG = ChartLoader.load(FNF, Paths.chart("tutorial"));

		Conductor.bpm = SONG.bpm;
		Conductor.mapBPMChanges(SONG);
		Conductor.position = Conductor.crochet * -5;

		FlxG.sound.playMusic(Paths.inst(SONG.name), 0, false);
		FlxG.sound.list.add(vocals = (Paths.exists(Paths.voices(SONG.name)) ? new FlxSound().loadEmbedded(Paths.voices(SONG.name), false) : new FlxSound()));

		add(stage = new Stage("default"));
		add(stage.dadLayer);
		add(stage.gfLayer);
		add(stage.bfLayer);

		FlxG.camera.zoom = defaultCamZoom;

		// Load global song scripts
		for(item in Paths.getFolderContents("songs")) {
			var path:String = Paths.getAsset('songs/$item');
			if(Paths.isDirectory(path)) continue;
			
			for(extension in Paths.scriptExtensions) {
				if(path.endsWith("."+extension)) {
					var script:ScriptModule = ScriptHandler.loadModule(path);
					script.load();
					scripts.add(script);
				}
			}
		}

		// Load song specific scripts
		for(item in Paths.getFolderContents('songs/${SONG.name.toLowerCase()}')) {
			var path:String = Paths.getAsset('songs/${SONG.name.toLowerCase()}/$item');
			if(Paths.isDirectory(path)) continue;
			
			for(extension in Paths.scriptExtensions) {
				if(path.endsWith("."+extension)) {
					var script:ScriptModule = ScriptHandler.loadModule(path);
					script.load();
					scripts.add(script);
				}
			}
		}

		// END OF CACHING & LOADING!

		scripts.call("onCreate");
	}

	override function createPost() {
		super.createPost();
		scripts.call("onCreatePost");
	}

	public function startSong() {
		startingSong = false;
		
		FlxG.sound.music.pause();
		FlxG.sound.music.time = Conductor.position = 0;
		FlxG.sound.music.volume = 1;
		FlxG.sound.music.play();
		vocals.play();

		scripts.call("onStartSong");
	}

	public function resyncVocals() {
		@:privateAccess
		if(vocals._sound != null && SONG.needsVoices) {
            FlxG.sound.music.pause();
            vocals.pause();

            Conductor.position = FlxG.sound.music.time;
            vocals.time = FlxG.sound.music.time;

            if(vocals.time < vocals.length)
                vocals.play();

            FlxG.sound.music.play();
		} 
		else 
			Conductor.position = FlxG.sound.music.time;

		scripts.call("onResyncVocals");
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		scripts.call("onUpdate", [elapsed]);

		vocals.pitch = FlxG.sound.music.pitch;
		if(!inCutscene && !endingSong) Conductor.position += (elapsed * 1000) * FlxG.sound.music.pitch;
		if(Conductor.position >= 0 && startingSong) startSong();

		// If the vocals are out of sync, resync them!
		@:privateAccess
		var shouldResync = (vocals._sound != null && SONG.needsVoices && vocals.time < vocals.length) ? !Conductor.isAudioSynced(vocals) : !Conductor.isAudioSynced(FlxG.sound.music);
		if(shouldResync) resyncVocals();

		scripts.call("onUpdatePost", [elapsed]);
	}

	@:dox(hide) override function beatHit(curBeat:Int) {
		scripts.call("onBeatHit", [curBeat]);
		super.beatHit(curBeat);
	}

	@:dox(hide) override function stepHit(curStep:Int) {
		scripts.call("onStepHit", [curStep]);
		super.stepHit(curStep);
	}

	@:dox(hide) override function sectionHit(curSection:Int) {
		if(SONG.sections[curSection] != null && SONG.sections[curSection].changeBPM)
			Conductor.bpm = SONG.sections[curSection].bpm;

		scripts.call("onSectionHit", [curSection]);
		super.sectionHit(curSection);
	}

	override function destroy() {
		current = null;
		scripts.call("onDestroy");
		scripts.destroy();
		super.destroy();
	}
}
