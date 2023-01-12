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

    /**
     * Whether or not the player should play a singing animation
     * when hitting this note.
     */
    public var cancelSingAnim:Bool = false;

    public function new(note:Note, healthLoss:Float) {
        super();
        this.note = note;
        this.healthLoss = 0.0475;
    }
}