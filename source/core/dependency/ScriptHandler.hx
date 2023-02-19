package core.dependency;

import core.dependency.scripting.events.CancellableEvent;
import core.dependency.scripting.*;
import flixel.FlxBasic;
import haxe.io.Path;
import hscript.Expr;
import hscript.Parser;
import flixel.util.FlxColor;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText.FlxTextAlign;
import flixel.FlxCamera.FlxCameraFollowStyle;
import openfl.display.BlendMode;
import flixel.input.keyboard.FlxKey;

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

            // VVV -- these are classes because tables are shitting themselves --

            "FlxColor" => core.dependency.scripting.helperClasses.FlxColorHelper,
            "FlxKey" => core.dependency.scripting.helperClasses.FlxKeyHelper,
            "BlendMode" => core.dependency.scripting.helperClasses.BlendModeHelper,
            "FlxCameraFollowStyle" => core.dependency.scripting.helperClasses.FlxCameraFollowStyleHelper,
            "FlxTextAlign" => core.dependency.scripting.helperClasses.FlxTextAlignHelper,
            "FlxTextBorderStyle" => core.dependency.scripting.helperClasses.FlxTextBorderStyleHelper,
            "FlxAxes" => core.dependency.scripting.helperClasses.FlxAxesHelper,
            "StringHelper" => core.dependency.scripting.helperClasses.StringHelper,

            // ^^^ -------------------------------------------------------------

            @:access(flixel.math.FlxPoint.FlxBasePoint)
            "FlxPoint" => flixel.math.FlxPoint.FlxBasePoint,

            // Classes [Funkin]
            "MusicBeatState" => states.MusicBeat.MusicBeatState,
            "MusicBeatSubstate" => states.MusicBeat.MusicBeatSubstate,
            "MusicBeatSubState" => states.MusicBeat.MusicBeatSubstate,
            "CoolUtil" => CoolUtil,
            "Controls" => Controls,
            "Paths" => Paths,
            "PlayState" => states.PlayState,

            // Classes [Nova]
            "ModUtil" => core.modding.ModUtil,
            "engine" => {
                name: "Nova Engine",
                version: Main.engineVersion
            },
            "FNFSprite" => FNFSprite,
            "IniParser" => IniParser,
            "SettingsAPI" => SettingsAPI,
            "ModState" => states.ModState,
            "ModSubstate" => states.ModState.ModSubstate,
            "ModSubState" => states.ModState.ModSubstate,
            "Init" => Init,
            "Logs" => Logs,

            "FunkinShader" => shaders.FunkinShader,
            "CustomShader" => shaders.CustomShader,
            "OutlineShader" => shaders.OutlineShader,
            "FlxFixedShader" => shaders.FlxFixedShader,

            // Variables
            "platform" => CoolUtil.getPlatform(), // Shortcut to "CoolUtil.getPlatform()".
            "window" => lime.app.Application.current.window,
            "mod" => core.modding.ModUtil.currentMod, // Shortcut to "ModUtil.currentMod".
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

    public static function loadModule(path:String):ScriptModule {
        if(!FileSystem.exists(path) || !Paths.scriptExts.contains(Path.extension(path)))
            return new DummyScript(path, "dummy");

        var fileName:String = Path.withoutDirectory(path);

        return switch(Path.extension(path)) {
            // haxe scripting
            case "hx", "hxs", "hsc", "hscript":
                new HScript(path, fileName);

            // lua scripting
            case "lua":
                new LuaScript(path, fileName);

            // dummy script for files that don't exist or unsupported script types
            default:
                new DummyScript(path, "dummy");
        }
    }
}

class ScriptModule extends FlxBasic {
    public var path:String;
    public var fileName:String;

    public var parent:Dynamic;

    public function new(path:String, fileName:String = "hscript") {
        super();
        this.path = path;
        this.fileName = fileName;
    }

    /**
     * Gets a variable from this script and returns it.
     * @param val The name of the variable to get.
     */
    public function get(val:String):Dynamic {return null;}

    /**
     * Sets a variable from this script.
     * @param val The name of the variable to set.
     * @param value The value to set the variable to.
     */
    public function set(val:String, value:Dynamic) {}

    /**
     * Calls a function from this script and returns whatever the function returns (Can be `null`!).
     * @param funcName The name of the function to call.
     * @param parameters The parameters/arguments to give the function when calling it.
     */
    public function call(funcName:String, parameters:Array<Dynamic>):Dynamic {return null;}

    /**
     * Calls a function from this script with an event that can be cancelled.
     * Useful for stopping certain things from running in `PlayState`.
     * 
     * @param funcName The name of the function to call.
     * @param event The event to run.
     */
     public function event<T:CancellableEvent>(funcName:String, event:T):T {
        if(event.cancelled) return event;
        call(funcName, [event]);
        return event;
    }

    public function trace(v:Dynamic) {}

    override public function destroy() {
        fileName = null;
        super.destroy();
    }

    public function setParent(parent:Dynamic) {}
}

/**
 * A group of `ScriptModule`, used primarily in `PlayState`.
 */
class ScriptGroup extends FlxBasic {
    public var additionalDefaultVariables:Map<String, Dynamic> = [];
    private var __scripts:Array<ScriptModule> = [];
    public var parent:Dynamic;

    public function new() {
        additionalDefaultVariables["importScript"] = importScript;
        super();
    }

    public function importScript(path:String) {
        var script = ScriptHandler.loadModule(Paths.script(path));
        add(script);
        return script;
    }

    public function add(script:ScriptModule) {
        __configureNewScript(script);
        __scripts.push(script);
    }

    public function remove(script:ScriptModule) {
        __scripts.remove(script);
    }

    public function insert(pos:Int, script:ScriptModule) {
        __configureNewScript(script);
        __scripts.insert(pos, script);
    }

    private function __configureNewScript(script:ScriptModule) {
        if (parent != null) script.setParent(parent);
        for(k=>e in additionalDefaultVariables) script.set(k, e);
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

    /**
     * Calls a function on all scripts in this group with an event that can be cancelled.
     * Useful for stopping certain things from running in `PlayState`.
     * 
     * @param funcName The name of the function to call.
     * @param event The event to run.
     */
    public function event<T:CancellableEvent>(funcName:String, event:T):T {
        for(script in __scripts) {
            if(event.cancelled) break;
            script.call(funcName, [event]);
        }
        return event;
    }

    override public function destroy() {
        for(script in __scripts)
            script.destroy();

        super.destroy();
    }
}