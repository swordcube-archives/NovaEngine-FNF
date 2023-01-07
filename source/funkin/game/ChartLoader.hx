package funkin.game;

import funkin.game.Song;

using StringTools;

enum abstract EngineFormat(String) to String from String {
    var AUTO_DETECT = "AUTO_DETECT"; // Automatically detect the chart format
    var FNF = "FNF"; // Specifically vanilla Funkin' charts
    var PSYCH = "PSYCH"; // Specifically Psych 0.6.3+ iirc
    var FUNKIN_FOREVER = "FUNKIN_FOREVER"; // Specifically Funkin' Forever charts
}

/**
 * This class is used to load and save charts.
 * 
 * ### You can save charts into the following formats:
 * 
 * `FNF` - Vanilla Funkins' chart format
 * 
 * `PSYCH` - Psych Engine 0.6.3+ chart format
 * 
 * `FUNKIN_FOREVER` - Funkin' Forever's chart format
 * 
 * ### You can load all of these formats too.
 */
class ChartLoader {
    public static var fallbackSong:Song = {
        name: "Test",
        bpm: 150.0,
        sections: [],
        events: [],
        keyAmount: 4,
        scrollSpeed: 2,
        needsVoices: true,

        stage: "default",
        dad: "bf-pixel",
        gf: "gf",
        bf: "bf",

        uiSkin: "default",
        noteSkin: "default",
        splashSkin: "default"
    };

    public static function load(?format:Null<EngineFormat> = AUTO_DETECT, path:String):Song {
        if(format == null) format = AUTO_DETECT;
        
        switch(format) {
            case FNF:
                if(Paths.exists(path)) {
                    var vanillaChart:LegacySong = cast Json.parse(Assets.getText(path)).song;

                    var sections:Array<Section> = [];
                    for(section in vanillaChart.notes) {
                        if(section != null) {
                            var coolSex:Section = {
                                notes: [],
                                playerSection: section.mustHitSection,
                                altAnim: section.altAnim,
                                bpm: section.bpm,
                                changeBPM: section.changeBPM,
                                lengthInSteps: section.lengthInSteps
                            }
                            for(note in section.sectionNotes) {
                                var altAnim:Bool = section.altAnim;
                                if(note[3] != null && note[3]) altAnim = note[3];

                                coolSex.notes.push({
                                    strumTime: note[0],
                                    direction: Std.int(note[1]),
                                    sustainLength: note[2],
                                    altAnim: altAnim,
                                    type: "Default"
                                });
                            }
                            sections.push(coolSex);
                        }
                    }
                    var keyAmount:Int = 4;
                    var gfVersion:String = "gf";
                    if(vanillaChart.player3 != null) gfVersion = vanillaChart.player3;
                    if(vanillaChart.gfVersion != null) gfVersion = vanillaChart.gfVersion;
                    if(vanillaChart.gf != null) gfVersion = vanillaChart.gf;
                    if(vanillaChart.keyCount != null) keyAmount = vanillaChart.keyCount;
                    if(vanillaChart.keyNumber != null) keyAmount = vanillaChart.keyNumber;
                    if(vanillaChart.mania != null) {
                        switch(vanillaChart.mania) {
                            case 1: keyAmount = 6;
                            case 2: keyAmount = 7;
                            case 3: keyAmount = 9;
                            default: keyAmount = 4;
                        }
                    }
                    return {
                        name: vanillaChart.song,
                        bpm: vanillaChart.bpm,
                        scrollSpeed: vanillaChart.speed,
                        sections: sections,
                        events: [],
                        needsVoices: vanillaChart.needsVoices,

                        keyAmount: keyAmount,
            
                        dad: vanillaChart.player2,
                        bf: vanillaChart.player1,
                        gf: gfVersion, // Ik base game charts don't have this but i am not hardcoding gfVersion
                        stage: vanillaChart.stage,

                        uiSkin: vanillaChart.uiSkin != null ? vanillaChart.uiSkin : "default",
                        noteSkin: vanillaChart.noteSkin != null ? vanillaChart.noteSkin : "Default",
                        splashSkin: vanillaChart.splashSkin != null ? vanillaChart.splashSkin : "Default"
                    };
                }

            case PSYCH:
                if(Paths.exists(path)) {
                    var psychChart:PsychSong = cast Json.parse(Assets.getText(path)).song;
                    if(psychChart.stage == null || psychChart.stage == "stage") psychChart.stage = "default";

                    var eventList:Array<EventGroup> = [];
                    var sections:Array<Section> = [];
                    for(section in psychChart.notes) {
                        if(section != null) {
                            var secBeats:Float = section.sectionBeats != null ? section.sectionBeats : 4.0;
                            var coolSex:Section = {
                                notes: [],
                                playerSection: section.mustHitSection,
                                altAnim: section.altAnim,
                                bpm: section.bpm,
                                changeBPM: section.changeBPM,
                                lengthInSteps: Std.int(secBeats * 4) // section beats is a float!!! what the fuck!!!
                            }
                            for(note in section.sectionNotes) {
                                var altAnim:Bool = section.altAnim;
                                if(note[3] != null && ((note[3] is Bool && note[3]) || (note[3] is String && note[3] == "Alt Animation")))
                                    altAnim = true;

                                coolSex.notes.push({
                                    strumTime: note[0],
                                    direction: Std.int(note[1]),
                                    sustainLength: note[2],
                                    altAnim: altAnim,
                                    type: note[3] is String ? note[3] : "Default"
                                });
                            }
                            sections.push(coolSex);
                        }
                    }
                    var gfVersion:String = "gf";
                    if(psychChart.player3 != null) gfVersion = psychChart.player3;
                    if(psychChart.gfVersion != null) gfVersion = psychChart.gfVersion;
                    for(event in psychChart.events) {
                        var convertedEventGroup:EventGroup = {
                            strumTime: event[0],
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
                                        values: ["game", shit1[0].trim(), shit1[1].trim()]
                                    });
                                    convertedEventGroup.events.push({
                                        name: eventData[1],
                                        values: ["hud", shit2[0].trim(), shit2[1].trim()]
                                    });

                                case "Change Scroll Speed":
                                    // Lazy fix (again)
                                    convertedEventGroup.events.push({
                                        name: eventData[1],
                                        values: ["opponent", eventData[2], eventData[3]]
                                    });
                                    convertedEventGroup.events.push({
                                        name: eventData[1],
                                        values: ["player", eventData[2], eventData[3]]
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
                                        values: [eventData[2], eventData[3]]
                                    });

                                default:
                                    convertedEventGroup.events.push({
                                        name: eventData[1],
                                        values: [eventData[2], eventData[3]]
                                    });
                            }
                        }
                        eventList.push(convertedEventGroup);
                    }
                    return {
                        name: psychChart.song,
                        bpm: psychChart.bpm,
                        scrollSpeed: psychChart.speed,
                        sections: sections,
                        events: eventList,
                        needsVoices: psychChart.needsVoices,

                        keyAmount: 4,
            
                        dad: psychChart.player2,
                        bf: psychChart.player1,
                        gf: gfVersion,
                        stage: psychChart.stage,

                        uiSkin: psychChart.uiSkin != null ? psychChart.uiSkin : "default",

                        // these don't work exactly how they do in psych
                        noteSkin: psychChart.arrowSkin != null ? psychChart.arrowSkin : "Default",
                        splashSkin: psychChart.splashSkin != null ? psychChart.splashSkin : "Default"
                    };
                }

            case AUTO_DETECT: // Auto-detect the chart type
                if(Paths.exists(path)) {
                    var chart:Dynamic = Json.parse(Assets.getText(path)).song;
                    if(chart.sections != null && chart.scrollSpeed != null) {
                        // Guessed "FUNKIN_FOREVER"!
                        return ChartLoader.load(FUNKIN_FOREVER, path);
                    }
                    var assNuts:Array<Dynamic> = chart.notes;
                    if(assNuts != null) {
                        for(section in assNuts) {
                            if(section.sectionBeats != null) {
                                // Guessed "PSYCH"!
                                return ChartLoader.load(PSYCH, path);
                            }
                        }
                    }
                    // If we can't guess anything else, just use "FNF"!
                    return ChartLoader.load(FNF, path);
                }

            default:
                if(Paths.exists(path))
                    return cast Json.parse(Assets.getText(path)).song;
        }
        // Fallback return
        return fallbackSong;
    }
}