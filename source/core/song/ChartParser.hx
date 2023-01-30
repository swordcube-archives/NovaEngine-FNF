package core.song;

import flixel.util.FlxSort;
import states.PlayState;
import objects.ui.Note;
import core.song.SongFormat.SongData;

class ChartParser {
    static function sortByShit(n1:Note, n2:Note):Int {
		if (n1.strumTime == n2.strumTime)
			return n1.isSustainNote ? -1 : 1;

		return FlxSort.byValues(FlxSort.ASCENDING, n1.strumTime, n2.strumTime);
	}
    
    public static function parseChart(songData:SongData) {
        var noteArray:Array<Note> = [];

        for(sectionID => section in songData.notes) {
            for(note in section.sectionNotes) {
                var game:PlayState = PlayState.current;

                var daStrumTime:Float = note[0];
				var daNoteData:Int = Std.int(note[1]);

				var gottaHitNote:Bool = section.mustHitSection;
                if(daNoteData > songData.keyCount - 1)
                    gottaHitNote = !section.mustHitSection;

                var oldNote:Note = (noteArray.length > 0 && noteArray.last() != null) ? noteArray.last() : null;

                var swagNote:Note = new Note(-9999, -9999, PlayState.changeableSkin, PlayState.SONG.keyCount, daNoteData % songData.keyCount);
                swagNote.strumTime = daStrumTime;
                swagNote.curSection = sectionID;
                swagNote.prevNote = oldNote;
                swagNote.sustainLength = note[2];
                swagNote.mustPress = gottaHitNote;
                swagNote.strumLine = gottaHitNote ? game.playerStrums : game.cpuStrums;
                swagNote.rawNoteData = daNoteData;
                noteArray.push(swagNote);

                var susLength:Int = Math.floor(swagNote.sustainLength / Conductor.stepCrochet);
                for(i in 0...susLength) {
                    var susNote:Note = new Note(-9999, -9999, PlayState.changeableSkin, PlayState.SONG.keyCount, daNoteData % songData.keyCount);
                    susNote.strumTime = daStrumTime + (Conductor.stepCrochet * i);
                    susNote.curSection = sectionID;
                    susNote.prevNote = noteArray.last();
                    susNote.mustPress = gottaHitNote;
                    susNote.strumLine = swagNote.strumLine;
                    susNote.rawNoteData = daNoteData;
                    susNote.isSustainNote = true;
                    susNote.isSustainTail = i >= susLength - 1;
                    susNote.flipY = susNote.strumLine.downscroll;
                    susNote.alpha = 0.6;
                    susNote.parentNote = swagNote;
                    susNote.stepCrochet = Conductor.stepCrochet;
                    susNote.resetAnim();
                    noteArray.push(susNote);

                    swagNote.sustainNotes.push(susNote);
                }
            }
        }

        var oldNote:Note = null;
        for(note in noteArray) {
            if(oldNote != null && !note.isSustainNote && note.noteData == oldNote.noteData && note.strumTime <= oldNote.strumTime + 2) {
                note.kill();
                note.destroy();
                noteArray.remove(note);
            }
            oldNote = note;
        }
        oldNote = null;

        noteArray.sort(sortByShit);

        return noteArray;
    }
}