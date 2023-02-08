package objects.ui;

import flixel.util.FlxSort;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.math.FlxRect;
import objects.ui.StrumLine;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import states.PlayState;
import flixel.group.FlxGroup.FlxTypedGroup;

class NoteField extends NoteGroup {
	private var game = PlayState.current;
	private var __pressedKeys:Array<Bool> = [];

	public function new() {
		super();

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
	}

	public function fillUpPressedKeys(length:Int) {
		if(!(__pressedKeys.length < length)) return;

		while(__pressedKeys.length < length)
			__pressedKeys.push(false);
	}

	public function sortHitNotes(a:Note, b:Note):Int {
		if (!a.shouldHit && b.shouldHit) return 1;
		else if (a.shouldHit && !b.shouldHit) return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	public function onKeyPress(event:KeyboardEvent) {
		var binds:Array<FlxKey> = [S,D,K,L];

		fillUpPressedKeys(binds.length);
		var data:FlxKey = binds.indexOf(event.keyCode);

		if(data == -1 || __pressedKeys[data]) return;
		__pressedKeys[data] = true;

		var receptor:Receptor = game.playerStrums.members[data];
		receptor.playAnim("pressed");

        // Initialize a list of notes that are possible to hit
        var possibleNotes:Array<Note> = [];

        // Check for notes that are possible to hit and add them to possibleNotes
        forEachAlive((note:Note) -> {
            if(!note.tooLate && note.canBeHit && note.mustPress && !note.wasGoodHit) {
                if(!note.isSustainNote) possibleNotes.push(note);
            } else
                return;
        });

        // Sort the possible notes so you can't hit like 3 notes with one input
        possibleNotes.sort(sortHitNotes);

        // Check if there are any notes to hit
        if(possibleNotes.length > 0) {
            var dontHit:Array<Bool> = [for(i in 0...game.playerStrums.keyCount) false];

            for(note in possibleNotes) {
                // Hit the note
                if(!dontHit[data] && note.noteData == data) {
                    dontHit[data] = true;

                    receptor.playAnim("confirm");
					game.goodNoteHit(note);

                    break;
                }
            }
        }
	}

	public function onKeyRelease(event:KeyboardEvent) {
		var binds:Array<FlxKey> = [S,D,K,L];

		fillUpPressedKeys(binds.length);
		var data:FlxKey = binds.indexOf(event.keyCode);

		if(data == -1) return;
		__pressedKeys[data] = false;

		var receptor:Receptor = game.playerStrums.members[data];
		receptor.playAnim("static");
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		forEach((note:Note) -> {
			if (note.noteData < 0) return;

			var strumLine:StrumLine = note.strumLine;

			var roundedSpeed = FlxMath.roundDecimal(note.getScrollSpeed(), 2);
			var downscrollMultiplier:Int = (strumLine.downscroll ? -1 : 1) * FlxMath.signOf(roundedSpeed);

			var psuedoX:Float = 25;
			var psuedoY:Float = (downscrollMultiplier * -((Conductor.position - note.strumTime) * (0.45 * Math.abs(roundedSpeed))));
			var receptor:Receptor = strumLine.members[note.noteData];

			note.x = (receptor.x - psuedoX)
                + (Math.cos(FlxAngle.asRadians(note.noteAngle)) * psuedoX)
				+ (Math.sin(FlxAngle.asRadians(note.noteAngle)) * psuedoY);

			note.y = receptor.y
                + (Math.cos(FlxAngle.asRadians(note.noteAngle)) * psuedoY) 
                + (Math.sin(FlxAngle.asRadians(note.noteAngle)) * psuedoX);

			if (note.isSustainNote) {
				if (downscrollMultiplier < 0)
					note.y -= Note.swagWidth * 0.5;
				else
					note.y += Note.swagWidth * 0.5;
			}

            // this dumb but it works
			if (downscrollMultiplier < 0 && note.isSustainNote) {
				note.y += Note.swagWidth;
				note.y -= note.height;
			}

			note.angle = -note.noteAngle;

			// automatically hitting notes for opponent
			if (strumLine.autoplay && !note.wasGoodHit && note.strumTime <= Conductor.position) {
				receptor.playAnim("confirm", true);
				note.wasGoodHit = true;
				game.vocals.volume = 1;
				if(!note.isSustainNote) destroyNote(note);
			}

			// sustain input
			if(note.isSustainNote && !strumLine.autoplay && __pressedKeys[note.noteData] && note.strumTime <= Conductor.position && !note.wasGoodHit && !note.tooLate) {
				receptor.playAnim("confirm", true);
				note.wasGoodHit = true;
				game.health += 0.023;
				game.vocals.volume = 1;
			}

			// clip rect shit!
			if (note.isSustainNote) {
				note.flipY = downscrollMultiplier < 0;

				if (strumLine.autoplay || (note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit))) {
					var t = FlxMath.bound((Conductor.position - note.strumTime) / (note.height / (0.45 * Math.abs(roundedSpeed))), 0, 1);
					var swagRect = new FlxRect(0, t * note.frameHeight, note.frameWidth, note.frameHeight);
					note.clipRect = swagRect;
				}
			}

			// kill da note when it go off screen
			if ((downscrollMultiplier < 0 && note.y > FlxG.height + note.height) || (downscrollMultiplier > 0 && note.y < -note.height)) {
				if(note.mustPress && !note.wasGoodHit) {
					game.health -= 0.0475;
					game.vocals.volume = 0;
				}

				if(!note.isSustainNote) {
					for(note in note.sustainNotes)
						note.tooLate = true;
				}
				
				destroyNote(note);
			}
		});
	}

	public function destroyNote(note:Note) {
		note.kill();
		note.destroy();
		remove(note, true);
	}

	override public function destroy() {
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyRelease);
		super.destroy();
	}
}
