package objects.ui;

import backend.scripting.events.*;
import flixel.util.FlxSort;
import flixel.input.keyboard.FlxKey;
import openfl.events.KeyboardEvent;
import flixel.math.FlxRect;
import objects.ui.StrumLine;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import states.PlayState;

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

	public var keyBinds:Array<Array<FlxKey>> = [
		Controls.controlsList["NOTE_LEFT"],
		Controls.controlsList["NOTE_DOWN"],
		Controls.controlsList["NOTE_UP"],
		Controls.controlsList["NOTE_RIGHT"],
	];

	public function keyFromEvent(eventKey:Int) {
		for (i => list in keyBinds) {
			for(key in list)
				if(key == eventKey) return i;
		}
		return -1;
	}

	public function onKeyPress(event:KeyboardEvent) {
		fillUpPressedKeys(keyBinds.length);
		var data:Int = keyFromEvent(event.keyCode);

		if(PlayState.paused || data == -1 || __pressedKeys[data] || game.playerStrums.autoplay) return;

		var event = game.scripts.event("onKeyPress", new InputSystemEvent(data));
		if(event.cancelled) return;

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
        } else {
			var e = game.scripts.event("onGhostTap", new GhostTapEvent(data));

			if(!e.cancelled)
				game.ghostMiss(e);
		}

		game.scripts.event("onKeyPressPost", event);
	}

	public function onKeyRelease(event:KeyboardEvent) {
		fillUpPressedKeys(keyBinds.length);
		var data:Int = keyFromEvent(event.keyCode);

		if(PlayState.paused || data == -1 || game.playerStrums.autoplay) return;

		var event = game.scripts.event("onKeyRelease", new InputSystemEvent(data));
		if(event.cancelled) return;

		__pressedKeys[data] = false;

		var receptor:Receptor = game.playerStrums.members[data];
		receptor.playAnim("static");

		game.scripts.event("onKeyReleasePost", event);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		forEach((note:Note) -> {
			if (note.noteData < 0) return;

			var strumLine:StrumLine = note.strumLine;

			var roundedSpeed = FlxMath.roundDecimal(note.getScrollSpeed(), 2);
			var downscrollMultiplier:Int = (strumLine.downscroll ? -1 : 1) * FlxMath.signOf(roundedSpeed);

			var psuedoX:Float = 25;
			var psuedoY:Float = (downscrollMultiplier * -((Conductor.songPosition - note.strumTime) * (0.45 * Math.abs(roundedSpeed))));
			var receptor:Receptor = strumLine.members[note.noteData];

			note.x = (receptor.x - psuedoX)
                + (Math.cos(FlxAngle.asRadians(note.noteAngle)) * psuedoX)
				+ (Math.sin(FlxAngle.asRadians(note.noteAngle)) * psuedoY)
				+ note.offsetX;

			note.y = receptor.y
                + (Math.cos(FlxAngle.asRadians(note.noteAngle)) * psuedoY) 
                + (Math.sin(FlxAngle.asRadians(note.noteAngle)) * psuedoX)
				+ note.offsetY;

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
			if (strumLine.autoplay && !note.wasGoodHit && note.strumTime <= Conductor.songPosition && note.shouldHit) {
				receptor.playAnim("confirm", true);
				game.goodNoteHit(note);
			}

			// sustain input
			if(note.isSustainNote && !strumLine.autoplay && __pressedKeys[note.noteData] && note.strumTime <= Conductor.songPosition && !note.wasGoodHit && !note.tooLate) {
				receptor.playAnim("confirm", true);
				game.goodNoteHit(note);
			}

			// clip rect shit!
			if (note.isSustainNote) {
				note.flipY = downscrollMultiplier < 0;

				if ((strumLine.autoplay && note.shouldHit) || (note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit))) {
					var t = FlxMath.bound((Conductor.songPosition - note.strumTime) / (note.height / (0.45 * Math.abs(roundedSpeed))), 0, 1);
					var swagRect = new FlxRect(0, t * note.frameHeight, note.frameWidth, note.frameHeight);
					note.clipRect = swagRect;
				}
			}

			// kill da note when it go off screen
			if (!note.wasGoodHit && ((downscrollMultiplier < 0 && note.y > FlxG.height + note.height) || (downscrollMultiplier > 0 && note.y < -note.height))) {
				var funcName:String = note.mustPress ? "onPlayerMiss" : "onOpponentMiss";
				// other function names u can use if you're used to how another engine does it
				var funcNames:Array<Array<String>> = [
					["onBfMiss", "onDadMiss"],
					["noteMiss", "opponentNoteMiss"]
				];
					
				var event = game.scripts.event(funcName, new NoteMissEvent(note, 10));
				event = game.noteTypeScripts.get(note.noteType).event(funcName, event);
		
				for(f in funcNames)
					event = game.scripts.event(note.mustPress ? f[0] : f[1], event);
		
				for(f in funcNames)
					event = game.noteTypeScripts.get(note.noteType).event(note.mustPress ? f[0] : f[1], event);

				if(!event.cancelled) {
					if(note.mustPress && !note.wasGoodHit && note.shouldHit) {
						game.health -= event.healthLoss;
						game.songScore -= event.score;

						if(!note.isSustainNote) {
							// i think a gf sad anim played
							// if you lost a combo of 10+? i forget base game shits lol
							if(game.combo >= 10) {
								if(game.gf != null)
									game.gf.playAnim("sad");
							}
							game.combo = 0;
							game.songMisses++;
						}

						game.accuracyPressedNotes++;
						game.updateScoreText();

						if(!event.cancelSingAnim) {
							var singAnim:String = "sing"+event.note.directionName.toUpperCase()+"miss";
							if(event.characters != null && event.characters.length > 0) {
								for(char in event.characters) {
									char.holdTimer = 0;
									var altShit:String = (note.altAnim && char.animation.exists(singAnim+"-alt")) ? "-alt" : "";
									char.holdTimer = 0;
									if(!char.specialAnim)
										char.playAnim(singAnim+altShit, true);
								}
							} else {
								var char:Character = (note.mustPress) ? game.boyfriend : game.dad;
								var altShit:String = (note.altAnim && char.animation.exists(singAnim+"-alt")) ? "-alt" : "";
								char.holdTimer = 0;
								if(!char.specialAnim)
									char.playAnim(singAnim+altShit, true);
							}
						}

						if(note.shouldHit)
							game.vocals.volume = 0;
					}

					if(!note.isSustainNote && note.shouldHit) {
						for(note in note.sustainNotes)
							note.tooLate = true;
					}
					
					destroyNote(note);
				}
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
