package core.song;

import core.song.SongFormat.SongData;

class Song {
	public static final fallbackSong:SongData = {
		song: "ERROR, CHECK YOUR CHART JSON!",
		player1: "bf",
		player2: "bf",
		gfVersion: "gf",
		stage: "stage",
		speed: 1,
		bpm: 100,
		notes: [],
		events: [],
		changeableSkin: null,
		splashSkin: "noteSplashes",
		needsVoices: false,
		assetModifier: "base"
	};

    public static function loadChart(song:String, ?diff:String = "normal"):SongData {
		var data:SongData = try {
            var path:String = Paths.songJson(song, diff, true);
            Json.parse(FileSystem.exists(path) ? File.getContent(path) : Json.stringify({song: fallbackSong})).song;
        } catch(e) {
            Logs.trace('Error occured while loading chart for $song on $diff difficulty: $e', ERROR);
            fallbackSong;
        };

		// fix some things about the chart for u :D
		var fieldsToCheck:Array<Array<String>> = [
			["player3", "gfVersion"],
			["gf", "gfVersion"]
		];

		for(item in fieldsToCheck) {
			var penis = Reflect.field(data, item[0]);
			if(penis != null)
				Reflect.setField(data, item[1], penis);
		}

		var defaultFields:Array<Array<Dynamic>> = [
			["gfVersion", "gf"],
			["stage", "stage"],
			["keyCount", 4]
		];
		for(item in defaultFields)
			data.setFieldDefault(item[0], item[1]);

        return data;
    }
}