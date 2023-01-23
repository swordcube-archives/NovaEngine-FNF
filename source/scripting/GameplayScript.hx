package scripting;

import funkin.scripting.events.*;

/**
 * This is a list of all callbacks you can use in modcharts & stage scripts.
 */
interface GameplayScript {
	/**
	 * Triggered after the characters has been created, during PlayState's creation.
	 */
	public function create():Void;

	/**
	 * Triggered at the very end of PlayState's creation.
	 */
	public function postCreate():Void;

	/**
	 * Triggered every frame.
	 * @param elapsed Time elapsed since last frame.
	 */
	public function update(elapsed:Float):Void;

	/**
	 * Triggered at the end of every frame.
	 * @param elapsed Time elapsed since last frame.
	 */
	public function postUpdate(elapsed:Float):Void;

	/**
	 * Triggered every step
	 * @param curStep Current step.
	 */
	public function stepHit(curStep:Int):Void;

	/**
	 * Triggered every beat.
	 * @param curBeat Current beat.
	 */
	public function beatHit(curBeat:Int):Void;

	/**
	 * Triggered every countdown.
	 * @param event Countdown event.
	 */
	public function onCountdownTick(event:CountdownEvent):Void;

	/**
	 * Triggered after every countdown.
	 * @param event Countdown event.
	 */
	public function onCountdownTickPost(event:CountdownEvent):Void;


    /**
     * Triggered whenever the player hits a note.
     * @param note Event object with the note being pressed, the character who pressed it, and functions to alter or cancel the default behaviour.
     */
	public function onPlayerHit(event:NoteHitEvent):Void;

	 /**
	  * Triggered whenever the opponent hits a note.
	  * @param note Event object with the note being pressed, the character who pressed it, and functions to alter or cancel the default behaviour.
	  */
	public function onOpponentHit(event:NoteHitEvent):Void;

    /**
     * Triggered on each note creation.
     * @param event Event object containing information about the note.
     */
	public function onNoteCreation(event:NoteCreationEvent):Void;
}
