package funkin.scripting;

import funkin.interfaces.IScriptModule;
import haxe.io.Path;
import flixel.FlxBasic;
import hscript.Parser;

/**
 * Handles the Backend and Script interfaces of the engine, as well as exceptions and crashes.
 */
class ScriptHandler {
	/**
	 * Shorthand for exposure, specifically public exposure. 
	 * All scripts will be able to access these variables globally.
	 */
	public static var exp:Map<String, Dynamic>;

	public static var parser:Parser = new Parser();

	/**
	 * Initializes the basis of the Scripting system
	 */
	public static function init() {
		exp = [
            // Classes (Haxe)
            #if sys
            "Sys" => Sys,
            "File" => sys.io.File,
            "FileSystem" => sys.FileSystem,
            #end

            "Std" => Std,
            "Math" => Math,
            "StringTools" => StringTools,

            "Array" => Array,
            "Float" => Float,
            "Int" => Int,
            "String" => String,
            "Bool" => Bool,
            "Dynamic" => Dynamic,

            // Classes (Flixel)
            "Polymod" => polymod.Polymod,
            "FlxG" => flixel.FlxG,
            "FlxSprite" => flixel.FlxSprite,
            "FlxMath" => flixel.math.FlxMath,
            "FlxTween" => flixel.tweens.FlxTween,
            "FlxEase" => flixel.tweens.FlxEase,
            "FlxTimer" => flixel.util.FlxTimer,

            // Classes (Funkin)
            "CoolUtil" => funkin.system.CoolUtil,
            "MathUtil" => funkin.system.MathUtil,
            "Conductor" => funkin.system.Conductor,
            "PlayState" => funkin.game.PlayState,
            "Paths" => funkin.system.Paths
        ];

		parser.allowJSON = parser.allowMetadata = parser.allowTypes = true;
	}

    public static function loadModule(path:String):ScriptModule {
        if(!Paths.exists(path)) return new DummyScript(path);

        return switch(Path.extension(path).toLowerCase()) {
            case "hx", "hxs", "hsc", "hscript":
                new HScriptModule(path);

            case "lua":
                Console.error("LUA isn't supported! Use HScript instead.");
                new DummyScript(path);
                
            default: new DummyScript(path);
        }
    }
}

class ScriptModule extends FlxBasic implements IScriptModule {
    public var fileName:String;
    public var path:String;

    public function new(path:String) {
        super();

        this.path = path;
        fileName = Path.withoutDirectory(path);

        create(path);
    }

    /**
     * Currently executing script.
     */
     public static var curScript:ScriptModule = null;

    /**
	 * Loads the script.
	 */
	public function load() {
        var oldScript = curScript;
        curScript = this;
        onLoad();
        curScript = oldScript;
    }

    /**
     * The function that gets executed when the script is loaded.
     */
    public function onLoad() {}

	/**
	 * Hot-reloads the script if possible.
	 */
	public function reload() {}

	/**
	 * A function that gets ran when the script is created.
	 * @param path The path to the script.
	 */
	public function create(path:String) {}

	/**
	 * Gets a variable from the script.
	 * @param variable The name of the variable.
	 */
	public function get(variable:String):Dynamic {return null;}

    /**
	 * Sets a variable from the script to any value.
	 * @param variable The name of the variable.
     * @param value The value to set the variable to.
	 */
	public function set(variable:String, value:Dynamic):Dynamic {return null;}

	/**
	 * Sets a function in the script.
	 * @param funcName The name of the function. 
	 * @param value The function to use.
	 */
	public function setFunc(funcName:String, value:Dynamic):Dynamic {return null;}

	/**
	 * Allows the script to access variables and classes from `classInstance`
	 * @param classInstance The class to get variables and classes from.
	 */
	public function setParent(classInstance:Dynamic):Void {}

	/**
	 * Calls a function from the script.
	 * @param method The name of the function to call.
	 * @param parameters The arguments for the function.
	 */
	public function call(method:String, ?parameters:Array<Dynamic>):Dynamic {return null;}
}