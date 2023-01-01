package funkin.scripting;

import funkin.scripting.ScriptHandler;
import funkin.scripting.events.CancellableEvent;

@:access(CancellableEvent)
class ScriptPack extends ScriptModule {
    public var scripts:Array<ScriptModule> = [];
    public var additionalDefaultVariables:Map<String, Dynamic> = [];
    public var publicVariables:Map<String, Dynamic> = [];
    public var parent:Dynamic = null;

    public override function load() {
        for(e in scripts) {
            e.load();
        }
    }

    public function contains(path:String) {
        for(e in scripts)
            if (e.path == path)
                return true;
        return false;
    }
    public function new(name:String) {
        additionalDefaultVariables["importScript"] = importScript;
        super(name);
    }

    public function getByPath(name:String) {
        for(s in scripts)
            if (s.path == name)
                return s;
        return null;
    }

    public function getByName(name:String) {
        for(s in scripts)
            if (s.fileName == name)
                return s;
        return null;
    }
    public function importScript(path:String):ScriptModule {
        var script = ScriptHandler.loadModule(Paths.script(path));
        if (script is DummyScript) {
            Console.error('Script at ${path} does not exist.');
            return null;
        }
        add(script);
        script.load();
        return script;
    }

    public override function call(func:String, ?parameters:Array<Dynamic>):Dynamic {
        for(e in scripts)
            e.call(func, parameters);
        return null;
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

    public override function get(val:String):Dynamic {
        for(e in scripts) {
            var v = e.get(val);
            if (v != null) return v;
        }
        return null;
    }

    public override function reload() {
        for(e in scripts) e.reload();
    }

    public override function set(val:String, value:Dynamic) {
        for(e in scripts) e.set(val, value);
        return value;
    }

    public override function setParent(parent:Dynamic) {
        this.parent = parent;
        for(e in scripts) e.setParent(parent);
    }

    public override function destroy() {
        for(e in scripts) e.destroy();
        super.destroy();
    }
    
    public override function create(path:String) {}

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
        for(k=>e in additionalDefaultVariables) script.set(k, e);
    }
}