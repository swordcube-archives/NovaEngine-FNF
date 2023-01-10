package;

import flixel.FlxSprite;

using StringTools;

class Character extends FlxSprite {
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false) {
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		dance();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}

	private var danced:Bool = false;

	public function dance() {
		if (debugMode) return;
	}
}
