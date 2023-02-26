package backend.dependency;

import backend.scripting.events.CancellableEvent;
import backend.scripting.*;
import flixel.FlxBasic;
import haxe.io.Path;

typedef JSONReplacer = (key:Dynamic, value:Dynamic) -> Dynamic;

/**
 * The class that allows you to load scripts for things like stages, characters, modcharts, etc.
 */
class ScriptHandler {
    public static var preset:Map<String, Dynamic>;
    public static var compilerFlags:Map<String, Dynamic>;

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
            "Json" => {
                "parse": (value:String) -> {
                    return Json.parse(value);
                },
                "stringify": (value:Dynamic, ?space:String, ?replacer:JSONReplacer) -> {
                    return Json.stringify(value, replacer, space);
                }
            },

            // Classes [Flixel],
            "FlxG" => flixel.FlxG,
            "FlxSprite" => flixel.FlxSprite,
            "FlxBasic" => flixel.FlxBasic,
            "FlxObject" => flixel.FlxObject,
            "FlxSound" => flixel.system.FlxSound,
            "FlxSort" => flixel.util.FlxSort,
            "FlxStringUtil" => flixel.util.FlxStringUtil,
            "FlxMath" => flixel.math.FlxMath,
            "FlxState" => flixel.FlxState,
            "FlxSubState" => flixel.FlxSubState,
            "FlxText" => flixel.text.FlxText,
            "FlxTimer" => flixel.util.FlxTimer,
            "FlxTween" => flixel.tweens.FlxTween,
            "FlxEase" => flixel.tweens.FlxEase,
            "FlxTrail" => flixel.addons.effects.FlxTrail,
            "FlxBackdrop" => flixel.addons.display.FlxBackdrop,
            "FlxTypedGroup" => flixel.group.FlxGroup.FlxTypedGroup,
            "FlxGroup" => flixel.group.FlxGroup,

            "FlxUITabMenu" => flixel.addons.ui.FlxUITabMenu,
            "FlxInputText" => flixel.addons.ui.FlxInputText,
            "FlxUI9SliceSprite" => flixel.addons.ui.FlxUI9SliceSprite,
            "FlxUI" => flixel.addons.ui.FlxUI,
            "FlxUICheckBox" => flixel.addons.ui.FlxUICheckBox,
            "FlxUIDropDownMenu" => flixel.addons.ui.FlxUIDropDownMenu,
            "FlxUIInputText" => flixel.addons.ui.FlxUIInputText,
            "FlxUINumericStepper" => flixel.addons.ui.FlxUINumericStepper,

            // VVV -- these are classes because lua tables are shitting themselves --

            "FlxColor" => backend.scripting.helperClasses.FlxColorHelper,
            "FlxKey" => backend.scripting.helperClasses.FlxKeyHelper,
            "BlendMode" => backend.scripting.helperClasses.BlendModeHelper,
            "FlxCameraFollowStyle" => backend.scripting.helperClasses.FlxCameraFollowStyleHelper,
            "FlxTextAlign" => backend.scripting.helperClasses.FlxTextAlignHelper,
            "FlxTextBorderStyle" => backend.scripting.helperClasses.FlxTextBorderStyleHelper,
            "FlxAxes" => backend.scripting.helperClasses.FlxAxesHelper,
            "StringHelper" => backend.scripting.helperClasses.StringHelper,

            // ^^^ -------------------------------------------------------------

            @:access(flixel.math.FlxPoint.FlxBasePoint)
            "FlxPoint" => flixel.math.FlxPoint.FlxBasePoint,

            // Classes [Funkin]
            "Conductor" => music.Conductor,
            "Character" => objects.Character,
            "Boyfriend" => objects.Character, // compatibility
            "Alphabet" => objects.fonts.Alphabet,
            "StrumLine" => objects.ui.StrumLine,
            "StrumNote" => objects.ui.StrumLine.Receptor,
            "Receptor" => objects.ui.StrumLine.Receptor,
            "HealthIcon" => objects.ui.HealthIcon,
            "Stage" => objects.Stage,
            "Note" => objects.ui.Note,
            "MusicBeatState" => states.MusicBeat.MusicBeatState,
            "MusicBeatSubstate" => states.MusicBeat.MusicBeatSubstate,
            "MusicBeatSubState" => states.MusicBeat.MusicBeatSubstate,
            "GameOverSubstate" => states.substates.GameOverSubstate,
            "GameOverSubState" => states.substates.GameOverSubstate,
            "CoolUtil" => CoolUtil,
            "Controls" => Controls,
            "Paths" => Paths,
            "PlayState" => states.PlayState,

            // Classes [Nova]
            "ModUtil" => backend.modding.ModUtil,
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

            "WindowUtil" => backend.utilities.WindowUtil,

            // Variables
            "engine" => {
                name: "Nova Engine",
                version: Main.engineVersion
            },
            "platform" => CoolUtil.getPlatform(), // Shortcut to "CoolUtil.getPlatform()".
            "window" => lime.app.Application.current.window,
            "mod" => backend.modding.ModUtil.currentMod, // Shortcut to "ModUtil.currentMod".
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
     * Runs the script.
     */
    public function load() {}

    /**
     * Calls a function from this script and returns whatever the function returns (Can be `null`!).
     * @param funcName The name of the function to call.
     * @param parameters The parameters/arguments to give the function when calling it.
     */
    public function call(funcName:String, ?parameters:Array<Dynamic>):Dynamic {return null;}

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

    /**
     * Runs all of the scripts in this group.
     */
    public function load() {
        for(script in __scripts)
            script.load();
    }

    public function importScript(path:String) {
        var script = ScriptHandler.loadModule(Paths.script(path));
        add(script);
        return script;
    }

    public function add(script:ScriptModule) {
        __scripts.push(script);
        __configureNewScript(script);
    }

    public function remove(script:ScriptModule) {
        __scripts.remove(script);
    }

    public function insert(pos:Int, script:ScriptModule) {
        __scripts.insert(pos, script);
        __configureNewScript(script);
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