package objects;

import backend.dependency.ScriptHandler;

/**
 * A sprite with a script attached to it.
 * To access things from the sprite itself, use `this.variable`.
 * It's unlikely you need to use `this` as you can probably just do `variable`.
 * 
 * To access functions from the script use something like this:
 * 
 * (Haxe)
 * ```haxe
 * script.set("property", value);
 * ```
 * 
 * (Lua)
 * ```lua
 * script:set("property", value)
 * ```
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
        script.set("this", this);
        script.set("script", script);
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