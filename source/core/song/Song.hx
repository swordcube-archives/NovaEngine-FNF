package core.song;

import core.song.SongFormat.SongData;

class Song {
    public static function loadChart(song:String, ?diff:String = "normal"):SongData {
        return try {
            var path:String = Paths.songJson(song, diff, true);
            Json.parse(FileSystem.exists(path) ? File.getContent(path) : '{"error":null}').song;
        } catch(e) {
            Logs.trace('Error occured while loading chart for $song on $diff difficulty: $e', ERROR);
            {
				song: "ERROR, CHECK YOUR CHART JSON!",
				player1: "bf",
				player2: "bf",
				gfVersion: "gf",
				stage: "default",
				speed: 1,
				bpm: 100,
				notes: [],
				events: [],
				changeableSkin: null,
				noteSkin: null,
				splashSkin: "noteSplashes",
				needsVoices: false,
				assetModifier: "base"
            }
        }
    }
}