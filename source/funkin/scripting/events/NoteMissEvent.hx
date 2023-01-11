package funkin.scripting.events;

import funkin.game.Note;

class NoteMissEvent extends CancellableEvent {
    /**
     * The note being created.
     */
    public var note:Note;

    /**
     * The amount of health you lose when missing this note.
     */
    public var healthLoss:Float = 0.0475;

    public function new(note:Note, healthLoss:Float) {
        super();
        this.note = note;
        this.healthLoss = 0.0475;
    }
}