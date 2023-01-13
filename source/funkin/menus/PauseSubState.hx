package funkin.menus;

import funkin.game.PlayState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import funkin.system.MusicBeatSubstate;

class PauseSubState extends MusicBeatSubstate {
    public var game:PlayState;

    override function create() {
        super.create();
        game = PlayState.current;
        
        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        bg.alpha = 0;
        bg.scrollFactor.set();
        bg.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
        add(bg);

        FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        // goofy ahh flixel
        FlxG.sound.music.pause();
        game.vocals.pause();

        if(controls.ACCEPT) {
            PlayState.paused = false;
            FlxG.sound.music.play();
            game.vocals.play();
            close();
        }
    }
}