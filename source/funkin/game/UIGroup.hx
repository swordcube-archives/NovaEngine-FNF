package funkin.game;

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

    public function getScrollSpeed(?note:Note):Float {
        if (note != null && note.scrollSpeed != null) return note.scrollSpeed;
        var receptor:Receptor = note != null ? note.strumLine.members[note.noteData] : null;
        if (receptor != null && receptor.scrollSpeed != null) return receptor.scrollSpeed;
        if (PlayState.current != null) return PlayState.current.scrollSpeed;
        return 1.0;
    }

    public function new() {
        super();

        var SONG = PlayState.SONG;

        add(cpuStrums = new StrumLine(0, 25, SONG.keyAmount).generateReceptors().positionReceptors(true));
        add(playerStrums = new StrumLine(0, 25, SONG.keyAmount).generateReceptors().positionReceptors(false));
        add(notes = new NoteGroup());
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        notes.forEachAlive(function(note:Note) {
            var receptor:Receptor = note.strumLine.members[note.noteData];
            note.y = receptor.y - (Conductor.position - note.strumTime) * (0.45 * getScrollSpeed(note));
        });
    }
}