package objects.ui;

import core.utilities.FNFSprite.AnimationContext;
import flixel.math.FlxPoint;
import objects.TrackingSprite;
import states.PlayState;
import flixel.math.FlxMath;
import flixel.graphics.FlxGraphic;

typedef IconData = {
    @:optional var icons:Null<Int>;
    @:optional var iconHeight:Null<Int>;
    @:optional var scale:Null<Float>;
    @:optional var animations:Array<IconAnimation>;
    @:optional var positionOffset:Dynamic;
}

typedef IconAnimation = {
    var animName:String;
    var spritesheetAnim:String;
    @:optional var fps:Null<Int>;
    @:optional var loop:Null<Bool>;
    @:optional var indices:Array<Int>;
    var offsets:Dynamic;
}

/**
 * An extension of a `TrackingSprite` for health bar icons.
 */
class HealthIcon extends TrackingSprite {

    /**
     * The character used for this icon.
     */
    public var char:String = null;
    
    /**
     * The amount of icons detected.
     */
    public var iconAmount:Int = 0;

    /**
     * The initial scale of this icon.
     */
    public var initialScale:Float = 1.0;

    /**
     * The initial width of this icon.
     */
    public var initialWidth:Float = 150.0;

    /**
     * The initial height of this icon.
     */
    public var initialHeight:Float = 150.0;

    public var jsonData:IconData = {};

    public function new(?x:Float = 0, ?y:Float = 0, ?icon:String = "face") {
        super(x, y);
        loadIcon(icon);
    }

    /**
    * Loads an icon from "images/icons".
    * @param char The character's icon to load
    * @author swordcube
    */
    public function loadIcon(char:String) {
        this.char = char;
        if(!FileSystem.exists(Paths.image('game/icons/$char', true))) {
            char = "face";
            this.char = char;
        }
        loadGraphic(Paths.image('game/icons/$char')); // have to load stupidly first to get the icon size

        var jsonPath:String = Paths.json('images/game/icons/$char', true);
        try {
            if(FileSystem.exists(jsonPath))
                jsonData = Json.parse(File.getContent(jsonPath));
        } catch(e) {
            jsonData = {};
            Logs.trace("Error occured while loading health icon for character: "+char+" - "+e.details(), ERROR);
        }
        jsonData.setFieldDefault("icons", 2);
        jsonData.setFieldDefault("iconHeight", Std.int(height));
        jsonData.setFieldDefault("scale", 1.0);
        jsonData.setFieldDefault("animations", new Array<IconAnimation>());
        jsonData.setFieldDefault("positionOffset", {x: 0, y: 0});

        initialScale = jsonData.scale;
        scale.set(initialScale, initialScale);
        updateHitbox();
        
        if(jsonData.animations.length <= 0)
		    loadGraphic(Paths.image('game/icons/$char'), true, Std.int(width / jsonData.icons), jsonData.iconHeight);
        else {
            frames = Paths.getSparrowAtlas('game/icons/$char');
            for(anim in jsonData.animations) {
                anim.setFieldDefault("fps", 24);
                anim.setFieldDefault("loop", true);
                if(anim.indices != null && anim.indices.length > 0)
                    addAnimByIndices(anim.animName, anim.spritesheetAnim, anim.indices, anim.fps, anim.loop, FlxPoint.get(anim.offsets.x, anim.offsets.y));
                else
                    addAnim(anim.animName, anim.spritesheetAnim, anim.fps, anim.loop, FlxPoint.get(anim.offsets.x, anim.offsets.y));
            }
        }

        if(jsonData.animations.length <= 0) {
            iconAmount = frames.numFrames;
            var bitch = [for(i in 0...frames.numFrames) i];
            var oldBitch = [for(i in 0...frames.numFrames) i];
            if(bitch.length > 1) {
                bitch[0] = oldBitch[1];
                bitch[1] = oldBitch[0];
            }
            animation.add('icon', bitch, 0, false);
            animation.play('icon');
            if(bitch.length > 1) animation.curAnim.curFrame = 1;
        } else {
            iconAmount = jsonData.animations.length;
            var bitch = jsonData.animations;
            var oldBitch = jsonData.animations.copy();
            if(iconAmount > 1) {
                bitch[0] = oldBitch[1];
                bitch[1] = oldBitch[0];
            }
            playAnim(iconAmount > 1 ? bitch[Std.int(iconAmount * 0.5)].animName : bitch[0].animName);
        }

        initialWidth = width;
        initialHeight = height;
        
        return this;
    }

    /**
    * Gets desired icon index from specified data.
    * @param health Amount of health from 0 to 100 to use.
    * @param icons Amount of icons in our checks.
    * @return Int
    * @author Leather128
    */
    function getIconIndex(health:Float, icons:Int):Int {
        switch(icons) {
            case 1:
                return 0;
            case 2:
                if(health < 20) return 0;
                return 1;
            case 3:
                if(health < 20) return 0;
                if(health > 80) return 2;
                return 1;
            default:
                for (i in 0...icons) {
                    if (health > (100.0 / icons) * (i+1)) continue;
                    
                    // finds the first icon we are less or equal to, then choose it
                    return i;
                }
        }
        return 0;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(FlxG.state != PlayState.current) return; 

        if(jsonData.animations.length <= 0)
            animation.curAnim.curFrame = getIconIndex(health * 100, iconAmount);
        else {
            var index:Int = getIconIndex(health * 100, iconAmount);
            var animToPlay:String = jsonData.animations[index].animName;
            
            if(animation.name != animToPlay)
                playAnim(animToPlay);
        }
    }

    override function playAnim(name:String, force:Bool = false, ?context:AnimationContext = NORMAL, frame:Int = 0) {
        if(!animation.exists(name)) return Logs.trace('Animation "$name" doesn\'t exist!', WARNING);
        lastAnimContext = context;
        
        animation.play(name, force, false, frame);
        if(animOffsets.exists(name))
            rotOffset.copyFrom(animOffsets.get(name));
        else
            rotOffset.set(0, 0);

        rotOffset.subtract(jsonData.positionOffset.x, jsonData.positionOffset.y);
    }
}