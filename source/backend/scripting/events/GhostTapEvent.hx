package backend.scripting.events;

import objects.Character;

class GhostTapEvent extends CancellableEvent {
    /**
     * The note direction pressed/released.
     * Ranges from 0 to 3.
     */
    public var direction:Int;

    /**
     * The characters that pressed the note.
     * Defaults to only the Opponent or Player. (based on current section)
     */
     public var characters:Array<Character>;

    public function new(direction:Int) {
        super();
        this.direction = direction;
    }
}