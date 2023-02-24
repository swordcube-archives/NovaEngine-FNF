package core.song;

import core.dependency.scripting.events.*;
import states.PlayState;
import objects.ui.Note;
import core.song.SongFormat.SongData;
import core.dependency.ScriptHandler;

class ChartParser {    
    public static function parseChart(songData:SongData) {
        var noteArray:Array<Note> = [];

        for(sectionID => section in songData.notes) {
            for(note in section.sectionNotes) {
                var game:PlayState = PlayState.current;

                var daStrumTime:Float = note[0];
				var daNoteData:Int = Std.int(note[1]);

                var daNoteType:String = (note[3] != null && note[3] is String) ? note[3] : "Default";
                if((note[3] is Bool) && note[3] == true)
                    daNoteType = "Alt Animation"; // week 7 chart compatibility

				var gottaHitNote:Bool = section.mustHitSection;
                if(daNoteData > songData.keyCount - 1)
                    gottaHitNote = !section.mustHitSection;

                // loading note type scripts
                if(!game.noteTypeScripts.exists(daNoteType)) {
                    var script = ScriptHandler.loadModule(Paths.script('data/notetypes/$daNoteType'));
                    script.setParent(game);
                    script.call("onCreate", []);
                    game.noteTypeScripts.set(daNoteType, script);
                }

                var oldNote:Note = (noteArray.length > 0 && noteArray.last() != null) ? noteArray.last() : null;

                var swagNote:Note = new Note(-9999, -9999, PlayState.changeableSkin, PlayState.SONG.keyCount, daNoteData % songData.keyCount);
                swagNote.strumTime = daStrumTime;
                swagNote.curSection = sectionID;
                swagNote.prevNote = oldNote;
                swagNote.sustainLength = note[2];
                swagNote.mustPress = gottaHitNote;
                swagNote.strumLine = gottaHitNote ? game.playerStrums : game.cpuStrums;
                swagNote.rawNoteData = daNoteData;
                swagNote.noteType = daNoteType;
                swagNote.altAnim = (daNoteType == "Alt Animation") || section.altAnim;
                noteArray.push(swagNote);

                game.noteTypeScripts.get(daNoteType).event("onNoteCreation", new SimpleNoteEvent(swagNote));

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
                    susNote.alpha = (SettingsAPI.opaqueSustains) ? 1 : 0.6;
                    susNote.parentNote = swagNote;
                    susNote.stepCrochet = Conductor.stepCrochet;
                    susNote.noteType = daNoteType;
                    susNote.altAnim = (daNoteType == "Alt Animation") || section.altAnim;
                    susNote.resetAnim();
                    noteArray.push(susNote);

                    swagNote.sustainNotes.push(susNote);

                    game.noteTypeScripts.get(daNoteType).event("onNoteCreation", new SimpleNoteEvent(susNote));
                }
            }
        }

        // remove stacked notes so we don't have to make the
        // input system handle it

        var notesOnly:Array<Note> = [];
        for(note in noteArray) {
            if(note.isSustainNote) continue;
            notesOnly.push(note);
        }
        notesOnly.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

        var oldNote:Note = null;
        for(note in notesOnly) {
            if(oldNote != null && note.mustPress == oldNote.mustPress && note.noteData == oldNote.noteData && (note.strumTime - oldNote.strumTime) <= 5) {
                for(sus in note.sustainNotes) {
                    sus.kill();
                    sus.destroy();
                    noteArray.remove(sus);
                }
                note.kill();
                note.destroy();
                noteArray.remove(note);
            }
            oldNote = note;
        }
        oldNote = null;
        notesOnly = [];

        return noteArray;
    }
}