package;

import flixel.graphics.frames.FlxAtlasFrames;
import openfl.media.Sound;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import core.utilities.IniParser;

private enum abstract CacheType(String) to String from String {
    var IMAGE = "IMAGE";
    var SOUND = "SOUND";
    var TEXT = "TEXT";
    var JSON = "JSON";
    var INI = "INI";
    var ANY = "ANY"; // Basically the "i don't fuckin know what this is" type
}

private class CacheAsset {
    public var value:Dynamic;
    public var type:CacheType = ANY;

    public function new(value:Dynamic, ?type:CacheType = ANY) {
        this.value = value;
        this.type = type;
    }

    public function destroy() {
        switch(type) {
            case IMAGE:
                var graphic:FlxGraphic = value;
                graphic.persist = false;
                graphic.destroyOnNoUse = true;
                graphic.dump();
                graphic.destroy();

            default: value = null;
        }
    }
}

private class Cache {
    private var __cache:Map<String, CacheAsset> = [];

    public function new() {}
    
    public function get(name:String) return __cache.get(name);
    public function set(name:String, value:CacheAsset) __cache.set(name, value);
    public function exists(name:String) return __cache.exists(name);
    
    public function remove(name:String) {
        __cache.get(name).destroy();
        __cache.remove(name);
    }
    public function clear() {
        for(key in __cache.keys())
            remove(key);
    }
}

class Paths {
    public static var assetCache:Cache = new Cache();

    // Functions that return data only
    public static function returnGraphic(path:String):Dynamic {
        if(!assetCache.exists(path)) {
            var bitmap = BitmapData.fromFile(path);
            var graphic = FlxGraphic.fromBitmapData(bitmap, false, path, false);
            graphic.persist = true;
            graphic.destroyOnNoUse = false;
            assetCache.set(path, new CacheAsset(graphic, IMAGE));
        }
        return assetCache.get(path).value;
    }

    public static function returnSound(path:String):Dynamic {
        if(!assetCache.exists(path))
            assetCache.set(path, new CacheAsset(Sound.fromFile(path), SOUND));
        
        return assetCache.get(path).value;
    }

    public static function returnText(path:String):Dynamic {
        if(!assetCache.exists(path))
            assetCache.set(path, new CacheAsset(File.getContent(path), TEXT));
        
        return assetCache.get(path).value;
    }

    public static function returnJSON(path:String):Dynamic {
        if(!assetCache.exists(path))
            assetCache.set(path, new CacheAsset(try {
                Json.parse(FileSystem.exists(path) ? File.getContent(path) : '{"error":null}');
            } catch(e) {
                Logs.trace("Error occured while loading JSON at path: "+path+" - "+e, ERROR);
                {error:null};
            }, JSON));
        
        return assetCache.get(path).value;
    }

    public static function returnINI(path:String):Dynamic {
        if(!assetCache.exists(path))
            assetCache.set(path, new CacheAsset(IniParser.parse(File.getContent(path)), INI));
        
        return assetCache.get(path).value;
    }

    // Functions that can return a path only when needed or data (default)
    public static function getPath(path:String) return './assets/$path';

    public static function font(path:String) return getPath('fonts/$path');

    public static function image(path:String, ?pathOnly:Bool = false):Dynamic {
        var p:String = getPath('images/$path.png');
        return pathOnly ? p : returnGraphic(p);
    }

    public static function getSparrowAtlas(path:String, ?pathOnly:Bool = false):FlxAtlasFrames {
        return FlxAtlasFrames.fromSparrow(image(path), xml('images/$path'));
    }

    public static function getPackerAtlas(path:String, ?pathOnly:Bool = false):FlxAtlasFrames {
        return FlxAtlasFrames.fromSpriteSheetPacker(image(path), txt('images/$path'));
    }

    public static function music(path:String, ?pathOnly:Bool = false):Dynamic {
        var p:String = getPath('music/$path.ogg');
        return pathOnly ? p : returnSound(p);
    }

    public static function sound(path:String, ?pathOnly:Bool = false):Dynamic {
        var p:String = getPath('sounds/$path.ogg');
        return pathOnly ? p : returnSound(p);
    }

    public static function soundRandom(path:String, min:Int, max:Int, ?pathOnly:Bool = false):Dynamic {
        return sound(path + FlxG.random.int(min, max), pathOnly);
    }

    public static function txt(path:String, ?pathOnly:Bool = false):Dynamic {
        var p:String = getPath('$path.txt');
        return pathOnly ? p : returnText(p);
    }

    public static function xml(path:String, ?pathOnly:Bool = false):Dynamic {
        var p:String = getPath('$path.xml');
        return pathOnly ? p : returnText(p);
    }

    public static function ini(path:String, ?pathOnly:Bool = false):Dynamic {
        var p:String = getPath('$path.ini');
        return pathOnly ? p : returnINI(p);
    }

    public static function json(path:String, ?pathOnly:Bool = false):Dynamic {
        var p:String = getPath('$path.json');
        return pathOnly ? p : returnJSON(p);
    }

    public static function songJson(song:String, ?diff:String = "normal", ?pathOnly:Bool = false):Dynamic {
        var songPaths:Array<String> = [
            getPath('songs/$song/$song-$diff.json'),
            getPath('data/$song/$song-$diff.json'),
            getPath('data/$song/$diff.json'),
            getPath('data/charts/$song/$diff.json'),
            getPath('data/charts/$song/$song-$diff.json'),
        ];
        for(p in songPaths) {
            if(FileSystem.exists(p))
                return pathOnly ? p : returnJSON(p);
        }
        var p:String = getPath('songs/$song/$diff.json');
        return pathOnly ? p : returnJSON(p);
    }
}