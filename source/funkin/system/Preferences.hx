package funkin.system;

import haxe.DynamicAccess;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;

@:keep class PreferenceVariables {
	/**
	 * The controls used for menus.
	 */
	@:keep public static final UI_controls:DynamicAccess<Array<FlxKey>> = {
		"UI_LEFT":  [A, LEFT],
		"UI_DOWN":  [S, DOWN],
		"UI_UP":    [W, UP],
		"UI_RIGHT": [D, RIGHT],
        
		"ACCEPT":   [ENTER, SPACE],
		"BACK":     [BACKSPACE, ESCAPE],
		"PAUSE":    [ENTER, NONE],
	};

	/**
	 * The controls used for gameplay.
	 */
	@:keep public static final GAME_controls:DynamicAccess<Array<FlxKey>> = {
		"1K": [SPACE],
		"2K": [D, K],
		"3K": [D, SPACE, K],
		"4K": [D, F, J, K],
		"5K": [D, F, SPACE, J, K],
		"6K": [S, D, F, J, K, L],
		"7K": [S, D, F, SPACE, J, K, L],
		"8K": [A, S, D, F, H, J, K, L],
		"9K": [A, S, D, F, SPACE, H, J, K, L],
	};

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
		for (k in Type.getClassFields(PreferenceVariables)) {
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
