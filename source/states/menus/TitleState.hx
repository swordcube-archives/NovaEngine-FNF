package states.menus;

import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.fonts.Alphabet;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import states.MusicBeat.MusicBeatState;

enum abstract IntroLineType(Int) to Int from Int {
	var SET = 0;
	var ADD = 1;
}

class IntroLine {
	public var type:IntroLineType;
	public var lines:Array<String>;
	public var onShow:(Int, TitleState)->Void;
	
	public function new(type:IntroLineType, lines:Array<String>, ?onShow:(Int, TitleState)->Void) {
		this.type = type;
		this.lines = lines;
		this.onShow = onShow;
	}

	public function show() {
		var state:TitleState = cast FlxG.state;

		for(i in 0...lines.length) {
			for(wackyIndex => wackyLine in state.curWacky)
				lines[i] = lines[i].replace("{introtext"+(wackyIndex+1)+"}", wackyLine);
		}

		if(type == SET) state.deleteCoolText();
		state.createCoolText(lines);
		
		if(onShow != null)
			onShow(Conductor.curBeat, state);
	}
}

class TitleState extends MusicBeatState {
	public var skippedIntro:Bool = false;
	static var initializedTransitions:Bool = false;

	public var introLines:Map<Int, IntroLine> = [
		1 => new IntroLine(ADD, ["swordcube"]),
		3 => new IntroLine(ADD, ["presents"]),
		4 => new IntroLine(SET, []), // this removes all text
		5 => new IntroLine(ADD, ["You should go", "check out"]),
		7 => new IntroLine(ADD, ["Newgrounds"], (beat:Int, state:TitleState) -> {
			state.ngSpr.alpha = 1;
		}),
		8 => new IntroLine(SET, [], (beat:Int, state:TitleState) -> {
			state.ngSpr.visible = false;
		}), // this removes all text & hides the newgrounds logo
		9 => new IntroLine(ADD, ["{introtext1}"]),
		11 => new IntroLine(ADD, ["{introtext2}"]),
		12 => new IntroLine(SET, []), // this removes all text
		13 => new IntroLine(ADD, ["Friday"]),
		14 => new IntroLine(ADD, ["Night"]),
		15 => new IntroLine(ADD, ["Funkin"])
	];
	public var introLength:Int = 16;

	public var transitioning:Bool = false;

	public var logo:FNFSprite;
	public var gfDance:FNFSprite;
	public var titleText:FNFSprite;
	public var ngSpr:FNFSprite;

	public var curWacky:Array<String> = ["???", "???"];
	public var textGroup:FlxTypedGroup<Alphabet>;

	function initTransitions() {
		initializedTransitions = true;

		var diamond = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;

        FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
            new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
        FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, 1),
            {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
	}

	override public function create() {
		curWacky = FlxG.random.getObject(parseIntroText());
		super.create();

		if(!initializedTransitions)
			initTransitions();

		if(!runDefaultCode) return;

		if(FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			NovaTools.playMenuMusic("freakyMenu", 0, 1, 4);

		add(logo = new FNFSprite(-150, -100).loadAtlas(Paths.getSparrowAtlas("menus/base/title/logoBumpin")));
		logo.animation.addByPrefix("bump", "logo bumpin", 24, false);
		logo.animation.play("bump");

		add(gfDance = new FNFSprite(FlxG.width * 0.4, FlxG.height * 0.07).loadAtlas(Paths.getSparrowAtlas("menus/base/title/gfDanceTitle")));
		gfDance.animation.addByIndices("danceLeft", "gfDance", [for(i in 0...15) i], "", 24, false);
		gfDance.animation.addByIndices("danceRight", "gfDance", [for(i in 15...30) i], "", 24, false);
		gfDance.animation.play("danceLeft");

		add(titleText = new FNFSprite(100, FlxG.height * 0.8).loadAtlas(Paths.getSparrowAtlas("menus/base/title/titleEnter")));
		titleText.animation.addByPrefix("idle", "Press Enter to Begin", 24);
		titleText.animation.addByPrefix("press", "ENTER PRESSED", 24);
		titleText.animation.play("idle");

		add(ngSpr = new FNFSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image("menus/base/title/newgrounds_logo")));
		ngSpr.scale.set(0.8, 0.8);
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);

		add(textGroup = new FlxTypedGroup<Alphabet>());

		// setting visible to false causes the game to lag a bit when setting to true later???
		// so we do this shit so the sprites don't do that
		for(sprite in [logo, gfDance, titleText, ngSpr])
			sprite.alpha = 0.001;
	}

	public function createCoolText(textList:Array<String>) {
		if(textGroup == null) return;

		for(text in textList)
			addMoreText(text);
	}

	public function addMoreText(text:String) {
		if(textGroup == null) return;

		var text:Alphabet = new Alphabet(0, 200, Bold, text);
		text.screenCenter(X);
		text.y += textGroup.length * 60;
		textGroup.add(text);
	}

	public function deleteCoolText() {
		if(textGroup == null || textGroup.length <= 0) return;

		while(textGroup.length > 0) {
			textGroup.members[0].destroy();
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if(!runDefaultCode) return;

		if(FlxG.sound.music != null)
			Conductor.position = FlxG.sound.music.time;
		else
			Conductor.position += elapsed * 1000;

		if(controls.ACCEPT) {
			if(!transitioning && skippedIntro) {
				transitioning = true;

				titleText.animation.play("press");

				FlxG.camera.flash(0xFFFFFFFF, 1);
				CoolUtil.playMenuSFX(CONFIRM);

				new FlxTimer().start(2, (tmr:FlxTimer) -> {
					FlxG.switchState(new MainMenuState());
				});
			}
			if(!skippedIntro) skipIntro();
		}

		if(controls.SWITCH_MOD) {
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new ModSwitcher());
		}
	}

	override public function beatHit(curBeat:Int) {
		if(runDefaultCode) {
			logo.animation.play("bump", true);
			gfDance.animation.play((curBeat % 2 == 0) ? "danceLeft" : "danceRight");

			if(!skippedIntro && curBeat >= introLength)
				skipIntro();

			if(!skippedIntro && introLines.exists(curBeat))
				introLines.get(curBeat).show();
		}

		super.beatHit(curBeat);
	}

	public function parseIntroText() {
		var lines:Array<String> = Paths.txt("data/introText").split("\n");

		var finalList:Array<Array<String>> = [];
		for(line in lines) finalList.push(line.split("--"));

		return finalList;
	}

	public function skipIntro() {
		skippedIntro = true;
		
		FlxG.camera.flash(FlxColor.WHITE, 4);
		ngSpr.destroy();
		remove(ngSpr, true);
		ngSpr = null;

		textGroup.destroy();
		remove(textGroup, true);
		textGroup = null;

		for(sprite in [logo, gfDance, titleText])
			sprite.alpha = 1;
	}
}
