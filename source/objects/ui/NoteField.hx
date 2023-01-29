package objects.ui;

import flixel.math.FlxRect;
import objects.ui.StrumLine;
import flixel.math.FlxMath;
import flixel.math.FlxAngle;
import states.PlayState;
import flixel.group.FlxGroup.FlxTypedGroup;

class NoteField extends FlxTypedGroup<Note> {
	override public function update(elapsed:Float) {
		super.update(elapsed);
		forEach((note:Note) -> {
			var strumLine:StrumLine = note.strumLine;

			var roundedSpeed = FlxMath.roundDecimal(note.scrollSpeed, 2);
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
			if (downscrollMultiplier < 0) {
				note.y += receptor.height;
				note.y -= note.height;
			}

			note.angle = -note.noteAngle;

			// clip rect shit!
			var center:Float = receptor.y + Note.swagWidth * 0.5;
			if (note.isSustainNote) {
				if (downscrollMultiplier < 0) {
					if ((note.parentNote != null && note.parentNote.wasGoodHit)
						&& note.y - note.offset.y * note.scale.y + note.height >= center
						&& (strumLine.autoplay || (note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit)))) 
                    {
                        // downscroll
                        var t = FlxMath.bound((Conductor.songPosition - note.strumTime) / (note.height / (0.45 * Math.abs(roundedSpeed))), 0, 1);
                        var swagRect = new FlxRect(0, t * note.frameHeight, note.frameWidth, note.frameHeight);
                        note.clipRect = swagRect;
					}
				} else if (downscrollMultiplier > 0) {
					if ((note.parentNote != null && note.parentNote.wasGoodHit)
						&& note.y + note.offset.y * note.scale.y <= center
						&& (strumLine.autoplay || (note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit))))
                    {
                        // upscroll
                        var t = FlxMath.bound((Conductor.songPosition - note.strumTime) / (note.height / (0.45 * Math.abs(roundedSpeed))), 0, 1);
                        var swagRect = new FlxRect(0, t * note.frameHeight, note.frameWidth, note.frameHeight);
                        note.clipRect = swagRect;
					}
				}
			}

			// automatically hitting notes for opponent
			if (strumLine.autoplay && !note.wasGoodHit && note.strumTime <= Conductor.position) {
				receptor.playAnim("confirm", true);
                note.wasGoodHit = true;
                if(!note.isSustainNote) destroyNote(note);
			}

			// kill da note when it go off screen
			// if ((downscrollMultiplier < 0 && note.y > FlxG.height + note.height) || (downscrollMultiplier > 0 && note.y < -note.height))
			// 	destroyNote(note);
		});
	}

	public function destroyNote(note:Note) {
		note.kill();
		note.destroy();
		remove(note, true);
	}
}
