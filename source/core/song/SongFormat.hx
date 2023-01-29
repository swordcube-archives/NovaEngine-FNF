package core.song;

typedef SongData = {
	var song:String;
	var notes:Array<SectionData>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
	var noteSkin:String;
	var splashSkin:String;
	var assetModifier:String;
	@:optional var keyCount:Null<Int>;
}

typedef SectionNote = Array<Dynamic>;

typedef SectionData = {
	var sectionNotes:Array<SectionNote>;
	var sectionBeats:Float; // psych engine
	var lengthInSteps:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

typedef EventData = {
    var name:String;
    var parameters:Array<String>;
}

typedef EventGroup = {
    var time:Float;
    var events:Array<EventData>;
}