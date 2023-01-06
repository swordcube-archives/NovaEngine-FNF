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

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

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

		cacheCount = 0;
		currentTime = 0;
		times = [];
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void {
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000) {
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);

		// Your framerate shouldn't be able to go above the cap!!
		var cap:Int = Std.int(FlxG.stage.frameRate);
		if(currentFPS > cap) currentFPS = cap;

		if (currentCount != cacheCount /*&& visible*/) {
			text = "";
			text += 'FPS: $currentFPS\n';
			text += 'MEM: ${CoolUtil.getSizeLabel(Memory.getCurrentUsage())} / ${CoolUtil.getSizeLabel(Memory.getPeakUsage())}\n';
		}

		cacheCount = currentCount;
	}
}
