package objects.ui;

import flixel.math.FlxMath;
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

    public var rawNoteData:Int = 0;
    public var noteData:Int = 0;

    public var strumTime:Float = 0;
    public var sustainLength:Float = 0;

    public var mustPress:Bool = false;
    public var isSustainNote:Bool = false;
    public var isSustainTail:Bool = false;

    public var wasGoodHit:Bool = false;
    public var canBeHit:Bool = false;
    public var tooLate:Bool = false;
    public var shouldHit:Bool = true;

    public var parentNote:Note;
    public var prevNote:Note;
    public var curSection:Int = 0;

    public var scrollSpeed(get, default):Null<Float> = null;
    private function get_scrollSpeed():Float {
        if(scrollSpeed != null)
            return scrollSpeed;

        if(strumLine != null && strumLine.members[noteData] != null && strumLine.members[noteData].scrollSpeed != null)
            return strumLine.members[noteData].scrollSpeed;

        return PlayState.current.scrollSpeed;
    }
    
    public var noteAngle:Float = 0;
    public var stepCrochet:Float = 0;

    public var strumLine:StrumLine;

    public var directionName(get, never):String;
    private function get_directionName() return extraKeyInfo[keyCount].directions[noteData];

    public static var extraKeyInfo:Map<Int, Dynamic> = [
        4 => {
            directions: ["left", "down", "up", "right"]
        }
    ];
    public static var swagWidth:Float = 160 * 0.7;

    public var initialScale:Float = 0.7;
    public var skinData:NoteSkinData;

    public function new(?x:Float = 0, ?y:Float = 0, ?skin:String = "default", ?keyCount:Int = 4, ?noteData:Int = 0) {
        super(x, y);
        this.keyCount = keyCount;
        this.noteData = noteData;

        var skinAsset:String = NovaTools.returnSkinAsset("NOTE_assets", PlayState.assetModifier, skin, "game");
        loadAtlas(Paths.getSparrowAtlas(skinAsset));
        skinData = Paths.json('images/${skinAsset}_config');
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

    public function resetAnim() {
        if(isSustainNote) {
            if(isSustainTail)
                playAnim("holdend");
            else
                playAnim("hold");
        } else
            playAnim("note");
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (mustPress) {
            if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
                && strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
                canBeHit = true;
            else
                canBeHit = false;

            if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
                tooLate = true;
        }
        else
            canBeHit = false;

        if (tooLate) alpha = 0.3;

        if(isSustainNote) {
            if(!isSustainTail) {
                scale.y = 1 * ((stepCrochet / 100) * 1.05) * scrollSpeed;

                if(skinData.isPixel) {
					scale.y *= 1.19;
					scale.y *= (6 / height);
				}
            }
            
            updateHitbox();
            centerXOffset();
        }
    }

    public function centerXOffset() {
        if (!skinData.isPixel) {
			offset.x = frameWidth * 0.5;
			offset.x -= 156 * (initialScale * 0.5);
		} else
            offset.x = (frameWidth - width) * 0.5;
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