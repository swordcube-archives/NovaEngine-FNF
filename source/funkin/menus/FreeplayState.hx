package funkin.menus;

import funkin.game.PlayState;
import flixel.math.FlxMath;
import funkin.ui.HealthIcon;
import funkin.ui.Alphabet;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.game.ChartLoader;
import funkin.system.FNFSprite;
import funkin.system.MusicBeatState;

typedef SongMetadata = {
    var name:String;
    var ?displayName:Null<String>;
    var character:String;
    var difficulties:Array<String>;
    var ?bgColor:Null<FlxColor>;
    var ?chartType:Null<EngineFormat>;
    var ?bpm:Null<Float>;
}

class FreeplayState extends MusicBeatState {
    public var bg:FNFSprite;

    public var songs:Array<SongMetadata> = [];
    
    public var grpSongs:FlxTypedGroup<Alphabet>;
    public var grpIcons:FlxTypedGroup<HealthIcon>;

    public var curSelected:Int = 0;

    override function create() {
        super.create();

        if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			CoolUtil.playMusic(Paths.music("freakyMenu"));

        if(!runDefaultCode) return;

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
            var songText = new Alphabet(0, (70 * i) + 30, Bold, song.name);
            songText.isMenuItem = true;
            songText.targetY = i;
            songText.alpha = 0.6;
            grpSongs.add(songText);

            var icon:HealthIcon = new HealthIcon().loadIcon(song.character);
            icon.tracked = songText;
            grpIcons.add(icon);
        }

        changeSelection();
    }

    public function loadXML() {
        var path:String = Paths.xml("data/freeplaySongList");
        if(!Paths.exists(path)) return;

        var xml:Xml = Xml.parse(Assets.getText(path)).firstElement();
        if(xml == null) return;

        try {
            var data = new haxe.xml.Access(xml);
            for (song in data.nodes.song) {
                var chartType:EngineFormat = song.has.chartType ? song.att.chartType : AUTO_DETECT;
                var bpm:Float = song.has.bpm ? Std.parseFloat(song.att.bpm) : 100;
                var songName:String = song.has.name ? song.att.name : "???";
                songs.push({
                    name: songName,
                    displayName: song.has.displayName ? song.att.displayName : songName,
                    character: song.has.character ? song.att.character : "face",
                    difficulties: song.has.difficulties ? CoolUtil.trimArray(song.att.difficulties.split(",")) : ["easy", "normal", "hard"],
                    bgColor: song.has.bgColor ? FlxColor.fromString(song.att.bgColor) : 0xFF9271FD,
                    chartType: chartType,
                    bpm: bpm
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
            PlayState.SONG = ChartLoader.load(songs[curSelected].chartType, Paths.chart(songs[curSelected].name, "hard"));
            PlayState.isStoryMode = false;
            PlayState.campaignScore = 0;
            FlxG.switchState(new PlayState());
        }

        if(controls.UI_UP_P) changeSelection(-1);
        if(controls.UI_DOWN_P) changeSelection(1);

        if (FlxG.keys.justPressed.TAB) {
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new ModSwitcher());
		}

        if(controls.BACK) FlxG.switchState(new MainMenuState());
    }

    function changeSelection(?change:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + change, 0, grpSongs.length - 1);
        for(i => member in grpSongs.members) {
            member.targetY = i - curSelected;
            member.alpha = curSelected == i ? 1 : 0.6;
        }
        CoolUtil.playMenuSFX(0);
    }
}