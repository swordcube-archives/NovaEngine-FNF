package;

import flixel.FlxGame;
import openfl.display.Sprite;
import lime.app.Application;

class Main extends Sprite {
	/**
	 * The version number of the engine.
	 */
	public static var engineVersion(get, never):String;

	static function get_engineVersion():String {
		return Application.current.meta.get("version");
	}

	public function new() {
		super();
		addChild(new FlxGame(1280, 720, Init, 240, 240, true, false));
	}
}
