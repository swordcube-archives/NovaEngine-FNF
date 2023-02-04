package core.dependency;

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
            "FlxColor" => {
                "BLACK": FlxColor.BLACK,
                "BLUE": FlxColor.BLUE,
                "BROWN": FlxColor.BROWN,
                "CYAN": FlxColor.CYAN,
                "GRAY": FlxColor.GRAY,
                "GREEN": FlxColor.GREEN,
                "LIME": FlxColor.LIME,
                "MAGENTA": FlxColor.MAGENTA,
                "ORANGE": FlxColor.ORANGE,
                "PINK": FlxColor.PINK,
                "PURPLE": FlxColor.PURPLE,
                "RED": FlxColor.RED,
                "TRANSPARENT": FlxColor.TRANSPARENT,
                "WHITE": FlxColor.WHITE,
                "YELLOW": FlxColor.YELLOW,
    
                "add": FlxColor.add,
                "fromCMYK": FlxColor.fromCMYK,
                "fromHSB": FlxColor.fromHSB,
                "fromHSL": FlxColor.fromHSL,
                "fromInt": FlxColor.fromInt,
                "fromRGB": FlxColor.fromRGB,
                "fromRGBFloat": FlxColor.fromRGBFloat,
                "fromString": FlxColor.fromString,
                "interpolate": FlxColor.interpolate,
                "to24Bit": function(color:Int) {
                    return color & 0xffffff;
                },
            },
            "FlxKey" => {
                'ANY': -2,
                'NONE': -1,
                'A': 65,
                'B': 66,
                'C': 67,
                'D': 68,
                'E': 69,
                'F': 70,
                'G': 71,
                'H': 72,
                'I': 73,
                'J': 74,
                'K': 75,
                'L': 76,
                'M': 77,
                'N': 78,
                'O': 79,
                'P': 80,
                'Q': 81,
                'R': 82,
                'S': 83,
                'T': 84,
                'U': 85,
                'V': 86,
                'W': 87,
                'X': 88,
                'Y': 89,
                'Z': 90,
                'ZERO': 48,
                'ONE': 49,
                'TWO': 50,
                'THREE': 51,
                'FOUR': 52,
                'FIVE': 53,
                'SIX': 54,
                'SEVEN': 55,
                'EIGHT': 56,
                'NINE': 57,
                'PAGEUP': 33,
                'PAGEDOWN': 34,
                'HOME': 36,
                'END': 35,
                'INSERT': 45,
                'ESCAPE': 27,
                'MINUS': 189,
                'PLUS': 187,
                'DELETE': 46,
                'BACKSPACE': 8,
                'LBRACKET': 219,
                'RBRACKET': 221,
                'BACKSLASH': 220,
                'CAPSLOCK': 20,
                'SEMICOLON': 186,
                'QUOTE': 222,
                'ENTER': 13,
                'SHIFT': 16,
                'COMMA': 188,
                'PERIOD': 190,
                'SLASH': 191,
                'GRAVEACCENT': 192,
                'CONTROL': 17,
                'ALT': 18,
                'SPACE': 32,
                'UP': 38,
                'DOWN': 40,
                'LEFT': 37,
                'RIGHT': 39,
                'TAB': 9,
                'PRINTSCREEN': 301,
                'F1': 112,
                'F2': 113,
                'F3': 114,
                'F4': 115,
                'F5': 116,
                'F6': 117,
                'F7': 118,
                'F8': 119,
                'F9': 120,
                'F10': 121,
                'F11': 122,
                'F12': 123,
                'NUMPADZERO': 96,
                'NUMPADONE': 97,
                'NUMPADTWO': 98,
                'NUMPADTHREE': 99,
                'NUMPADFOUR': 100,
                'NUMPADFIVE': 101,
                'NUMPADSIX': 102,
                'NUMPADSEVEN': 103,
                'NUMPADEIGHT': 104,
                'NUMPADNINE': 105,
                'NUMPADMINUS': 109,
                'NUMPADPLUS': 107,
                'NUMPADPERIOD': 110,
                'NUMPADMULTIPLY': 106,
    
                'fromStringMap': FlxKey.fromStringMap,
                'toStringMap': FlxKey.toStringMap,
                'fromString': FlxKey.fromString,
                'toString': function(key:Int) {
                    return FlxKey.toStringMap.get(key);
                },
            },
            "BlendMode" => {
                "ADD": BlendMode.ADD,
                "ALPHA": BlendMode.ALPHA,
                "DARKEN": BlendMode.DARKEN,
                "DIFFERENCE": BlendMode.DIFFERENCE,
                "ERASE": BlendMode.ERASE,
                "HARDLIGHT": BlendMode.HARDLIGHT,
                "INVERT": BlendMode.INVERT,
                "LAYER": BlendMode.LAYER,
                "LIGHTEN": BlendMode.LIGHTEN,
                "MULTIPLY": BlendMode.MULTIPLY,
                "NORMAL": BlendMode.NORMAL,
                "OVERLAY": BlendMode.OVERLAY,
                "SCREEN": BlendMode.SCREEN,
                "SHADER": BlendMode.SHADER,
                "SUBTRACT": BlendMode.SUBTRACT
            },
            "FlxCameraFollowStyle" => {
                "LOCKON": FlxCameraFollowStyle.LOCKON,
                "PLATFORMER": FlxCameraFollowStyle.PLATFORMER,
                "TOPDOWN": FlxCameraFollowStyle.TOPDOWN,
                "TOPDOWN_TIGHT": FlxCameraFollowStyle.TOPDOWN_TIGHT,
                "SCREEN_BY_SCREEN": FlxCameraFollowStyle.SCREEN_BY_SCREEN,
                "NO_DEAD_ZONE": FlxCameraFollowStyle.NO_DEAD_ZONE
            },
            "FlxTextAlign" => {
                "LEFT": FlxTextAlign.LEFT,
                "CENTER": FlxTextAlign.CENTER,
                "RIGHT": FlxTextAlign.RIGHT,
                "JUSTIFY": FlxTextAlign.JUSTIFY,
                "fromOpenFL": FlxTextAlign.fromOpenFL,
                "toOpenFL": FlxTextAlign.toOpenFL
            },
            "FlxTextBorderStyle" => {
                "NONE": FlxTextBorderStyle.NONE,
                "SHADOW": FlxTextBorderStyle.SHADOW,
                "OUTLINE": FlxTextBorderStyle.OUTLINE,
                "OUTLINE_FAST": FlxTextBorderStyle.OUTLINE_FAST
            },
            "FlxAxes" => {
                "X": flixel.util.FlxAxes.X,
                "Y": flixel.util.FlxAxes.Y,
                "XY": flixel.util.FlxAxes.XY,
                "YX": flixel.util.FlxAxes.XY,
                "NONE": flixel.util.FlxAxes.NONE,
                "fromString": function(str:String) {
                    return switch(str.toLowerCase()) {
                        case "x": flixel.util.FlxAxes.X;
                        case "y": flixel.util.FlxAxes.Y;
                        case "xy", "yx", "both": flixel.util.FlxAxes.XY;
                        case "none", "", null: flixel.util.FlxAxes.NONE;
                        default: flixel.util.FlxAxes.NONE;
                    }
                },
                "fromBools": function(x:Bool, y:Bool) {
                    return cast(x ? (cast flixel.util.FlxAxes.X : Int) : 0) | (y ? (cast flixel.util.FlxAxes.Y : Int) : 0);
                }
            },
            @:access(flixel.math.FlxPoint.FlxBasePoint)
            "FlxPoint" => flixel.math.FlxPoint.FlxBasePoint,

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
            "window" => lime.app.Application.current.window,
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