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
     * Whether or not the rating you got hitting this note
     * should show up in gameplay.
     */
    public var showRating:Bool = true;

    /**
     * Whether or not the combo you got hitting this note
     * should show up in gameplay.
     */
    public var showCombo:Bool = true;

    /**
     * Whether or not your combo should increase when hitting this note.
     */
    public var countAsCombo:Bool = true;

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

    	/**
	 * The path to the sprites used for note ratings.
	 */
	public var ratingSprites:String = "game/judgements/default";

	/**
	 * The path to the sprites used for note combo.
	 */
	public var comboSprites:String = "game/combo/default";

    public var ratingAntialiasing:Bool = true;
    public var comboAntialiasing:Bool = true;

    public var ratingScale:Float = 0.7;
    public var comboScale:Float = 0.5;

    /**
     * The amount of health you gain when hitting this note.
     */
    public var healthGain:Float = 0.023;

    public function new(note:Note, rating:String, showRating:Bool, showCombo:Bool, countAsCombo:Bool, score:Int, accuracyGain:Float) {
        super();
        this.note = note;
        this.rating = rating;
        this.showRating = showRating;
        this.showCombo = showCombo;
        this.countAsCombo = countAsCombo;
        this.score = score;
        this.accuracyGain = accuracyGain;
    }
}