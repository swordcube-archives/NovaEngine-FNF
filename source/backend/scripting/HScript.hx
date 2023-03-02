package backend.scripting;

import backend.dependency.ScriptHandler;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;

/**
 * The class used for handling HScript functionality.
 */
class HScript extends ScriptModule {
    public var interp:Interp;
    public var expr:Expr;

    private function __errorHandler(error:Error) {
        #if !doc_gen
        var fn = '$fileName:${error.line}: ';
        var err = error.toString();
        if (err.startsWith(fn)) err = err.substr(fn.length);

        Logs.trace('Error occured on script: $fileName at Line ${error.line} - $err', ERROR);
        #end
    }

    public function new(path:String, fileName:String = "hscript") {
        super(path, fileName);

        #if !doc_gen
        var parser:Parser = new Parser();
        parser.allowJSON = parser.allowTypes = parser.allowMetadata = true;
        parser.preprocesorValues = ScriptHandler.compilerFlags;

        try {
            if(!FileSystem.exists(path))
                throw 'Script doesn\'t exist at path: $path';
            
            expr = parser.parseString(File.getContent(path));
        } 
        catch(e) {
            expr = null;
            Logs.trace('Error occured while loading script at path: $path - $e', ERROR);
        }
        
        interp = new Interp();
        interp.errorHandler = __errorHandler;

        interp.variables.set("trace", Reflect.makeVarArgs((args) -> {
            var v:String = Std.string(args.shift());
            for (a in args) v += ", " + Std.string(a);
            this.trace(v);
        }));

        for(name => value in ScriptHandler.preset)
            interp.variables.set(name, value);
        #end
    }

    /**
     * Runs the script.
     */
    override public function load() {
        // If the script failed to load, just treat it as a dummy script!
        if(expr == null) return;
        interp.execute(expr);
    }

    /**
     * Gets a variable from this script and returns it.
     * @param val The name of the variable to get.
     */
    override public function get(val:String):Dynamic {
        if(interp == null) return null;
        return interp.variables.get(val);
    }

    /**
     * Sets a variable from this script.
     * @param val The name of the variable to set.
     * @param value The value to set the variable to.
     */
     override public function set(val:String, value:Dynamic) {
        if(interp == null) return;
        interp.variables.set(val, value);
    }

    /**
     * Calls a function from this script and returns whatever the function returns (Can be `null`!).
     * @param funcName The name of the function to call.
     * @param parameters The parameters/arguments to give the function when calling it.
     */
     override public function call(funcName:String, ?parameters:Array<Dynamic>):Dynamic {
        if(interp == null) return null;
        if(parameters == null) parameters = [];

        var func:Dynamic = interp.variables.get(funcName);
        if(func != null && Reflect.isFunction(func))
            return (parameters != null && parameters.length > 0) ? Reflect.callMethod(null, func, parameters) : func();

        return null;
    }

    override public function trace(v:Dynamic) {
        if(interp == null) return Logs.trace(v, TRACE);

        #if !doc_gen
        var pos = interp.posInfos();
        Logs.trace('$fileName - Line ${pos.lineNumber}: $v', TRACE);
        #end
    }

    override public function destroy() {
        interp = null;
        super.destroy();
    }

    override public function setParent(parent:Dynamic) {
        #if !doc_gen
        if(interp == null) return;
        this.parent = interp.scriptObject = parent;
        #end
    }
}