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

    /**
	 * Essentially just Haxe compiler flags but for HScript.
     * You would use them exactly how you normally would in Haxe.
     *  
	 * All scripts will be able to access these flags globally.
	 */
	public static var preprocessorFlags:Map<String, Dynamic>;

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
            "FlxGroup" => flixel.group.FlxGroup,
            "FlxTypedGroup" => flixel.group.FlxGroup.FlxTypedGroup,

            // Classes (Funkin)
            "Preferences" => funkin.system.Preferences.save,
            "CoolUtil" => funkin.system.CoolUtil,
            "MathUtil" => funkin.system.MathUtil,
            "Conductor" => funkin.system.Conductor,
            "PlayState" => funkin.game.PlayState,
            "Paths" => funkin.system.Paths,
            "FNFSprite" => funkin.system.FNFSprite
        ];

        preprocessorFlags = [
            "debug" => #if debug true #else false #end,
            "release" => #if !debug true #else false #end,

            // OS flags
            "desktop" => #if desktop true #else false #end,
            "windows" => #if windows true #else false #end,
            "macos" => #if macos true #else false #end,
            "mac" => #if macos true #else false #end,
            "linux" => #if linux true #else false #end,
            "hl" => #if hl true #else false #end,
            "hashlink" => #if hl true #else false #end,
            "android" => #if android true #else false #end,
            "web" => #if web true #else false #end,
            "html5" => #if html5 true #else false #end,
            "neko" => #if neko true #else false #end,

            // Library/feature flags
            "MOD_SUPPORT" => #if MOD_SUPPORT true #else false #end,
            "DISCORD_RPC" => #if DISCORD_RPC true #else false #end,
        ];

        parser.preprocesorValues = preprocessorFlags;
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

        onCreate(path);
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
	public function onCreate(path:String) {}

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