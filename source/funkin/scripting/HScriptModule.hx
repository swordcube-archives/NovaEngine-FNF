package funkin.scripting;

import hscript.Expr.Error;
import hscript.Interp;
import hscript.Expr;
import funkin.scripting.ScriptHandler.ScriptModule;

using StringTools;

class HScriptModule extends ScriptModule {
    public var interp:Interp;
    public var code:String = "";

    public var expr:Expr;

	override function reload() {
        var savedVariables:Map<String, Dynamic> = [];
        for(k=>e in interp.variables) {
            if (!Reflect.isFunction(e))
                savedVariables[k] = e;
        }
        var oldParent = interp.scriptObject;
        create(path);
        load();
        setParent(oldParent);
        for(k=>e in savedVariables)
            interp.variables.set(k, e);
    }

	override function create(path:String) {
        interp = new Interp();

        code = OpenFLAssets.getText(path);

        var parser = ScriptHandler.parser;
        var exp = ScriptHandler.exp;

        try {
            expr = parser.parseString(code, fileName);
        } catch(e:Error) {
            _errorHandler(e);
        } catch(e) {
            _errorHandler(new Error(ECustom(e.toString()), 0, 0, fileName, 0));
        }

        for(name => value in exp)
            interp.variables.set(name, value);
    }

    function _errorHandler(error:Error) {
        var fn = '$fileName:${error.line}: ';
        var err = error.toString();
        if (err.startsWith(fn)) err = err.substr(fn.length);

        Console.error('$fn$err');
    }

    override function onLoad() {
        if(expr != null) interp.execute(expr);
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

    override public function destroy() {
        interp = null;
        expr = null;
        super.destroy();
    }
}