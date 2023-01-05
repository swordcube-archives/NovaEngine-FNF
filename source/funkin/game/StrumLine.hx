package funkin.game;

import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class StrumLine extends FlxTypedSpriteGroup<Receptor> {
    public var keyAmount:Null<Int>;

    public function new(?x:Float = 0, ?y:Float = 0, ?keyAmount:Int = 4) {
        super(x, y);
        this.keyAmount = keyAmount;
    }

    public function generateReceptors():StrumLine {
        for(member in members) {
            member.kill();
            member.destroy();
            remove(member, true);
        }

        for(i in 0...keyAmount) {
            var receptor:Receptor = new Receptor(Note.swagWidth * i, 0, keyAmount, i);
            receptor.alpha = 0;
			FlxTween.tween(receptor, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
            add(receptor);
        }
        return this;
    }

    public function positionReceptors(?left:Bool = true) {
        screenCenter(X);
        var mult:Float = FlxG.width / 4;
        x += left ? -mult : mult;
        return this;
    }
}