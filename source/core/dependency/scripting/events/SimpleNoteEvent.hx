package core.dependency.scripting.events;

import objects.ui.*;

class SimpleNoteEvent extends CancellableEvent {
    /**
     * The note that belongs to this event.
     * Modify it in anyway you like.
     */
    public var note:Note;

    public function new(note:Note) {
        super();
        this.note = note;
    }
}