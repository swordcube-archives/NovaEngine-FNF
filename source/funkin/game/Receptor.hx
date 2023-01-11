package funkin.game;

import funkin.game.Note.NoteSkin;
import funkin.system.FNFSprite;

using StringTools;

class Receptor extends FNFSprite {
    /**
     * The original scale of this receptor when it was loaded.
     */
    public var initialScale:Float = 0.7;

    /**
     * The skin this receptor has loaded.
     */
    public var skin(default, set):String;

    public var scrollSpeed:Null<Float>;

    function set_skin(value:String) {
        skin = value;

        var data:NoteSkin = Note.noteSkins[skin];
        if(data == null) data = Note.noteSkins["Default"];

        var funnyPath:String = 'game/notes/${data.texture.name}';
        frames = data.texture.type == PACKER ? Paths.getPackerAtlas(funnyPath) : Paths.getSparrowAtlas(funnyPath);
        for(anim in data.animations) {
            var directionShit:Array<String> = [
                "$DIRECTION",
                "${DIRECTION}"
            ];
            var spriteShitName:String = anim.spritesheetName;
            for(d in directionShit)
                spriteShitName = spriteShitName.replace(d, Note.extraKeyInfo[keyAmount+"K"].directions[noteData]);
            
            if(anim.indices != null && anim.indices.length > 0)
                addAnimByIndices(anim.name, spriteShitName+"0", anim.indices, anim.fps, anim.loop, anim.offsets);
            else
                addAnim(anim.name, spriteShitName+"0", anim.fps, anim.loop, anim.offsets);
        }
        initialScale = data.scale;
        scale.set(data.scale, data.scale);
        updateHitbox();
        playAnim("static");

        return value;
    }

    public var keyAmount:Int = 4;
    public var noteData:Int = 0;

    public function new(?x:Float = 0, ?y:Float = 0, ?keyAmount:Int = 4, ?noteData:Int = 0, ?skin:String = "Default") {
        super(x, y);
        this.keyAmount = keyAmount;
        this.noteData = noteData;
        this.skin = skin;
    }

    override function playAnim(name:String, force:Bool = false, ?context:AnimationContext = NORMAL, reversed:Bool = false, frame:Int = 0) {
        if(!animation.exists(name)) return Console.warn('Animation "$name" doesn\'t exist!');
        lastAnimContext = context;
        animation.play(name, force, reversed, frame);
        centerOffsets();
        centerOrigin(); // sonic origins reference?!?!!?
        if(offsets.exists(name))
            offset.add(offsets[name].x, offsets[name].y);
    }
}