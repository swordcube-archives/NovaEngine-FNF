package states.editors;

import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.ui.FlxButton;
import openfl.net.FileReference;
import openfl.events.IOErrorEvent;
import openfl.events.Event;
import flixel.util.FlxTools;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUI;
import flixel.util.FlxColor;
import objects.ui.StrumLine.Receptor;
import objects.ui.*;
import flixel.addons.ui.FlxUITabMenu;
import flixel.group.FlxGroup;
import objects.ui.HealthIcon;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import music.SongFormat;
import flixel.math.FlxMath;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxStringUtil;
import flixel.FlxObject;
import flixel.FlxSprite;
import backend.utilities.MathUtil;
import states.MusicBeat.MusicBeatState;
import music.SongFormat;

// TODO: MODIFING SONG & SECTION DATA

class ChartingState extends MusicBeatState {
    public var __file:FileReference;

    public var SONG:SongData;

    public var bg:FlxSprite;

    public var gridBG:FlxSprite;
    public var gridBGTop:FlxSprite;
    public var gridBGBottom:FlxSprite;
    public var gridSeperator:FlxSprite;

    public var camFollow:FlxObject;
    public var dummyNote:FlxSprite;
    public var strumLine:FlxSprite;

    public var ROWS:Int = 16;
    public var COLUMNS:Int = 8;
    public var GRID_SIZE:Int = 40;

    public var selectedSection:Int = 0;

    public var vocals:FlxSound;
    public var musicList:Array<FlxSound> = [];

    public var bpmTxt:FlxText;

    public var iconP2:HealthIcon;
    public var iconP1:HealthIcon;

    public var prevRenderedNotes:FlxTypedGroup<Note>;
    public var prevRenderedSustains:FlxTypedGroup<FlxSprite>;

    public var curRenderedNotes:FlxTypedGroup<Note>;
    public var curRenderedSustains:FlxTypedGroup<FlxSprite>;

    public var nextRenderedNotes:FlxTypedGroup<Note>;
    public var nextRenderedSustains:FlxTypedGroup<FlxSprite>;

    public var strumNotes:FlxTypedGroup<Receptor>;

    public var curNoteType:Int = 0;
    public var curSelectedNote:SectionNote;

    public var noteTypeList:Array<String> = [
        "Default",
        "Alt Animation"
    ];

    // UI elements
    public var uiBox:FlxUITabMenu;

    public function yToTime(y:Float) {
        return FlxMath.remapToRange(y, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
    }

    public function timeToY(time:Float) {
        return FlxMath.remapToRange(time, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
    }

    public function sectionStartTime() {
        var daBPM:Float = SONG.bpm;
        var daPos:Float = 0;
        for (i in 0...selectedSection) {
            if (SONG.sections[i].changeBPM)
                daBPM = SONG.sections[i].bpm;
            
            daPos += 4 * (1000 * 60 / daBPM);
        }
        return daPos;
    }

    override function create() {
        super.create();

        if(!runDefaultCode) return;

        SONG = PlayState.SONG;

        Conductor.position = 0;

        add(bg = new FlxSprite().loadGraphic(Paths.image("menus/base/menuBGDesat")));
        bg.screenCenter();
        bg.scrollFactor.set();
        bg.alpha = 0.2;

        add(gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * COLUMNS, GRID_SIZE * ROWS));
        gridBG.screenCenter(X);

        add(gridBGTop = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * COLUMNS, GRID_SIZE * ROWS));
        gridBGTop.screenCenter(X);
        gridBGTop.y -= gridBG.height;

        add(gridBGBottom = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * COLUMNS, GRID_SIZE * ROWS));
        gridBGBottom.screenCenter(X);
        gridBGBottom.y += gridBG.height;

        add(gridSeperator = new FlxSprite(gridBG.x + (gridBG.width * 0.5), gridBGTop.y).makeGraphic(2, Std.int(gridBGTop.height + gridBG.height + gridBGBottom.height), 0xFF000000));
        gridSeperator.alpha = 0.4;

        for(dupeGrid in [gridBGTop, gridBGBottom])
            dupeGrid.alpha = 0.4;

        add(dummyNote = new FlxSprite(gridBG.x, gridBG.y).makeGraphic(GRID_SIZE, GRID_SIZE, 0xFFFFFFFF));
        add(strumLine = new FlxSprite(gridBG.x, gridBG.y).makeGraphic(Std.int(gridBG.width), 5, 0xFFFFFFFF));

        add(prevRenderedNotes = new FlxTypedGroup<Note>());
        add(prevRenderedSustains = new FlxTypedGroup<FlxSprite>());

        add(curRenderedSustains = new FlxTypedGroup<FlxSprite>());

        add(nextRenderedNotes = new FlxTypedGroup<Note>());
        add(nextRenderedSustains = new FlxTypedGroup<FlxSprite>());

        add(strumNotes = new FlxTypedGroup<Receptor>());
        add(curRenderedNotes = new FlxTypedGroup<Note>());

        add(iconP2 = new HealthIcon(0, 20, SONG.opponent));
        add(iconP1 = new HealthIcon(0, 20, SONG.player));

        updateIcons();

        var tabs = [
            {name: "Song", label: 'Song'},
            {name: "Section", label: 'Section'},
            {name: "Note", label: 'Note'}
        ];
        tabs.reverse();

        add(bpmTxt = new FlxText(gridBG.x + (gridBG.width + 10), 10, 0, "", 16));

        uiBox = new FlxUITabMenu(null, tabs, true);
        uiBox.resize(300, 400);
        uiBox.x = bpmTxt.x;
        uiBox.y = bpmTxt.y + 90;
        add(uiBox);

        for(obj in [uiBox, bpmTxt])
            obj.scrollFactor.set();

        add(camFollow = new FlxObject(FlxG.width * 0.5, 250, 1, 1));
        FlxG.camera.follow(camFollow, null, 1);

        loadSong(SONG.name, PlayState.storyDifficulty);

        for(i in 0...(SONG.keyCount * 2)) {
            var receptor = new Receptor(gridBG.x + (GRID_SIZE * i), gridBG.y, "default", SONG.keyCount, i % SONG.keyCount);
            receptor.setGraphicSize(GRID_SIZE, GRID_SIZE);
            receptor.updateHitbox();
            receptor.initialScale = receptor.scale.x;

            var strumLine = new StrumLine();
            strumLine.autoplay = true;
            receptor.parent = strumLine;

            strumNotes.add(receptor);
        }

        for(tab in tabs)
            initTab(tab);

        uiBox.selected_tab = 0;

        Conductor.changeBPM(SONG.bpm);
        Conductor.mapBPMChanges(SONG);

        updateGrid();
    }

    public function updateIcons() {
        for(icon in [iconP2, iconP1]) {
            icon.scrollFactor.set();
            icon.scale.set(icon.initialScale * 0.5, icon.initialScale * 0.5);
            icon.updateHitbox();
            icon.screenCenter(X);
        }

        var iconSpacing:Float = gridBG.width * 0.5;
        iconP2.x -= iconSpacing - iconP2.width;
        iconP1.x += iconSpacing - iconP1.width;
    }

    public function loadSong(name:String, ?difficulty:String = "normal") {
        FlxG.sound.playMusic(Paths.songInst(SONG.name, difficulty), 1);
        FlxG.sound.music.pause();
        FlxG.sound.music.time = 0;

        FlxG.sound.list.add(vocals = new FlxSound().loadEmbedded(Paths.songVoices(SONG.name, difficulty)));
        
        musicList = [FlxG.sound.music, vocals];
        musicList[0].onComplete = () -> {
            FlxG.sound.music.pause();
            Conductor.position = 0;
            if(vocals != null) {
                vocals.pause();
                vocals.time = 0;
            }
            selectedSection = 0;
            changeSection();
            updateGrid();
            Conductor.update();
        }
    }

    public var inputBoxes:Array<FlxUIInputText> = [];

    public function initTab(tab:{name:String, label:String}) {
        var tabGroup = new FlxUI(null, uiBox);
        tabGroup.name = tab.label;

        switch(tab.name) {
            case "Song":
                var songName = new FlxUIInputText(10, 10, 70, SONG.name, 8);
                songName.callback = (text:String, action:String) -> SONG.name = text;
                inputBoxes.push(songName);

                var needsVoices = FlxTools.makeCheckbox(10, 25, "Has voice track", SONG.needsVoices);
                needsVoices.callback = () -> SONG.needsVoices = needsVoices.checked;

                var muteInst = FlxTools.makeCheckbox(10, 200, "Mute Instrumental (Editor only)");
                muteInst.callback = () -> musicList[0].volume = (muteInst.checked) ? 1 : 0;

                var saveButton = new FlxButton(110, 8, "Save", () -> saveSong());
                var reloadSong = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", () -> loadSong(SONG.name, PlayState.storyDifficulty));
                var reloadSongJson = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", () -> {
                    PlayState.SONG = Song.loadChart(SONG.name, PlayState.storyDifficulty);
                    FlxG.resetState();
                });
                
                var autosaveButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, "Load Autosave", loadAutosave);

                var stepperSpeed = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 2);
                stepperSpeed.value = SONG.scrollSpeed;
                stepperSpeed.callback = () -> SONG.scrollSpeed = stepperSpeed.value;
        
                var stepperBPM = new FlxUINumericStepper(10, 65, 1, 100, 1, FlxMath.MAX_VALUE_INT, 3);
                stepperBPM.value = Conductor.bpm;
                stepperBPM.callback = () -> {
                    SONG.bpm = stepperBPM.value;
                    Conductor.mapBPMChanges(SONG);
                    Conductor.changeBPM(SONG.bpm);
                };

                var characters:Array<String> = Paths.getFolderContents("data/characters", false, DIRS_ONLY);
                var stages:Array<String> = Paths.getFolderContents("data/stages", false, FILES_ONLY, REMOVE_EXTENSION);
                if(stages.length < 1) stages = ["", "stage"];
                else stages.insert(0, "");

                var dropDownLabel1 = new FlxText(10, 100, 0, "Player", 8);
                var player1DropDown = new FlxUIDropDownMenu(10, 120, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), (character:String) -> {
                    SONG.player = characters[Std.parseInt(character)];
                    iconP1.loadIcon(SONG.player);
                    updateIcons();
                });
                player1DropDown.selectedLabel = SONG.player;
        
                var dropDownLabel2 = new FlxText(140, 100, 0, "Opponent", 8);
                var player2DropDown = new FlxUIDropDownMenu(140, 120, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), (character:String) -> {
                    SONG.opponent = characters[Std.parseInt(character)];
                    iconP2.loadIcon(SONG.opponent);
                    updateIcons();
                });
                player2DropDown.selectedLabel = SONG.opponent;

                var dropDownLabel3 = new FlxText(10, 150, 0, "Spectator", 8);
                var player3DropDown = new FlxUIDropDownMenu(10, 170, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), (character:String) -> SONG.spectator = characters[Std.parseInt(character)]);
                player3DropDown.selectedLabel = SONG.spectator;

                var dropDownLabel4 = new FlxText(140, 150, 0, "Stage", 8);
                var stageDropDown = new FlxUIDropDownMenu(140, 170, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), (stage:String) -> SONG.stage = stages[Std.parseInt(stage)]);
                stageDropDown.selectedLabel = SONG.stage;

                for(item in [songName, needsVoices, saveButton, reloadSong, reloadSongJson, autosaveButton, stepperSpeed, stepperBPM, dropDownLabel3, player3DropDown, dropDownLabel4, stageDropDown, dropDownLabel1, player1DropDown, dropDownLabel2, player2DropDown])
                    tabGroup.add(item);
        }

        uiBox.addGroup(tabGroup);
    }

	public function loadAutosave() {
        PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
        FlxG.resetState();
    }

    public function autosaveSong() {
        FlxG.save.data.autosave = Json.stringify({song: SONG});
        FlxG.save.flush();
    }

    public function changeSection(?change:Int) {
        if(change == null) change = 0;
        selectedSection += change;
        if(selectedSection < 0) selectedSection = 0;

        if(SONG.sections[selectedSection] == null) {
            SONG.sections.push({
                notes: [],
                stepLength: SONG.sections[SONG.sections.length - 1].stepLength,
                playerSection: SONG.sections[SONG.sections.length - 1].playerSection,
                bpm: 0,
                changeBPM: false,
                altAnim: false
            });
        }

        updateGrid();
    }

    public function initNote(dataShit:SectionNote, section:Int) {
        var strumTime:Float = dataShit.strumTime;
        var noteData:Int = dataShit.noteData;
        var sustainLength:Float = dataShit.sustainLength;
        var noteType:Dynamic = dataShit.noteType;

        var adjustedNoteData:Int = noteData;
        if(SONG.sections[section].playerSection)
            adjustedNoteData = Std.int((adjustedNoteData + SONG.keyCount) % (SONG.keyCount * 2));

        var note = new Note(-9999, -9999, PlayState.changeableSkin, SONG.keyCount, noteData % SONG.keyCount);
        note.strumTime = strumTime - SettingsAPI.noteOffset;
        note.curSection = section;
        note.sustainLength = sustainLength;
        note.rawNoteData = noteData;
        note.noteType = noteType;
        note.setGraphicSize(GRID_SIZE, GRID_SIZE);
        note.updateHitbox();
        note.x = gridBG.x + Math.floor(noteData * GRID_SIZE);
        note.y = timeToY((strumTime - sectionStartTime()));
        note.alpha = 0.4;
        note.noteData = adjustedNoteData;

        if(SONG.sections[section].playerSection)
            note.x = gridBG.x + Math.floor((noteData + SONG.keyCount) % (SONG.keyCount * 2) * GRID_SIZE);

        return note;
    }

    public function updateGrid() {
        var noteList:Array<FlxTypedGroup<Dynamic>> = [prevRenderedNotes, curRenderedNotes, nextRenderedNotes, prevRenderedSustains, curRenderedSustains, nextRenderedSustains];
        for(list in noteList) {
            for(item in list) {
                item.kill();
                item.destroy();
            }
            list.clear();
        }

        if (SONG.sections[selectedSection].changeBPM)
            Conductor.bpm = SONG.sections[selectedSection].bpm;
        else {
            // get last bpm
            var daBPM:Float = SONG.bpm;
            for (i in 0...selectedSection) {
                if (SONG.sections[i].changeBPM)
                    daBPM = SONG.sections[i].bpm;
            }
            Conductor.bpm = daBPM;
        }

        var groups:Array<Array<FlxTypedGroup<Dynamic>>> = [
            [prevRenderedNotes, prevRenderedSustains],
            [curRenderedNotes, curRenderedSustains],
            [nextRenderedNotes, nextRenderedSustains]
        ];
        var sectionsToRender = [
            selectedSection - 1,
            selectedSection,
            selectedSection + 1
        ];
        var penis:Int = 0;
        for(section in sectionsToRender) {
            if(section < 0 || section >= SONG.sections.length) {
                penis++;
                continue;
            }

            for(note in SONG.sections[section].notes) {
                var sustainLength:Float = note.sustainLength;
        
                var note = initNote(note, section);
                groups[penis][0].add(note);

                if (sustainLength > 0) {
                    var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2), note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(sustainLength, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
                    sustainVis.x -= sustainVis.width * 0.5;
                    groups[penis][1].add(sustainVis);
                }
            }

            penis++;
        }
    }

    public function addNote() {
        var strumTime:Float = yToTime(dummyNote.y) + sectionStartTime();
        var noteData:Int = Math.floor((FlxG.mouse.x - gridBG.x) / GRID_SIZE);

        if(SONG.sections[selectedSection].playerSection)
            noteData = Math.floor((noteData + SONG.keyCount) % (SONG.keyCount * 2));

        SONG.sections[selectedSection].notes.push({
            strumTime: strumTime, 
            noteData: noteData, 
            sustainLength: 0, 
            noteType: noteTypeList[curNoteType]
        });
        curSelectedNote = SONG.sections[selectedSection].notes[SONG.sections[selectedSection].notes.length - 1];

        curRenderedNotes.add(initNote(curSelectedNote, selectedSection));
    }

    public function selectNote(note:Note) {
        var swagNum:Int = 0;

        for (i in SONG.sections[selectedSection].notes) {
            if (i.strumTime == note.strumTime && i.noteData == note.rawNoteData) {
                curSelectedNote = SONG.sections[selectedSection].notes[swagNum];
                break;
            }
            swagNum++;
        }
    }

    public function deleteNote(note:Note) {
        for (i in SONG.sections[selectedSection].notes) {
            if (i.strumTime == note.strumTime && i.noteData == note.rawNoteData) {
                if(i == curSelectedNote) curSelectedNote = null;
                SONG.sections[selectedSection].notes.remove(i);
            }
        }
        updateGrid();
    }

    public function changeNoteSustain(value:Float) {
        if (curSelectedNote != null) {
            if (curSelectedNote.sustainLength != null) {
                curSelectedNote.sustainLength += value;
                curSelectedNote.sustainLength = Math.max(curSelectedNote.sustainLength, 0);
            }
        }
        updateGrid();
    }

    var autosaveTimer:Float = 0;
    var autosaveInterval:Float = 5000;

    var colorSine:Float = 0;

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(!runDefaultCode) return;

        autosaveTimer += elapsed;
        if(autosaveTimer >= autosaveInterval) {
            autosaveSong();
            autosaveTimer = 0;
        }

        vocals.volume = (SONG.needsVoices) ? 1 : 0;

        var iconLerp:Float = 0.15;

        var P2Scale:Float = (SONG.sections[selectedSection].playerSection) ? iconP2.initialScale * 0.4 : iconP2.initialScale * 0.5;
        var P2Alpha:Float = (SONG.sections[selectedSection].playerSection) ? 0.6 : 1;
        iconP2.scale.set(MathUtil.lerp(iconP2.scale.x, P2Scale, iconLerp), MathUtil.lerp(iconP2.scale.y, P2Scale, iconLerp));
        iconP2.alpha = MathUtil.lerp(iconP2.alpha, P2Alpha, iconLerp);

        var P1Scale:Float = (SONG.sections[selectedSection].playerSection) ? iconP1.initialScale * 0.5 : iconP1.initialScale * 0.4;
        var P1Alpha:Float = (SONG.sections[selectedSection].playerSection) ? 1 : 0.6;
        iconP1.scale.set(MathUtil.lerp(iconP1.scale.x, P1Scale, iconLerp), MathUtil.lerp(iconP1.scale.y, P1Scale, iconLerp));
        iconP1.alpha = MathUtil.lerp(iconP1.alpha, P1Alpha, iconLerp);

        if(FlxG.keys.justPressed.SPACE) {
            if(musicList[0].playing) {
                for(music in musicList) {
                    music.pause();
                    music.time = Conductor.position;
                }
            } else {
                for(music in musicList) {
                    music.time = Conductor.position;
                    music.play();
                }
            }
        } else if(controls.ACCEPT) {
            persistentUpdate = false;
            persistentDraw = true;
            PlayState.SONG = SONG;
            autosaveSong();

            for(obj in [gridBG, gridBGTop, gridBGBottom, gridSeperator, prevRenderedNotes, curRenderedNotes, nextRenderedNotes, prevRenderedSustains, curRenderedSustains, nextRenderedSustains, dummyNote, strumLine]) {
                obj.kill();
                obj.destroy();
                remove(obj, true);
            }

            for(music in musicList)
                music.stop();

            FlxG.switchState(new PlayState());
            return;
        }

        if(FlxG.mouse.wheel != 0) {
            Conductor.position -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
            if(Conductor.position < 0)
                Conductor.position = 0;

            if(Conductor.position >= FlxG.sound.music.length) {
                Conductor.position = 0;
                selectedSection = 0;
                changeSection();
                Conductor.update();
            }

            for(music in musicList) {
                music.pause();
                music.time = Conductor.position;
            }
        }

        if(musicList[0].playing)
            Conductor.position = musicList[0].time;

        if(Conductor.position >= FlxG.sound.music.length) {
            Conductor.position = 0;
            selectedSection = 0;
            changeSection();
        }

        if(Conductor.position < sectionStartTime()) {
            changeSection(-1);
            Conductor.update();
            for(music in musicList) {
                music.pause();
                music.time = Conductor.position;
            }
        }

        if(Conductor.position > sectionStartTime() + (4 * (1000 * (60 / Conductor.bpm)))) {
            changeSection(1);
            Conductor.position = sectionStartTime();
            Conductor.update();
            var playing = musicList[0].playing;
            for(music in musicList) {
                music.pause();
                music.time = Conductor.position;
                if(playing)
                    music.play();
            }
        }

        var left:Bool = (FlxG.keys.justPressed.A || FlxG.keys.justPressed.LEFT);
        var right:Bool = (FlxG.keys.justPressed.D || FlxG.keys.justPressed.RIGHT);

        if(left || right) {
            changeSection((right ? 1 : 0) + (left ? -1 : 0));

            Conductor.position = sectionStartTime();
            if(Conductor.position >= FlxG.sound.music.length) {
                Conductor.position = 0;
                selectedSection = 0;
                changeSection();
            }
            Conductor.update();

            for(music in musicList) {
                music.pause();
                music.time = Conductor.position;
            }
        }

        if(musicList[0].playing && !Conductor.isAudioSynced(musicList[0])) {
            for(music in musicList) {
                music.pause();
                music.time = Conductor.position;
                music.play();
            }
        }

        Conductor.update();

        var mousePos = [
            Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE,
            (FlxG.keys.pressed.SHIFT) ? FlxG.mouse.y : Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE
        ];
        var dummyVisible:Bool = (
            mousePos[0] >= gridBG.x &&
            mousePos[0] <= (gridBG.x + gridBG.width) - GRID_SIZE &&
            mousePos[1] >= gridBG.y &&
            mousePos[1] <= (gridBG.y + gridBG.height) - GRID_SIZE
        );

        if(dummyVisible) {
            dummyNote.setPosition(
                mousePos[0],
                mousePos[1]
            );
        }

        if(FlxG.mouse.justPressed) {
            if (FlxG.mouse.overlaps(curRenderedNotes)) {
                curRenderedNotes.forEach((note:Note) -> {
                    if(!FlxG.mouse.overlaps(note)) return;

                    if(FlxG.keys.pressed.CONTROL)
                        selectNote(note);
                    else
                        deleteNote(note);
                });
            } else if(dummyVisible)
                addNote();
        }

        if(curSelectedNote != null) {
            if (FlxG.keys.justPressed.Q)
                changeNoteSustain(-Conductor.stepCrochet);

            if (FlxG.keys.justPressed.E)
                changeNoteSustain(Conductor.stepCrochet);
        }

        curRenderedNotes.forEach((note:Note) -> {
            note.color = 0xFFFFFFFF;

            if (curSelectedNote != null && curSelectedNote.strumTime == note.strumTime && curSelectedNote.noteData == note.rawNoteData) {
                colorSine += FlxG.elapsed;
                var colorVal:Float = 0.7 + Math.sin(Math.PI * colorSine) * 0.3;
                note.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal, 0.999); //Alpha can't be 100% or the color won't be updated for some reason, good job flixel devs
            }

            if(yToTime(note.y) + (Conductor.stepCrochet / 4) <= Conductor.position - sectionStartTime()) {
                if(musicList[0].playing && note.noteData >= 0 && note.alpha == 1) {
                    FlxG.sound.play(Paths.sound("game/hitsound"));
                    var receptor:Receptor = strumNotes.members[note.noteData];
                    receptor.playAnim("confirm", true);
                    receptor.cpuAnimTimer += (note.sustainLength / 1000);
                }
                note.alpha = 0.4;
            } else
                note.alpha = 1;
        });

        strumLine.y = timeToY(Conductor.position - sectionStartTime());
        camFollow.y = strumLine.y + 50;
        strumNotes.forEach((receptor:Receptor) -> receptor.y = strumLine.y);
        FlxG.camera.snapToTarget();

        bpmTxt.text = (FlxStringUtil.formatTime(Conductor.position / 1000)
            + " / "
            + FlxStringUtil.formatTime(FlxG.sound.music.length / 1000)
            + "\nBeat: "
            + curBeat
            + "\nStep: "
            + curStep
            + "\nSection: "
            + selectedSection
        );
    }

    public function saveSong() {
        var data:String = Json.stringify({song: SONG});

        if (data != null && data.length > 0) {
            __file = new FileReference();
            __file.addEventListener(Event.COMPLETE, onSaveComplete);
            __file.addEventListener(Event.CANCEL, onSaveCancel);
            __file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            __file.save(data.trim(), SONG.name.toLowerCase() + ".json");
        }
    }

	function onSaveComplete(_):Void {
        __file.removeEventListener(Event.COMPLETE, onSaveComplete);
        __file.removeEventListener(Event.CANCEL, onSaveCancel);
        __file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        __file = null;
    }

    function onSaveCancel(_):Void {
        __file.removeEventListener(Event.COMPLETE, onSaveComplete);
        __file.removeEventListener(Event.CANCEL, onSaveCancel);
        __file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        __file = null;
    }

    function onSaveError(_):Void {
        __file.removeEventListener(Event.COMPLETE, onSaveComplete);
        __file.removeEventListener(Event.CANCEL, onSaveCancel);
        __file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
        __file = null;
    }
}