package backend.dependency;

import flixel.graphics.FlxGraphic;

enum abstract CacheType(String) to String from String {
    var IMAGE = "IMAGE";
    var SOUND = "SOUND";
    var TEXT = "TEXT";
    var JSON = "JSON";
    var INI = "INI";
    var ANY = "ANY"; // Basically the "i don't fuckin know what this is" type
}

class CacheAsset {
    public var value:Dynamic;
    public var path:String;
    public var type:CacheType = ANY;

    public function new(value:Dynamic, path:String, ?type:CacheType = ANY) {
        this.value = value;
        this.path = path;
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

class Cache {
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