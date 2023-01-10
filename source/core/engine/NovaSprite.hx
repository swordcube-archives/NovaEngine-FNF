package core.engine;

import core.utils.Vector2;
import flixel.FlxSprite;

class NovaSprite extends FlxSprite {
    public var offsets:Map<String, Vector2> = [];

    public function addOffset(anim:String, ?x:Float = 0, ?y:Float = 0) {
        if(offsets.exists(anim))
            offsets[anim].set(x, y);
        else
            offsets[anim] = new Vector2(x, y);
    }

    public function playAnim(anim:String, ?force:Bool = false) {
        if(!animation.exists(anim)) return Console.warn('Animation named "$anim" doesn\'t exist!');
        
        animation.play(anim, force);
        if(offsets.exists(anim)) {
            var daOffset:Vector2 = offsets[anim];
            offset.set(daOffset.x, daOffset.y);
        } else
            offset.set(0, 0);
    }
}