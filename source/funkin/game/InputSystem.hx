package funkin.game;

import funkin.scripting.events.*;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * The class for handling note input in gameplay.
 */
class InputSystem implements IFlxDestroyable {
    public var parent:StrumLine;
    public var pressed:Array<Bool> = [];

    public function new(parent:StrumLine) {
        this.parent = parent;
        pressed = [for(i in 0...parent.keyAmount) false];
        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
        FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
    }

    public function onKeyPress(event:KeyboardEvent) {
        var direction:Int = directionFromEvent(event);

        var game = PlayState.current;

        if(pressed[direction] || direction == -1 || !parent.handleInput) return;
        pressed[direction] = true;

        var receptor:Receptor = parent.receptors.members[direction];
        receptor.playAnim("pressed");

        // Initialize a list of notes that are possible to hit
        var possibleNotes:Array<Note> = [];

        // Check for notes that are possible to hit and add them to possibleNotes
        parent.notes.forEachAlive(function(note:Note) {
            if(!note.tooLate && note.canBeHit && note.mustPress && !note.wasGoodHit) {
                if(!note.isSustainNote) possibleNotes.push(note);
            } else
                return;
        });

        // Sort the possible notes so you can't hit like 3 notes with one input
        possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

        // Check if there are any notes to hit
        if(possibleNotes.length > 0) {
            var dontHit:Array<Bool> = [for(i in 0...parent.keyAmount) false];
            var stackedTimes:Array<Float> = [for(i in 0...parent.keyAmount) -1];

            for(note in possibleNotes) {
                // Hit the note
                if(!dontHit[note.noteData] && note.noteData == direction) {
                    stackedTimes[note.noteData] = note.strumTime;
                    dontHit[note.noteData] = true;

                    var rating:String = "sick";
                    var score:Int = 350;
                    var accuracyGain:Float = 1;

                    var event = game.scripts.event("onPlayerHit", new NoteHitEvent(note, rating, score, accuracyGain));
					game.eventOnNoteType(note.noteType, "onPlayerHit", event);

                    if(!event.cancelled) {
                        game.characterSing(BF, note.strumLine.keyAmount, note.noteData);
                        receptor.playAnim("confirm");

                        game.health += 0.023;
                        game.vocals.volume = 1;

                        parent.deleteNote(note);
                    }
                    continue;
                }
                // Get rid of any stacked notes
                if(note.noteData == direction && note.strumTime - stackedTimes[note.noteData] <= 2)
                    parent.deleteNote(note);
            }
        }
    }

    public function onKeyRelease(event:KeyboardEvent) {
        var direction:Int = directionFromEvent(event);

        if(direction == -1 || !parent.handleInput) return;
        pressed[direction] = false;

        var receptor:Receptor = parent.receptors.members[direction];
        receptor.playAnim("static");
    }

    public function directionFromEvent(event:KeyboardEvent) {
        var keyList:Array<FlxKey> = cast Reflect.field(Preferences.save.GAME_controls, parent.keyAmount+"K");
        for(i => key in keyList) {
            if(event.keyCode == key)
                return i;
        }
        return -1;
    }

	public function destroy() {
        FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
        FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
    }
}