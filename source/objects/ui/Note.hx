package objects.ui;

import core.utilities.FNFSprite.AnimationContext;
import states.PlayState;

typedef NoteSkinAnimation = {
    var name:String;
    var spritesheetName:String;
    @:optional var fps:Null<Int>;
    @:optional var loop:Null<Bool>;
}

typedef NoteSkinData = {
    @:optional var scale:Float;
    @:optional var isPixel:Bool;
    var animations:Array<NoteSkinAnimation>;
}

typedef ExtraKeyData = {
    var directions:Array<String>;
    @:optional var scale:Null<Float>;
    @:optional var spacing:Null<Float>;
}

class Note extends FNFSprite {
    public var keyCount:Int = 4;
    public var noteData:Int = 0;

    public var directionName(get, never):String;
    private function get_directionName() return extraKeyInfo[keyCount].directions[noteData];

    public static var extraKeyInfo:Map<Int, Dynamic> = [
        4 => {
            directions: ["left", "down", "up", "right"]
        }
    ];

    public var initialScale:Float = 0.7;
    public var skinData:NoteSkinData;

    public function new(?x:Float = 0, ?y:Float = 0, ?skin:String = "default", ?keyCount:Int = 4, ?noteData:Int = 0) {
        super(x, y);
        this.keyCount = keyCount;
        this.noteData = noteData;

        var skinAsset:String = NovaTools.returnSkinAsset("NOTE_assets", PlayState.assetModifier, skin, "game");
        loadAtlas(Paths.getSparrowAtlas(skinAsset));
        skinData = Paths.json('images/$skinAsset');
        skinData.setFieldDefault("scale", 0.7);
        skinData.setFieldDefault("isPixel", false);

        for(animation in skinData.animations) {
            animation.setFieldDefault("fps", 24);
            animation.setFieldDefault("loop", false);
            this.animation.addByPrefix(animation.name, animation.spritesheetName.replace("${DIRECTION}", directionName), animation.fps, animation.loop);
        }
        playAnim("note");
        
        initialScale = skinData.scale;
        scale.set(initialScale, initialScale);
        updateHitbox();
    }

    override function playAnim(name:String, force:Bool = false, context:AnimationContext = NORMAL, frame:Int = 0) {
        super.playAnim(name, force, context, frame);

        centerOrigin();
        if (!skinData.isPixel) {
			offset.x = frameWidth * 0.5;
			offset.y = frameHeight * 0.5;

			offset.x -= 156 * (initialScale * 0.5);
			offset.y -= 156 * (initialScale * 0.5);
		} else
            centerOffsets();
    }
}