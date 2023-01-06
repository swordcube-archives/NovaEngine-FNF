package funkin.game;

import flixel.math.FlxMath;
import flixel.math.FlxRect;
import funkin.system.Conductor;
import flixel.group.FlxGroup;

class UIGroup extends FlxGroup {
	/**
	 * CPU/Opponent strums.
	 */
	public var cpuStrums:StrumLine;

	/**
	 * Player strums.
	 */
	public var playerStrums:StrumLine;

	/**
	 * The group of all notes on screen.
	 */
	public var notes:NoteGroup;

	// -------------------------------------------------------------------------------------------- //

	public function new() {
		super();

		var SONG = PlayState.SONG;

		add(cpuStrums = new StrumLine(0, 50, SONG.keyAmount).generateReceptors().positionReceptors(true));
		add(playerStrums = new StrumLine(0, 50, SONG.keyAmount).generateReceptors().positionReceptors(false));
		add(notes = new NoteGroup());

        for(receptor in cpuStrums.members) {
            receptor.animation.finishCallback = function(name:String) {
                if(name == "confirm") receptor.playAnim("static");
            };
        }
	}

	public function updateSustain(note:Note) {
        if (!note.isSustainNote) return;
        note.flipY = PlayState.current.downscroll != (note.strumLine.getScrollSpeed(note) < 0);
    }

	override function update(elapsed:Float) {
		super.update(elapsed);

		notes.forEachAlive(function(note:Note) {
			if (note.noteData < 0) return;

			var receptor:Receptor = note.strumLine.members[note.noteData];
			note.setPosition(receptor.x, receptor.y - (Conductor.position - note.strumTime) * (0.45 * note.strumLine.getScrollSpeed(note)));
			updateSustain(note);
			if(note.isSustainNote) note.y += Note.swagWidth / 2;

			if (note.isSustainNote
				&& note.y + note.offset.y <= receptor.y + Note.swagWidth / 2
				&& (!note.mustPress || (note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit))))
			{
				var t = FlxMath.bound((Conductor.position - note.strumTime) / (note.height / (0.45 * note.strumLine.getScrollSpeed(note))), 0, 1);
				var swagRect = new FlxRect(0, t * note.frameHeight, note.frameWidth, note.frameHeight);

				note.clipRect = swagRect;
			}

			var noteKillRange:Float = 255;

			if (!note.mustPress) {
				// Opponent note logic
				if (note.strumTime <= Conductor.position && !note.wasGoodHit) {
					note.wasGoodHit = true;
					receptor.playAnim("confirm");
					if(!note.isSustainNote) deleteNote(note);
				}

				if (note.isSustainNote && note.wasGoodHit && note.strumTime <= Conductor.position - noteKillRange)
					deleteNote(note);
			} else {
				// Player note logic
				if (note.strumTime <= Conductor.position - noteKillRange)
					deleteNote(note);
			}
		});
	}

	public function deleteNote(note:Note) {
		note.kill();
		note.destroy();
		notes.remove(note, true);
	}
}
