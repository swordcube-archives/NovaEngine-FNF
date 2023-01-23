package funkin.ui;

import openfl.text.TextField;
import openfl.text.TextFormat;
import core.utilities.memory.Memory;

class FPSCounter extends TextField {
	/**
	 * The current frame rate, expressed using frames-per-second
	 */
	public var currentFPS(default, null):Int;

	@:noCompletion var __fps:Int = 0;
	@:noCompletion var currentTime:Float = 1.0;

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
		text = "";

		currentTime = 0;
	}

	@:noCompletion override function __enterFrame(deltaTime:Float):Void {
		currentTime += deltaTime / 1000;
		__fps++;

		if(currentTime >= 1.0) {
			currentFPS = __fps;

			// Your framerate shouldn't be able to go above the cap!!
			var cap:Int = Std.int(FlxG.stage.frameRate);
			if(currentFPS > cap) currentFPS = cap;

			text = "";

			if(OptionsAPI.get("FPS Counter"))
				text += 'FPS: $currentFPS\n';

			if(OptionsAPI.get("Memory Counter"))
				text += 'MEM: ${CoolUtil.getSizeLabel(Memory.getCurrentUsage())} / ${CoolUtil.getSizeLabel(Memory.getPeakUsage())}\n';

			__fps = 0;
			currentTime = 0.0;
		}
	}
}
