package states.substates;

import states.MusicBeat.MusicBeatSubstate;
import openfl.media.Sound;
import states.PlayState;
import objects.Character;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

class GameOverSubstate extends MusicBeatSubstate {
	public var boyfriend:Character;
	public var camFollow:FlxObject;

    public static var characterName:String = "bf-dead";
	public static var deathSoundName:String;
	public static var loopSoundName:String;
	public static var endSoundName:String;

	public static function resetVariables() {
        characterName = (PlayState.current.boyfriend != null) ? PlayState.current.boyfriend.deathCharacter : "bf-dead";
		deathSoundName = "fnf_loss_sfx";
		loopSoundName = "gameOver";
		endSoundName = "gameOverEnd";
	}

	public var playingDeathSound:Bool = false;

    public var deathX:Float = 0;
    public var deathY:Float = 0;

	public function new(x:Float, y:Float) {
		super();
        deathX = x;
        deathY = y;
	}

    override function create() {
        super.create();

		if(runDefaultCode) {
			Conductor.songPosition = 0;

			boyfriend = new Character(deathX, deathY, true).loadCharacter(characterName);
			add(boyfriend);

			camFollow = new FlxObject(0, 0, 1, 1);
			add(camFollow);

			FlxG.sound.play(Paths.sound(deathSoundName));
			Conductor.changeBPM(100);

			FlxG.camera.target = null;
			FlxG.camera.scroll.set();

			boyfriend.playAnim("firstDeath");
		}
    }

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(runDefaultCode) {
			if (controls.ACCEPT) endBullshit();

			if (controls.BACK) {
				FlxG.sound.music.stop();

				if (PlayState.isStoryMode)
					FlxG.switchState(new states.menus.StoryMenuState());
				else
					FlxG.switchState(new states.menus.FreeplayState());
			}

			if (boyfriend.animation.curAnim != null && boyfriend.animation.name == "firstDeath" && boyfriend.animation.curAnim.curFrame == 12) {
				camFollow.setPosition(boyfriend.getGraphicMidpoint().x + boyfriend.positionOffset.x, boyfriend.getGraphicMidpoint().y + boyfriend.positionOffset.y);
				FlxG.camera.follow(camFollow, LOCKON, 0.01);
			}

			if(PlayState.SONG.stage == "tank") {
				if(boyfriend.animation.curAnim != null && boyfriend.animation.name == "firstDeath" && boyfriend.animation.curAnim.finished && !playingDeathSound) {
					boyfriend.playAnim("deathLoop");
					playingDeathSound = true;
					coolStartDeath(0.2);

                    var exclude:Array<Int> = [];
                    // if (prefs.get("censor-naughty"))
                    // 	exclude = [1, 3, 8, 13, 17, 21];
					FlxG.sound.play(Paths.sound("week7/jeffGameover/jeffGameover-" + FlxG.random.int(1, 25, exclude)), 1, false, null, true, () -> {
						FlxG.sound.music.fadeIn(4, 0.2, 1);
					});
				}
			} else if (boyfriend.animation.curAnim != null && boyfriend.animation.curAnim.name == "firstDeath" && boyfriend.animation.curAnim.finished) {
				boyfriend.playAnim("deathLoop");
				coolStartDeath();
			}

			if (FlxG.sound.music.playing) Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	public function coolStartDeath(?startVol:Float = 1) {
		FlxG.sound.playMusic(Paths.music(loopSoundName), startVol);
	}

	public var isEnding:Bool = false;

	public function endBullshit():Void {
		if (isEnding) return;

        isEnding = true;
        boyfriend.playAnim("deathConfirm", true);
        FlxG.sound.music.stop();
        FlxG.sound.play(Paths.music(endSoundName));
        new FlxTimer().start(0.7, function(tmr:FlxTimer) {
            FlxG.camera.fade(FlxColor.BLACK, 2, false, function() {
                FlxG.switchState(new PlayState());
            });
        });
	}
}