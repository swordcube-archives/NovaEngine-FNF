package funkin.game;

import haxe.xml.Access;
import flixel.math.FlxPoint;
import funkin.system.FNFSprite;

typedef NoteSkin = {
    var scale:Float;
    var noteTextures:SpritesheetData;
    var splashTextures:SpritesheetData;
    var animations:Array<NoteAnim>;
}

typedef SpritesheetData = {
    var name:String;
    var type:SpriteType;
}

typedef NoteAnim = {
    var name:String;
    var spritesheetName:String;
    var indices:Array<Int>;
    var offsets:FlxPoint;
    var fps:Int;
    var loop:Bool;
}

typedef EKInfo = {
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

    public static function reloadSkins() {
        noteSkins = [];
        for(item in Paths.getFolderContents("data/noteskins")) {
            var path = Paths.getAsset('data/noteskins/$item');
            if(Paths.isDirectory(path)) continue;

            var skinName:String = item.removeExtension();

            var xml:Xml = Xml.parse(Assets.getText(path)).firstElement();
            if(xml == null) {
                Console.error('Occured while loading note skin: $skinName | Either the XML doesn\'t exist or the "noteskin" node is missing!');
                continue;
            }

            try {
                var data:Access = new Access(xml);
    
                var scale:Float = data.has.scale ? Std.parseFloat(data.att.scale) : 0.7;

                var noteTexturesNode:Access = data.node.noteTextures;
                var noteTextures:SpritesheetData = {
                    name: noteTexturesNode.has.name ? noteTexturesNode.att.name : "NOTE_assets",
                    type: noteTexturesNode.has.type ? noteTexturesNode.att.type : SPARROW
                };

                var splashTexturesNode:Access = data.node.splashTextures;
                var splashTextures:SpritesheetData = {
                    name: splashTexturesNode.has.name ? splashTexturesNode.att.name : "NOTE_splashes",
                    type: splashTexturesNode.has.type ? splashTexturesNode.att.type : SPARROW
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
                    noteTextures: noteTextures,
                    splashTextures: splashTextures,
                    animations: animArray
                };
                Console.debug('Loaded note skin: $skinName successfully');
            } catch(e) {
                Console.error('Failed to load a note skin: $skinName - ${e.details()}');
            }
        }
    }
    
    // -------------------------------------------------------------------------------------------- //

    public var strumTime:Float = 0;
    public var noteData:Int = 0;
    public var isSustainNote:Bool = false;

    public var strumLine:StrumLine;
    public var scrollSpeed(get, default):Null<Float>;
    function get_scrollSpeed() {
        if(scrollSpeed != PlayState.current.scrollSpeed && scrollSpeed != null)
            return scrollSpeed;

        return PlayState.current.scrollSpeed;
    }
}