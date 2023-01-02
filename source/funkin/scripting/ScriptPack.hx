package funkin.scripting;

import flixel.FlxBasic;
import funkin.scripting.ScriptHandler;
import funkin.scripting.events.CancellableEvent;

@:access(CancellableEvent)
class ScriptPack extends FlxBasic {
    public var scripts:Array<ScriptModule> = [];
    public var parent:Dynamic = null;

    public function load() {
        for(e in scripts)
            e.load();
    }

    public function contains(path:String) {
        for(e in scripts)
            if (e.path == path)
                return true;
        return false;
    }

    public function containsModule(module:ScriptModule) {
        return scripts.contains(module);
    }

    public function call(method:String, ?parameters:Array<Dynamic>, ?defaultReturnVal:Dynamic):Dynamic {
        var realReturnVal:Dynamic = defaultReturnVal;
        if (parameters == null) parameters = [];
        for (e in scripts) {
            var returnVal = e.call(method, parameters);
            if (returnVal != defaultReturnVal && defaultReturnVal != null) realReturnVal = returnVal;
        }
        return realReturnVal;
    }

    /**
     * Sends an event to every single script, and returns the event.
     * @param func Function to call
     * @param event Event (will be the first parameter of the function)
     * @return (modified by scripts)
     */
    public function event<T:CancellableEvent>(func:String, event:T):T {
        for(e in scripts) {
            e.call(func, [event]);
            @:privateAccess
            if (event.cancelled && !event.__continueCalls) break;
        }
        return event;
    }

    public function get(val:String):Dynamic {
        for(e in scripts) {
            var v = e.get(val);
            if (v != null) return v;
        }
        return null;
    }

    public function reload() {
        for(e in scripts) e.reload();
    }

    public function set(val:String, value:Dynamic) {
        for(e in scripts) e.set(val, value);
        return value;
    }

    public function setParent(parent:Dynamic) {
        this.parent = parent;
        for(e in scripts) e.setParent(parent);
    }

    override function destroy() {
        for(e in scripts) e.destroy();
        super.destroy();
    }

    public function add(script:ScriptModule) {
        scripts.push(script);
        __configureNewScript(script);
    }

    public function remove(script:ScriptModule) {
        scripts.remove(script);
    }

    public function insert(pos:Int, script:ScriptModule) {
        scripts.insert(pos, script);
        __configureNewScript(script);
    }

    private function __configureNewScript(script:ScriptModule) {
        if (parent != null) script.setParent(parent);
    }
}