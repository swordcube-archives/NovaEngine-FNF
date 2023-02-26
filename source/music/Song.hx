package music;

import music.SongFormat;

enum abstract ChartFormat(String) to String from String {
	var AUTO_DETECT = "AUTO_DETECT";
	var FNF = "FNF";
	var PSYCH = "PSYCH";
	var NOVA = "NOVA";
	var CODENAME = "CODENAME";
}

class Song {
	public static final fallbackSong:SongData = {
		name: "ERROR, CHECK YOUR CHART JSON!",
		player: "bf",
		opponent: "bf",
		spectator: "gf",
		stage: "stage",
		scrollSpeed: 1,
		bpm: 100,
		sections: [],
		events: [],
		changeableSkin: null,
		splashSkin: "noteSplashes",
		needsVoices: false,
		assetModifier: "base",
		timeScale: [4, 4],
		novaChart: true
	};

	public static inline function loadFromJson(song:String, ?diff:String = "normal", ?chartFormat:ChartFormat = AUTO_DETECT) {
		return loadChart(song, diff, chartFormat);
	}

	public static inline function parseJSONshit(jsonString:String) {
		return Json.parse(jsonString);
	}

    public static function loadChart(song:String, ?diff:String = "normal", ?chartFormat:ChartFormat = AUTO_DETECT):SongData {
		var data:SongData = null;

		// Actually parse the chart
		switch(chartFormat) {
			case AUTO_DETECT:
				if(FileSystem.exists(Paths.songJson(song, diff, true))) {
					var chartOG:Dynamic = Paths.songJson(song, diff);
					if(chartOG.song == null) return fallbackSong;

                    var chart:Dynamic = chartOG.song;
                    if(chart.novaChart) {
                        // Guessed "NOVA"!
                        return loadChart(song, diff, NOVA);
                    }
                    var assNuts:Array<Dynamic> = chart.notes;
                    if(assNuts != null) {
                        for(section in assNuts) {
                            if(section.sectionBeats != null) {
                                // Guessed "PSYCH"!
                                return loadChart(song, diff, PSYCH);
                            }
                        }
                    }
                    // If we can't guess anything else, just guess "FNF"!
                    return loadChart(song, diff, FNF);
                }

			case FNF:
				var fnfChart:VanillaSongData = try {
					var path:String = Paths.songJson(song, diff, true);
					Json.parse(FileSystem.exists(path) ? File.getContent(path) : Json.stringify({song: fallbackSong})).song;
				} catch(e) {
					Logs.trace('Error occured while loading chart for $song on $diff difficulty: $e', ERROR);
					null;
				};
				if(fnfChart.stage == null) fnfChart.stage = "stage";

				var eventList:Array<EventGroup> = [];
				var sections:Array<SectionData> = [];

				if(fnfChart.events != null) {
					for(item in fnfChart.events) {
						if(item is Array)
							trace("Found an event that the engine can't parse: "+item);
						else if(item is Dynamic)
							eventList.push(item);
					}
				}

				var prevSteps:Int = (fnfChart.notes[0] != null) ? fnfChart.notes[0].lengthInSteps : 16;
				for(section in fnfChart.notes) {
					if(section == null) continue;

					var coolSex:SectionData = {
						notes: [],
						playerSection: section.mustHitSection,
						altAnim: section.altAnim,
						bpm: section.bpm,
						changeBPM: section.changeBPM,
						changeTimeScale: (prevSteps != section.lengthInSteps),
						timeScale: [Std.int(section.lengthInSteps / 4), 4]
					}
					for(note in section.sectionNotes) {
						var altAnim:Bool = section.altAnim;
						if(note[3] != null && note[3]) altAnim = note[3];

						coolSex.notes.push({
							strumTime: note[0],
							noteData: Std.int(note[1]),
							sustainLength: note[2],
							noteType: "Default"
						});
					}
					prevSteps = section.lengthInSteps;
					sections.push(coolSex);
				}

				var keyCount:Int = 4;
				var gfVersion:String = "gf";
				var assetModifier:String = "base";
				var changeableSkin:String = "default";
				var splashSkin:String = "noteSplashes";

				if(fnfChart.player3 != null) gfVersion = fnfChart.player3;
				if(fnfChart.gfVersion != null) gfVersion = fnfChart.gfVersion;
				if(fnfChart.gf != null) gfVersion = fnfChart.gf;
				if(fnfChart.keyCount != null) keyCount = fnfChart.keyCount;
				if(fnfChart.keyNumber != null) keyCount = fnfChart.keyNumber;
				if(fnfChart.assetModifier != null) assetModifier = fnfChart.assetModifier;
				if(fnfChart.changeableSkin != null) changeableSkin = fnfChart.changeableSkin;
				if(fnfChart.splashSkin != null) splashSkin = fnfChart.splashSkin;

				if(fnfChart.mania != null) {
					switch(fnfChart.mania) {
						case 1: keyCount = 6;
						case 2: keyCount = 7;
						case 3: keyCount = 9;
						default: keyCount = 4;
					}
				}
				data = {
					name: fnfChart.song,
					bpm: fnfChart.bpm,
					scrollSpeed: fnfChart.speed,
					sections: sections,
					events: eventList,
					needsVoices: fnfChart.needsVoices,

					keyCount: keyCount,
		
					opponent: fnfChart.player2,
					player: fnfChart.player1,
					spectator: gfVersion,
					stage: fnfChart.stage,

					assetModifier: assetModifier,
					changeableSkin: changeableSkin,
					splashSkin: splashSkin,
					timeScale: [4, 4],

					novaChart: true
				};

			case PSYCH:
				var psychChart:VanillaSongData = try {
					var path:String = Paths.songJson(song, diff, true);
					Json.parse(FileSystem.exists(path) ? File.getContent(path) : Json.stringify({song: fallbackSong})).song;
				} catch(e) {
					Logs.trace('Error occured while loading chart for $song on $diff difficulty: $e', ERROR);
					null;
				};
				if(psychChart.stage == null) psychChart.stage = "stage";

				var eventList:Array<EventGroup> = [];
				var sections:Array<SectionData> = [];

				var prevBeats:Int = (psychChart.notes[0] != null) ? Std.int(psychChart.notes[0].sectionBeats) : 4;
				for(section in psychChart.notes) {
					if(section == null) continue;

					var coolSex:SectionData = {
						notes: [],
						playerSection: section.mustHitSection,
						altAnim: section.altAnim,
						bpm: section.bpm,
						changeBPM: section.changeBPM,
						changeTimeScale: (prevBeats != Std.int(section.sectionBeats)),
						timeScale: [Std.int(section.sectionBeats), 4]
					}
					for(note in section.sectionNotes) {
						var altAnim:Bool = section.altAnim;
						if(note[3] != null && note[3]) altAnim = note[3];

						coolSex.notes.push({
							strumTime: note[0],
							noteData: Std.int(note[1]),
							sustainLength: note[2],
							noteType: "Default"
						});
					}
					prevBeats = Std.int(section.sectionBeats);
					sections.push(coolSex);
				}

				var gfVersion:String = "gf";
				var splashSkin:String = "noteSplashes";

				if(psychChart.player3 != null) gfVersion = psychChart.player3;
				if(psychChart.gfVersion != null) gfVersion = psychChart.gfVersion;
				if(psychChart.gf != null) gfVersion = psychChart.gf;
				if(psychChart.splashSkin != null) splashSkin = psychChart.splashSkin;

				for(event in psychChart.events) {
					var convertedEventGroup:EventGroup = {
						time: event[0],
						events: []
					};
					for (i in 0...event[1].length) {
						var eventData:Array<Dynamic> = [event[0], event[1][i][0], event[1][i][1], event[1][i][2]];
						switch(eventData[1]) {
							case "Screen Shake":
								// Lazy fix
								var shit1:Array<String> = eventData[2].split(",");
								var shit2:Array<String> = eventData[3].split(",");
								convertedEventGroup.events.push({
									name: eventData[1],
									parameters: ["game", shit1[0].trim(), shit1[1].trim()]
								});
								convertedEventGroup.events.push({
									name: eventData[1],
									parameters: ["hud", shit2[0].trim(), shit2[1].trim()]
								});

							case "Change Scroll Speed":
								// Lazy fix (again)
								convertedEventGroup.events.push({
									name: eventData[1],
									parameters: ["opponent", eventData[2], eventData[3]]
								});
								convertedEventGroup.events.push({
									name: eventData[1],
									parameters: ["player", eventData[2], eventData[3]]
								});

							case "Change Character":
								// because in psych 0 = bf and 1 = dad
								// even though the charter says otherwise
								if(eventData[2] == "0")
									eventData[2] = "1";
								else if(eventData[2] == "1")
									eventData[2] = "0";
								
								convertedEventGroup.events.push({
									name: eventData[1],
									parameters: [eventData[2], eventData[3]]
								});

							default:
								convertedEventGroup.events.push({
									name: eventData[1],
									parameters: [eventData[2], eventData[3]]
								});
						}
					}
					eventList.push(convertedEventGroup);
				}

				data = {
					name: psychChart.song,
					bpm: psychChart.bpm,
					scrollSpeed: psychChart.speed,
					sections: sections,
					events: [],
					needsVoices: psychChart.needsVoices,

					keyCount: 4,
		
					opponent: psychChart.player2,
					player: psychChart.player1,
					spectator: gfVersion,
					stage: psychChart.stage,

					assetModifier: "base",
					changeableSkin: "default",
					splashSkin: splashSkin,
					timeScale: [(psychChart.notes[0] != null) ? Std.int(psychChart.notes[0].sectionBeats * 4) : 16, 4],

					novaChart: true
				};
			
			case NOVA: // gonna do soon

			default: // fuck you
		}

		// Fix it up and return it

		if(data != null) {	
			var defaultFields:Array<Array<Dynamic>> = [
				["gfVersion", "gf"],
				["stage", "stage"],
				["keyCount", 4]
			];
			for(item in defaultFields)
				data.setFieldDefault(item[0], item[1]);

			var fieldsToCheck:Array<Array<String>> = [
				["player3", "gfVersion"],
				["gf", "gfVersion"]
			];
			for(item in fieldsToCheck) {
				var penis = Reflect.field(data, item[0]);
				if(penis != null)
					Reflect.setField(data, item[1], penis);
			}
	
			return data;
		}

		return fallbackSong;
    }
}