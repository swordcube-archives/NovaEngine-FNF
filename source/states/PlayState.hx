package states;

import states.editors.ChartingState;
import states.substates.GameOverSubstate;
import backend.modding.ModUtil;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import game.cutscenes.*;
import flixel.text.FlxText;
import music.Ranking;
import objects.ui.StrumLine.Receptor;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.io.Path;
import backend.dependency.ScriptHandler;
import backend.scripting.events.*;
import openfl.media.Sound;
import flixel.tweens.*;
import flixel.graphics.FlxGraphic;
import flixel.util.*;
import flixel.math.*;
import flixel.ui.FlxBar;
import objects.*;
import objects.fonts.*;
import objects.ui.*;
import states.menus.*;
import flixel.system.FlxSound;
import states.MusicBeat.MusicBeatState;
import music.SongFormat.SongData;

class PlayState extends MusicBeatState {
	public static var current:PlayState;
	public static var SONG:SongData;

	public static var storyDifficulty:String = "hard";

	public static var assetModifier:String = "base";
	public static var changeableSkin:String = "default";

	public static var paused:Bool = false;
	public static var isStoryMode:Bool = false;
	public static var campaignScore:Int = 0;

	public var playCutscenes:Bool = isStoryMode;

	public var vocals:FlxSound;

	public var defaultCamZoom:Float = 1.05;

	public var camGame:FNFCamera;
	public var camHUD:FNFCamera;
	public var camOther:FNFCamera;

	public var camFollow:FlxObject;
	public static var prevCamFollow:FlxObject;

 	public var cutscene:String = null;
	public var endCutscene:String = null;

	public var stage:Stage;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	public var bf(get, set):Character;
	private function get_bf():Character {
		return boyfriend;
	}
	private function set_bf(newChar:Character):Character {
		return boyfriend = newChar;
	}

	public var usedAutoplay:Bool = SettingsAPI.autoplay;
	public var gfSpeed:Int = 1;

	public var cpuStrums:StrumLine;
	public var playerStrums:StrumLine;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var notes:NoteField;

	public var healthBarBG:TrackingSprite;
	public var healthBar:FlxBar;

	public var timeBarBG:TrackingSprite;
	public var timeBar:FlxBar;
	public var timeTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var scoreTxt:FlxText;

	public var autoplayTxt:FlxText;

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

	public var iconBumping:Bool = true;
	public var iconZooming:Bool = true;
	public var iconZoomingSpeed:Float = 0.5;

	public var camBumping:Bool = true;
	public var camBumpingMult:Float = 1;

	public var camZooming:Bool = true;
	public var camZoomingSpeed:Float = 0.05;

	public var inCutscene:Bool = false;
	public var startingSong:Bool = true;
	public var endingSong:Bool = false;

	public var startTimer:FlxTimer;
	public var finishTimer:FlxTimer;

	public var preloadedCharacters:Map<String, Character> = [];
	public var noteTypeScripts:Map<String, ScriptModule> = [];
	public var eventScripts:Map<String, ScriptModule> = [];

	public var events:EventManager;

	public var countdownImages:Map<Int, FlxGraphic> = [];
	public var countdownSounds:Map<Int, Sound> = [];

	public var accuracyPressedNotes:Int = 0;
	public var accuracyTotalHit:Float = 0;

	/**
	 * This variable is a shortcut to `accuracyTotalHit / accuracyPressedNotes`.
	 */
	public var accuracy(get, never):Float;
	private function get_accuracy():Float {
		if(accuracyTotalHit != 0 && accuracyPressedNotes != 0)
			return accuracyTotalHit / accuracyPressedNotes;

		return 0;
	}

	public var songScore:Int = 0;
	public var songMisses:Int = 0;

	public var score(get, set):Int;
	private function get_score():Int {
		return songScore;
	}
	private function set_score(v:Int):Int {
		return songScore = v;
	}

	public var misses(get, set):Int;
	private function get_misses():Int {
		return songMisses;
	}
	private function set_misses(v:Int):Int {
		return songMisses = v;
	}

	public var sicks:Int = 0;
	public var goods:Int = 0;
	public var bads:Int = 0;
	public var shits:Int = 0;
	public var combo:Int = 0;

	public var comboGroup:FlxTypedSpriteGroup<FNFSprite>;

	public var scripts:ScriptGroup;
	public var scrollSpeed:Float = 1;

	public var rankFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF888888, false), "<rank>");

	public static function resetStatics() {
		paused = false;
		assetModifier = "base";
		changeableSkin = "default";

		Ranking.judgements = [for(i in Ranking.defaultJudgements) i.clone()];
		Ranking.ranks = [for(i in Ranking.defaultRanks) i.clone()];
	}

	/**
	 * Instantly causes a game over.
	 */
	public function gameOver() {
		if(startTimer != null)
			startTimer.active = false;

		FlxG.sound.music.stop();
		vocals.stop();

		endingSong = true;
		persistentUpdate = false;
		persistentDraw = false;

		openSubState(new GameOverSubstate(
			boyfriend != null ? boyfriend.getScreenPosition().x : 700, 
			boyfriend != null ? boyfriend.getScreenPosition().y : 360
		));
	}
	
	override public function create() {
		super.create();

		resetStatics();

		current = this;
		FlxG.sound.music.stop();

		(scripts = new ScriptGroup()).setParent(this);

		// VVV -- PRELOADING -----------------------------------------------------------

		if(SONG == null) SONG = Song.fallbackSong;
		if(SONG.assetModifier != null) assetModifier = SONG.assetModifier;
		if(SONG.changeableSkin != null) changeableSkin = SONG.changeableSkin;
		if(SONG.splashSkin == null) SONG.splashSkin = "noteSplashes";
		if(SONG.keyCount == null) SONG.keyCount = 4;
		if(SONG.timeScale == null) SONG.timeScale = [4, 4];

		scrollSpeed = SONG.scrollSpeed;
		if(SettingsAPI.scrollSpeed > 0) {
			switch(SettingsAPI.scrollType.toLowerCase()) {
				case "multiplier":
					scrollSpeed *= SettingsAPI.scrollSpeed;
				case "constant":
					scrollSpeed = SettingsAPI.scrollSpeed;
			}
		}

		// Preload music
		var instPath:String = Paths.songInst(SONG.name, storyDifficulty, true);
		FlxG.sound.playMusic(Paths.songInst(SONG.name, storyDifficulty), 0, false);
		FlxG.sound.list.add(vocals = new FlxSound());

		if(SONG.needsVoices && FileSystem.exists(Paths.songVoices(SONG.name, storyDifficulty, true)))
			vocals.loadEmbedded(Paths.songVoices(SONG.name, storyDifficulty), false);

		FlxG.cameras.reset(camGame = new FNFCamera());
		FlxG.cameras.add(camHUD = new FNFCamera(), false);
		FlxG.cameras.add(camOther = new FNFCamera(), false);

		// Setup song
		Conductor.changeBPM(SONG.bpm, SONG.timeScale[0], SONG.timeScale[1]);
		Conductor.mapBPMChanges(SONG);

		Conductor.songPosition = Conductor.crochet * -5;

		// Load stages & characters
		add(stage = new Stage(SONG.stage));

		gf = new Character(0, 0, SONG.spectator);
		if(gf.trail != null) add(gf.trail);
		add(gf);
		gf.danceOnBeat = false;
		add(stage.gfLayer);

		dad = new Character(0, 0, SONG.opponent);
		if(dad.trail != null) add(dad.trail);
		add(dad);
		add(stage.dadLayer);

		boyfriend = new Character(0, 0, SONG.player, true);
		if(boyfriend.trail != null) add(boyfriend.trail);
		add(boyfriend);
		add(stage.bfLayer);

		GameOverSubstate.resetVariables();

		camFollow = new FlxObject(0, 0, 1, 1);
		if(prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);
		add(events = new EventManager());

		// ^^^ -- END OF PRELOADING ----------------------------------------------------

		// Global song scripts
		for(path in Paths.getFolderContents("songs", true, FILES_ONLY)) {
			if(!FileSystem.exists(path) || !Paths.scriptExts.contains(Path.extension(path)))
				continue;

			scripts.add(ScriptHandler.loadModule(path));
		}

		// Scripts specific to the current song
		for(path in Paths.getFolderContents('songs/${SONG.name.toLowerCase()}', true, FILES_ONLY)) {
			if(!FileSystem.exists(path) || !Paths.scriptExts.contains(Path.extension(path)))
				continue;
			
			scripts.add(ScriptHandler.loadModule(path));
		}

		scripts.load();
		scripts.call("onCreate", []);
		camGame.zoom = defaultCamZoom;

		// Position the characters to the positions set
		// in the stage (this used to be broken, whoops)
		var stageShit:Array<Array<Dynamic>> = [
			[stage.dadPos, dad],
			[stage.gfPos, gf],
			[stage.bfPos, boyfriend],
		];
		for(item in stageShit) {
			var position:FlxPoint = item[0];
			var character:Character = item[1];

			if (character == null) continue;

			character.setPosition(position.x, position.y);
		}

		// tutoirial fix
		if(SONG.opponent == SONG.spectator) {
			dad.setPosition(gf.x, gf.y);
			gf.kill();
			gf.destroy();
			remove(gf, true);
			gf = null;
		}

		// Center the camera on the spectator/opponent (depends on if the spectator is null or not)
		var spectator:Character = (gf != null) ? gf : dad;
		camFollow.setPosition(
			((spectator != null) ? spectator.getMidpoint().x : 0) - 100, 
			((boyfriend != null) ? boyfriend.getCameraPosition().y : 0) - 100
		);
		camGame.follow(camFollow, null, 0.04);
		camGame.snapToTarget();

		// Generate strumlines
		var receptorSpacing:Float = FlxG.width / 4;
		var strumY:Float = (SettingsAPI.downscroll) ? FlxG.height - 160 : 50;

		add(cpuStrums = new StrumLine(0, strumY, SettingsAPI.downscroll, true, changeableSkin, SONG.keyCount));
		cpuStrums.screenCenter(X);

		add(playerStrums = new StrumLine(0, strumY, SettingsAPI.downscroll, SettingsAPI.autoplay, changeableSkin, SONG.keyCount));
		playerStrums.screenCenter(X);

		if(SettingsAPI.centeredNotefield) {
			cpuStrums.x -= 999999;
		} else {
			cpuStrums.x -= receptorSpacing;
			playerStrums.x += receptorSpacing;
		}

		var autoplayTxtSpacing:Float = (SettingsAPI.downscroll) ? -50 : 125;
		add(autoplayTxt = new FlxText(0, strumY + autoplayTxtSpacing, 0, "[AUTOPLAY]", 30));
		autoplayTxt.visible = playerStrums.autoplay;
		autoplayTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		autoplayTxt.borderSize = 2;
		autoplayTxt.screenCenter(X);

		// Preload notes
		add(notes = new NoteField());
		add(grpNoteSplashes = new FlxTypedGroup<NoteSplash>());
 
		add(comboGroup = new FlxTypedSpriteGroup<FNFSprite>(FlxG.width * 0.55, (FlxG.height * 0.5) - 60));

		if(SettingsAPI.judgementCamera.toLowerCase() == "hud")
			comboGroup.cameras = [camHUD];
		
		notes.addNotes(ChartParser.parseChart(SONG));

		// Load events
		if(SONG.events != null && SONG.events.length > 0) {
			for(group in SONG.events) {
				for(event in group.events) {
					if(event.name == "Change Character" && !preloadedCharacters.exists(event.parameters[1]))
						preloadedCharacters.set(event.parameters[1], Character.preloadCharacter(event.parameters[1]));
					
					if(eventScripts.exists(event.name)) continue;
					var script = ScriptHandler.loadModule(Paths.script('data/events/${event.name}'));
					eventScripts.set(event.name, script);
					scripts.add(script);
				}
				events.add(group.time, EventManager.generateList(group));
			}
		}

		// Generate health bar & icons
		healthBarBG = new TrackingSprite(0, FlxG.height * (SettingsAPI.downscroll ? 0.1 : 0.9)).loadGraphic(Paths.image("UI/base/healthBar"));
		healthBarBG.screenCenter(X);
		healthBarBG.trackingOffset.set(-4, -4);

		var healthBarColors = [
			(dad != null && dad.healthBarColor != null) ? dad.healthBarColor : 0xFFFF0000,
			(boyfriend != null && boyfriend.healthBarColor != null) ? boyfriend.healthBarColor : 0xFF66FF33
		];

		add(healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, maxHealth));
		healthBar.createFilledBar(healthBarColors[0], healthBarColors[1]);

		add(healthBarBG);

		add(iconP1 = new HealthIcon(0, healthBar.y, (boyfriend != null) ? boyfriend.healthIcon : SONG.player));
		iconP1.flipX = true;

		add(iconP2 = new HealthIcon(0, healthBar.y, (dad != null) ? dad.healthIcon : SONG.opponent));

		add(scoreTxt = new FlxText(0, healthBarBG.y + 36, 0, "obtain realism", 18));
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.borderSize = 2;
		updateScoreText();

		// Generate time bar
		timeBarBG = new TrackingSprite(0, FlxG.height * (SettingsAPI.downscroll ? 0.945 : 0.025)).loadGraphic(Paths.image("UI/base/timeBar"));
		timeBarBG.screenCenter(X);
		timeBarBG.trackingOffset.set(-4, -4);

		add(timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8)));
		timeBar.createGradientBar([0xFF2C183B, 0xFF5C1C57], [0xFFB062F0, 0xFFE44DD7], 1, 90);

		timeBar.setParent(Conductor, "songPosition");
		timeBar.setRange(0, (FileSystem.exists(instPath)) ? FlxG.sound.music.length : 1);

		add(timeBarBG);

		add(timeTxt = new FlxText(0, timeBar.y - 8, 0, "0:00 / 0:00", 22));
		timeTxt.setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.borderSize = 2;
		timeTxt.screenCenter(X);

		for(obj in [timeBarBG, timeBar, timeTxt])
			obj.alpha = 0;

		// Put everything HUD related on the HUD camera
		timeBarBG.trackingMode = healthBarBG.trackingMode = LEFT;
		healthBarBG.tracked = healthBar;
		timeBarBG.tracked = timeBar;

		for(obj in [cpuStrums, playerStrums, notes, grpNoteSplashes, healthBarBG, healthBar, timeBarBG, timeBar, timeTxt, autoplayTxt, iconP1, iconP2, scoreTxt])
			obj.cameras = [camHUD];

		// Preload countdown
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

		// Preload ratings, combo & hitsounds
		var ratingImages:Array<String> = ["sick", "good", "bad", "shit"];
		for(item in ratingImages)
			FlxG.bitmap.add(Paths.image(NovaTools.returnSkinAsset('ratings/$item', assetModifier, changeableSkin, "game")));

		var comboImages:Array<String> = ["combo"];
		for(i in 0...10) comboImages.push('num${Std.string(i)}');
		
		for(item in comboImages)
			FlxG.bitmap.add(Paths.image(NovaTools.returnSkinAsset('combo/$item', assetModifier, changeableSkin, "game")));

		if(SettingsAPI.hitsoundVolume > 0)
			FlxG.sound.play(Paths.sound("game/hitsound"), 0);
		
		// Preload note splashes
		if(SettingsAPI.noteSplashes) {
			var loadedSplashes:Array<String> = [];
			for(note in notes.members) {
				if(!loadedSplashes.contains(note.splashSkin)) {
					var noteSplash = new NoteSplash(-10000, -10000, note.splashSkin, note.keyCount, note.noteData);
					noteSplash.alpha = 0.00001;
					grpNoteSplashes.add(noteSplash);
					loadedSplashes.push(note.splashSkin);
				}
			}
		}
	}

	override public function createPost() {
		super.createPost();

		// Start the song's cutscene if it exists
		// or the countdown if it doesn't exist
		if(!inCutscene)
			startCutscene();

		scripts.call("onCreatePost", []);
	}

	public function startCutscene() {
		if(!playCutscenes)
			startCountdown();
		else {
			var videoCutscene = Paths.video('${PlayState.SONG.name.toLowerCase()}-cutscene');
			persistentUpdate = false;
			persistentDraw = false;
			if (cutscene != null) {
				inCutscene = true;

				openSubState(new ScriptedCutscene(cutscene, () -> {
					startCountdown();
				}));
			}
			#if VIDEO_CUTSCENES
			else if (FileSystem.exists(videoCutscene)) {
				inCutscene = true;

				var sprite = new VideoSprite();
				sprite.cameras = [camOther];
				sprite.finishCallback = () -> {
					sprite.kill();
					sprite.destroy();
					remove(sprite, true);

					startCountdown();
				}
				sprite.play(videoCutscene, false);
				add(sprite);
			}
			#end
			else
				startCountdown();
		}

		scripts.call("onStartCutscene", []);
		scripts.call("onCutsceneStart", []);
	}

	public function startEndCutscene() {
		if(!playCutscenes)
			endSong();
		else {
			var videoCutscene = Paths.video('${PlayState.SONG.name.toLowerCase()}-endcutscene');
			persistentUpdate = false;
			if (endCutscene != null) {
				openSubState(new ScriptedCutscene(endCutscene, () -> {
					endSong();
				}));
			}
			#if VIDEO_CUTSCENES
			else if (FileSystem.exists(videoCutscene)) {
				inCutscene = true;

				var sprite = new VideoSprite();
				sprite.cameras = [camOther];
				sprite.finishCallback = () -> {
					sprite.kill();
					sprite.destroy();
					remove(sprite, true);
					
					endSong();
				}
				sprite.play(videoCutscene, false);
				add(sprite);
			}
			#end
			else
				endSong();
		}

		scripts.call("onStartEndCutscene", []);
	}

	public function finishSong(?ignoreNoteOffset:Bool = false) {
		FlxG.sound.music.volume = 0;
		FlxG.sound.music.pause();
		vocals.volume = 0;
		vocals.pause();

		if(SettingsAPI.noteOffset <= 0 || ignoreNoteOffset) {
			startEndCutscene();
		} else {
			finishTimer = new FlxTimer().start(SettingsAPI.noteOffset / 1000, (tmr:FlxTimer) -> {
				startEndCutscene();
			});
		}
		scripts.call("onFinishSong", []);
		scripts.call("onSongFinish", []);
	}

	public function endSong() {
		inCutscene = false;
		endingSong = true;

		// make sure it's fair to set the score before setting it
		if(!usedAutoplay && SettingsAPI.healthGainMultiplier <= 1 && SettingsAPI.healthLossMultiplier >= 1)
			Highscore.setScore(SONG.name+":"+ModUtil.currentMod, storyDifficulty, songScore);

		var event = scripts.event("onEndSong", new CancellableEvent());
		event = scripts.event("onSongEnd", event);

		if(event.cancelled) return;

		if(isStoryMode)
			FlxG.switchState(new StoryMenuState());
		else
			FlxG.switchState(new FreeplayState());

		NovaTools.playMenuMusic("freakyMenu");
	}

	public function popUpScore(event:NoteHitEvent, rating:String, combo:Int) {
		event = scripts.event("onPopUpScore", event);
		if(event.cancelled) return;

		var ratingSpr:FNFSprite = null;
		if(event.showRating) {
			ratingSpr = comboGroup.recycle(FNFSprite).loadGraphic(Paths.image(event.ratingSprites+'/$rating'));
			comboGroup.remove(ratingSpr, true);
			ratingSpr.setPosition(-40, -60);
			ratingSpr.antialiasing = event.ratingAntialiasing;
			ratingSpr.scale.set(event.ratingScale, event.ratingScale);
			ratingSpr.updateHitbox();
			ratingSpr.alpha = 1;

			ratingSpr.acceleration.y = 550;
			ratingSpr.velocity.y = -FlxG.random.int(140, 175);
			ratingSpr.velocity.x = -FlxG.random.int(0, 10);
		}

		var comboSpr:FNFSprite = null;
		if(event.showCombo) {
			comboSpr = comboGroup.recycle(FNFSprite).loadGraphic(Paths.image(event.comboSprites+'/combo'));
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
					var numScore:FNFSprite = comboGroup.recycle(FNFSprite).loadGraphic(Paths.image(event.comboSprites+'/num${separatedScore.charAt(i)}'));
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
		}

		if(event.showRating && rating != null) {
			comboGroup.add(ratingSpr);

			FlxTween.tween(ratingSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
					ratingSpr.kill();
				},
				startDelay: Conductor.crochet * 0.001
			});
		}

		if(event.showCombo && comboSpr != null) {
			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween) {
					comboSpr.kill();
				},
				startDelay: Conductor.crochet * 0.001
			});
		}
	}

	public function goodNoteHit(note:Note) {
		vocals.volume = 1;
		note.wasGoodHit = true;

		var judgeData:Judgement = (note.mustPress && !note.strumLine.autoplay) ? Ranking.judgementFromTime(note.strumTime - Conductor.songPosition) : Ranking.judgements[0];

		var funcName:String = note.mustPress ? "onPlayerHit" : "onOpponentHit";
		// other function names u can use if you're used to how another engine does it
		var funcNames:Array<Array<String>> = [
			["onBfHit", "onDadHit"],
			["goodNoteHit", "opponentNoteHit"],
			["bfHit", "onCPUHit"],
			["playerHit", "onCpuHit"]
		];
		
		var event = scripts.event(funcName, new NoteHitEvent(note, judgeData, note.mustPress ? judgeData.score : 0, note.mustPress && judgeData.showSplash));
		event = noteTypeScripts.get(note.noteType).event(funcName, event);

		for(f in funcNames)
			event = scripts.event(note.mustPress ? f[0] : f[1], event);

		for(f in funcNames)
			event = noteTypeScripts.get(note.noteType).event(note.mustPress ? f[0] : f[1], event);

		if(event.cancelled) return;

		if(note.mustPress) {
			health += event.healthGain;

			if(!note.isSustainNote) {
				accuracyPressedNotes++;
				accuracyTotalHit += event.accuracy;
				songScore += Std.int(event.score * ((Conductor.rate > 1) ? 1 : Conductor.rate));

				switch(event.rating) {
					case "sick": sicks++;
					case "good": goods++;
					case "bad":  bads++;
					case "shit": shits++;
				}

				popUpScore(event, judgeData.name, combo++);
				updateScoreText();

				if(SettingsAPI.hitsoundVolume > 0)
					FlxG.sound.play(Paths.sound("game/hitsound"), SettingsAPI.hitsoundVolume / 100);
			}
		}

		if(!event.cancelSingAnim) {
			var singAnim:String = "sing"+event.note.directionName.toUpperCase();
			if(event.characters != null && event.characters.length > 0) {
				for(char in event.characters) {
					char.holdTimer = 0;
					var altShit:String = (note.altAnim && char.animation.exists(singAnim+"-alt")) ? "-alt" : "";
					char.holdTimer = 0;
					if(!char.specialAnim)
						char.playAnim(singAnim+altShit, true);
				}
			} else {
				var char:Character = (note.mustPress) ? boyfriend : dad;
				var altShit:String = (note.altAnim && char.animation.exists(singAnim+"-alt")) ? "-alt" : "";
				char.holdTimer = 0;
				if(!char.specialAnim)
					char.playAnim(singAnim+altShit, true);
			}
		}

		if(note.isSustainNote) return;

		var receptor:Receptor = note.strumLine.members[note.noteData];

		if(event.showSplash && SettingsAPI.noteSplashes) {
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.setup(receptor.x, receptor.y, note.splashSkin, note.keyCount, note.noteData);
			splash.animation.finishCallback = (name:String) -> {
				splash.kill();
				splash.destroy();
				grpNoteSplashes.remove(splash, true);
			};
			grpNoteSplashes.add(splash);
		}

		note.kill();
		note.destroy();
		notes.remove(note, true);
	}

	public function startCountdown() {
		inCutscene = false;

		var event = scripts.event("onStartCountdown", new CancellableEvent());
		event = scripts.event("onCountdownStart", event);

		if(event.cancelled) return;
		
		// don't even need to do Json.parse because i made Paths cool 😎
		var config:Dynamic = Paths.json('images/UI/$assetModifier/countdown/config');
		config.setFieldDefault("scale", 1.0);

		var swagCounter:Int = 0;
		startTimer = new FlxTimer().start(Conductor.crochet / 1000, (tmr:FlxTimer) -> {
			var char:Character = ((SONG.sections[0] != null && SONG.sections[0].playerSection) ? boyfriend : dad);
			var pos = char.getCameraPosition();
			if(swagCounter == 0) camFollow.setPosition(pos.x, pos.y);

			var event = scripts.event("onCountdownTick", new CountdownEvent(
				countdownImages.get(tmr.loopsLeft - 1),
				countdownSounds.get(tmr.loopsLeft - 1),
				config.scale,
				swagCounter++,
				tmr.loopsLeft - 1
			));
			event = scripts.event("onCountdown", event);
			event = scripts.event("onTickCountdown", event);

			for(m in members) {
				if(m != null && m is MusicHandler)
					cast(m, MusicHandler).beatHit((tmr.loops - tmr.loopsLeft) - 5);
			}
			
			if(gf != null && gf.lastAnimContext != SING && gfSpeed > 0 && curBeat % gfSpeed == 0)
				gf.dance();

			if(event.image != null && !event.cancelled) {
				var sprite = new FNFSprite().loadGraphic(event.image);
				sprite.scale.set(event.scale, event.scale);
				sprite.updateHitbox();
				sprite.screenCenter();
				sprite.scrollFactor.set();
				event.sprite = sprite;
				add(sprite);

				FlxTween.tween(sprite, {alpha: 0}, Conductor.crochet / 1000, {ease: FlxEase.cubeInOut});
			}
			if(event.sound != null && !event.cancelled)
				FlxG.sound.play(event.sound);

			scripts.event("onCountdownPost", event);
			scripts.event("onCountdownTickPost", event);
			scripts.event("onTickCountdownPost", event);
		}, 5);

		scripts.event("onStartCountdownPost", event);
		scripts.event("onCountdownStartPost", event);
	}

	public function positionIcons() {
		var iconOffset:Int = 26;

		// fuck you remapToRange you aren't needed here!!!
		iconP1.setPosition(healthBar.x + (healthBar.width * ((100 - healthBar.percent) / 100) - iconOffset), healthBar.y - (iconP1.initialHeight * 0.5));
		iconP2.setPosition(healthBar.x + (healthBar.width * ((100 - healthBar.percent) / 100)) - (iconP2.width - iconOffset), healthBar.y - (iconP2.initialHeight * 0.5));
	}

	public function getFCRank() {
		if(sicks > 0 && goods <= 0 && bads <= 0 && shits <= 0 && songMisses <= 0)
			return "SFC";

		if(goods > 0 && bads <= 0 && shits <= 0 && songMisses <= 0)
			return "GFC";

		if((bads > 0 || shits > 0) && songMisses <= 0)
			return "FC";

		if(songMisses > 0 && songMisses < 10)
			return "SDCB";

		if(songMisses >= 10)
			return "CLEAR";

		return "N/A";
	}

	public function updateScoreText() {
		var rank:Rank = Ranking.rankFromAccuracy(accuracy * 100);

		var fcRank:String = '[${getFCRank()}]';
		var accRank:String = (accuracyPressedNotes > 0) ? ' • Rank: <rank>${rank}<rank>' : '';
		scoreTxt.text = 'Score: $songScore • Misses: $songMisses • Accuracy: ${FlxMath.roundDecimal(accuracy * 100, 2)}% $fcRank$accRank';

		@:privateAccess rankFormat.format.format.color = rank.color;
		scoreTxt.applyMarkup(scoreTxt.text, [rankFormat]);

		// doin this so the text doesn't look weird when centered & antialiased
		scoreTxt.x = Math.floor((FlxG.width - scoreTxt.width) * 0.5);
	}

	public var autoplaySine:Float = 0;

	override public function update(elapsed:Float) {
		super.update(elapsed);

		scripts.call("onUpdate", [elapsed]);
		for(script in noteTypeScripts)
			script.call("onUpdate", [elapsed]);

		@:privateAccess
		if (!startingSong && !inCutscene && !Conductor.isAudioSynced(FlxG.sound.music) || (vocals._sound != null && !Conductor.isAudioSynced(vocals)))
			resyncVocals();

		timeTxt.text = FlxStringUtil.formatTime(FlxG.sound.music.time / 1000)+" / "+FlxStringUtil.formatTime(FlxG.sound.music.length / 1000);
		if(playerStrums.autoplay)
			timeTxt.text += " [AUTO]";

		// doin this so the text doesn't look weird when centered & antialiased
		timeTxt.x = Math.floor((FlxG.width - timeTxt.width) * 0.5);

		iconP1.health = healthBar.percent / 100;
		iconP2.health = 1 - (healthBar.percent / 100);

		if(autoplayTxt.visible) {
			autoplaySine += 180 * elapsed;
			autoplayTxt.alpha = 1 - Math.sin((Math.PI * autoplaySine) / 180);
		}

		if(health <= 0 || (controls.RESET && !SettingsAPI.disableResetButton)) gameOver();
		if(controls.CHARTER) {
			FlxG.sound.music.stop();
			vocals.stop();
			FlxG.switchState(new ChartingState());
		}

		if(iconZooming) {
			iconP1.scale.set(MathUtil.lerp(iconP1.scale.x, iconP1.initialScale, iconZoomingSpeed), MathUtil.lerp(iconP1.scale.y, iconP1.initialScale, iconZoomingSpeed));
			iconP1.updateHitbox();

			iconP2.scale.set(MathUtil.lerp(iconP2.scale.x, iconP2.initialScale, iconZoomingSpeed), MathUtil.lerp(iconP2.scale.y, iconP2.initialScale, iconZoomingSpeed));
			iconP2.updateHitbox();
		}
		
		positionIcons();

		if(camZooming) {
			camGame.zoom = MathUtil.lerp(camGame.zoom, defaultCamZoom, camZoomingSpeed);
			camHUD.zoom = MathUtil.lerp(camHUD.zoom, camHUD.initialZoom, camZoomingSpeed);
		}

		if(controls.PAUSE) {
			var pauseFuncs:Array<String> = [
				"onPauseSong",
				"onSongPause"
			];

			var event = scripts.event("onPause", new CancellableEvent());
			for(f in pauseFuncs)
				event = scripts.event(f, event);

			if(!event.cancelled) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;
				FlxG.sound.music.pause();
				vocals.pause();
				openSubState(new PauseSubState());
				scripts.call("onPausePost", []);
			}
		}

		if(!endingSong && !inCutscene) {
			Conductor.songPosition += elapsed * 1000;
			if(Conductor.songPosition >= 0 && startingSong)
				startSong();
		}

		scripts.call("onUpdatePost", [elapsed]);
		for(script in noteTypeScripts)
			script.call("onUpdatePost", [elapsed]);
	}

	override public function fixedUpdate(elapsed:Float) {
		super.fixedUpdate(elapsed);
		scripts.call("onFixedUpdate", [elapsed]);
		for(script in noteTypeScripts)
			script.call("onFixedUpdate", [elapsed]);
	}

	override public function fixedUpdatePost(elapsed:Float) {
		super.fixedUpdatePost(elapsed);
		scripts.call("onFixedUpdatePost", [elapsed]);
		for(script in noteTypeScripts)
			script.call("onFixedUpdatePost", [elapsed]);
	}

	override public function beatHit(curBeat:Int) {
		if(FlxG.sound.music.time >= FlxG.sound.music.length || endingSong) return;

		super.beatHit(curBeat);
		
		if(camBumping && camBumpingInterval > 0 && curBeat % camBumpingInterval == 0 && camGame.zoom < 1.35) {
			camGame.zoom += 0.015 * camBumpingMult;
			camHUD.zoom += 0.03 * camBumpingMult;
		}

		if(iconBumping) {
			iconP1.scale.add(0.3, 0.3);
			iconP1.updateHitbox();

			iconP2.scale.add(0.3, 0.3);
			iconP2.updateHitbox();
		}

		if(gf != null && gf.lastAnimContext != SING && gfSpeed > 0 && curBeat % gfSpeed == 0)
			gf.dance();

		positionIcons();

		scripts.call("onBeatHit", [curBeat]);
		for(script in noteTypeScripts)
			script.call("onBeatHit", [curBeat]);
	}

	override public function stepHit(curStep:Int) {
		if(FlxG.sound.music.time >= FlxG.sound.music.length || endingSong) return;

		super.stepHit(curStep);

		scripts.call("onStepHit", [curStep]);
		for(script in noteTypeScripts)
			script.call("onStepHit", [curStep]);
	}

	public function updateCamera() {
		var char:Character = ((SONG.sections[curMeasure] != null && SONG.sections[curMeasure].playerSection) ? boyfriend : dad);
		var pos = char.getCameraPosition();
		camFollow.setPosition(pos.x, pos.y);
	}

	override public function measureHit(curMeasure:Int) {
		if(FlxG.sound.music.time >= FlxG.sound.music.length || endingSong) return;

		super.measureHit(curMeasure);

		if(SONG.sections[curMeasure] != null && SONG.sections[curMeasure].changeBPM)
			Conductor.changeBPM(SONG.sections[curMeasure].bpm);

		if(SONG.sections[curMeasure] != null && SONG.sections[curMeasure].changeTimeScale) {
			Conductor.beatsPerMeasure = SONG.sections[curMeasure].timeScale[0];
			Conductor.stepsPerBeat = SONG.sections[curMeasure].timeScale[1];
		}

		updateCamera();

		scripts.call("onMeasureHit", [curMeasure]);
		for(script in noteTypeScripts)
			script.call("onMeasureHit", [curMeasure]);
	}

	public function resyncVocals() {
		if(startingSong || endingSong) return;

		if (Conductor.songPosition <= vocals.length)
			vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		if (Conductor.songPosition <= vocals.length) {
			vocals.time = Conductor.songPosition;
			vocals.play();
		}

		scripts.call("onResyncVocals", []);
		for(script in noteTypeScripts)
			script.call("onResyncVocals", []);
	}

	public function startSong() {
		startingSong = false;

		FlxG.sound.music.pause();
		FlxG.sound.music.volume = 1;
		FlxG.sound.music.time = vocals.time = Conductor.songPosition = 0;
		FlxG.sound.music.onComplete = finishSong.bind();
		FlxG.sound.music.play();
		vocals.play();

		for(obj in [timeBarBG, timeBar, timeTxt])
			FlxTween.tween(obj, {alpha: 1}, 0.5, {ease: FlxEase.cubeOut});

		resyncVocals();
		scripts.call("onStartSong", []);
		scripts.call("onSongStart", []);
		for(script in noteTypeScripts) {
			script.call("onStartSong", []);
			script.call("onSongStart", []);
		}
	}

	override public function destroy() {
		current = null;
		scripts.call("onDestroy", []);
		scripts.destroy();
		for(script in noteTypeScripts) {
			script.call("onDestroy", []);
			script.destroy();
		}
		super.destroy();
	}
}