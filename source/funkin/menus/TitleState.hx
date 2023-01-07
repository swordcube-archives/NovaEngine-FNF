package funkin.menus;

import flixel.input.keyboard.FlxKey;
import funkin.system.Conductor;
import funkin.system.MusicBeatState;
import funkin.system.FNFSprite;
import haxe.xml.Access;
import flixel.util.typeLimit.OneOfTwo;
import funkin.ui.Alphabet;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

typedef TitleXMLSpriteVisibility = {
	var spriteName:String;
	var visible:Bool;
}

typedef TitleXMLLines = Array<OneOfTwo<String, TitleXMLSpriteVisibility>>;

class IntroText {
	public var lines:TitleXMLLines;

	public function new(?lines:Null<TitleXMLLines>) {
		if(lines == null) lines = [];
		this.lines = lines;
	}

	public function show() {
		var state = cast(FlxG.state, TitleState);
		state.deleteCoolText();

		for(sprite in state.shownSprites)
			sprite.visible = false;

		if (lines == null || lines.length <= 0) return;

		for(e in lines) {
			if (e is String) {
				var text:String = cast e;
				for(k=>e in state.curWacky) text = text.replace('{introText${k+1}', e);
				state.addMoreText(text);
			} else if (e is Dynamic) {
				var data:TitleXMLSpriteVisibility = e;
				if (data.spriteName == "" || data.spriteName == null) continue;

				var sprite:Dynamic = state.script.get(data.spriteName);
				@:privateAccess
				if(sprite == null) sprite = Reflect.getProperty(state, data.spriteName);
				if(sprite == null || !(sprite is FlxSprite || sprite is FNFSprite)) continue;

				sprite.visible = data.visible;
				state.shownSprites.push(sprite);
			}
		}
	}
}

class TitleState extends MusicBeatState {
	public static var hasCheckedUpdates:Bool = false;

	public var shownSprites:Array<Dynamic> = [];

	public var titleLines:Map<Int, IntroText> = [
		// Fallback data for if the XML can't load
		1 => new IntroText(['swordcube', 'Leather128', 'Stilic', 'Raf']),
		3 => new IntroText(['swordcube', 'Leather128', 'Stilic', 'Raf', 'present']),
		4 => new IntroText(),
		5 => new IntroText(['In association', 'with']),
		7 => new IntroText(['In association', 'with', 'newgrounds', {
			spriteName: "ngSpr",
			visible: true
		}]),
		8 => new IntroText(),
		9 => new IntroText(["{introText1}"]),
		11 => new IntroText(["{introText1}", "{introText2}"]),
		12 => new IntroText(),
		13 => new IntroText(['Friday']),
		14 => new IntroText(['Friday', 'Night']),
		15 => new IntroText(['Friday', 'Night', "Funkin'"]),
	];
	public var default_titleLines:Map<Int, IntroText> = [];
	public var titleLength:Int = 16;
	
	public var startedIntro:Bool = false;
	static var initialized:Bool = false;

	public var blackScreen:FlxSprite;
	public var credGroup:FlxGroup;
	public var textGroup:FlxGroup;
	public var ngSpr:FlxSprite;

	public var curWacky:Array<String> = [];

	override public function create():Void {
		curWacky = FlxG.random.getObject(parseIntroText());
		super.create();

		for(beat => line in titleLines)
			default_titleLines[beat] = new IntroText(line.lines);

		DiscordRPC.changePresence(
			"In the Title Screen", 
			null
		);

		// hey guys..  .  it's  me. . . . ..... saster
		// YOOO IS THAT SASTICLES/?!!?!@?!@?!@?!@?

		if(runDefaultCode)
			startIntro();
	}

	public var logoBl:FlxSprite;
	public var gfDance:FlxSprite;
	public var titleText:FlxSprite;

	function loadXML() {
		// Load the intial XML Data.
		var xml:Xml = Xml.parse(Assets.getText(Paths.xml('data/titlescreen/titlescreen'))).firstElement();
		if (xml == null)
			return Console.error('Occured while loading the title screen XML: Either the XML doesn\'t exist or the "titlescreen" node is missing!');

		try {
			var data:Access = new Access(xml);

			if(data.hasNode.intro) {
				titleLines = [];
				var intro_node:Access = data.node.intro; // <- This is done to make the code look cleaner (aka instead of data.node.intro.nodes.intro)
				if (intro_node.has.length) titleLength = Std.parseInt(intro_node.att.length);

				for (text in intro_node.nodes.text) {
					var beat:Int = text.has.beat ? Std.parseInt(text.att.beat) : 0;
					var texts:Array<OneOfTwo<String, TitleXMLSpriteVisibility>> = [];
					for(e in text.elements) {
						switch(e.name) {
							case "line":
								if (!e.has.text) continue;
								texts.push(e.att.text);
								
							case "introtext":
								if (!e.has.line) continue;
								texts.push('{introText${e.att.line}}');

							case "showsprite", "hidesprite":
								if (!e.has.name) continue;
								texts.push({
									spriteName: e.att.name,
									visible: e.name == "showsprite"
								});
						}
					}
					titleLines[beat] = new IntroText(texts);
				}
			}
		} catch(e) {
			titleLines = default_titleLines;
			Console.error('Failed to load the Titlescreen XML: ${e.details()}');
		}
	}

	function startIntro() {
		startedIntro = true;
		persistentUpdate = true;

		loadXML();
			
		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('menus/titlescreen/logo');
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('menus/titlescreen/gf');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('menus/titlescreen/titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52);
		ngSpr.loadGraphic(Paths.image('menus/titlescreen/newgrounds'));
		ngSpr.visible = false;
		ngSpr.scale.set(0.8, 0.8);
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		add(ngSpr);

		new FlxTimer().start(1, function(tmr:FlxTimer) {
			if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
				CoolUtil.playMusic(Paths.music("freakyMenu"), 0, true, 1, 4);

			if (initialized)
				skipIntro();
			else
				initialized = true;
		});
	}

	function parseIntroText():Array<Array<String>> {
		var fullText:String = Assets.getText(Paths.txt('data/titlescreen/introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
			swagGoodArray.push(i.split('--'));

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float) {
        super.update(elapsed);

		if(runDefaultCode) {
			if (FlxG.sound.music != null)
				Conductor.position = FlxG.sound.music.time;

			var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;
			if (pressedEnter && startedIntro && !transitioning && skippedIntro) {
				if (titleText != null)
					titleText.animation.play('press');

				FlxG.camera.flash(FlxColor.WHITE, 1);
				CoolUtil.playMenuSFX(1);

				transitioning = true;

				new FlxTimer().start(2, function(tmr:FlxTimer) {
					FlxG.switchState(new MainMenuState());
				});
			}

			if (pressedEnter && startedIntro && !skippedIntro)
				skipIntro();
		}
	}

	public function createCoolText(textArray:Array<String>) {
		for (i in 0...textArray.length) {
			var money:Alphabet = new Alphabet(0, 0, Bold, textArray[i]);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	public function addMoreText(text:String) {
		var coolText:Alphabet = new Alphabet(0, 0, Bold, text);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	public function deleteCoolText() {
		while (textGroup.members.length > 0) {
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit(curBeat:Int) {
		if(runDefaultCode) {
			logoBl.animation.play('bump', true);
			gfDance.animation.play(curBeat % 2 == 0 ? 'danceRight' : 'danceLeft');

			if (curBeat >= titleLength)
				skipIntro();
			else {
				var introText = titleLines[curBeat];
				if (introText != null)
					introText.show();
			}
		}

		super.beatHit(curBeat);
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void {
		if (skippedIntro) return;

		remove(ngSpr);

		FlxG.camera.flash(FlxColor.WHITE, 4);
		remove(credGroup);
		skippedIntro = true;
	}
}