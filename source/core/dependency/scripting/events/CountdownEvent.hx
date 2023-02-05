package core.dependency.scripting.events;

import flixel.graphics.FlxGraphic;
import openfl.media.Sound;

class CountdownEvent extends CancellableEvent {
    /**
     * The image/graphic the sprite should load.
     */
    public var image:FlxGraphic;

    /**
     * The sound that should play.
     */
    public var sound:Sound;

    /**
     * The scale of the sprite.
     */
    public var scale:Float;

    /**
     * The sprite for this part of the countdown (ready set go)
     * ⚠ WARNING: Can be `null`!
     */
    public var sprite:FlxSprite;

    public var swagCounter:Int;
    public var altCounter:Int;

    public function new(image:FlxGraphic, sound:Sound, scale:Float, swagCounter:Int, altCounter:Int) {
        super();
        this.image = image;
        this.sound = sound;
        this.scale = scale;
        this.swagCounter = swagCounter;
        this.altCounter = altCounter;
    }
}