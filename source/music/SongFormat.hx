package music;

import flixel.util.typeLimit.OneOfTwo;

// Nova Engine charts
typedef EventData = {
    var name:String;
    var parameters:Array<String>;
}

typedef EventGroup = {
    var time:Float;
    var events:Array<EventData>;
}

typedef SongData = {
	var name:String;
	@:optional var displayName:String;
	var needsVoices:Bool;

	var bpm:Float;
	var sections:Array<SectionData>;
	var events:Array<EventGroup>;
	var scrollSpeed:Float;

	var opponent:String;
	var spectator:String;
	var player:String;

	var stage:String;
	@:optional var keyCount:Int; // Usually 4

	var assetModifier:String; // Usually "base"
	var changeableSkin:String; // Usually "default"
	var splashSkin:String; // Usually "noteSplashes"
	var timeScale:Array<Int>; // Measure & Steps (Default is 4/4)

	var novaChart:Bool; // Usually set to true to indicate that this is a Nova chart, if you have this value in another chart and it's set to true, Things will break.
}

typedef SectionData = {
	var playerSection:Bool;
	var notes:Array<SectionNote>;
	var altAnim:Bool;
	var changeBPM:Bool;
	var changeTimeScale:Bool;
	var bpm:Float;
	var timeScale:Array<Int>; // Measure & Steps (Default is 4/4)
}

typedef SectionNote = {
	var strumTime:Float;
	var noteData:Int;
	var sustainLength:Null<Float>;
	var noteType:OneOfTwo<String, Bool>; // Can be String (Nova / Psych charts) or Bool (Week 7 charts)
}

// Compatibility with charts not made in Nova Engine

typedef VanillaSongData = {
	var song:String;
	var notes:Array<VanillaSectionData>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var player1:String;
	var player2:String;
	@:optional var player3:String;
	@:optional var gfVersion:String;
	@:optional var gf:String;
	var stage:String;
	var changeableSkin:String;
	var splashSkin:String;
	var assetModifier:String;
	@:optional var keyCount:Null<Int>;
	@:optional var keyNumber:Null<Int>;
	@:optional var mania:Null<Int>;
}

typedef VanillaSectionNote = Array<Dynamic>;

typedef VanillaSectionData = {
	var sectionNotes:Array<VanillaSectionNote>;
	@:optional var sectionBeats:Float; // psych engine
	var lengthInSteps:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

// Psych Engine Charts
@:dox(hide)
typedef PsychSongData = {
	var song:String;
	var notes:Array<VanillaSectionData>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var player3:String;
	var gfVersion:String;
	var stage:Null<String>;
	var arrowSkin:String;
	var splashSkin:String;
	var validScore:Bool;
}

@:dox(hide)
typedef PsychEvent = {
	var strumTime:Float;
	var event:String;
	var value1:String;
	var value2:String;
}