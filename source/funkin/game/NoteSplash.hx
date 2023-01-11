package funkin.game;

import funkin.system.FNFSprite;

using StringTools;

class NoteSplash extends FNFSprite {
    public function setup(x:Float, y:Float, skinName:String, keyAmount:Int, noteData:Int) {
        setPosition(x, y);
        var data = Note.splashSkins[skinName];
        if(data == null) data = Note.splashSkins["Default"];

        var path:String = 'game/splashes/${data.texture.name}';
        frames = data.texture.type == PACKER ? Paths.getPackerAtlas(path) : Paths.getSparrowAtlas(path);

        for(anim in data.animations) {
            var directionShit:Array<String> = [
                "$DIRECTION",
                "${DIRECTION}"
            ];
            var spriteShitName:String = anim.spritesheetName;
            for(d in directionShit)
                spriteShitName = spriteShitName.replace(d, Note.extraKeyInfo[keyAmount+"K"].directions[noteData]);

            addAnim(anim.name, spriteShitName+"0", anim.fps, false, anim.offsets);
        }

        animation.finishCallback = function(name:String) {
            kill();
        };

        scale.set(data.scale, data.scale);
        updateHitbox();

        alpha = data.alpha;
        playAnim("splash"+FlxG.random.int(1,2), true);
    }
}