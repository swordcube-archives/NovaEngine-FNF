package funkin.menus;

import funkin.system.Conductor;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import funkin.game.PlayState;
import flixel.math.FlxMath;
import funkin.ui.HealthIcon;
import openfl.media.Sound;
import sys.thread.Mutex;
import sys.thread.Thread;
import funkin.ui.Alphabet;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.game.ChartLoader;
import funkin.system.FNFSprite;
import funkin.system.MusicBeatState;
import funkin.system.Highscore;

@:dox(hide) typedef SongMetadata = {
    var name:String;
    var ?displayName:Null<String>;
    var character:String;
    var difficulties:Array<String>;
    var ?bgColor:Null<FlxColor>;
    var ?chartType:Null<EngineFormat>;
    var ?bpm:Null<Float>;
}

class FreeplayState extends MusicBeatState {
    var bgTween:FlxTween;

    public var bg:FNFSprite;
    public var scoreBG:FlxSprite;
	public var scoreText:FlxText;
	public var diffText:FlxText;
    public var lerpScore:Float = 0;
	public var intendedScore:Int = 0;

    public var songs:Array<SongMetadata> = [];
    
    public var grpSongs:FlxTypedGroup<Alphabet>;
    public var grpIcons:FlxTypedGroup<HealthIcon>;

    public var curSelected:Int = 0;
    public var curDifficulty:Int = 1;

    public var curSongPlaying:Int = -1;

	public var songThread:Thread;
	public var threadActive:Bool = true;
	public var mutex:Mutex;
	public var songToPlay:Sound;

    override function create() {
        super.create();

        if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			CoolUtil.playMusic(Paths.music("freakyMenu"));

        if(!runDefaultCode) return;

        mutex = new Mutex();

        bg = new FNFSprite().load(IMAGE, Paths.image("menus/menuBGDesat"));
        bg.screenCenter();
        add(bg);

        add(grpSongs = new FlxTypedGroup<Alphabet>());
        add(grpIcons = new FlxTypedGroup<HealthIcon>());

        loadXML();
        if(songs.length < 1) songs.push({
            name: "Tutorial",
            character: "gf",
            difficulties: ["easy", "normal", "hard"]
        });

        for(i => song in songs) {
            var songText = new Alphabet(0, (70 * i) + 30, Bold, (song.displayName != null) ? song.displayName : song.name);
            songText.isMenuItem = true;
            songText.targetY = i;
            songText.alpha = 0.6;
            songText.ID = i;
            grpSongs.add(songText);

            var icon:HealthIcon = new HealthIcon().loadIcon(song.character);
            icon.tracked = songText;
            grpIcons.add(icon);
        }

        scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.antialiasing = false;
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

        changeSelection();
        positionHighscore();
    }

	function positionHighscore() {
        scoreText.x = FlxG.width - scoreText.width - 6;
        scoreBG.scale.x = FlxG.width - scoreText.x + 6;
        scoreBG.x = FlxG.width - scoreBG.scale.x / 2;
        diffText.x = scoreBG.x + scoreBG.width / 2;
        diffText.x -= diffText.width / 2;
    }

    public function loadXML() {
        var path:String = Paths.xml("data/freeplaySongList");
        if(!Paths.exists(path)) return;

        var xml:Xml = Xml.parse(Assets.getText(path)).firstElement();
        if(xml == null) return;

        try {
            var data = new haxe.xml.Access(xml);
            for (song in data.nodes.song) {
                var songName:String = song.has.name ? song.att.name : "???";
                songs.push({
                    name: songName,
                    displayName: (song.has.displayName && song.att.displayName != "") ? song.att.displayName : songName,
                    character: song.has.character ? song.att.character : "face",
                    difficulties: song.has.difficulties ? CoolUtil.trimArray(song.att.difficulties.split(",")) : ["easy", "normal", "hard"],
                    bgColor: song.has.bgColor ? FlxColor.fromString(song.att.bgColor) : 0xFF9271FD,
                    chartType: song.has.chartType ? song.att.chartType : AUTO_DETECT,
                    bpm: song.has.bpm ? Std.parseFloat(song.att.bpm) : 100
                });
            }
        } catch(e) {
            songs = [];
			Console.error('Failed to load the freeplay song list XML: ${e.details()}');
		}
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(!runDefaultCode) return;

        if(controls.ACCEPT) {
            threadActive = false;
            var selectedDiff:String = songs[curSelected].difficulties[curDifficulty];
            var chartType:EngineFormat = (songs[curSelected].chartType != null) ? songs[curSelected].chartType : AUTO_DETECT;
            PlayState.SONG = ChartLoader.load(chartType, Paths.chart(songs[curSelected].name, selectedDiff));
            PlayState.isStoryMode = false;
            PlayState.campaignScore = 0;
            PlayState.storyDifficulty = selectedDiff;
            FlxG.switchState(new PlayState());
        }

        if(controls.UI_UP_P) changeSelection(-1);
        if(controls.UI_DOWN_P) changeSelection(1);

        if(controls.UI_LEFT_P) changeDifficulty(-1);
        if(controls.UI_RIGHT_P) changeDifficulty(1);

        lerpScore = MathUtil.fixedLerp(lerpScore, intendedScore, 0.4);
        scoreText.text = "PERSONAL BEST:" + Math.round(lerpScore);
        positionHighscore();

        if (FlxG.keys.justPressed.TAB) {
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new ModSwitcher());
		}

        if(controls.BACK) {
            threadActive = false;
            CoolUtil.playMenuSFX(2);
            FlxG.switchState(new MainMenuState());
        }

        mutex.acquire();
        if (songToPlay != null) {
            FlxG.sound.playMusic(songToPlay);
            if (FlxG.sound.music.fadeTween != null) FlxG.sound.music.fadeTween.cancel();
            FlxG.sound.music.volume = 0.0;
            FlxG.sound.music.fadeIn(1.0, 0.0, 1.0);
            FlxG.sound.music.pitch = 1;
            Conductor.bpm = songs[curSelected].bpm;
            songToPlay = null;
        }
        mutex.release();
    }

    function changeSelection(?change:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + change, 0, grpSongs.length - 1);

        if(bgTween != null) bgTween.cancel();
        var color:FlxColor = (songs[curSelected].bgColor != null) ? songs[curSelected].bgColor : 0xFF9271FD;
        bgTween = FlxTween.color(bg, 0.35, bg.color, color);

        grpSongs.forEach((member:Alphabet) -> {
            member.targetY = member.ID - curSelected;
            member.alpha = (curSelected == member.ID) ? 1 : 0.6;
        });
        CoolUtil.playMenuSFX();
        changeDifficulty();
        changeSongPlaying();
    }

    function changeDifficulty(?change:Int = 0) {
        var diffs:Array<String> = songs[curSelected].difficulties;

        curDifficulty = FlxMath.wrap(curDifficulty + change, 0, diffs.length - 1);
        intendedScore = Highscore.getScore(songs[curSelected].name.toLowerCase(), diffs[curDifficulty]);

        var arrows:Array<String> = diffs.length <= 1 ? ["", ""] : ["< ", " >"];
        diffText.text = '${arrows[0]}${diffs[curDifficulty].toUpperCase()}${arrows[1]}';
        positionHighscore();
    }

    function changeSongPlaying() {
		if(songThread == null) {
			songThread = Thread.create(function() {
				while (true) {
					if (!threadActive) return;
					var index:Null<Int> = Thread.readMessage(false);
					if (index != null) {
						if (index == curSelected && index != curSongPlaying) {
							var inst:Sound = Sound.fromFile(Assets.getPath(Paths.inst(songs[curSelected].name)));
							if (index == curSelected && threadActive && Paths.exists(Paths.inst(songs[curSelected].name))) {
								if(curSongPlaying > -1) grpIcons.members[curSongPlaying].scale.set(1,1);
								mutex.acquire();
								songToPlay = inst;
								mutex.release();
								curSongPlaying = curSelected;
							}
						}
					}
				}
			});
		}
		songThread.sendMessage(curSelected);
	}
}