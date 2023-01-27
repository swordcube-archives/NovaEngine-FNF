package core.song;

import states.PlayState;
import core.song.SongFormat.SongData;

import flixel.system.FlxSound;
import flixel.util.FlxSignal.FlxTypedSignal;

@:dox(hide)
typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

// totally not half stolen from vs impostor no i would never that's fucking impossiblre
// https://github.com/Clowfoe/IMPOSTOR-UPDATE/blob/main/source/hx
// https://github.com/Clowfoe/IMPOSTOR-UPDATE/blob/main/source/hx
// https://github.com/Clowfoe/IMPOSTOR-UPDATE/blob/main/source/hx
// https://github.com/Clowfoe/IMPOSTOR-UPDATE/blob/main/source/hx
// credit to whoever the fuck coded this LoL!

class Conductor {
	public static var bpm(default, set):Float = 100;

	static function set_bpm(v:Float) {
		crochet = ((60.0 / v) * 1000.0);
		stepCrochet = crochet / 4.0;
		return bpm = v;
	}

	// compatibility
	public static function changeBPM(?newBPM:Float = 100) {
		bpm = newBPM;
	}

	public static var rate:Float = 1.0;

	/**
	 * The time between beats in milliseconds.
	 */
	public static var crochet:Float = ((60 / bpm) * 1000.0);

	/**
	 * The time between steps in milliseconds.
	 */
	public static var stepCrochet:Float = crochet / 4.0;

	public static var position:Float = 0;

	public static var songPosition(get, set):Float;
	static function get_songPosition():Float {
		return position;
	}
	static function set_songPosition(v:Float):Float {
		return position = v;
	}

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds
	public static var ROWS_PER_BEAT = 48; // from Stepmania
	public static var BEATS_PER_MEASURE = 4; // TODO: time sigs
	public static var ROWS_PER_MEASURE = ROWS_PER_BEAT * BEATS_PER_MEASURE; // from Stepmania
	public static var MAX_NOTE_ROW = 1 << 30; // from Stepmania

	public static var onBeatHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public static var onStepHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public static var onSectionHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public static var curStep:Int = 0;
	public static var curBeat:Int = 0;

	public static var preciseStep:Float = 0;
	public static var preciseBeat:Float = 0;

	public static var curSection:Int = 0;

	static var stepsToDo:Int = 0;

	public static function init() {
		FlxG.signals.preUpdate.add(update);
		reset();
	}

	public static function reset() {
		stepsToDo = 0;
		curSection = 0;
		storedSteps = [];
		skippedSteps = [];
		onBeatHit.removeAll();
		onStepHit.removeAll();
		onSectionHit.removeAll();
	}

	static var oldStep:Int = 0;
	static var storedSteps:Array<Int> = [];
	static var skippedSteps:Array<Int> = [];

	static function getSectionSteps(song:SongData, section:Int):Int {
		var val:Null<Int> = null;
		if (song.notes[section] != null)
			val = song.notes[section].lengthInSteps;
		return val != null ? val : 16;
	}

	static function stepHit() {
		if (PlayState.SONG != null && FlxG.state == PlayState.current) {
			if (oldStep < curStep)
				updateSection();
			else
				rollbackSection();
		} else
			curSection = Std.int(curStep / 16);

		onStepHit.dispatch(curStep);
		if (curStep % 4 == 0)
			onBeatHit.dispatch(Math.floor(curStep / 4.0));

		if (!storedSteps.contains(curStep))
			storedSteps.push(curStep);
	}

	static function updateSection():Void {
		if (stepsToDo < 1)
			stepsToDo = getSectionSteps(PlayState.SONG, curSection);
		while (curStep >= stepsToDo) {
			curSection++;
			stepsToDo += getSectionSteps(PlayState.SONG, curSection);
			onSectionHit.dispatch(curSection);
		}
	}

	static function rollbackSection():Void {
		if (curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length) {
			if (PlayState.SONG.notes[i] != null) {
				stepsToDo += getSectionSteps(PlayState.SONG, curSection);
				if (stepsToDo > curStep)
					break;

				curSection++;
			}
		}

		if (curSection > lastSection)
			onSectionHit.dispatch(curSection);
	}

	public static function update() {
		curStep = getStepRounded(position);
		preciseStep = getStep(position);

		curBeat = getBeatRounded(position);
		preciseBeat = getBeat(position);

		var trueStep:Int = curStep;
		for (i in storedSteps)
			if (i < oldStep)
				storedSteps.remove(i);

		for (i in oldStep...trueStep) {
			if (!storedSteps.contains(i) && i > 0) {
				curStep = i;
				stepHit();
				skippedSteps.push(i);
			}
		}
		if (skippedSteps.length > 0)
			skippedSteps = [];

		curStep = trueStep;

		if (oldStep != curStep && curStep > 0 && !storedSteps.contains(curStep))
			stepHit();

		oldStep = curStep;
	}

	public inline static function beatToRow(beat:Float):Int
		return Math.round(beat * ROWS_PER_BEAT);

	public inline static function rowToBeat(row:Int):Float
		return row / ROWS_PER_BEAT;

	public inline static function secsToRow(sex:Float):Int
		return Math.round(getBeat(sex) * ROWS_PER_BEAT);

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public static function getBPMFromStep(step:Float) {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm
		}
		for (i in 0...bpmChangeMap.length) {
			if (bpmChangeMap[i].stepTime <= step)
				lastChange = bpmChangeMap[i];
		}

		return lastChange;
	}

	public static function getBPMFromSeconds(time:Float) {
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm
		}
		for (i in 0...bpmChangeMap.length) {
			if (time >= bpmChangeMap[i].songTime)
				lastChange = bpmChangeMap[i];
		}

		return lastChange;
	}

	public static function stepToSeconds(step:Float) {
		var lastChange = getBPMFromStep(step);
		return step * (((60 / lastChange.bpm) * 1000) / 4);
	}

	public static function beatToSeconds(beat:Float) {
		var step = beat * 4;
		var lastChange = getBPMFromStep(step);
		return lastChange.songTime + ((step - lastChange.stepTime) / (lastChange.bpm / 60) / 4) * 1000;
	}

	public static function getStep(time:Float) {
		var lastChange = getBPMFromSeconds(time);
		return lastChange.stepTime + (time - lastChange.songTime) / (((60 / lastChange.bpm) * 1000) / 4);
	}

	public static function getStepRounded(time:Float) {
		var lastChange = getBPMFromSeconds(time);
		return Math.floor(lastChange.stepTime + (time - lastChange.songTime) / (((60 / lastChange.bpm) * 1000) / 4));
	}

	public static function getBeat(time:Float) {
		return getStep(time) / 4;
	}

	public static function getBeatRounded(time:Float) {
		return Math.floor(getStepRounded(time) / 4);
	}

	public static function mapBPMChanges(song:SongData) {
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length) {
			if (song.notes[i].changeBPM && song.notes[i].bpm != curBPM) {
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = getSectionSteps(song, i);
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
	}
}
