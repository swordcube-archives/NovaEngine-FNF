package objects;

import backend.dependency.ScriptHandler;

/**
 * A sprite with a script attached to it.
 * 
 * Can be used for separating certain stage elements to prevent clutter
 * and bloat in your stages.
 */
class ModSprite extends FNFSprite {
    public var scriptName:String;
    public var script:ScriptModule;

    public function new(?x:Float = 0, ?y:Float = 0, scriptName:String, ?parameters:Array<Dynamic>) {
        super();
        if(parameters == null) parameters = [];

        script = ScriptHandler.loadModule(Paths.script('data/sprites/$scriptName'));
        script.setParent(this);
        script.load();
        script.call("new", parameters);
        script.call("onNew", parameters);
        script.call("onCreate", parameters);
    }

    override function update(elapsed:Float) {
        script.call("onUpdate", [elapsed]);
        super.update(elapsed);
        script.call("onUpdatePost", [elapsed]);
    }

    override function draw() {
        script.call("onDraw");
        super.draw();
        script.call("onDrawPost");
    }

    override function destroy() {
        script.call("onDestroy");
        script.destroy();
        super.destroy();
    }
}