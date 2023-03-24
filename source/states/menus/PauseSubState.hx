package states.menus;

import objects.fonts.Alphabet;
import flixel.util.FlxColor;
import states.MusicBeat.MusicBeatSubstate;
import sys.thread.Mutex;
import sys.thread.Thread;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.system.FlxSound;

/**
 * The pause screen. You can modify this to your liking with scripts!
 * If you want to resume the game in your pause menu script, Use the `resumeGame()` function.
 */
class PauseSubState extends MusicBeatSubstate {
    var oldFollowLerp:Float = FlxG.camera.followLerp;

    public var game:PlayState;
    public var grpAlphabet:PauseMenuGroup;

    public var curSelected:Int = 0;

    public var pauseMusic:FlxSound;

    public var mutex:Mutex;

    override function create() {
        game = PlayState.current;
        FlxG.camera.followLerp = 0;
        PlayState.paused = true;

        super.create();
        
        FlxTimer.globalManager.forEach(function(tmr:FlxTimer) {
            if (!tmr.finished)
                @:privateAccess tmr.paused = true;
        });
        FlxTween.globalManager.forEach(function(twn:FlxTween) {
            if (!twn.finished)
                @:privateAccess twn.paused = true;
        });

        if (!runDefaultCode) return;

        mutex = new Mutex();
        
        Thread.create(() -> {
            mutex.acquire();
			pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
			FlxG.sound.list.add(pauseMusic);
			pauseMusic.volume = 0;
			mutex.release();
        });

        var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
        
		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += (PlayState.SONG.displayName != null) ? PlayState.SONG.displayName : PlayState.SONG.name;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += PlayState.storyDifficulty.toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

        add(grpAlphabet = new PauseMenuGroup());

        // VVV - ADD PAUSE OPTIONS HERE!
        grpAlphabet.createItem("Resume", resumeGame);
        grpAlphabet.createItem("Restart Song", () -> FlxG.resetState());
        grpAlphabet.createItem("Change Options", () -> {
            NovaTools.playMenuMusic("freakyMenu");
            OptionsMenuState.stateData = {
                state: PlayState
            };
            FlxG.switchState(new OptionsMenuState());
        });
        grpAlphabet.createItem("Exit To Menu", () -> {
            NovaTools.playMenuMusic("freakyMenu");

            // gotta fix for story mode eventually
            FlxG.switchState(new FreeplayState());
        });
        // ^^^ -------------------------

        changeSelection();
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    public function resumeGame() {
        FlxTimer.globalManager.forEach(function(tmr:FlxTimer) {
            if (!tmr.finished)
                @:privateAccess tmr.paused = false;
        });
        FlxTween.globalManager.forEach(function(twn:FlxTween) {
            if (!twn.finished)
                @:privateAccess twn.paused = false;
        });
        FlxG.camera.followLerp = oldFollowLerp;
        PlayState.paused = false;
        if(!game.startingSong && !game.endingSong) {
            FlxG.sound.music.play();
            game.vocals.play();
            game.resyncVocals();
        }
        close();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // flixel is dumb
        FlxG.sound.music.pause();
        game.vocals.pause();

        if (!runDefaultCode) return;

        if (pauseMusic != null && pauseMusic.playing) {
			if (pauseMusic.volume < 0.5)
				pauseMusic.volume += 0.01 * elapsed;
		}

        if(controls.UI_UP_P) changeSelection(-1);
        if(controls.UI_DOWN_P) changeSelection(1);
        if(controls.ACCEPT) grpAlphabet.members[curSelected].select();
    }

    public function changeSelection(?change:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + change, 0, grpAlphabet.length - 1);
        grpAlphabet.forEach((text:PauseMenuItem) -> {
            text.targetY = text.ID - curSelected;
            text.alpha = (curSelected == text.ID) ? 1 : 0.6;
        });
        CoolUtil.playMenuSFX(SCROLL);
    }

    override function destroy() {
		if (pauseMusic != null)
			pauseMusic.destroy();

		super.destroy();
	}
}

class PauseMenuGroup extends FlxTypedGroup<PauseMenuItem> {
    public function createItem(text:String, onSelect:Void->Void) {
        var item = new PauseMenuItem(0, (70 * length) + 30, Bold, text);
        item.isMenuItem = true;
        item.onSelect.add(onSelect);
        item.ID = length;
        add(item);
        return item;
    }
}

class PauseMenuItem extends Alphabet {
    public var onSelect = new FlxTypedSignal<Void->Void>();
    public function select() onSelect.dispatch();
}