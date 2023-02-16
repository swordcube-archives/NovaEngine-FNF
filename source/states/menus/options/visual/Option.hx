package states.menus.options.visual;

import objects.fonts.Alphabet;
import flixel.group.FlxSpriteGroup;

class Option extends FlxSpriteGroup {
	public var alphabet:Alphabet;

    public function new(text:String) {
        super();
        add(alphabet = new Alphabet(0, 0, Bold, text));
    }

    public function select() {}
}