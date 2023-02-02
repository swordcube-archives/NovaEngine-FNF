package objects;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxColor;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.math.FlxPoint;
import flixel.FlxObject;

/**
 * Enum to store the mode (or direction) that a tracking sprite tracks.
 */
enum abstract TrackingMode(Int) to Int from Int {
    var RIGHT = 0;
    var LEFT = 1;
    var UP = 2;
    var DOWN = 3;
}

/**
 * A sprite that tracks another sprite with customizable offsets.
 * @author Leather128
 */
 class TrackingSprite extends FNFSprite {
    /**
     * The offest in X and Y to the tracked object.
     */
    public var trackingOffset:FlxPoint = new FlxPoint(10, -30);

    /**
     * The object / sprite we are tracking.
     */
    public var tracked:FlxObject;

    /**
     * Tracking mode (or direction) of this sprite.
     */
    public var trackingMode:TrackingMode = RIGHT;

    override function update(elapsed:Float):Void {
        // tracking modes
        if (tracked != null) {
            switch (trackingMode) {
                case RIGHT: setPosition(tracked.x + tracked.width + trackingOffset.x, tracked.y + trackingOffset.y);
                case LEFT: setPosition(tracked.x + trackingOffset.x, tracked.y + trackingOffset.y);
                case UP: setPosition(tracked.x + (tracked.width * 0.5) + trackingOffset.x, tracked.y - height + trackingOffset.y);
                case DOWN: setPosition(tracked.x + (tracked.width * 0.5) + trackingOffset.x, tracked.y + tracked.height + trackingOffset.y);
            }
        }

        super.update(elapsed);
    }

    override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false, ?Key:String) {
        super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
        return this;
    }

    override public function makeGraphic(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String) {
        super.makeGraphic(Width, Height, Color, Unique, Key);
        return this;
    }

    override public function loadAtlas(Data:FlxAtlasFrames) {
        frames = Data;
        return this;
    }
}