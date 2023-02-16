package core;

import flixel.util.FlxSave;
import core.modding.ModUtil;

typedef ModdedOption = {
    var name:String;
    var value:Dynamic;
}

class SettingsAPI {
    // VVV -- ADD/EDIT SETTINGS HERE!!!! -----------------------------------------

	public static var downscroll:Bool = false;
	public static var centeredNotefield:Bool = false;

    public static var antialiasing:Bool = true;
    public static var fpsCap:Int = 240;
    public static var vsync:Bool = false;
    public static var noteOffset:Float = 0;

    // ^^^ -----------------------------------------------------------------------

    // ------ INTERNAL VARIABLES & FUNCTIONS -------------------------------------

    public static var controls:Controls;
    static var __save:FlxSave;

    /**
     * Initializes the save data for your settings.
     */
    public static function init() {
        __save = new FlxSave();
        __save.bind("preferences", "NovaEngine");

        controls = new Controls();
    }

	/**
	 * Loads all of your saved settings.
	 */
	public static function load() {
        // -- HARDCODED SETTINGS --
        // Go through each variable
		for (field in Type.getClassFields(SettingsAPI)) {
            // Make sure the variable isn't actually a function in disguise 👻
			if (Type.typeof(Reflect.field(SettingsAPI, field)) != TFunction) {
                // Set the variable's value to the value in save data
                var defaultValue:Dynamic = Reflect.field(SettingsAPI, field);
                var savedProp:Dynamic = Reflect.field(__save.data, field);
                Reflect.setField(SettingsAPI, field, (savedProp != null ? savedProp : defaultValue));
            }
		}

        // -- MODDED SETTINGS --
        var optionsJson:Dynamic = Paths.json("data/customOptions");
        optionsJson.setFieldDefault("options", new Array<ModdedOption>());

        var doFlush:Bool = false;

        var optionsList:Array<ModdedOption> = optionsJson.options;
        
        for(option in optionsList) {
            var optionName:String = ModUtil.currentMod+":"+option.name;

            if(Reflect.field(__save.data, optionName) == null) {
                Reflect.setField(__save.data, optionName, option.value);
                doFlush = true;
            }
        }

        if(doFlush) save();
	}

    public static inline function flush() {save();}

    /**
	 * Saves all of your settings.
	 */
	public static function save() {
        var fieldsToIgnore:Array<String> = ["controls", "__save"];

        // Go through each variable
		for (field in Type.getClassFields(SettingsAPI)) {
            // Make sure the variable isn't actually a function in disguise 👻
			if (Type.typeof(Reflect.field(SettingsAPI, field)) != TFunction && !fieldsToIgnore.contains(field)) {
                // Set the variable's value in save data to the value from this class
                Reflect.setField(__save.data, field, Reflect.field(SettingsAPI, field));
            }
		}
        __save.flush();
	}
}
