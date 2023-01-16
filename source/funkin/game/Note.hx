package funkin.game;

import funkin.system.Conductor;
import haxe.xml.Access;
import flixel.math.FlxPoint;
import funkin.system.FNFSprite;

using StringTools;

@:dox(hide) typedef NoteSkin = {
    var scale:Float;
    var isPixel:Bool;
    var texture:SpritesheetData;
    var animations:Array<NoteAnim>;
}

@:dox(hide) typedef SplashSkin = {
    var scale:Float;
    var alpha:Float;
    var texture:SpritesheetData;
    var animations:Array<SplashAnim>;
}

@:dox(hide) typedef SpritesheetData = {
    var name:String;
    var type:SpriteType;
}

@:dox(hide) typedef NoteAnim = {
    var name:String;
    var spritesheetName:String;
    var indices:Array<Int>;
    var offsets:FlxPoint;
    var fps:Int;
    var loop:Bool;
}

@:dox(hide) typedef SplashAnim = {
    var name:String;
    var spritesheetName:String;
    var indices:Array<Int>;
    var offsets:FlxPoint;
    var fps:Int;
}

@:dox(hide) typedef EKInfo = {
    var directions:Array<String>;
    var ?scaleMult:Float;
    var ?spacingMult:Float;
}

class Note extends FNFSprite {
    public static final swagWidth:Float = 160 * 0.7;

    public static var extraKeyInfo:Map<String, EKInfo> = [
        "1K" => {
            directions: ["middle"]
        },
        "2K" => {
            directions: ["left", "right"]
        },
        "3K" => {
            directions: ["left", "middle", "right"]
        },
        "4K" => {
            directions: ["left", "down", "up", "right"]
        },
    ];
    public static var noteSkins:Map<String, NoteSkin> = [];
    public static var splashSkins:Map<String, SplashSkin> = [];

    public static function reloadSkins() {
        #if sys
        noteSkins = [];
        for(item in Paths.getFolderContents("data/noteskins")) {
            var path = Paths.getAsset('data/noteskins/$item');
            if(Paths.isDirectory(path)) continue;

            var skinName:String = item.removeExtension();

            if(!Paths.exists(path)) {
                Console.error('Occured while loading note skin: $skinName | The XML doesn\'t exist!');
                continue;
            }

            var xml:Xml = Xml.parse(Assets.getText(path)).firstElement();
            if(xml == null) {
                Console.error('Occured while loading note skin: $skinName | Either the XML doesn\'t exist or the "noteskin" node is missing!');
                continue;
            }

            try {
                var data:Access = new Access(xml);
    
                var scale:Float = data.has.scale ? Std.parseFloat(data.att.scale) : 0.7;
                var isPixel:Bool = data.has.isPixel ? data.att.isPixel == "true" : false;

                var noteTexturesNode:Access = data.node.noteTextures;
                var noteTextures:SpritesheetData = {
                    name: noteTexturesNode.has.name ? noteTexturesNode.att.name : "NOTE_assets",
                    type: noteTexturesNode.has.type ? noteTexturesNode.att.type : SPARROW
                };

                var animArray:Array<NoteAnim> = [];
                var animations:Access = data.node.anims; // <- This is done to make the code look cleaner (aka instead of data.node.animations.nodes.animation)

                for (anim in animations.nodes.anim) {
                    animArray.push({
                        name: anim.att.name,
                        spritesheetName: anim.att.anim,
                        indices: anim.has.indices ? CoolUtil.splitInt(anim.att.indices, ",") : [],
                        fps: anim.has.fps ? Std.parseInt(anim.att.fps) : 24,
                        loop: anim.has.loop ? anim.att.loop == "true" : false,
                        offsets: FlxPoint.get(anim.has.x ? Std.parseFloat(anim.att.x) : 0.0, anim.has.y ? Std.parseFloat(anim.att.y) : 0.0)
                    });
                }

                noteSkins[skinName] = {
                    scale: scale,
                    isPixel: isPixel,
                    texture: noteTextures,
                    animations: animArray
                };
                Console.debug('Loaded note skin: $skinName successfully');
            } catch(e) {
                Console.error('Failed to load a note skin: $skinName - ${e.details()}');
            }
        }
        #else
        // dumbass html5 hardcoding but i don't know how to read
        // directories in html5
        noteSkins = [
            "Default" => {
                scale: 0.7,
                isPixel: false,
                texture: {name: "NOTE_assets", type: SPARROW},
                animations: [
                    {
                        name: "static",
                        spritesheetName: "${DIRECTION} static",
                        indices: [],
                        offsets: FlxPoint.get(0, 0),
                        fps: 24,
                        loop: false
                    },
                    {
                        name: "pressed",
                        spritesheetName: "${DIRECTION} pressed",
                        indices: [],
                        offsets: FlxPoint.get(0, 0),
                        fps: 24,
                        loop: false
                    },
                    {
                        name: "confirm",
                        spritesheetName: "${DIRECTION} confirm",
                        indices: [],
                        offsets: FlxPoint.get(0, 0),
                        fps: 24,
                        loop: false
                    },

                    {
                        name: "note",
                        spritesheetName: "${DIRECTION}",
                        indices: [],
                        offsets: FlxPoint.get(0, 0),
                        fps: 24,
                        loop: false
                    },
                    {
                        name: "sustain",
                        spritesheetName: "${DIRECTION} hold piece",
                        indices: [],
                        offsets: FlxPoint.get(0, 0),
                        fps: 24,
                        loop: false
                    },
                    {
                        name: "sustainEnd",
                        spritesheetName: "${DIRECTION} hold end",
                        indices: [],
                        offsets: FlxPoint.get(0, 0),
                        fps: 24,
                        loop: false
                    }
                ]
            }
        ];
        #end
    }

    public static function reloadSplashSkins() {
        #if sys
        splashSkins = [];
        for(item in Paths.getFolderContents("data/splashes")) {
            var path = Paths.getAsset('data/splashes/$item');
            if(Paths.isDirectory(path)) continue;

            var skinName:String = item.removeExtension();

            if(!Paths.exists(path)) {
                Console.error('Occured while loading note splash skin: $skinName | The XML doesn\'t exist!');
                continue;
            }

            var xml:Xml = Xml.parse(Assets.getText(path)).firstElement();
            if(xml == null) {
                Console.error('Occured while loading note splash skin: $skinName | Either the XML doesn\'t exist or the "splashskin" node is missing!');
                continue;
            }

            try {
                var data:Access = new Access(xml);
    
                var scale:Float = data.has.scale ? Std.parseFloat(data.att.scale) : 0.7;
                var alpha:Float = data.has.alpha ? Std.parseFloat(data.att.alpha) : 0.6;

                var textureNode:Access = data.node.texture;
                var texture:SpritesheetData = {
                    name: textureNode.has.name ? textureNode.att.name : "NOTE_splashes",
                    type: textureNode.has.type ? textureNode.att.type : SPARROW
                };

                var animArray:Array<SplashAnim> = [];
                var animations:Access = data.node.anims; // <- This is done to make the code look cleaner (aka instead of data.node.animations.nodes.animation)

                for (anim in animations.nodes.anim) {
                    animArray.push({
                        name: anim.att.name,
                        spritesheetName: anim.att.anim,
                        indices: anim.has.indices ? CoolUtil.splitInt(anim.att.indices, ",") : [],
                        fps: anim.has.fps ? Std.parseInt(anim.att.fps) : 24,
                        offsets: FlxPoint.get(anim.has.x ? Std.parseFloat(anim.att.x) : 0.0, anim.has.y ? Std.parseFloat(anim.att.y) : 0.0)
                    });
                }

                splashSkins[skinName] = {
                    scale: scale,
                    alpha: alpha,
                    texture: texture,
                    animations: animArray
                };
                Console.debug('Loaded note splash skin: $skinName successfully');
            } catch(e) {
                Console.error('Failed to load a note splash skin: $skinName - ${e.details()}');
            }
        }
        #else
        // dumbass html5 hardcoding but i don't know how to read
        // directories in html5
        splashSkins = [
            "Default" => {
                scale: 0.7,
                alpha: 0.6,
                texture: {name: "NOTE_splashes", type: SPARROW},
                animations: [
                    {
                        name: "splash1",
                        spritesheetName: "splash ${DIRECTION} 1",
                        indices: [],
                        offsets: FlxPoint.get(-80, -80),
                        fps: 24
                    },
                    {
                        name: "splash2",
                        spritesheetName: "splash ${DIRECTION} 2",
                        indices: [],
                        offsets: FlxPoint.get(-80, -80),
                        fps: 24
                    }
                ]
            }
        ];
        #end
    }

    public static function getSingAnim(keyAmount:Int = 4, noteData:Int = 0) {
		var dir:String = Note.extraKeyInfo[keyAmount+"K"].directions[noteData].toUpperCase();
		switch (dir) {
			case "MIDDLE":
				dir = "UP";
		}
		return "sing" + dir;
	}
    
    // -------------------------------------------------------------------------------------------- //

    /**
     * The position of this note in the song.
     */
    public var strumTime(get, default):Float = 0;
    function get_strumTime():Float {
        return strumTime + (OptionsAPI.get("Note Offset") * FlxG.sound.music.pitch);
    }

    /**
     * The direction of the note.
     */
    public var noteData:Int = 0;

    /**
     * The name version of `noteData`.
     */
    public var directionName(get, never):String;
    function get_directionName():String {
        return Note.extraKeyInfo[keyAmount+"K"].directions[noteData];
    }

    public var keyAmount:Int = 4;

    /**
     * Whether or not this note must be held down.
     */
    public var isSustainNote:Bool = false;

    /**
     * Whether or not this note is the tip of a sustain.
     */
    public var isSustainTail:Bool = false;

    /**
     * Whether or not this note is a player note.
     */
    public var mustPress:Bool = false;

    /**
     * Whether this note should play an alt animation.
     */
    public var altAnim:Bool = false;

    /**
     * The original scale of this note when it was loaded.
     */
    public var initialScale:Float = 0.7;

    /**
     * The note type.
     */
    public var noteType:String = "Default";

    /**
     * Whether or not you should hit this note.
     * Useful for note types such as mines.
     */
    public var shouldHit:Bool = true;

    /**
     * Whether or not this note can be hit.
     */
    public var canBeHit:Bool = false;

    /**
     * Whether or not this note was already hit.
     */
    public var wasGoodHit:Bool = false;

    public var tooLate:Bool = false;

    public var prevNote:Note;

    public var strumLine:StrumLine;
    public var scrollSpeed:Null<Float>;
    public var stepCrochet:Float = 0;

    public var row:Int = 0;

    /**
     * The skin this note has loaded.
     */
    public var skin(default, set):String;
    function set_skin(value:String):String {
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
        playCorrectAnim();

        return value;
    }

    /**
     * The skin used for the note splash that occurs when hitting a "SiCK!!" on this note.
     */
    public var splashSkin:String = "Default";

    public function playCorrectAnim() {
        if(isSustainNote)
            playAnim(isSustainTail ? "sustainEnd" : "sustain");
        else
            playAnim("note");
    }

    public function new(?x:Float = 0, ?y:Float = 0, ?keyAmount:Int = 4, ?noteData:Int = 0, ?skin:String = "Default") {
        super(x, y);
        this.keyAmount = keyAmount;
        this.noteData = noteData;
        this.skin = skin;
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
            if(!isSustainTail)
                scale.y = initialScale * ((stepCrochet / 100 * 1.5) * strumLine.getScrollSpeed(this));

            updateHitbox();
            centerXOffset();
        }
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

    public function centerXOffset() {
        var data:NoteSkin = Note.noteSkins[skin];
        if(data == null) data = Note.noteSkins["Default"];

        if(!data.isPixel) {
            offset.x = frameWidth * 0.5;
            offset.x -= 156 * (initialScale * 0.5);
        } else offset.x = (frameWidth - width) * 0.5;
    }
}