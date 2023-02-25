package objects.ui;

import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import backend.utilities.FNFSprite.AnimationContext;
import states.PlayState;

typedef NoteSplashAnimation = {
    var spritesheetName:String;
    @:optional var fps:Null<Int>;
    @:optional var offset:Dynamic;
}

typedef NoteSplashSkinData = {
    @:optional var scale:Float;
    @:optional var alpha:Float;
    @:optional var positionOffset:Dynamic;
    var animations:Array<NoteSplashAnimation>;
} 

class NoteSplash extends FNFSprite {
    public var keyCount:Int = 4;
    public var noteData:Int = 0;

    public var directionName(get, never):String;
    private function get_directionName() return Note.extraKeyInfo[keyCount].directions[noteData];

    public var skinData:NoteSplashSkinData;
    public var initialScale:Float = 0.7;

    public function new(?x:Float = 0, ?y:Float = 0, ?skin:String = "noteSplashes", ?keyCount:Int = 4, ?noteData:Int = 0) {
        super(x, y);
        setup(x, y, skin, keyCount, noteData);
    }

    public function setup(?x:Float = 0, ?y:Float = 0, ?skin:String = "noteSplashes", ?keyCount:Int = 4, ?noteData:Int = 0) {
        this.keyCount = keyCount;
        this.noteData = noteData;

        var skinAsset:String = NovaTools.returnSkinAsset('noteSplashes/$skin', PlayState.assetModifier, PlayState.changeableSkin, "game");
        loadAtlas(Paths.getSparrowAtlas(skinAsset));
        skinData = Paths.json('images/${skinAsset}_config');
        skinData.setFieldDefault("scale", 1);
        skinData.setFieldDefault("alpha", 0.6);
        skinData.setFieldDefault("positionOffset", {x: 0, y: 0});

        for(i => animation in skinData.animations) {
            animation.setFieldDefault("fps", 24);
            animation.setFieldDefault("offset", {x: 0, y: 0});
            this.addAnim("splash" + (i + 1), animation.spritesheetName.replace("${DIRECTION}", directionName), animation.fps, false, FlxPoint.get(animation.offset.x, animation.offset.y));
        }
        playAnim("splash" + FlxG.random.int(1, skinData.animations.length));
        
        initialScale = skinData.scale;
        scale.set(initialScale, initialScale);
        updateHitbox();

        alpha = skinData.alpha;

        setPosition(x + skinData.positionOffset.x, y + skinData.positionOffset.y);
    }
}