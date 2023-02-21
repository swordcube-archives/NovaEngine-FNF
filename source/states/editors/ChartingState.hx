package states.editors;

import haxe.io.Path;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxe.Json;
import states.MusicBeat.MusicBeatState;
import core.song.SongFormat.SectionData;
import core.song.SongFormat.SongData;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import objects.ui.*;

using StringTools;

class ChartingState extends MusicBeatState {
	public var _file:FileReference;

	public var UI_box:FlxUITabMenu;

    public var curChartSection:Int = 0;

	public static var lastMusicTime:Float = Math.NEGATIVE_INFINITY;
	public static var lastSection:Int = 0;

	public var bpmTxt:FlxText;

	public var strumLine:FlxSprite;
	public var curSong:String = 'Dadbattle';
	public var amountSteps:Int = 0;
	public var bullshitUI:FlxGroup;

	public var highlight:FlxSprite;

	public static var GRID_SIZE:Int = 40;

	public var dummyArrow:FlxSprite;

	public var curRenderedNotes:FlxTypedGroup<Note>;
	public var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	public var curRenderedNoteTypes:FlxTypedGroup<FlxText>;

	public var gridBG:FlxSprite;

	public var _song:SongData;

	public var typingShit:FlxInputText;
	public var curSelectedNote:Array<Dynamic>;

	public var tempBpm:Float = 0;

	public var vocals:FlxSound;

	public var leftIcon:HealthIcon;
	public var rightIcon:HealthIcon;

	public var playTicksBf:FlxUICheckBox;
	public var playTicksDad:FlxUICheckBox;

    public var bg:FlxSprite;

	public var noteTypes:Array<String> = ["Default"];

	override function create() {
		super.create();

        if(!runDefaultCode) return;

        add(bg = new FlxSprite().loadGraphic(Paths.image("menus/base/menuBGDesat")));
        bg.screenCenter();
        bg.alpha = 0.15;
        bg.scrollFactor.set();

		curChartSection = lastSection;

		for(item in Paths.getFolderContents("notetypes", true, FILES_ONLY))
			noteTypes.push(Path.withoutExtension(item));

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedNoteTypes = new FlxTypedGroup<FlxText>();

		if(PlayState.SONG != null)
			_song = PlayState.SONG;

        if(_song.keyCount == null)
            _song.keyCount = 4;

		leftIcon = new HealthIcon(0, 0, _song.player1);
		rightIcon = new HealthIcon(0, 0, _song.player2);
        
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		FlxG.mouse.visible = true;

		tempBpm = _song.bpm;

		addSection();

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 2), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedNoteTypes);
	}

	function addSongUI():Void {
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		check_voices.callback = () -> {
			_song.needsVoices = check_voices.checked;
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = () -> {
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			songMusic.volume = vol;
		};

		var check_mute_vocals = new FlxUICheckBox(check_mute_inst.x + 120, check_mute_inst.y - 5, null, null, "Mute Vocals (in editor)", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = () -> {
			if (vocals != null) {
				var vol:Float = 1;

				if (check_mute_vocals.checked)
					vol = 0;

				vocals.volume = vol;
			}
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", () -> {
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", () -> {
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", () -> {
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var characters:Array<String> = Paths.getFolderContents("data/characters", false, DIRS_ONLY);

		var player1DropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), (character:String) -> {
			_song.player1 = characters[Std.parseInt(character)];
            leftIcon.loadIcon(_song.player1);
            leftIcon.setGraphicSize(0, 45);
			updateHeads();
		});
		player1DropDown.selectedLabel = _song.player1;

		var player2DropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), (character:String) -> {
			_song.player2 = characters[Std.parseInt(character)];
            rightIcon.loadIcon(_song.player2);
            rightIcon.setGraphicSize(0, 45);
			updateHeads();
		});
		player2DropDown.selectedLabel = _song.player2;

        var player3DropDown = new FlxUIDropDownMenu(10, 140, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), (character:String) -> {
			_song.gfVersion = characters[Std.parseInt(character)];
		});
		player3DropDown.selectedLabel = _song.gfVersion;

		var assetModifiers:Array<String> = Paths.getFolderContents("images/UI", false, DIRS_ONLY);

		var assetModifierDropDown = new FlxUIDropDownMenu(player2DropDown.x, player2DropDown.y + 40,
			FlxUIDropDownMenu.makeStrIdLabelArray(assetModifiers, true), (character:String) -> {
				_song.assetModifier = assetModifiers[Std.parseInt(character)];
		});
		assetModifierDropDown.selectedLabel = _song.assetModifier;

		playTicksBf = new FlxUICheckBox(check_mute_inst.x, check_mute_inst.y + 25, null, null, 'Play Hitsounds (Boyfriend - in editor)', 100);
		playTicksBf.checked = false;

		playTicksDad = new FlxUICheckBox(check_mute_inst.x + 120, playTicksBf.y, null, null, 'Play Hitsounds (Opponent - in editor)', 100);
		playTicksDad.checked = false;

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(check_mute_vocals);
        tab_group_song.add(playTicksBf);
		tab_group_song.add(playTicksDad);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
        tab_group_song.add(assetModifierDropDown);
        tab_group_song.add(player3DropDown);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(player2DropDown);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine, null, 1);

		if(lastMusicTime >= 0) {
			songMusic.time = vocals.time = Conductor.position = lastMusicTime;
			Conductor.update();
		}
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void {
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 4, 999, 0);
		stepperLength.value = _song.notes[curChartSection].lengthInSteps;
		stepperLength.name = "section_length";

		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 130, 1, 1, -999, 999, 0);

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", () -> {
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap section", () -> {
			for (i in 0..._song.notes[curChartSection].sectionNotes.length) {
				var note = _song.notes[curChartSection].sectionNotes[i];
				note[1] = (note[1] + 4) % 8;
				_song.notes[curChartSection].sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alt Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	var noteTypeDropdown:FlxUIDropDownMenu;

	function addNoteUI():Void {
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';
		tab_group_note.add(stepperSusLength);

		noteTypeDropdown = new FlxUIDropDownMenu(10, 50, FlxUIDropDownMenu.makeStrIdLabelArray(noteTypes, true), (type:String) -> {
			if(curSelectedNote.length == 3)
				curSelectedNote.push(noteTypes[Std.parseInt(type)]);
			else
				curSelectedNote[3] = noteTypes[Std.parseInt(type)];

			updateGrid();
		});
		noteTypeDropdown.selectedLabel = noteTypes[0];

		tab_group_note.add(new FlxText(noteTypeDropdown.x, noteTypeDropdown.y - 15, 0, "Note Type"));
		tab_group_note.add(noteTypeDropdown);

		UI_box.addGroup(tab_group_note);
	}

	var songMusic:FlxSound;

	function loadSong(daSong:String):Void {
		if (songMusic != null)
			songMusic.stop();

		if (vocals != null)
			vocals.stop();

		songMusic = new FlxSound().loadEmbedded(Paths.songInst(daSong, PlayState.storyDifficulty), false, true);
		if (_song.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.songVoices(daSong, PlayState.storyDifficulty), false, true);
		else
			vocals = new FlxSound();
		FlxG.sound.list.add(songMusic);
		FlxG.sound.list.add(vocals);

		songMusic.play();
		vocals.play();

		pauseMusic();

		songMusic.onComplete = () -> {
			songMusic.destroy();
            vocals.destroy();
			loadSong(daSong);
			changeSection();
		};
	}

	function pauseMusic() {
		songMusic.time = Math.max(songMusic.time, 0);
		songMusic.time = Math.min(songMusic.time, songMusic.length);

		songMusic.pause();
		vocals.pause();
	}

	function generateUI():Void {
		while (bullshitUI.members.length > 0)
			bullshitUI.remove(bullshitUI.members[0], true);
		
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>) {
		if (id == FlxUICheckBox.CLICK_EVENT) {
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label) {
				case 'Must hit section':
					_song.notes[curChartSection].mustHitSection = check.checked;
					updateHeads();

				case 'Change BPM':
					_song.notes[curChartSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curChartSection].altAnim = check.checked;
			}
		} else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper)) {
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);

			switch (wname) {
				case 'section_length':
					_song.notes[curChartSection].lengthInSteps = Std.int(nums.value); // change length
					updateGrid();

				case 'song_speed':
					_song.speed = nums.value;

				case 'song_bpm':
					tempBpm = Std.int(nums.value);
					Conductor.mapBPMChanges(_song);
					Conductor.changeBPM(Std.int(nums.value));

				case 'note_susLength':
					curSelectedNote[2] = nums.value;
					updateGrid();

				case 'section_bpm':
					_song.notes[curChartSection].bpm = Std.int(nums.value);
					updateGrid();
			}
		}
	}

	var updatedSection:Bool = false;

	function sectionStartTime():Float {
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curChartSection) {
			if (_song.notes[i].changeBPM)
				daBPM = _song.notes[i].bpm;
			
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	var colorSine:Float = 0;
	var lastSongPos:Null<Float> = null;

	override function update(elapsed:Float) {
        if(!runDefaultCode) return;

		Conductor.update();

		Conductor.position = songMusic.time;
		_song.song = typingShit.text;

		var playedSound:Array<Bool> = [for(i in 0...8) false];

		curRenderedNotes.forEachAlive((note:Note) -> {
			note.alpha = 1;

			if(curSelectedNote != null) {
				var noteDataToCheck:Int = note.noteData;
				if(noteDataToCheck > -1 && note.mustPress != _song.notes[curChartSection].mustHitSection) noteDataToCheck += 4;

				if (curSelectedNote[0] == note.strumTime && ((curSelectedNote[2] == null && noteDataToCheck < 0) || (curSelectedNote[2] != null && curSelectedNote[1] == noteDataToCheck))) {
					colorSine += elapsed;
					var colorVal:Float = 0.7 + Math.sin(Math.PI * colorSine) * 0.3;
					note.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal, 0.999); //Alpha can't be 100% or the color won't be updated for some reason
				}
			}

			if (note.strumTime <= songMusic.time) {
				note.alpha = 0.4;
				var data:Int = note.noteData % _song.keyCount;

				if (songMusic.playing && !playedSound[data] && note.noteData > -1 && note.strumTime >= lastSongPos) {
					if ((playTicksBf.checked) && (note.mustPress) || (playTicksDad.checked) && (!note.mustPress)) {
						FlxG.sound.play(Paths.sound('game/hitsound'));
						playedSound[data] = true;
					}
				}
			}
		});

		strumLine.y = getYfromStrum((Conductor.position - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curChartSection].lengthInSteps));

		if (Math.ceil(strumLine.y) <= -10) {
            if(curChartSection > 0)
			    changeSection(curChartSection - 1, false);
            else
                strumLine.y = 0;
		}

		if (curBeat % 4 == 0 && curStep >= 16 * (curChartSection + 1)) {
			if (_song.notes[curChartSection + 1] == null)
				addSection();
			
			changeSection(curChartSection + 1, false);
		}
        FlxG.camera.snapToTarget();

		if (FlxG.mouse.justPressed) {
			if (FlxG.mouse.overlaps(curRenderedNotes) || FlxG.mouse.overlaps(curRenderedNoteTypes)) {
				curRenderedNotes.forEach((note:Note) -> {
					if (FlxG.mouse.overlaps(note)) {
						if (FlxG.keys.pressed.CONTROL)
							selectNote(note);
						else
							deleteNote(note);
					}
				});
			} else {
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curChartSection].lengthInSteps)) {
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curChartSection].lengthInSteps)) {
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER) {
			lastSection = curChartSection;
			lastMusicTime = songMusic.time;

			PlayState.SONG = _song;
			songMusic.stop();
			vocals.stop();
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E) {
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q) {
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.TAB) {
			if (FlxG.keys.pressed.SHIFT) {
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			} else {
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus) {
			if (FlxG.keys.justPressed.SPACE) {
				if (songMusic.playing) {
					songMusic.pause();
					vocals.pause();
				} else {
					if(lastMusicTime != Math.NEGATIVE_INFINITY) {
						songMusic.time = lastMusicTime;
						vocals.time = lastMusicTime;
						lastMusicTime = Math.NEGATIVE_INFINITY;
					}
					vocals.play();
					songMusic.play();
				}
			}

			if (FlxG.keys.justPressed.R) {
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0) {
				songMusic.pause();
				vocals.pause();

				songMusic.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = songMusic.time;

                songMusic.time = FlxMath.bound(songMusic.time, 0, songMusic.length);
                vocals.time = FlxMath.bound(vocals.time, 0, songMusic.length);
			}

			if (!FlxG.keys.pressed.SHIFT) {
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S) {
					songMusic.pause();
					vocals.pause();

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W) {
						songMusic.time -= daTime;
					} else
						songMusic.time += daTime;

					vocals.time = songMusic.time;

                    songMusic.time = FlxMath.bound(songMusic.time, 0, songMusic.length);
                    vocals.time = FlxMath.bound(vocals.time, 0, songMusic.length);
				}
			} else {
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S) {
					songMusic.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W) {
						songMusic.time -= daTime;
					} else
						songMusic.time += daTime;

					vocals.time = songMusic.time;
                    
                    songMusic.time = FlxMath.bound(songMusic.time, 0, songMusic.length);
                    vocals.time = FlxMath.bound(vocals.time, 0, songMusic.length);
				}
			}
		}

		_song.bpm = tempBpm;

		var shiftThing:Int = (FlxG.keys.pressed.SHIFT) ? 4 : 1;

		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curChartSection + shiftThing);

		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curChartSection - shiftThing);

		bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.position / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(songMusic.length / 1000, 2))
			+ "\nSection: "
			+ curChartSection
			+ "\nBeat: "
			+ curBeat
			+ "\nStep: "
			+ curStep;
            
        super.update(elapsed);

		lastSongPos = Conductor.position;
	}

	function changeNoteSustain(value:Float):Void {
		if (curSelectedNote != null) {
			if (curSelectedNote[2] != null) {
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function resetSection(songBeginning:Bool = false):Void {
		updateGrid();

		songMusic.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		songMusic.time = sectionStartTime();

		if (songBeginning) {
			songMusic.time = 0;
			curChartSection = 0;
		}

		vocals.time = songMusic.time;
		Conductor.update();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void {
		if (_song.notes[sec] != null) {
			curChartSection = sec;

			if (updateMusic) {
				songMusic.pause();
				vocals.pause();

                lastMusicTime = songMusic.time = vocals.time = sectionStartTime();
				Conductor.update();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1) {
		var daSec = FlxMath.maxInt(curChartSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes) {
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void {
		var sec = _song.notes[curChartSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void {
		if (!_song.notes[curChartSection].mustHitSection) {
			leftIcon.setPosition(gridBG.width / 2, -100);
			rightIcon.setPosition(0, -100);
		} else {
			leftIcon.setPosition(0, -100);
			rightIcon.setPosition(gridBG.width / 2, -100);
		}
	}

	function updateNoteUI():Void {
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void {
		while (curRenderedNotes.members.length > 0) {
			curRenderedNotes.members[0].destroy();
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0) {
			curRenderedSustains.members[0].destroy();
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		while (curRenderedNoteTypes.members.length > 0) {
			curRenderedNoteTypes.members[0].destroy();
			curRenderedNoteTypes.remove(curRenderedNoteTypes.members[0], true);
		}

		var sectionInfo:Array<Dynamic> = _song.notes[curChartSection].sectionNotes;

		if (_song.notes[curChartSection].changeBPM && _song.notes[curChartSection].bpm > 0) {
			Conductor.changeBPM(_song.notes[curChartSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		} else {
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curChartSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		for (i in sectionInfo) {
			var daNoteInfo = i[1];
			var daStrumTime = i[0];
			var daSus = i[2];
			var daNoteType = i[3];

			var note:Note = new Note(0, 0, PlayState.changeableSkin, _song.keyCount, daNoteInfo % _song.keyCount);
            note.strumTime = daStrumTime;
            note.rawNoteData = daNoteInfo;
			note.sustainLength = daSus;
            note.noteType = daNoteType;
			note.setGraphicSize(GRID_SIZE, GRID_SIZE);
			note.updateHitbox();
			note.x = Math.floor(daNoteInfo * GRID_SIZE);
			note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curChartSection].lengthInSteps)));
			note.mustPress = _song.notes[curChartSection].mustHitSection;

			if (daNoteInfo > (_song.keyCount - 1))
				note.mustPress = !note.mustPress;

			curRenderedNotes.add(note);

			var typeIndex:Int = noteTypes.indexOf(note.noteType);
			if(typeIndex > -1 && note.noteType != "Default") {
				var noteTypeText = new FlxText(note.x + (note.width * 0.5), note.y + (note.height * 0.5), 0, Std.string(typeIndex), 32);
				noteTypeText.setFormat(Paths.font("vcr.ttf"), 48, 0xFFFFFFFF, CENTER, OUTLINE, 0xFF000000);
				noteTypeText.borderSize = 1.25;
				noteTypeText.x -= noteTypeText.width * 0.5;
				noteTypeText.y -= noteTypeText.height * 0.5;
				curRenderedNoteTypes.add(noteTypeText);
			}

			if (daSus > 0) {
				var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2), note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
                sustainVis.x -= sustainVis.width * 0.5;
				curRenderedSustains.add(sustainVis);
			}
		}
	}

	private function addSection(lengthInSteps:Int = 16):Void {
		var sec:SectionData = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void {
		var swagNum:Int = 0;

		for (i in _song.notes[curChartSection].sectionNotes) {
			if (i[0] == note.strumTime && i[1] == note.rawNoteData) {
				curSelectedNote = _song.notes[curChartSection].sectionNotes[swagNum];
				noteTypeDropdown.selectedLabel = curSelectedNote[3] != null ? curSelectedNote[3] : "Default";
			}

			swagNum += 1;
		}

		updateNoteUI();
	}

	function deleteNote(note:Note):Void {
		var data:Null<Int> = note.noteData;

		if (data > -1 && note.mustPress != _song.notes[curChartSection].mustHitSection)
			data += 4;

		if (data > -1) {
			for (i in _song.notes[curChartSection].sectionNotes) {
				if (i[0] == note.strumTime && i[1] == data) {
					if(i == curSelectedNote) curSelectedNote = null;
					_song.notes[curChartSection].sectionNotes.remove(i);
					break;
				}
			}
		}

		updateGrid();
	}

	function clearSection():Void {
		_song.notes[curChartSection].sectionNotes = [];

		updateGrid();
	}

	function clearSong():Void {
		for (daSection in 0..._song.notes.length)
			_song.notes[daSection].sectionNotes = [];

		updateGrid();
	}

	private function addNote():Void {
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime();
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0; // ninja you will NOT get away with this

		_song.notes[curChartSection].sectionNotes.push([noteStrum, noteData, noteSus, noteTypeDropdown.selectedLabel]);

		curSelectedNote = _song.notes[curChartSection].sectionNotes[_song.notes[curChartSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL)
			_song.notes[curChartSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteTypeDropdown.selectedLabel]);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float {
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float {
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}

	function loadJson(song:String):Void {
		PlayState.SONG = Song.loadChart(song.toLowerCase(), "normal");
		FlxG.resetState();
	}

	function loadAutosave():Void {
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void {
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel() {
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0)) {
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void {
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}