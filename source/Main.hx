package;

import game.FNFGame;
import openfl.display.Sprite;

class Main extends Sprite {
	public static var gameSettings = {
		width: 1280,
		height: 720,
		framerate: 1000,
		skipSplash: true,
		fullscreen: false
	};

	@:dox(hide) public static var audioDisconnected:Bool = false;
	@:dox(hide) public static var changeID:Int = 0;

	public static function setFPSCap(framerate:Int) {
		var refreshRate = lime.app.Application.current.window.displayMode.refreshRate;

		if(SettingsAPI.vsync) {
			if(refreshRate > 0)
				framerate = refreshRate;
			else
				framerate = 60;
		}

		if(framerate > FlxG.drawFramerate) {
			FlxG.updateFramerate = framerate;
			FlxG.drawFramerate = framerate;
		} else {
			FlxG.drawFramerate = framerate;
			FlxG.updateFramerate = framerate;
		}
	}

	public static var engineName:String = "Nova Engine";
	public static var engineVersion(get, never):String;
	private static function get_engineVersion():String {
		return lime.app.Application.current.meta.get("version");
	}

	public static var fpsOverlay:FPSOverlay;

	public static function framerateAdjust(input:Float) {
		return FlxG.elapsed * 60 * input;
	}

	public function new() {
		super();

		// no one line shit because null object reference!!
		fpsOverlay = new FPSOverlay(10, 3);
		addChild(new FNFGame(gameSettings.width, gameSettings.height, Init, gameSettings.framerate, gameSettings.framerate, gameSettings.skipSplash, gameSettings.fullscreen));
		addChild(fpsOverlay);
	}
}
