package funkin.ui;

import flixel.FlxSprite;

class Checkbox extends FlxSprite {
	public var value(default, set):Bool;

	public function new(x:Float, y:Float, state:Bool = false) {
		super(x, y);
		frames = Paths.getSparrowAtlas('ui/checkboxThingie');
		animation.addByPrefix('static', 'Check Box unselected', 24, false);
		animation.addByPrefix('checked', 'Check Box selecting animation', 24, false);
		scale.set(0.7, 0.7);
		updateHitbox();
		value = state;
	}

	function set_value(state:Bool) {
		animation.play(state ? 'checked' : 'static', true);

        switch (animation.name) {
			case 'checked': offset.set(17, 70);
			case 'static': offset.set();
		}

		return state;
	}
}
