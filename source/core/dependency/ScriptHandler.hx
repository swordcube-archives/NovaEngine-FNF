package core.dependency;

import flixel.FlxBasic;
import haxe.io.Path;
import hscript.Expr;
import hscript.Parser;
import hscript.Interp;

/**
 * The class that allows you to load scripts for things like stages, characters, modcharts, etc.
 */
class ScriptHandler {
    public static var preset:Map<String, Dynamic>;
    public static var compilerFlags:Map<String, Dynamic>;
    public static var parser:Parser;

    public static function init() {
        preset = [
            // Classes [Haxe]
            "Type" => Type,
            "Reflect" => Reflect,
            "Std" => Std,
            "Math" => Math,
            "Array" => Array,
            "String" => String,
            "Int" => Int,
            "Float" => Float,
            "Bool" => Bool,
            "Date" => Date,
            "DateTools" => DateTools,
            "Main" => Main,
            "Path" => Path,

            // Classes [Flixel],
            "FlxG" => flixel.FlxG,
            "FlxSprite" => flixel.FlxSprite,
            "FlxBasic" => flixel.FlxBasic,
            "FlxObject" => flixel.FlxObject,
            "FlxSound" => flixel.system.FlxSound,
            "FlxSort" => flixel.util.FlxSort,
            "FlxStringUtil" => flixel.util.FlxStringUtil,
            "FlxState" => flixel.FlxState,
            "FlxSubState" => flixel.FlxSubState,
            "FlxText" => flixel.text.FlxText,
            "FlxTimer" => flixel.util.FlxTimer,
            "FlxTween" => flixel.tweens.FlxTween,
            "FlxEase" => flixel.tweens.FlxEase,
            "FlxTrail" => flixel.addons.effects.FlxTrail,
            "FlxBackdrop" => flixel.addons.display.FlxBackdrop,

            // Classes [Funkin]
            "CoolUtil" => CoolUtil,
            "Controls" => Controls,
            "Paths" => Paths,

            // Classes [Nova]
            "engine" => {
                name: "Nova Engine",
                version: Main.engineVersion
            },
            "FNFSprite" => FNFSprite,
            "IniParser" => IniParser,
            "SettingsAPI" => SettingsAPI,
            "Init" => Init,
            "Logs" => Logs,

            "FunkinShader" => shaders.FunkinShader,
            "CustomShader" => shaders.CustomShader,
            "OutlineShader" => shaders.OutlineShader,
            "FlxFixedShader" => shaders.FlxFixedShader,

            // Variables
            "platform" => CoolUtil.getPlatform(), // Shortcut to "CoolUtil.getPlatform()".
        ];

        compilerFlags = [
            "windows" => #if windows true #else false #end,
            "mac" => #if mac true #else false #end,
            "linux" => #if linux true #else false #end,
            "bsd" => #if bsd true #else false #end,

            "debug" => #if debug true #else false #end,
            "release" => #if !debug true #else false #end,
            "final" => #if final true #else false #end,
        ];

        parser = new Parser();
        parser.allowJSON = true;
        parser.allowTypes = true;
        parser.allowMetadata = true;
        parser.preprocesorValues = compilerFlags;
    }

    public static function loadModule(path:String) {
        var expr:Expr = null;
        try {
            if(!FileSystem.exists(path))
                throw 'Script doesn\'t exist at path: $path';
            
            expr = parser.parseString(File.getContent(path));
        } 
        catch(e) {
            expr = null;
            Logs.trace('Error occured while loading a script! - $e', ERROR);
        }

        return new ScriptModule(expr, Path.withoutDirectory(path));
    }
}

class ScriptModule extends FlxBasic {
    public var interp:Interp;
    public var fileName:String;

    private function __errorHandler(error:Error) {
        var fn = '$fileName:${error.line}: ';
        var err = error.toString();
        if (err.startsWith(fn)) err = err.substr(fn.length);

        Logs.trace('Error occured on script: $fileName at Line ${error.line} - $err', ERROR);
    }

    public function new(expr:Expr, ?fileName:String = "hscript") {
        super();
        this.fileName = fileName;
        
        // If the script failed to load, just treat it as a dummy script!
        if(expr == null) return;

        interp = new Interp();
        interp.errorHandler = __errorHandler;

        interp.variables.set("trace", Reflect.makeVarArgs((args) -> {
            var v:String = Std.string(args.shift());
            for (a in args) v += ", " + Std.string(a);
            this.trace(v);
        }));

        for(name => value in ScriptHandler.preset)
            interp.variables.set(name, value);

        interp.execute(expr);
    }

    /**
     * Gets a variable from this script and returns it.
     * @param val The name of the variable to get.
     */
    public function get(val:String):Dynamic {
        if(interp == null) return null;
        return interp.variables.get(val);
    }

    /**
     * Sets a variable from this script.
     * @param val The name of the variable to set.
     * @param value The value to set the variable to.
     */
    public function set(val:String, value:Dynamic) {
        if(interp == null) return;
        interp.variables.set(val, value);
    }

    /**
     * Calls a function from this script and returns whatever the function returns (Can be `null`!).
     * @param funcName The name of the function to call.
     * @param parameters The parameters/arguments to give the function when calling it.
     */
    public function call(funcName:String, parameters:Array<Dynamic>):Dynamic {
        if(interp == null) return null;

        var func:Dynamic = interp.variables.get(funcName);
        if(func != null && Reflect.isFunction(func))
            return (parameters != null && parameters.length > 0) ? Reflect.callMethod(null, func, parameters) : func();

        return null;
    }

    public function trace(v:Dynamic) {
        if(interp == null) return Logs.trace(v, TRACE);

        var pos = interp.posInfos();
        Logs.trace('$fileName - Line ${pos.lineNumber}: $v', TRACE);
    }

    override public function destroy() {
        interp = null;
        fileName = null;
        super.destroy();
    }

    public function setParent(parent:Dynamic) {
        if(interp == null) return;
        interp.scriptObject = parent;
    }
}

/**
 * A group of `ScriptModule`, used primarily in `PlayState`.
 */
class ScriptGroup extends FlxBasic {
    private var __scripts:Array<ScriptModule> = [];
    public var parent:Dynamic;

    public function add(script:ScriptModule) {
        script.setParent(parent);
        __scripts.push(script);
    }

    public function remove(script:ScriptModule) {
        __scripts.remove(script);
    }

    public function setParent(parent:Dynamic, ?force:Bool = false) {
        if(parent == null && !force) return this;

        this.parent = parent;

        for(script in __scripts)
            script.setParent(parent);

        return this;
    }

    /**
     * Calls a function on all scripts in this group.
     * Returns a value from one of the scripts that has the function.
     * 
     * @param funcName The name of the function to call.
     * @param parameters The parameters/arguments to give the function when calling it.
     * @param defaultReturn The default return value if none of the scripts return anything.
     */
    public function call(funcName:String, parameters:Array<Dynamic>, ?defaultReturn:Dynamic = null):Dynamic {
        var finalizedReturn:Dynamic = defaultReturn;

        for(script in __scripts) {
            var returnValue:Dynamic = script.call(funcName, parameters);

            if(returnValue != null && returnValue != defaultReturn)
                finalizedReturn = returnValue;
        }

        return finalizedReturn;
    }

    override public function destroy() {
        for(script in __scripts)
            script.destroy();

        super.destroy();
    }
}