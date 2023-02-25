package objects;

import states.PlayState;
import flixel.FlxBasic;
import flixel.math.FlxPoint;
import flixel.util.typeLimit.OneOfTwo;
import backend.dependency.ScriptHandler;
import flixel.group.FlxGroup.FlxTypedGroup;

typedef StageLayer = FlxTypedGroup<FlxBasic>;

/**
 * The class used for handling backgrounds in gameplay.
 */
class Stage extends StageLayer {
    public var firstLoad:Bool = true;

    public var curStage:String = "";
    public var script:ScriptModule;

    public var dadPos = FlxPoint.get(100, 100);
    public var gfPos = FlxPoint.get(400, 130);
    public var bfPos = FlxPoint.get(770, 100);

    public var dadLayer:StageLayer = new StageLayer();
    public var gfLayer:StageLayer = new StageLayer();
    public var bfLayer:StageLayer = new StageLayer();

    public function new(?stage:String = "stage") {
        super();
        load(stage);
    }

    public function load(?stage:String = "stage") {
        var game = PlayState.current;
        curStage = stage;

        if(script != null) {
            game.scripts.remove(script);
            script.destroy();
            for(layer in [this, dadLayer, gfLayer, bfLayer]) {
                layer.forEach((fuck:FlxBasic) -> {
                    fuck.kill();
                    fuck.destroy();
                    layer.remove(fuck, true);
                });
            }
        }

        var scriptPath:String = Paths.script('data/stages/$curStage');
        if(!FileSystem.exists(scriptPath)) {
            curStage = "stage";
            scriptPath = Paths.script('data/stages/$curStage');
        }

        script = ScriptHandler.loadModule(scriptPath);
        script.setParent(game);
        script.set("stage", this);
        script.set("stageImage", (path:String) -> {
            return Paths.image('game/stages/$curStage/$path');
        });
        script.set("add", (object:FlxBasic, ?layer:OneOfTwo<String, Int> = 0) -> {
            var val:OneOfTwo<String, Int> = layer is String ? cast(layer, String).toLowerCase() : layer;
            switch(val) {
                case 1, "dad", "opponent": dadLayer.add(object);
                case 2, "gf", "girlfriend", "speakers": gfLayer.add(object);
                case 3, "bf", "boyfriend", "foreground", "fg": bfLayer.add(object);
                default: add(object);
            }
        });
        script.set("remove", (object:FlxBasic) -> {
            for(layer in [this, dadLayer, gfLayer, bfLayer]) {
                if(layer.members.contains(object)) {
                    layer.remove(object, true);
                    break;
                } else
                    continue;
            }
        });
        if(!firstLoad) {
            script.load();
            script.call("onCreate", []);
        }        
        firstLoad = false;
        game.scripts.add(script);
        return this;
    }
}