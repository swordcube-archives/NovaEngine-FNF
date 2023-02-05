package states;

import haxe.io.Path;
import core.dependency.ScriptHandler;
import core.dependency.scripting.events.*;
import openfl.media.Sound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.ui.FlxBar;
import objects.*;
import objects.fonts.*;
import objects.ui.*;
import states.menus.*;
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

	public var startTimer:FlxTimer;
	public var finishTimer:FlxTimer;

	public var countdownImages:Map<Int, FlxGraphic> = [];
	public var countdownSounds:Map<Int, Sound> = [];

	public var scripts:ScriptGroup;
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

		(scripts = new ScriptGroup()).setParent(this);

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

		Conductor.bpm = SONG.bpm;
		Conductor.position = Conductor.crochet * -5;

		// ^^^ -- END OF PRELOADING ----------------------------------------------------

		// Global song scripts
		for(path in Paths.getFolderContents("songs", true, true)) {
			if(!FileSystem.exists(path) || !Paths.scriptExts.contains(Path.extension(path)))
				continue;

			scripts.add(ScriptHandler.loadModule(path));
		}

		// Scripts specific to the current song
		for(path in Paths.getFolderContents('songs/${SONG.song.toLowerCase()}', true, true)) {
			if(!FileSystem.exists(path) || !Paths.scriptExts.contains(Path.extension(path)))
				continue;
			
			scripts.add(ScriptHandler.loadModule(path));
		}

		scripts.call("onCreate", []);

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

		countdownImages = [
			3 => null,
			2 => Paths.image('UI/$assetModifier/countdown/ready'),
			1 => Paths.image('UI/$assetModifier/countdown/set'),
			0 => Paths.image('UI/$assetModifier/countdown/go')
		];
		countdownSounds = [
			3 => Paths.sound('game/countdown/$assetModifier/intro3'),
			2 => Paths.sound('game/countdown/$assetModifier/intro2'),
			1 => Paths.sound('game/countdown/$assetModifier/intro1'),
			0 => Paths.sound('game/countdown/$assetModifier/introGo')
		];

		startCutscene();
	}

	override public function createPost() {
		super.createPost();
		scripts.call("onCreatePost", []);
	}

	public function startCutscene() {
		startCountdown();
	}

	public function startEndCutscene() {
		// placeholder
	}

	public function finishSong(?ignoreNoteOffset:Bool = false) {
		FlxG.sound.music.volume = 0;
		FlxG.sound.music.pause();
		vocals.volume = 0;
		vocals.pause();
		if(SettingsAPI.noteOffset <= 0 || ignoreNoteOffset) {
			endSong();
		} else {
			finishTimer = new FlxTimer().start(SettingsAPI.noteOffset / 1000, (tmr:FlxTimer) -> {
				endSong();
			});
		}
		scripts.call("onFinishSong", []);
		scripts.call("onSongFinish", []);
	}

	public function endSong() {
		endingSong = true;

		var event = scripts.event("onEndSong", new CancellableEvent());
		event = scripts.event("onSongEnd", event);

		if(event.cancelled) return;

		FlxG.switchState(new MainMenuState());
	}

	public function startCountdown() {
		var event = scripts.event("onStartCountdown", new CancellableEvent());
		event = scripts.event("onCountdownStart", event);

		if(event.cancelled) return;
		
		// don't even need to do Json.parse because i made Paths cool 😎
		var config:Dynamic = Paths.json('images/UI/$assetModifier/countdown/config');
		config.setFieldDefault("scale", 1.0);

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, (tmr:FlxTimer) -> {
			var event = scripts.event("onCountdownTick", new CountdownEvent(
				countdownImages.get(tmr.loopsLeft),
				countdownSounds.get(tmr.loopsLeft),
				config.scale,
				tmr.loops - tmr.loopsLeft,
				tmr.loopsLeft
			));
			event = scripts.event("onCountdown", event);
			event = scripts.event("onTickCountdown", event);

			if(event.image != null && !event.cancelled) {
				var sprite = new FNFSprite().loadGraphic(event.image);
				sprite.scale.set(event.scale, event.scale);
				sprite.updateHitbox();
				sprite.screenCenter();
				event.sprite = sprite;
				add(sprite);

				FlxTween.tween(sprite, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut});
			}
			if(event.sound != null && !event.cancelled)
				FlxG.sound.play(event.sound);

			scripts.event("onCountdownPost", event);
			scripts.event("onCountdownTickPost", event);
			scripts.event("onTickCountdownPost", event);
		}, 4);

		scripts.event("onStartCountdownPost", event);
		scripts.event("onCountdownStartPost", event);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		scripts.call("onUpdate", [elapsed]);

		if(camZooming) {
			var zoomSpeed:Float = Main.framerateAdjust(0.05);	
			camGame.zoom = FlxMath.lerp(camGame.zoom, defaultCamZoom, zoomSpeed);
			camHUD.zoom = FlxMath.lerp(camHUD.zoom, camHUD.initialZoom, zoomSpeed);
		}

		if(controls.PAUSE) {
			var event = scripts.event("onPause", new CancellableEvent());
			event = scripts.event("onPauseSong", event);
			event = scripts.event("onSongPause", event);

			if(!event.cancelled) {
				// pause menu code will be made eventually
			}
		}

		if(!endingSong) {
			Conductor.position += elapsed * 1000;
			if(Conductor.position >= 0 && startingSong)
				startSong();
		}

		scripts.call("onUpdatePost", [elapsed]);
	}

	override public function fixedUpdate(elapsed:Float) {
		super.fixedUpdate(elapsed);
		scripts.call("onFixedUpdate", [elapsed]);

		if(unspawnNotes.length > 0 && unspawnNotes[0] != null && unspawnNotes[0].strumTime <= Conductor.position + (3500 / Math.abs(unspawnNotes[0].scrollSpeed))) {
			while(unspawnNotes.length > 0 && unspawnNotes[0] != null && unspawnNotes[0].strumTime <= Conductor.position + (3500 / Math.abs(unspawnNotes[0].scrollSpeed)))
				notes.add(unspawnNotes.shift());
		}
	}

	override public function fixedUpdatePost(elapsed:Float) {
		super.fixedUpdatePost(elapsed);
		scripts.call("onFixedUpdatePost", [elapsed]);
	}

	override public function beatHit(curBeat:Int) {
		if(FlxG.sound.music.time >= FlxG.sound.music.length || endingSong) return;
		
		if(camBumping && camBumpingInterval > 0 && curBeat % camBumpingInterval == 0 && camGame.zoom < 1.35) {
			camGame.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		scripts.call("onBeatHit", [curBeat]);
	}

	override public function stepHit(curStep:Int) {
		if(FlxG.sound.music.time >= FlxG.sound.music.length || endingSong) return;

		var resyncMS:Float = 20;

		@:privateAccess
		if (Math.abs(FlxG.sound.music.time - Conductor.songPosition) > resyncMS
			|| (vocals._sound != null && Math.abs(vocals.time - Conductor.songPosition) > resyncMS))
		{
			resyncVocals();
		}

		scripts.call("onStepHit", [curStep]);
	}

	override public function sectionHit(curSection:Int) {
		if(FlxG.sound.music.time >= FlxG.sound.music.length || endingSong) return;

		scripts.call("onSectionHit", [curSection]);
	}

	public function resyncVocals() {
		if(startingSong || endingSong) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.position = FlxG.sound.music.time;
		if (Conductor.position <= vocals.length)
			vocals.time = Conductor.position;
		
		vocals.play();
		scripts.call("onResyncVocals", []);
	}

	public function startSong() {
		startingSong = false;

		FlxG.sound.music.pause();
		FlxG.sound.music.volume = 1;
		FlxG.sound.music.time = vocals.time = Conductor.position = 0;
		FlxG.sound.music.onComplete = finishSong.bind();
		FlxG.sound.music.play();
		vocals.play();

		resyncVocals();
		scripts.call("onStartSong", []);
		scripts.call("onSongStart", []);
	}

	override public function destroy() {
		current = null;
		super.destroy();
	}
}