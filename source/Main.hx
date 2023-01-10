package;

import flixel.FlxGame;
import flixel.FlxState;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite {
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var framerate:Int = 240; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	// You can pretty much ignore everything from here on - your code should go in your states.

	@:dox(hide) public static var audioDisconnected:Bool = false;
	@:dox(hide) public static var changeID:Int = 0;

	public function new() {
		super();
		addChild(new FlxGame(gameWidth, gameHeight, Init, framerate, framerate, skipSplash, startFullscreen));
		addChild(new FPS(10, 3, 0xFFFFFF));
	}
}
