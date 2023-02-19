package states.menus.options.visual;

import objects.fonts.Alphabet;
import flixel.group.FlxSpriteGroup;

class Option extends FlxSpriteGroup {
	/**
	 * Whether or not this option was softcoded via a mod.
	 */
	public var isModded:Bool = false;

	public var description:String;
    public var saveData:String;

	public var alphabet:Alphabet;

	public function new(text:String, description:String, saveData:String) {
		super();
        this.description = description;
        this.saveData = saveData;
		add(alphabet = new Alphabet(0, 0, Bold, text));
	}

	public function select() {}
}
