package states.menus.options;

import flixel.input.keyboard.FlxKey;
import flixel.effects.FlxFlicker;
import objects.TrackingSprite;
import objects.ui.Note;
import flixel.math.FlxMath;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import objects.fonts.Alphabet;
import states.MusicBeat.MusicBeatSubstate;

class Control {
	public var name:String;
	public var saveData:String;

	public function new(name:String, saveData:String) {
		this.name = name;
		this.saveData = saveData;
	}
}

class ControlsMenu extends MusicBeatSubstate {
    public var bg:FNFSprite;

	public var curSelected:Int = 0;
    public var camFollow:FlxObject;

	public var categories:Array<String> = [];
	public var controlsList:Map<String, Array<Control>> = [
		"Notes" => [
			new Control("Left",			"NOTE_LEFT"),
			new Control("Down",			"NOTE_DOWN"),
			new Control("Up",			"NOTE_UP"),
			new Control("Right",		"NOTE_RIGHT"),
		],
		"UI" => [
			new Control("Up",			"UI_UP"),
			new Control("Down",			"UI_DOWN"),
			new Control("Left",			"UI_LEFT"),
			new Control("Right",		"UI_RIGHT"),
			new Control("Reset",		"RESET"),
			new Control("Accept",		"ACCEPT"),
			new Control("Pause",		"PAUSE"),
			new Control("Back",			"BACK"),
		],
		"Volume" => [
			new Control("Mute",			"VOLUME_MUTE"),
			new Control("Up",			"VOLUME_UP"),
			new Control("Down",			"VOLUME_DOWN"),
		],
		"Engine" => [
			new Control("Charter",		"CHARTER"),
			new Control("Switch Mod",	"SWITCH_MOD")
		]
	];

	public var curBind:Int = 0;
	public var changingBind:Bool = false;
	public var flicker:FlxFlicker;

	public var controlDataArray:Array<Control> = [];
	public var controlsArray:Array<Array<Alphabet>> = [];

    override function create() {
        super.create();

        if(!runDefaultCode) return;

		add(bg = new FNFSprite().loadGraphic(Paths.image("menus/base/menuBGDesat")));
		bg.scale.set(1.1, 1.1);
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xFFea71fd;
		bg.scrollFactor.set();

		call("onPreGenerateCategories", []);
		categories = ["Notes", "UI", "Volume", "Engine"];
		call("onGenerateCategories", []);

		call("onPreGenerateControls", []);
		var textSpacing:Float = 70;
		var i:Int = 0;
		for(category in categories) {
			var categoryName = new Alphabet(0, textSpacing * i, Bold, category);
			categoryName.screenCenter(X);
			categoryName.scrollFactor.x = 0;
			add(categoryName);
			i++;

			for(control in controlsList[category]) {
				controlDataArray.push(control);

				var controlName = new Alphabet(FlxG.width * 0.115, textSpacing * i, Bold, control.name);
				controlName.scrollFactor.x = 0;
				add(controlName);

				switch(category) {
					case "Notes":
						var piss:Array<String> = ["NOTE_LEFT", "NOTE_DOWN", "NOTE_UP", "NOTE_RIGHT"];
						var note = new TrackingSprite(controlName.x, controlName.y);
						note.loadGraphic(Paths.image("menus/base/options/defaultNotes"), true, 158, 158);
						note.setGraphicSize(70, 70);
						note.updateHitbox();
						note.animation.add("penis", [piss.indexOf(control.saveData)], 0, true);
						note.animation.play("penis");
						note.scrollFactor.x = 0;
						add(note);

						controlName.x += 90;
				}

				var controlBind = new Alphabet(FlxG.width * 0.53, textSpacing * i, Default, CoolUtil.keyToString(Controls.controlsList[control.saveData][0]));
				controlBind.color = 0xFF000000;
				controlBind.scrollFactor.x = 0;
				controlBind.ID = 0;
				add(controlBind);

				var controlBindAlt = new Alphabet(FlxG.width * 0.75, textSpacing * i, Default, CoolUtil.keyToString(Controls.controlsList[control.saveData][1]));
				controlBindAlt.color = 0xFF000000;
				controlBindAlt.scrollFactor.x = 0;
				controlBindAlt.ID = 1;
				add(controlBindAlt);

				controlsArray.push([controlName, controlBind, controlBindAlt]);

				i++;
			}
		}
		call("onGenerateControls", []);

		add(camFollow = new FlxObject(0, 0, 1, 1));
		var pos = getCameraPosition();
		camFollow.setPosition(pos.x, pos.y);
		FlxG.camera.follow(camFollow, null, 0.1);

		changeSelection(0, true);
    }

	override function close() {
		camFollow.setPosition(0, 0);
		FlxG.camera.snapToTarget();
        FlxG.camera.follow(null, null, 0);
		FlxG.camera.scroll.set(0, 0);
		super.close();
	}

	public function getCameraPosition() {
		return FlxPoint.get(
			0,
			FlxMath.bound(controlsArray[curSelected][0].y, 320, ((controlsArray.length + categories.length) * 70) - 320)
		);
	}

	public function changeSelection(change:Int, force:Bool = false) {
		if (change == 0 && !force)
			return;

		curSelected = FlxMath.wrap(curSelected + change, 0, controlsArray.length - 1);

		for(i => item in controlsArray) {
			for(control in item)
				control.alpha = (curSelected == i) ? 1 : 0.6;
		}

		var pos = getCameraPosition();
        camFollow.setPosition(pos.x, pos.y);
		changeSelectedBind(0, true);
	}

	public function changeSelectedBind(change:Int, force:Bool = false) {
		if (change == 0 && !force)
			return;

		curBind = FlxMath.wrap(curBind + change, 0, 1);

		for(i => text in controlsArray[curSelected]) {
			if(i == 0) continue;
			text.alpha = (curBind == text.ID) ? 1 : 0.6;
		}

		CoolUtil.playMenuSFX(SCROLL);
	}

    override public function update(elapsed:Float) {
		super.update(elapsed);

		if(!runDefaultCode) return;

		if(!changingBind) {
			changeSelection((controls.UI_DOWN_P ? 1 : 0) + (controls.UI_UP_P ? -1 : 0));
			changeSelectedBind((controls.UI_RIGHT_P ? 1 : 0) + (controls.UI_LEFT_P ? -1 : 0));

			if(controls.BACK) {
				CoolUtil.playMenuSFX(CANCEL);
				Controls.save();
				close();
			}

			if(controls.ACCEPT) {
				changingBind = true;
				var text:Alphabet = controlsArray[curSelected][curBind + 1];
				flicker = FlxFlicker.flicker(text, 0, 0.1, true, true);
				CoolUtil.playMenuSFX(SCROLL);
			}
		}
		else {
			if(FlxG.keys.justPressed.ANY) {
				changingBind = false;

				var saveData:String = controlDataArray[curSelected].saveData;
				var curKey:FlxKey = FlxG.keys.getIsDown()[0].ID;
				var text:Alphabet = controlsArray[curSelected][curBind + 1];
				text.text = CoolUtil.keyToString(curKey);
				Controls.controlsList[saveData][curBind] = curKey;

				flicker.stop();
				CoolUtil.playMenuSFX(CONFIRM);

				// Make the Flixel volume binds adjust
				switch(saveData) {
					case "VOLUME_MUTE":
						FlxG.sound.muteKeys = Controls.controlsList[saveData];
					case "VOLUME_UP":
						FlxG.sound.volumeUpKeys = Controls.controlsList[saveData];
					case "VOLUME_DOWN":
						FlxG.sound.volumeDownKeys = Controls.controlsList[saveData];
				}
			}
		}
	}
}