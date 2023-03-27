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

    /**
     * The name of the currently loaded stage.
     */
    public var curStage:String = "";

    /**
     * The stage's script.
     */
    public var script:ScriptModule;

    /**
     * The X and Y position of the opponent on the stage.
     */
    public var dadPos = FlxPoint.get(100, 100);

    /**
     * The X and Y position of the spectator on the stage.
     */
    public var gfPos = FlxPoint.get(400, 130);

    /**
     * The X and Y position of the player on the stage.
     */
    public var bfPos = FlxPoint.get(770, 100);

    public var dadLayer:StageLayer = new StageLayer();
    public var gfLayer:StageLayer = new StageLayer();
    public var bfLayer:StageLayer = new StageLayer();

    public var globalSprites:Map<String, FlxBasic> = [];

    public function new(?stage:String = "stage") {
        super();
        load(stage);
    }

    public function getSprite(name:String) {
        var sprite = globalSprites.get(name);
        if(!globalSprites.exists(name) || sprite == null)
            Logs.trace('Sprite called "$name" doesn\'t exist in the current stage!', ERROR);
        
        return sprite;
    }

    /**
     * Unloads the current stage and loads a new one.
     * @param stage The stage you want to load.
     */
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

		// stage image types
		
        script.set("stageImage", (path:String, ?pathOnly:Bool = false, ?mod:Null<String>) -> {
            return Paths.image('game/stages/$curStage/$path', pathOnly, mod);
        });
		script.set("stageSparrow", (path:String, ?mod:Null<String>) -> {
			return Paths.getSparrowAtlas('game/stages/$curStage/$path', mod);
		});
		script.set("stagePacker", (path:String, ?mod:Null<String>) -> {
			return Paths.getPackerAtlas('game/stages/$curStage/$path', mod);
		});

        script.set("add", addObject);

        // basically a duplicate of add
        // EXCEPT anything added thru this function
        // can be accessed in scripts that aren't stage scripts
        script.set("addGlobally", (name:String, object:FlxBasic, ?layer:OneOfTwo<String, Int> = 0) -> {
            addObject(object, layer);
            globalSprites.set(name, object);
        });

        script.set("remove", (object:FlxBasic) -> {
            for(layer in [this, dadLayer, gfLayer, bfLayer]) {
                if(layer.members.contains(object)) {
                    layer.remove(object, true);
                    break;
                } else
                    continue;
            }

            for(key => sprite in globalSprites) {
                if(sprite == object)
                    globalSprites.remove(key);
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

    function addObject(object:FlxBasic, ?layer:OneOfTwo<String, Int> = 0) {
        var val:OneOfTwo<String, Int> = layer is String ? cast(layer, String).toLowerCase() : layer;
        switch(val) {
            case 1, "dad", "opponent": dadLayer.add(object);
            case 2, "gf", "girlfriend", "speakers": gfLayer.add(object);
            case 3, "bf", "boyfriend", "foreground", "fg": bfLayer.add(object);
            default: add(object);
        }
    }
}