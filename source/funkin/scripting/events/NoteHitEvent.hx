package funkin.scripting.events;

import funkin.game.Note;

class NoteHitEvent extends CancellableEvent {
    /**
     * The note being created.
     */
    public var note:Note;

    /**
     * The rating you got when hitting this note.
     * You can modify this to be string of text you want.
     */
    public var rating:String = "sick";

    /**
     * The score you got when hitting this note.
     * You can modify this to be any number you want.
     */
    public var score:Int = 350;

    /**
     * The accuracy you gained when hitting this note.
     * You can modify this to be any number you want.
     */
    public var accuracyGain:Float = 1;

    public function new(note:Note, rating:String, score:Int, accuracyGain:Float) {
        super();
        this.note = note;
        this.rating = rating;
        this.score = score;
        this.accuracyGain = accuracyGain;
    }
}