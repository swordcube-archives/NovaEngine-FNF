package funkin.game;

import funkin.scripting.events.*;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import funkin.game.Ranking;

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

                    var data:Judgement = Ranking.judgeTime(note.strumTime);

                    var rating:String = data.name;
                    var score:Int = data.score;
                    var accuracyGain:Float = data.accuracyGain;
                    var doSplash:Bool = data.doSplash;

                    var event = game.scripts.event("onPlayerHit", new NoteHitEvent(note, rating, "Default", doSplash, true, true, score, accuracyGain));
					game.eventOnNoteType(note.noteType, "onPlayerHit", event);

                    if(!event.cancelled) {
                        if(!event.cancelSingAnim)
                            game.characterSing(BF, note.strumLine.keyAmount, note.noteData);
                        
                        receptor.playAnim("confirm");

                        game.health += event.healthGain;
                        game.vocals.volume = 1;

                        parent.goodNoteHit(event, note);
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
        var keyList:Array<FlxKey> = Reflect.field(OptionsAPI.save.data, 'CONTROLS_GAME_${parent.keyAmount}K');
        return keyList.indexOf(event.keyCode);
    }

	public function destroy() {
        FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
        FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
    }
}