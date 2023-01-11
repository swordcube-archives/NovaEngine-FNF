package funkin.scripting;

import funkin.scripting.ScriptHandler.ScriptModule;

/**
 * Simple class for empty scripts or scripts whose language isn't imported yet.
 */
class DummyScript extends ScriptModule {
    public var variables:Map<String, Dynamic> = [];
    
    public override function get(v:String) {return variables.get(v);}
    public override function set(v:String, v2:Dynamic) {variables.set(v, v2); return v2;}
    public override function call(method:String, ?parameters:Array<Dynamic>):Dynamic {
        var func = variables.get(method);
        if (Reflect.isFunction(func))
            return (parameters != null && parameters.length > 0) ? Reflect.callMethod(null, func, parameters) : func();

        return null;
    }
}