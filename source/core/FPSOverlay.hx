package core;

import haxe.Timer;
import openfl.events.Event;
import openfl.text.TextField;
import openfl.text.TextFormat;

class FPSOverlay extends TextField {
	private var times:Array<Float> = [];
	public var memPeak:Float = 0;

    public var displayFPS:Bool = true;
    public var displayMemory:Bool = true;
    public var displayDebug:Bool = true;

	public function new(inX:Float = 10.0, inY:Float = 10.0, inCol:Int = 0xFFFFFF) {
		super();

		x = inX;
		y = inY;

        autoSize = LEFT;
		selectable = false;
		defaultTextFormat = new TextFormat(Paths.font("vcr.ttf"), 16, inCol);

		text = "";

		addEventListener(Event.ENTER_FRAME, onEnter);
	}

	private function onEnter(_) {
		var now = Timer.stamp();

		times.push(now);
		while (times[0] < now - 1) times.shift();

		if (visible) {
			var mem:Float = MemoryUtil.getCurrentUsage();
			if(mem > memPeak) memPeak = mem;

			var stateDisplay:String = null;
			if(Std.isOfType(FlxG.state, states.ModState))
				stateDisplay = "states." + cast(FlxG.state, states.ModState).scriptName.replace("/", ".");
			else
				stateDisplay = Type.getClassName(Type.getClass(FlxG.state));

            text = (
                (displayFPS ? '${times.length} FPS\n' : '') +
                (displayMemory ? '${CoolUtil.getSizeLabel(mem)} / ${CoolUtil.getSizeLabel(memPeak)}\n' : '') +
                (displayDebug ? stateDisplay : '')
            );
        }
	}
}