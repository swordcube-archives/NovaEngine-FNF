package music;

import states.PlayState;
import music.SongFormat.SongData;
import flixel.system.FlxSound;
import flixel.util.FlxSignal.FlxTypedSignal;

@:dox(hide)
typedef BPMChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}

@:dox(hide)
typedef TimeScaleChangeEvent = {
	var stepTime:Int;
	var songTime:Float;
	var timeScale:Array<Int>;
}

class Conductor {
	/**
	 * A signal that runs when a beat is hit.
	 */
	public static var onBeatHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

	/**
	 * A signal that runs when a step is hit.
	 */
	public static var onStepHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

	/**
	 * A signal that runs when a measure is hit.
	 */
	public static var onMeasureHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal();

	/**
	 * A signal that runs when a BPM change happens.
	 */
	public static var onBPMChange:FlxTypedSignal<Float->Void> = new FlxTypedSignal();

	/**
	 * Current BPM.
	 */
	public static var bpm:Float = 0;

	/**
	 * Current speed of the song.
	 */
	public static var rate:Float = 1;

	/**
	 * Current Crochet (time per beat), in milliseconds.
	 */
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds

	/**
	 * Current StepCrochet (time per step), in milliseconds.
	 */
	public static var stepCrochet:Float = (crochet / 4); // steps in milliseconds

	/**
	 * Number of beats per mesure (top number in time signature). Defaults to 4.
	 */
	public static var beatsPerMeasure:Int = 4;

	/**
	 * Number of steps per beat (bottom number in time signature). Defaults to 4.
	 */
	public static var stepsPerBeat:Int = 4;

	/**
	 * Current position of the song, in milliseconds.
	 */
	public static var songPosition:Float;

	/**
	 * Current step
	 */
	public static var curStep:Int = 0;

	/**
	 * Current beat
	 */
	public static var curBeat:Int = 0;

	/**
	 * Current measure
	 */
	public static var curMeasure:Int = 0;

	/**
	 * Current step, as a `Float` (ex: 4.94, instead of 4)
	 */
	public static var preciseStep:Float = 0;

	/**
	 * Current beat, as a `Float` (ex: 1.24, instead of 1)
	 */
	public static var preciseBeat:Float = 0;

	/**
	 * Current measure, as a `Float` (ex: 1.24, instead of 1)
	 */
	public static var preciseMeasure:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];
	public static var timeScaleChangeMap:Array<TimeScaleChangeEvent> = [];

	public static var stepsPerSection:Int = 16;

	static var oldStep:Int = 0;
	static var storedSteps:Array<Int> = [];
	static var skippedSteps:Array<Int> = [];

	public static function init() {
		FlxG.signals.preUpdate.add(update);
		reset();
	}

	public static function reset() {
		songPosition = preciseBeat = preciseStep = preciseMeasure = curBeat = curStep = curMeasure = 0;
		bpmChangeMap = [];
		timeScaleChangeMap = [];
		storedSteps = [];
		skippedSteps = [];
	}

	public static function update() {
		if (bpm <= 0)
			return;

		// Handle BPM & Timescale changes
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		};
		for (change in Conductor.bpmChangeMap) {
			if (Conductor.songPosition >= change.songTime)
				lastChange = change;
		}

		if (lastChange.bpm > 0 && bpm != lastChange.bpm)
			changeBPM(lastChange.bpm);

		var dumb:TimeScaleChangeEvent = {
			stepTime: 0,
			songTime: 0,
			timeScale: [4, 4]
		};

		var lastTimeChange:TimeScaleChangeEvent = dumb;
		for (i in 0...Conductor.timeScaleChangeMap.length) {
			if (Conductor.songPosition >= Conductor.timeScaleChangeMap[i].songTime)
				lastTimeChange = Conductor.timeScaleChangeMap[i];
		}

		if (lastTimeChange != dumb) {
			Conductor.beatsPerMeasure = lastTimeChange.timeScale[0];
			Conductor.stepsPerBeat = lastTimeChange.timeScale[1];
		}

		// Handles beats, steps, and measures
		preciseStep = lastChange.stepTime + ((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
		preciseBeat = preciseStep / stepsPerBeat;
		preciseMeasure = preciseBeat / beatsPerMeasure;

		curStep = Std.int(preciseStep);

		var trueStep:Int = curStep;
		for (i in storedSteps)
			if (i < oldStep)
				storedSteps.remove(i);

		for (i in oldStep...trueStep) {
			if (!storedSteps.contains(i) && i > 0) {
				curStep = i;
				stepHit(true, true);
				skippedSteps.push(i);
			}
		}
		if (skippedSteps.length > 0)
			skippedSteps = [];

		curStep = trueStep;

		if (oldStep != curStep && curStep > 0 && !storedSteps.contains(curStep)) {
			var updateBeat:Bool = curBeat != (curBeat = Std.int(preciseBeat));
			var updateMeasure:Bool = updateBeat && (curMeasure != (curMeasure = Std.int(preciseMeasure)));
			stepHit(updateBeat, updateMeasure);
		}

		oldStep = curStep;
	}

	public static function stepHit(updateBeat:Bool, updateMeasure:Bool) {
		onStepHit.dispatch(curStep);
		if (updateBeat)
			onBeatHit.dispatch(curBeat);

		if (updateMeasure)
			onMeasureHit.dispatch(curMeasure);

		if (!storedSteps.contains(curStep))
			storedSteps.push(curStep);
	}

	public static function mapBPMChanges(song:SongData) {
		bpmChangeMap = [];
		timeScaleChangeMap = [];

		var curBPM:Float = song.bpm;
		var curTimeScale:Array<Int> = [beatsPerMeasure, stepsPerBeat];
		var totalSteps:Int = 0;
		var totalPos:Float = 0;

		for (i in 0...song.sections.length) {
			if (song.sections[i].changeBPM && song.sections[i].bpm != curBPM) {
				curBPM = song.sections[i].bpm;

				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};

				bpmChangeMap.push(event);
			}

			if (song.sections[i].changeTimeScale
				&& song.sections[i].timeScale[0] != curTimeScale[0]
				&& song.sections[i].timeScale[1] != curTimeScale[1])
			{
				curTimeScale = song.sections[i].timeScale;

				var event:TimeScaleChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					timeScale: curTimeScale
				};

				timeScaleChangeMap.push(event);
			}

			var deltaSteps:Int = Math.floor((16 / curTimeScale[1]) * curTimeScale[0]);
			totalSteps += deltaSteps;

			totalPos += ((60 / curBPM) * 1000 / curTimeScale[0]) * deltaSteps;
		}

		recalculateStuff();
	}

	public static function changeBPM(newBpm:Float, ?beatsPerMeasure:Float = 4, ?stepsPerBeat:Float = 4) {
		bpm = newBpm;
		recalculateStuff();
		onBPMChange.dispatch(bpm);
	}

	public static function recalculateStuff() {
		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / stepsPerBeat;

		Conductor.beatsPerMeasure = beatsPerMeasure;
		Conductor.stepsPerBeat = stepsPerBeat;

		stepsPerSection = Math.floor((16 / stepsPerBeat) * beatsPerMeasure);
	}

	public static function isAudioSynced(sound:FlxSound) {
		var resyncTime:Float = 20 * sound.pitch;
		return !(sound.time > songPosition + resyncTime || sound.time < songPosition - resyncTime);
	}
}
