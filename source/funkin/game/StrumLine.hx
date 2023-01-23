package funkin.game;

import flixel.FlxBasic;
import flixel.FlxCamera;
import funkin.scripting.events.*;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import funkin.system.Conductor;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class StrumLine extends FlxSpriteGroup {
    /**
	 * The group of all notes on screen.
	 */
	public var notes:NoteGroup;

    /**
     * Whether or not this strumline should be able to handle input.
     */
    public var handleInput:Bool = false;

    public var receptors:FlxTypedSpriteGroup<Receptor>;
	public var splashes:FlxTypedSpriteGroup<NoteSplash>;

    public var input:InputSystem;
    public var keyAmount(default, set):Null<Int>;
    function set_keyAmount(value:Null<Int>) {
        keyAmount = value;
        input.pressed = [for(i in 0...value) false];
        return value;
    }

    public function new(?x:Float = 0, ?y:Float = 0, ?keyAmount:Int = 4, ?handleInput:Bool = false) {
        super(x, y);
        add(receptors = new FlxTypedSpriteGroup<Receptor>());
		add(splashes = new FlxTypedSpriteGroup<NoteSplash>());
    	notes = new NoteGroup();

		// precache splashes
		var splash = new NoteSplash();
		var skin:String = PlayState.SONG.splashSkin;
		splash.setup(0, 0, skin, keyAmount, 0);
		splash.alpha = 0.001;
		splashes.add(splash);

        input = new InputSystem(this);
        this.keyAmount = keyAmount;
        this.handleInput = handleInput;
    }

    public function updateSustain(note:Note) {
        if (!note.isSustainNote) return;
        note.flipY = PlayState.current.downscroll != (getScrollSpeed(note) < 0);
    }

	override function update(elapsed:Float) {
		super.update(elapsed);
		notes.update(elapsed);

		var game = PlayState.current;

		notes.forEachAlive(function(note:Note) {
			if (note.noteData < 0) return;

			var receptor:Receptor = receptors.members[note.noteData];
			note.setPosition(receptor.x, receptor.y - (Conductor.position - note.strumTime) * (0.45 * getScrollSpeed(note)));
			updateSustain(note);
			if(note.isSustainNote) note.y += Note.swagWidth / 2;

			if (note.isSustainNote
				&& note.y + note.offset.y <= receptor.y + Note.swagWidth / 2
				&& (!note.mustPress || (note.wasGoodHit || (note.prevNote.wasGoodHit && !note.canBeHit))))
			{
				var t = FlxMath.bound((Conductor.position - note.strumTime) / (note.height / (0.45 * getScrollSpeed(note))), 0, 1);
				var swagRect = new FlxRect(0, t * note.frameHeight, note.frameWidth, note.frameHeight);

				note.clipRect = swagRect;
			}

			var noteKillRange:Float = 255;

			if (!note.mustPress) {
				// Opponent note logic
				if (note.strumTime <= Conductor.position && !note.wasGoodHit) {
					note.wasGoodHit = true;

					var event = game.scripts.event("onOpponentHit", new NoteHitEvent(note, "sick", "Default", true, true, true, 350, 1));
					game.eventOnNoteType(note.noteType, "onOpponentHit", event);

					if(!note.isSustainTail && !event.cancelled) {
						game.vocals.volume = 1;
						receptor.playAnim("confirm", true);
						if(!event.cancelSingAnim) game.characterSing(DAD, note.strumLine.keyAmount, note.noteData);

						if(!note.isSustainNote) deleteNote(note);
					}
				}
				if (note.strumTime <= Conductor.position - noteKillRange) {
					var event = game.scripts.event("onOpponentMiss", new NoteMissEvent(note, 0.0475));
					game.eventOnNoteType(note.noteType, "onOpponentMiss", event);

					if(!note.wasGoodHit && !event.cancelSingAnim)
						game.characterSing(DAD, note.strumLine.keyAmount, note.noteData);

					deleteNote(note);
				}
			}
			else if(note.mustPress && handleInput) {
				// Player note logic
                if (input.pressed[note.noteData] && note.strumTime <= Conductor.position && !note.wasGoodHit && note.isSustainNote) {
					note.wasGoodHit = true;

					var event = game.scripts.event("onPlayerHit", new NoteHitEvent(note, "sick", "Default", true, true, true, 0, 0));
					game.eventOnNoteType(note.noteType, "onPlayerHit", event);

					if(!note.isSustainTail && !event.cancelled) {
						receptor.playAnim("confirm", true);
						game.health += event.healthGain * 0.5;
						game.vocals.volume = 1;
						if(!event.cancelSingAnim) game.characterSing(BF, note.strumLine.keyAmount, note.noteData, note.altAnim ? "-alt" : "");
					}
				}
				if (note.strumTime <= Conductor.position - noteKillRange) {
					if(!note.wasGoodHit) {
						var event = game.scripts.event("onPlayerMiss", new NoteMissEvent(note, 0.0475));
						game.eventOnNoteType(note.noteType, "onPlayerMiss", event);

						if(!note.isSustainTail && !event.cancelled) {
							game.score -= 10;
							game.health -= event.healthLoss;
							game.accuracyPressedNotes++;
							game.vocals.volume = 0;
							if(!event.cancelSingAnim) game.characterSing(BF, note.strumLine.keyAmount, note.noteData, "miss");
							if(!note.isSustainNote) {
								game.combo = 0;
								game.misses++;
							}
							if(OptionsAPI.get("Miss Sounds"))
								CoolUtil.playSound(Paths.soundRandom("game/missnote", 1, 3), FlxG.random.float(0.1, 0.3));
						}
					}
					deleteNote(note);
				}
			}
		});
	}

	function __drawAllSustains() {
		notes.forEachAlive((note:Note) -> {
			if(!note.isSustainNote) return;
			note.draw();
		});
	}

	function __drawAllNotes() {
		notes.forEachAlive((note:Note) -> {
			if(note.isSustainNote) return;
			note.draw();
		});
	}

	override function draw() {
		// this is the goofiest shit i've ever had to do
		// for a singular setting in options
		@:privateAccess {
			var sustainsBehindReceptors:Bool = (OptionsAPI.get("Sustain Layer").toLowerCase() == "behind");

			var oldDefaultCameras = FlxCamera._defaultCameras;
			if (cameras != null)
				FlxCamera._defaultCameras = cameras;

			if(sustainsBehindReceptors) __drawAllSustains();

			// literally copy pasted from super.draw lmao
			var i:Int = 0;
			var basic:FlxBasic = null;

			while (i < length) {
				basic = members[i++];

				if (basic != null && basic.exists && basic.visible)
					basic.draw();
			}

			__drawAllNotes();
			if(!sustainsBehindReceptors) __drawAllSustains();

			FlxCamera._defaultCameras = oldDefaultCameras;
		}
	}

	public function goodNoteHit(event:NoteHitEvent, note:Note) {
		var receptor:Receptor = receptors.members[note.noteData];

		var game = PlayState.current;
		if(!note.isSustainNote && !event.cancelled) {
			game.popUpScore(event, Ranking.judgeTime(note.strumTime).name, game.combo++);

			if(event.showSplash && OptionsAPI.get("Note Splashes")) {
				var splash = splashes.recycle(NoteSplash);
				splashes.remove(splash, true);
				var skin:String = event.splashSkin != "Default" ? event.splashSkin : note.splashSkin;
				splash.setup(receptor.x - x, receptor.y - y, skin, keyAmount, note.noteData);
				splashes.add(splash);
			}
		}
		deleteNote(note);
	}

	public function deleteNote(note:Note) {
		note.kill();
		note.destroy();
		notes.remove(note, true);
	}

    public function generateReceptors():StrumLine {
        for(member in receptors.members) {
            member.kill();
            member.destroy();
            receptors.remove(member, true);
        }

        for(i in 0...keyAmount) {
            var receptor:Receptor = new Receptor(Note.swagWidth * i, 0, keyAmount, i);
            receptor.alpha = 0;
			FlxTween.tween(receptor, {alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
            receptors.add(receptor);
        }
        return this;
    }

    public function positionReceptors(?left:Bool = true) {
        screenCenter(X);
        var mult:Float = FlxG.width / 4;
        x += left ? -mult : mult;
        return this;
    }

    public function getScrollSpeed(?note:Note):Float {
		if (note != null && note.scrollSpeed != null)
			return note.scrollSpeed;

		var receptor:Receptor = note != null ? receptors.members[note.noteData] : null;
		if (receptor != null && receptor.scrollSpeed != null)
			return receptor.scrollSpeed;

		if (PlayState.current != null)
			return PlayState.current.scrollSpeed;

		return 1.0;
	}

	override function destroy() {
		input.destroy();
		super.destroy();
	}
}