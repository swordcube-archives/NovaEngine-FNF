package backend.utilities;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.math.FlxPoint;

enum abstract AtlasType(String) to String from String {
    var SPARROW = "SPARROW";
    var PACKER = "PACKER";
}

enum abstract AnimationContext(String) to String from String {
    var NORMAL = "NORMAL";
    var SING = "SING";
}

class FNFSprite extends FlxSprite {
    public var lastAnimContext:AnimationContext = NORMAL;
    public var animOffsets:Map<String, FlxPoint> = [];

    public function addOffset(name:String, ?x:Float = 0, ?y:Float = 0, ?adjustToScale:Bool = false) {
        animOffsets.set(name, FlxPoint.get(x / (adjustToScale ? scale.x : 1), y / (adjustToScale ? scale.y : 1)));
    }

    public function addAnim(name:String, prefix:String, ?fps:Int = 24, ?loop:Bool = false, ?offsets:FlxPoint) {
        if(offsets == null) offsets = FlxPoint.get(0, 0);
        animation.addByPrefix(name, prefix, fps, loop);
        addOffset(name, offsets.x, offsets.y);
    }

    public function addAnimByIndices(name:String, prefix:String, indices:Array<Int>, ?fps:Int = 24, ?loop:Bool = false, ?offsets:FlxPoint) {
        if(offsets == null) offsets = FlxPoint.get(0, 0);
        animation.addByIndices(name, prefix, indices, "", fps, loop);
        addOffset(name, offsets.x, offsets.y);
    }

    public function playAnim(name:String, force:Bool = false, context:AnimationContext = NORMAL, frame:Int = 0) {
        animation.play(name, force, false, frame);
        lastAnimContext = context;
        if(animOffsets.exists(name)) {
            var daOffset:FlxPoint = animOffsets.get(name);
            offset.set(daOffset.x, daOffset.y);
        } else
            offset.set(0, 0);
    }

	override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String) {
        super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
        return this;
    }

    override public function makeGraphic(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String) {
        super.makeGraphic(Width, Height, Color, Unique, Key);
        return this;
    }

    public function loadAtlas(Data:FlxAtlasFrames) {
        frames = Data;
        return this;
    }
}