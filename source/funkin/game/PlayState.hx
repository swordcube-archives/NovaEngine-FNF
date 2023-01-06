package funkin.game;

import flixel.addons.transition.FlxTransitionableState;
import funkin.system.FNFSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flixel.system.FlxSound;
import funkin.system.Conductor;
import funkin.system.MusicBeatState;
import funkin.scripting.ScriptHandler;
import funkin.scripting.ScriptPack;
import funkin.scripting.events.*;
import funkin.cutscenes.*;
import funkin.game.Song;

using StringTools;

class PlayState extends MusicBeatState {
	/**
	 * The currently loaded song data.
	 */
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
	 * Whether or not we're playing a week in story mode.
	 */
	public static var isStoryMode:Bool = false;

	/**
	 * Score for the current week.
	 */
	public static var campaignScore:Int = 0;

	/**
	 * Zoom for the pixel assets.
	 */
	public static var daPixelZoom:Float = 6;

	/**
	 * Whenever the game should play the cutscenes. Defaults to whenever the game is currently in Story Mode or not.
	 */
	public var playCutscenes:Bool = isStoryMode;

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

	/**
	 * Controls how fast the notes move.
	 */
	public var scrollSpeed:Float = 2.7;

	function get_downscroll():Bool {
		return camHUD.downscroll;
	}
	function set_downscroll(v:Bool) {
		return camHUD.downscroll = v;
	}
	
	/**
	 * The camera for the UI (score, notes, time, etc)
	 */
	public var camHUD:HUDCamera;
	
	public var camOther:FlxCamera;

	public var UI:UIGroup;

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

	/**
	 * Length of the intro countdown.
	 */
	public var introLength:Int = 5;

	/**
	 * Array of sprites for the intro.
	 */
	public var introSprites:Array<String> = [
		null, 
		"game/countdown/default/ready", 
		"game/countdown/default/set", 
		"game/countdown/default/go"
	];

	 /**
	  * Array of sounds for the intro.
	  */
	public var introSounds:Array<String> = [
		"game/countdown/default/intro3", 
		"game/countdown/default/intro2", 
		"game/countdown/default/intro1", 
		"game/countdown/default/introGo"
	];

	/**
	 * Cutscene script path.
	 */
	public var cutscene:String = null;

	/**
	 * End cutscene script path.
	 */
	public var endCutscene:String = null;

	override function create() {
		super.create();
		
		current = this;

		(scripts = new ScriptPack()).setParent(this);

		// CACHING && LOADING!!!

		camHUD = new HUDCamera();
		camHUD.bgColor = 0x0;
		FlxG.cameras.add(camHUD, false);

		camOther = new FlxCamera();
		camOther.bgColor = 0x0;
		FlxG.cameras.add(camOther, false);

		downscroll = Preferences.save.downscroll;

		if(SONG == null)
			SONG = ChartLoader.load(FNF, Paths.chart("tutorial"));

		Conductor.bpm = SONG.bpm;
		Conductor.mapBPMChanges(SONG);
		Conductor.position = -90000;

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
					scripts.add(script);
				}
			}
		}

		// END OF CACHING & LOADING!

		scripts.load();
		scripts.call("onCreate");

		add(UI = new UIGroup());
		UI.cameras = [camHUD];

		for(section in SONG.sections) {
			if(section == null) continue;
			for(i => note in section.notes) {
				var mustHit:Bool = section.playerSection;
				if (note.direction > (SONG.keyAmount - 1)) mustHit = !section.playerSection;

				var strumLine:StrumLine = mustHit ? UI.playerStrums : UI.cpuStrums;
				var prevNote:Note = UI.notes.length > 0 ? UI.notes.members[UI.notes.length - 1] : null;

				var realNote:Note = GameplayUtil.generateNote(note.strumTime, strumLine.keyAmount, note.direction, SONG.noteSkin, mustHit, note.altAnim, strumLine);
				realNote.prevNote = prevNote;
				UI.notes.add(realNote);

				var susLength:Float = note.sustainLength / Conductor.stepCrochet;
				if(susLength > 0.75) susLength++;

				var flooredSus:Int = Math.floor(susLength);
				if(flooredSus > 0) {
					for(sus in 0...flooredSus) {
						var susNote:Note = GameplayUtil.generateNote(note.strumTime + (Conductor.stepCrochet * sus), strumLine.keyAmount, note.direction, SONG.noteSkin, mustHit, note.altAnim, strumLine);
						susNote.isSustainNote = true;
						susNote.stepCrochet = Conductor.stepCrochet;
						susNote.isSustainTail = sus >= flooredSus-1;
						susNote.alpha = 0.6;
						susNote.playCorrectAnim();
						susNote.prevNote = prevNote;
						UI.notes.add(susNote);
					}
				}
			}
		}

		UI.notes.sortNotes();
	}

	override function createPost() {
		startCutscene();
		super.createPost();
		scripts.call("onCreatePost");
	}

	public function startCutscene() {
		// If we're not allowed to play a cutscene
		// Then just start the countdown instead
		// if(!playCutscenes) {
		// 	startCountdown();
		// 	return;
		// }

		var videoCutscene = Paths.video('${PlayState.SONG.name.toLowerCase()}-cutscene');
		persistentUpdate = false;
		if (cutscene != null) {
			openSubState(new ScriptedCutscene(cutscene, function() {
				startCountdown();
			}));
		} 
		else if (Paths.exists(videoCutscene)) {
			FlxTransitionableState.skipNextTransIn = true;
			inCutscene = true;
			openSubState(new VideoCutscene(videoCutscene, function() {
				startCountdown();
			}));
			persistentDraw = false;
		} 
		else
			startCountdown();
	}

	public function startCountdown() {
		Conductor.position = Conductor.crochet * -5;
		inCutscene = false;

		var swagCounter:Int = 0;
		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer) {
			countdown(swagCounter++);
		}, introLength);
	}

	public function countdown(swagCounter:Int) {
		var event:CountdownEvent = scripts.event("onCountdown", new CountdownEvent(
			swagCounter, 
			introSprites[swagCounter],
			introSounds[swagCounter],
			1, 1, true
		));

		var sprite:FNFSprite = null;
		var sound:FlxSound = null;
		var tween:FlxTween = null;

		if (!event.cancelled) {
			if (event.spritePath != null) {
				var spr = event.spritePath;
				if (!Assets.exists(spr)) spr = Paths.image('$spr');

				sprite = new FNFSprite().load(IMAGE, spr);
				sprite.scrollFactor.set();
				sprite.scale.set(event.scale, event.scale);
				sprite.updateHitbox();
				sprite.screenCenter();
				add(sprite);
				tween = FlxTween.tween(sprite, {alpha: 0}, Conductor.crochet / 1000, {
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween) {
						sprite.destroy();
					}
				});
			}
			if (event.soundPath != null) {
				var sfx = event.soundPath;
				if (!Assets.exists(sfx)) sfx = Paths.sound(sfx);
				sound = FlxG.sound.play(sfx, event.volume);
			}
		}
		event.sprite = sprite;
		event.sound = sound;
		event.spriteTween = tween;
		event.cancelled = false;

		scripts.event("onCountdownPost", event);
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
		if(Conductor.position >= 0 && startingSong && !inCutscene) startSong();

		// If the vocals are out of sync, resync them!
		@:privateAccess
		var shouldResync = (vocals._sound != null && SONG.needsVoices && vocals.time < vocals.length) ? !Conductor.isAudioSynced(vocals) : !Conductor.isAudioSynced(FlxG.sound.music);
		if(shouldResync && !startingSong && !endingSong && !inCutscene) resyncVocals();

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
