package objects.ui;

import flixel.math.FlxMath;
import backend.utilities.FNFSprite.AnimationContext;
import states.PlayState;

@:dox(hide) typedef NoteSkinAnimation = {
    var name:String;
    @:optional var spritesheetName:String; // non-pixel only
    @:optional var frames:Array<Int>; // pixel only
    @:optional var fps:Null<Int>;
    @:optional var loop:Null<Bool>;
}

@:dox(hide) typedef NoteSkinData = {
    @:optional var scale:Float;
    @:optional var isPixel:Bool;
    @:optional var antialiasing:Bool;
    @:optional var rows:Int; // pixel only
    @:optional var columns:Int; // pixel only
    @:optional var animations:Array<NoteSkinAnimation>;
}

@:dox(hide) typedef ExtraKeyData = {
    var directions:Array<String>;
    @:optional var scale:Null<Float>;
    @:optional var spacing:Null<Float>;
}

class Note extends FNFSprite {
    public var keyCount:Int = 4;

    public var rawNoteData:Int = 0;
    public var noteData:Int = 0;

    public var strumTime(get, default):Float = 0;
    private function get_strumTime():Float {
        return strumTime + SettingsAPI.noteOffset;
    }
    public var sustainLength:Float = 0;

    public var mustPress:Bool = false;
    public var isSustainNote:Bool = false;
    public var isSustainTail:Bool = false;

    public var altAnim:Bool = false;

    public var wasGoodHit:Bool = false;
    public var canBeHit:Bool = false;
    public var tooLate:Bool = false;
    public var shouldHit:Bool = true;

    public var noteType:String = "Default";

    public var parentNote:Note;
    public var sustainNotes:Array<Note> = [];
    
    public var prevNote:Note;
    public var curSection:Int = 0;

    public var offsetX:Float = 0;
    public var offsetY:Float = 0;

    public var scrollSpeed:Null<Float> = null;
    public function getScrollSpeed():Float {
        if(strumLine != null && strumLine.scrollSpeed != null)
            return strumLine.scrollSpeed;

        if(strumLine != null && strumLine.members[noteData] != null && strumLine.members[noteData].scrollSpeed != null)
            return strumLine.members[noteData].scrollSpeed;

        if(scrollSpeed != null)
            return scrollSpeed;

        return PlayState.current.scrollSpeed;
    }
    
    public var noteAngle:Float = 0;
    public var stepCrochet:Float = 0;

    public var strumLine:StrumLine;

    public var directionName(get, never):String;
    private function get_directionName() return extraKeyInfo[keyCount].directions[noteData];

    public static var extraKeyInfo:Map<Int, ExtraKeyData> = [
        4 => {
            directions: ["left", "down", "up", "right"]
        }
    ];
    public static var swagWidth:Float = 160 * 0.7;

    public var initialScale:Float = 0.7;
    public var skinData:NoteSkinData;
    public var splashSkin:String = (FlxG.state == PlayState.current && PlayState.SONG != null) ? PlayState.SONG.splashSkin : "noteSplashes";

    public function new(?x:Float = 0, ?y:Float = 0, ?skin:String = "default", ?keyCount:Int = 4, ?noteData:Int = 0, ?isSustainNote:Bool = false, ?isSustainTail:Bool = false) {
        super(x, y);
        this.keyCount = keyCount;
        this.noteData = noteData;
        this.isSustainNote = isSustainNote;
        this.isSustainTail = isSustainTail;

        var skinAsset:String = NovaTools.returnSkinAsset("NOTE_assets", PlayState.assetModifier, skin, "game");
        skinData = Paths.json('images/${skinAsset}_config');
        skinData.setFieldDefault("animations", new Array<NoteSkinAnimation>());
        skinData.setFieldDefault("scale", 0.7);
        skinData.setFieldDefault("isPixel", false);
        skinData.setFieldDefault("antialiasing", true);

        var skinImageAsset:String = NovaTools.returnSkinAsset("NOTE_assets" + (((isSustainNote || isSustainTail) && skinData.isPixel) ? "ENDS" : ""), PlayState.assetModifier, skin, "game");
        if(skinData.isPixel) {
            if(isSustainNote || isSustainTail)
                offsetX += 30; // the magic number!
            
            skinData.setFieldDefault("rows", 4);
            skinData.setFieldDefault("columns", 5);

            loadGraphic(Paths.image(skinImageAsset));
            loadGraphic(Paths.image(skinImageAsset), true, Std.int(width / skinData.rows), Std.int(height / ((isSustainNote || isSustainTail) ? 2 : skinData.columns)));
        } else
            loadAtlas(Paths.getSparrowAtlas(skinImageAsset));

        for(animation in skinData.animations) {
            animation.setFieldDefault("fps", 24);
            animation.setFieldDefault("loop", false);
            if(skinData.isPixel) {
                animation.setFieldDefault("frames", new Array<Int>());
                var adjustedFrames:Array<Int> = [];
                for(item in animation.frames) 
                    adjustedFrames.push(item + noteData);

                this.animation.add(animation.name, adjustedFrames, animation.fps, animation.loop);
            } else {
                animation.setFieldDefault("spritesheetName", "${DIRECTION}");
                this.animation.addByPrefix(animation.name, animation.spritesheetName.replace("${DIRECTION}", directionName), animation.fps, animation.loop);
            }
        }
        resetAnim();
        antialiasing = (skinData.antialiasing) ? SettingsAPI.antialiasing : false;
        
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

        if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
            && strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
            canBeHit = true;
        else
            canBeHit = false;

        if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit && !tooLate) {
            tooLate = true;
            for(note in sustainNotes) {
                note.tooLate = true;
                note.alpha = 0.3;
            }
        }

        if (tooLate) alpha = 0.3;

        if(isSustainNote) {
            if(!isSustainTail) {
                scale.y = initialScale * ((stepCrochet / 100) * 1.5) * Math.abs(getScrollSpeed());

                if(skinData.isPixel)
                    scale.y *= 0.84;
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