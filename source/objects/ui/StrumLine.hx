package objects.ui;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import states.PlayState;
import objects.ui.Note;
import core.utilities.FNFSprite.AnimationContext;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class StrumLine extends FlxTypedSpriteGroup<Receptor> {
    public var downscroll:Bool = false;
    public var autoplay:Bool = false;

    public var skin:String = "default";
    public var keyCount:Int = 4;

    public var scrollSpeed:Null<Float> = null;

    public function new(x:Float = 0, y:Float = 0, downscroll:Bool = false, autoplay:Bool = false, skin:String = "default", keyCount:Int = 4) {
        super(x, y);

        this.downscroll = downscroll;
        this.autoplay = autoplay;
        this.keyCount = keyCount;

        generateReceptors();
    }

    public function generateReceptors() {
        forEach((receptor:Receptor) -> {
            receptor.kill();
            receptor.destroy();
            remove(receptor, true);
        });
        clear();

        for(noteData in 0...keyCount) {
            var receptor = new Receptor(Note.swagWidth * noteData, 0, skin, keyCount, noteData);
            receptor.ID = noteData;
            receptor.alpha = 0;
            FlxTween.tween(receptor, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * noteData)});
            receptor.parent = this;
            add(receptor);
        }
    }
}

class Receptor extends FNFSprite {
    public var keyCount:Int = 4;
    public var noteData:Int = 0;

    public var parent:StrumLine;

    public var scrollSpeed:Null<Float> = null;

    public var directionName(get, never):String;
    private function get_directionName() return Note.extraKeyInfo[keyCount].directions[noteData];

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
        playAnim("static");
        
        initialScale = skinData.scale;
        scale.set(initialScale, initialScale);
        updateHitbox();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(parent != null && parent.autoplay && cpuAnimTimer > 0)
            cpuAnimTimer -= elapsed;
        
        if(parent != null && parent.autoplay && animation.name == "confirm" && cpuAnimTimer <= 0)
            playAnim("static");
    }

    public var cpuAnimTimer:Float = 0;

    override function playAnim(name:String, force:Bool = false, context:AnimationContext = NORMAL, frame:Int = 0) {
        super.playAnim(name, force, context, frame);

        if(parent != null && parent.autoplay && name == "confirm")
            cpuAnimTimer = (Conductor.stepCrochet / 500) * 0.5;

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