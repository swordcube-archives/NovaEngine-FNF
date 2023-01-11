package funkin.game;

import flixel.FlxBasic;
import flixel.math.FlxPoint;
import flixel.util.typeLimit.OneOfTwo;
import funkin.scripting.ScriptHandler;
import flixel.group.FlxGroup.FlxTypedGroup;

typedef StageLayer = FlxTypedGroup<FlxBasic>;

/**
 * The class used for handling backgrounds in gameplay.
 */
class Stage extends StageLayer {
    public var firstLoad:Bool = true;

    public var name:String = "";
    public var script:ScriptModule;

    public var dadPos = FlxPoint.get(100, 100);
    public var gfPos = FlxPoint.get(400, 130);
    public var bfPos = FlxPoint.get(770, 100);

    public var dadLayer:StageLayer = new StageLayer();
    public var gfLayer:StageLayer = new StageLayer();
    public var bfLayer:StageLayer = new StageLayer();

    public function new(?stage:String = "default") {
        super();
        load(stage);
    }

    public function load(?stage:String = "default") {
        var game = PlayState.current;

        name = stage;

        if(script != null) {
            game.scripts.remove(script);
            script.destroy();
            for(layer in [this, dadLayer, gfLayer, bfLayer]) {
                layer.forEach(function(fuck:FlxBasic) {
                    fuck.kill();
                    fuck.destroy();
                    layer.remove(fuck, true);
                });
            }
        }

        script = ScriptHandler.loadModule(Paths.script('data/stages/$name'));
        script.setParent(PlayState.current);
        script.set("stage", this);
        script.set("stageImage", function(path:String) {
            return Paths.image('stages/$name/$path');
        });
        script.set("add", function(object:Dynamic, ?layer:OneOfTwo<String, Int> = 0) {
            var val:OneOfTwo<String, Int> = layer is String ? cast(layer, String).toLowerCase() : layer;
            switch(val) {
                case 1, "dad", "opponent": dadLayer.add(object);
                case 2, "gf", "girlfriend", "speakers": gfLayer.add(object);
                case 3, "bf", "boyfriend", "foreground", "fg": bfLayer.add(object);
                default: add(object);
            }
        });
        script.set("remove", function(object:Dynamic) {
            for(layer in [this, dadLayer, gfLayer, bfLayer]) {
                if(layer.members.contains(object)) {
                    layer.remove(object, true);
                    break;
                } else
                    continue;
            }
        });
        script.load();
        if(!firstLoad)
            script.call("onCreate");
        firstLoad = false;
        game.scripts.add(script);
        return this;
    }
}