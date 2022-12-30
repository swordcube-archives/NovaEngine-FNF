package funkin.scripting;

import hscript.Interp;
import funkin.scripting.ScriptHandler.ScriptModule;

class HScriptModule extends ScriptModule {
    public var interp = new Interp();

	override function reload() {}

	override function create(path:String) {
        var code:String = OpenFLAssets.getText(path);

        var parser = ScriptHandler.parser;
        var exp = ScriptHandler.exp;

        for(name => value in exp)
            interp.variables.set(name, value);
        
        interp.execute(parser.parseString(code, fileName));
    }

	override function get(variable:String):Dynamic {
		return interp.variables.get(variable);
	}

	override function set(variable:String, value:Dynamic):Dynamic {
        interp.variables.set(variable, value);
		return value;
	}

	override function setFunc(variable:String, value:Dynamic):Dynamic {
        interp.variables.set(variable, value);
		return value;
	}

	override function setParent(classInstance:Dynamic) {
        interp.scriptObject = classInstance;
    }

	override function call(method:String, ?parameters:Array<Dynamic>):Dynamic {
        var func:Dynamic = interp.variables.get(method);
        if(func != null && Reflect.isFunction(func))
            return (parameters != null && parameters.length > 0) ? Reflect.callMethod(null, func, parameters) : func();

		return null;
	}
}