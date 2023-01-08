package openfl.display;

import openfl.text.TextField;
import openfl.text.TextFormat;
import external.memory.Memory;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField {
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	var __fps:Int = 0;

	@:noCompletion private var currentTime:Float = 1.0;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000) {
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat(Paths.font("vcr.ttf"), 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		currentTime = 0;
	}

	// fuck u we're not using flash
	@:noCompletion override function __enterFrame(deltaTime:Float):Void {
		currentTime += FlxG.elapsed;
		__fps++;

		if(currentTime >= 1.0) {
			currentFPS = __fps;

			// Your framerate shouldn't be able to go above the cap!!
			var cap:Int = Std.int(FlxG.stage.frameRate);
			if(currentFPS > cap) currentFPS = cap;

			text = "";
			text += 'FPS: $currentFPS\n';
			text += 'MEM: ${CoolUtil.getSizeLabel(Memory.getCurrentUsage())} / ${CoolUtil.getSizeLabel(Memory.getPeakUsage())}\n';

			__fps = 0;
			currentTime = 0.0;
		}
	}
}
