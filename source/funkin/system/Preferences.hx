package funkin.system;

import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

@:keep class PreferenceVariables {
    /**
     * The skin used for all notes that show up during gameplay.
     */
    @:keep public static final noteSkin:String = "Arrows";
    
    /**
     * Whether or not the arrows should move down during gameplay.
     */
    @:keep public static final downscroll:Bool = false;

    /**
     * Whether or not your arrows should be centered during gameplay.
     * The opponent's notes will get hidden with this turned on.
     */
    @:keep public static final middlescroll:Bool = false;

    /**
     * Whether or not the camera should zoom in every 4 beats.
     */
    @:keep public static final cameraZoomsOnBeat:Bool = true;
}

class Preferences {
    /**
	 * `FlxSave` that contains all of the engine settings.
	 */
    @:noCompletion static var __save:FlxSave;

    public static var save(get, never):Dynamic;
    @:noCompletion static function get_save():Dynamic {
        return __save.data;
    }

    public static function init() {
        __save = new FlxSave();

		__save.bind("preferencesSave", "FunkinForever");
		for(k in Type.getClassFields(PreferenceVariables)) {
			var ogVal:Dynamic = Reflect.field(__save.data, k);
			if (ogVal == null)
				Reflect.setField(__save.data, k, Reflect.field(PreferenceVariables, k));
		}
		__save.flush();
    }

    /**
     * Saves all settings.
     */
    public static function flush() {
        __save.flush();
    }
}