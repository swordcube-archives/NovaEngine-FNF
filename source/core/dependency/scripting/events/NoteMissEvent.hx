package core.dependency.scripting.events;

import objects.*;
import objects.ui.*;

class NoteMissEvent extends CancellableEvent {
    /**
     * The note that belongs to this event.
     * Modify it in anyway you like.
     */
    public var note:Note;

    /**
     * The score you lose when missing this note.
     */
    public var score:Int;

    /**
     * Whether or not the characters shouldn't play a missing animation when missing this note.
     */
    public var cancelSingAnim:Bool = false;

    /**
     * The amount of health you gain from missing this note.
     */
    public var healthLoss:Float = 0.0475 * SettingsAPI.healthLossMultiplier;

    /**
     * The characters that missed the note.
     * Defaults to only the Opponent or Player. (based on current section)
     */
    public var characters:Array<Character>;

    public function new(note:Note, score:Int) {
        super();
        this.note = note;
        this.score = score;
        this.cancelSingAnim = (note.noteType == "No Animation");
    }
}