package funkin.game;

import flixel.group.FlxSpriteGroup;
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
import flixel.math.FlxMath;
import funkin.game.Song;
import haxe.io.Path;

using StringTools;

enum abstract CharacterType(String) to String from String {
	var DAD = "DAD";
	var OPPONENT = "OPPONENT";
	var GF = "GF";
	var GIRLFRIEND = "GIRLFRIEND";
	var SPEAKERS = "SPEAKERS";
	var BF = "BF";
	var PLAYER = "PLAYER";
	var BOYFRIEND = "BOYFRIEND";
}

class PlayState extends MusicBeatState {
	/**
	 * The currently loaded song data.
	 */
	public static var SONG:Song;
	public static var current:PlayState;

	/**
	 * Whether or not the game is paused.
	 */
	public static var paused:Bool = false;

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
	 * Whether or not the camera should zoom in every 4 beats.
	 */
	public var camBumping:Bool = true;

	/**
	 * How much the camera should zoom to the beat.
	 * 4 = Every 4 beats.
	 * 2 = Every 2 beats.
	 * 1 = Every beat.
	 */
	public var camBumpingInterval:Int = 4;

	/**
	 * Whether or not the camera should zoom out after bumping.
	 */
	public var camZooming:Bool = true;

	/**
	 * Dad character
	 */
	public var dad:Character;
	public var dads:Array<Character> = [];

	/**
	 * Girlfriend character
	 */
	public var gf:Character;
	public var gfs:Array<Character> = [];

	/**
	 * Boyfriend character
	 */
	public var boyfriend:Character;
	public var boyfriends:Array<Character> = [];

	/**
	 * Boyfriend character
	 */
	public var bf(get, set):Character;
	function get_bf():Character {
		return boyfriend;
	}
	function set_bf(newChar:Character):Character {
		return boyfriend = newChar;
	}

	public var bfs(get, set):Array<Character>;
	function get_bfs():Array<Character> {
		return boyfriends;
	}
	function set_bfs(newChars:Array<Character>):Array<Character> {
		return boyfriends = newChars;
	}

	/**
	 * The amount of health the player has.
	 * Limited to the values of `minHealth` and `maxHealth`.
	 */
	public var health(default, set):Float = 0;
	function set_health(value:Float) {
		return health = FlxMath.bound(value, minHealth, maxHealth);
	}

	/**
	 * The minimum amount of health the player can have.
	 */
	public var minHealth(default, set):Float = 0;
	function set_minHealth(value:Float) {
		health = FlxMath.bound(health, value, maxHealth);
		if(UI.healthBar != null) UI.healthBar.setRange(minHealth, UI.healthBar.max);
		return maxHealth = value;
	}

	/**
	 * The maximum amount of health the player can have.
	 */
	public var maxHealth(default, set):Float = 2;
	function set_maxHealth(value:Float) {
		health = FlxMath.bound(health, minHealth, value);
		if(UI.healthBar != null) UI.healthBar.setRange(UI.healthBar.min, maxHealth);
		return maxHealth = value;
	}

	/**
	 * Cutscene script path.
	 */
	public var cutscene:String = null;

	/**
	 * End cutscene script path.
	 */
	public var endCutscene:String = null;

	/**
	 * A map containing all scripts for note types.
	 */
	public var noteTypes:Map<String, ScriptModule> = [];

	/**
	 * The group of sprites used to display your ratings and combo
	 * when hitting notes.
	 */
	public var comboGroup:FlxTypedSpriteGroup<FNFSprite>;

	// Accuracy related variables
	/**
	 * The score of every note you've hit.
	 */
	public var songScore:Int = 0;

	/**
	 * The amount of notes you've missed.
	 */
	public var songMisses:Int = 0;

	/**
	 * The player's accuracy (shortcut to `totalAccuracyAmount / accuracyPressedNotes`).
	 */
	public var songAccuracy(get, never):Float;
	function get_songAccuracy():Float {
		if(accuracyPressedNotes <= 0) return -1;
		return totalAccuracyAmount / accuracyPressedNotes;
	}

	/**
	 * The number of pressed notes.
	 */
	public var accuracyPressedNotes:Int = 0;

	/**
	 * The total accuracy amount.
	 */
	public var totalAccuracyAmount:Float = 0;

	public var score(get, set):Int;
	function get_score():Int {
		return songScore;
	}
	function set_score(value:Int):Int {
		return songScore = value;
	}

	public var misses(get, set):Int;
	function get_misses():Int {
		return songMisses;
	}
	function set_misses(value:Int):Int {
		return songMisses = value;
	}

	public var accuracy(get, never):Float;
	function get_accuracy():Float {
		return get_songAccuracy();
	}

	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	public var combo:Int = 0;

	override function create() {
		super.create();
		
		current = this;
		paused = false;

		(scripts = new ScriptPack()).setParent(this);

		// CACHING && LOADING!!!

		camHUD = new HUDCamera();
		camHUD.bgColor = 0x0;
		FlxG.cameras.add(camHUD, false);

		camOther = new FlxCamera();
		camOther.bgColor = 0x0;
		FlxG.cameras.add(camOther, false);

		downscroll = OptionsAPI.get("Downscroll");

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

		add(gf = new Character(stage.gfPos.x, stage.gfPos.y, SONG.gf));
		add(dad = new Character(stage.dadPos.x, stage.dadPos.y, SONG.dad));
		add(boyfriend = new Character(stage.bfPos.x, stage.bfPos.y, SONG.bf, true));

		gfs = [gf];
		dads = [dad];
		boyfriends = [bf];

		add(comboGroup = new FlxTypedSpriteGroup<FNFSprite>(FlxG.width * 0.55, (FlxG.height * 0.5) - 60));

		// Preloads rating & combo assets
		for(item in ["sick", "good", "bad", "shit"])
			FlxG.bitmap.add(Paths.image('game/judgements/default/$item'));

		var numList:Array<String> = [for(i in 0...10) 'num$i'];
		numList.insert(0, "combo");

		for(i in numList)
			FlxG.bitmap.add(Paths.image('game/combo/default/$i'));

		// Load global song scripts
		for(item in Paths.getFolderContents("songs", true, true)) {
			for(extension in Paths.scriptExtensions) {
				if(item.endsWith("."+extension))
					scripts.add(ScriptHandler.loadModule(item));
			}
		}

		// Load song specific scripts
		for(item in Paths.getFolderContents('songs/${SONG.name.toLowerCase()}', true, true)) {
			for(extension in Paths.scriptExtensions) {
				if(item.endsWith("."+extension))
					scripts.add(ScriptHandler.loadModule(item));
			}
		}

		// Load note types
		for(item in Paths.getFolderContents('data/notetypes', true, true)) {
			for(extension in Paths.scriptExtensions) {
				if(item.endsWith("."+extension)) {
					var typeName:String = Path.withoutDirectory(item.removeExtension());
					var script = ScriptHandler.loadModule(item);
					script.load();
					script.call("onCreate");
					noteTypes[typeName] = script;
				}
			}
		}

		// END OF CACHING & LOADING!

		scripts.load();
		scripts.call("onCreate");
		FlxG.camera.zoom = defaultCamZoom;

		health = maxHealth * 0.5;

		add(UI = new UIGroup());
		UI.cameras = [camHUD];

		var oldNotes:Array<Note> = [];
		for(section in SONG.sections) {
			if(section == null) continue;
			for(note in section.notes) {
				var mustHit:Bool = section.playerSection;
				if (note.direction > (SONG.keyAmount - 1)) mustHit = !section.playerSection;

				var strumLine:StrumLine = mustHit ? UI.playerStrums : UI.cpuStrums;
				var prevNote:Note = oldNotes.length > 0 ? oldNotes.last() : null;

				var realNote:Note = GameplayUtil.generateNote(note.strumTime, strumLine.keyAmount, note.direction, SONG.noteSkin, mustHit, note.altAnim, strumLine, note.type);
				realNote.prevNote = prevNote;
				oldNotes.push(realNote);
				strumLine.notes.add(realNote);

				var susLength:Float = note.sustainLength / Conductor.stepCrochet;
				if(susLength > 0.75) susLength++;

				var flooredSus:Int = Math.floor(susLength);
				if(flooredSus > 0) {
					for(sus in 0...flooredSus) {
						prevNote = oldNotes.last();
						var susNote:Note = GameplayUtil.generateNote(note.strumTime + (Conductor.stepCrochet * sus), strumLine.keyAmount, note.direction, SONG.noteSkin, mustHit, note.altAnim, strumLine, note.type);
						susNote.isSustainNote = true;
						susNote.stepCrochet = Conductor.stepCrochet;
						susNote.isSustainTail = sus >= flooredSus-1;
						susNote.alpha = 0.6;
						susNote.playCorrectAnim();
						susNote.prevNote = prevNote;
						oldNotes.push(susNote);
						strumLine.notes.add(susNote);
					}
				}
			}
		}

		UI.cpuStrums.notes.sortNotes();
		UI.playerStrums.notes.sortNotes();
	}

	public function popUpScore(event:NoteHitEvent, rating:String, combo:Int) {
		var rating:FNFSprite = comboGroup.recycle(FNFSprite).load(IMAGE, Paths.image(event.ratingSprites+'/$rating'));
		comboGroup.remove(rating, true);
		rating.setPosition(-40, -60);
		rating.antialiasing = event.ratingAntialiasing;
		rating.scale.set(event.ratingScale, event.ratingScale);
		rating.updateHitbox();
		rating.alpha = 1;

		rating.acceleration.y = 550;
		rating.velocity.y = -FlxG.random.int(140, 175);
		rating.velocity.x = -FlxG.random.int(0, 10);

		var comboSpr:FNFSprite = comboGroup.recycle(FNFSprite).load(IMAGE, Paths.image(event.comboSprites+'/combo'));
		comboGroup.remove(comboSpr, true);
		comboSpr.setPosition(0, 0);
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y = -150;
		comboSpr.velocity.x = FlxG.random.int(1, 10);
		comboSpr.antialiasing = event.ratingAntialiasing;
		comboSpr.scale.set(event.ratingScale, event.ratingScale);
		comboSpr.updateHitbox();
		comboSpr.alpha = 1;

		var separatedScore:String = Std.string(combo).addZeros(3);
		if (combo == 0 || combo >= 10) {
			comboGroup.add(comboSpr);
			for (i in 0...separatedScore.length) {
				var numScore:FNFSprite = comboGroup.recycle(FNFSprite).load(IMAGE, Paths.image(event.comboSprites+'/num${separatedScore.charAt(i)}'));
				comboGroup.remove(numScore, true);
				numScore.setPosition((43 * i) - 90, 80);
				numScore.antialiasing = event.comboAntialiasing;
				numScore.scale.set(event.comboScale, event.comboScale);
				numScore.updateHitbox();
				numScore.alpha = 1;
	
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y = -FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
	
				comboGroup.add(numScore);
	
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween) {
						numScore.kill();
					},
					startDelay: Conductor.crochet * 0.002
				});
			}
		}
		comboGroup.add(rating);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween) {
				rating.kill();
			},
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween) {
				comboSpr.kill();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	public function switchIcon(player:Int, name:String) {
		switch(player) {
			case 0: 
				UI.iconP2.loadIcon(name);
				UI.iconP2.scale.set(1, 1);
				UI.iconP2.updateHitbox();
				UI.iconP2.y = UI.healthBar.y - (UI.iconP2.height * 0.5);

			default:
				UI.iconP1.loadIcon(name);
				UI.iconP1.scale.set(1, 1);
				UI.iconP1.updateHitbox();
				UI.iconP1.y = UI.healthBar.y - (UI.iconP1.height * 0.5);
		}
	}

	override function createPost() {
		startCutscene();
		super.createPost();
		scripts.call("onCreatePost");
	}

	public function callOnNoteType(noteType:String, method:String, ?parameters:Array<Dynamic>) {
		if(!noteTypes.exists(noteType)) return;
		noteTypes[noteType].call(method, parameters);
	}

	public function eventOnNoteType<T:CancellableEvent>(noteType:String, method:String, event:T):T {
		if(!noteTypes.exists(noteType)) return event;
		noteTypes[noteType].call(method, [event]);
		return event;
	}

	public function characterSing(?type:Null<CharacterType>, ?keyAmount:Null<Int> = 4, noteData:Int, ?suffix:String = "") {
		if(type == null) type = DAD;
		if(keyAmount == null) keyAmount = 4;

		switch(type) {
			case DAD, OPPONENT: 
				for(character in dads)
					character.playAnim(Note.getSingAnim(keyAmount, noteData)+suffix, true);

			case GF, GIRLFRIEND, SPEAKERS:
				for(character in gfs)
					character.playAnim(Note.getSingAnim(keyAmount, noteData)+suffix, true);

			case BF, PLAYER, BOYFRIEND:
				for(character in boyfriends)
					character.playAnim(Note.getSingAnim(keyAmount, noteData)+suffix, true);
		}
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
			for(character in dads) character.dance();
			for(character in gfs) character.dance();
			for(character in bfs) character.dance();
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

	public function finishSong(?ignoreNoteOffset:Bool = false) {
		endingSong = true;
		FlxG.sound.music.onComplete = null;

        persistentUpdate = false;
        persistentDraw = true;

		if((OptionsAPI.get("Note Offset") * FlxG.sound.music.pitch) <= 0 || ignoreNoteOffset) {
			endSong();
		} else {
			new FlxTimer().start((OptionsAPI.get("Note Offset") * FlxG.sound.music.pitch) / 1000, function(tmr:FlxTimer) {
				endSong();
			});
		}
	}

	public function endSong() {
		if(inCutscene) return;
		
		endingSong = true;

		// story mode prob gonna be added last

		var ret:Dynamic = scripts.call("onEndSong", [], true);
        if(ret != false) {
			if(FlxG.sound.music != null) FlxG.sound.music.stop();
			if(vocals != null) vocals.stop();

			CoolUtil.playMusic(Paths.music("freakyMenu"));
			FlxG.sound.music.time = 0;
			FlxG.switchState(new funkin.menus.FreeplayState());
		}
	}

	public function startSong() {
		startingSong = false;
		
		FlxG.sound.music.pause();
		FlxG.sound.music.time = Conductor.position = 0;
		FlxG.sound.music.onComplete = finishSong.bind();
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
		for(type in noteTypes.keys()) callOnNoteType(type, "onUpdate", [elapsed]);
		scripts.call("onUpdate", [elapsed]);

		vocals.pitch = FlxG.sound.music.pitch;
		if(!inCutscene && !endingSong) Conductor.position += (elapsed * 1000) * FlxG.sound.music.pitch;
		if(Conductor.position >= 0 && startingSong && !inCutscene) startSong();

		if(controls.BACK && !endingSong) {
			endingSong = true;
			FlxG.sound.music.stop();
			vocals.stop();
			CoolUtil.playMusic(Paths.music("freakyMenu"));
			FlxG.switchState(isStoryMode ? new funkin.menus.StoryMenuState() : new funkin.menus.FreeplayState());
		}

		if(controls.PAUSE && !endingSong) {
			var ret:Dynamic = scripts.call("onPause", [], true);
			if(ret != false) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;
				FlxG.sound.music.pause();
				vocals.pause();
				openSubState(new funkin.menus.PauseSubState());
				scripts.call("onPausePost");
			}
		}

		if(camZooming) {
			FlxG.camera.zoom = MathUtil.fixedLerp(FlxG.camera.zoom, defaultCamZoom, 0.05);
			camHUD.zoom = MathUtil.fixedLerp(camHUD.zoom, camHUD.initialZoom, 0.05);
		}

		if(UI.playerStrums.input.pressed.contains(true)) {
			for(character in bfs)
				character.holdTimer = 0;
		}
		else if(!UI.playerStrums.input.pressed.contains(true) && boyfriend.lastAnimContext == SING && boyfriend.holdTimer >= Conductor.stepCrochet * boyfriend.singDuration * 0.0011) {
			for(character in bfs)
				character.dance();
		}

		// If the vocals are out of sync, resync them!
		@:privateAccess
		var shouldResync = ((vocals._sound != null && SONG.needsVoices && vocals.time < vocals.length) ? !Conductor.isAudioSynced(vocals) : !Conductor.isAudioSynced(FlxG.sound.music)) && !startingSong && !endingSong && !inCutscene;
		if(shouldResync) resyncVocals();

		for(type in noteTypes.keys()) callOnNoteType(type, "onUpdatePost", [elapsed]);
		scripts.call("onUpdatePost", [elapsed]);
	}

	@:dox(hide) override function beatHit(curBeat:Int) {
		if(camBumpingInterval > 0 && camBumping && FlxG.camera.zoom < 1.35 && curBeat % camBumpingInterval == 0) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
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
