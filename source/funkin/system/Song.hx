package funkin.system;

import funkin.system.Section;

using StringTools;

typedef EventGroup = {
	var strumTime:Float;
	var events:Array<Event>;
}

typedef Event = {
	var name:String;
	var values:Array<String>;
}

typedef Song = {
	var name:String;
	var sections:Array<Section>;
	var events:Array<EventGroup>;
	var bpm:Float;
	var needsVoices:Bool;
	var scrollSpeed:Float;

	var keyAmount:Int;

	var bf:String;
	var dad:String;
	var gf:String;
	var stage:Null<String>;

	var uiSkin:String;
	var noteSkin:String; // "default" gets replaced with whatever note skin you have selected in options
	var splashSkin:String;

	var sustainLengthOffset:Int;
}

// Base Game
@:dox(hide)
typedef LegacySong = {
	var song:String;
	var notes:Array<LegacySection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var keyCount:Null<Int>;
	var keyNumber:Null<Int>;
	var mania:Null<Int>;

	var uiSkin:Null<String>;
	var noteSkin:Null<String>; // "default" gets replaced with whatever note skin you have selected in options
	var splashSkin:Null<String>;

	var player1:String;
	var player2:String;
	var gf:String;
	var stage:Null<String>;
	@:optional var gfVersion:String; // psych engine moment
	@:optional var player3:String; // i don't know what engines use this
}

// Psych
@:dox(hide)
typedef PsychSong = {
	var song:String;
	var notes:Array<PsychSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var player3:String;
	var gfVersion:String;
	var stage:Null<String>;
	var uiSkin:Null<String>; // not apart of base psych but fuck you
	var arrowSkin:Null<String>;
	var splashSkin:Null<String>;
	var validScore:Null<String>;
}

@:dox(hide)
typedef PsychEvent = {
	var strumTime:Float;
	var event:String;
	var value1:String;
	var value2:String;
}