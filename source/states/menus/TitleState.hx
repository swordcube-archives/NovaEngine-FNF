package states.menus;

import objects.ui.Alphabet;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import states.MusicBeat.MusicBeatState;

class TitleState extends MusicBeatState {
	static var initializedTransitions:Bool = false;

	public var logo:FNFSprite;
	public var gfDance:FNFSprite;
	public var titleText:FNFSprite;

	function initTransitions() {
		initializedTransitions = true;

		var diamond = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;

        FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.3, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
            new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
        FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.3, new FlxPoint(0, 1),
            {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
	}

	override public function create() {
		super.create();

		if(FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			NovaTools.playMenuMusic("freakyMenu", 0, 1, 4);

		add(logo = new FNFSprite(-150, -100).loadAtlas(Paths.getSparrowAtlas("menus/base/logoBumpin")));
		logo.animation.addByPrefix("bump", "logo bumpin", 24, false);
		logo.animation.play("bump");

		add(gfDance = new FNFSprite(FlxG.width * 0.4, FlxG.height * 0.07).loadAtlas(Paths.getSparrowAtlas("menus/base/gfDanceTitle")));
		gfDance.animation.addByIndices("danceLeft", "gfDance", [for(i in 0...15) i], "", 24, false);
		gfDance.animation.addByIndices("danceRight", "gfDance", [for(i in 15...30) i], "", 24, false);
		gfDance.animation.play("danceLeft");

		add(titleText = new FNFSprite(100, FlxG.height * 0.8).loadAtlas(Paths.getSparrowAtlas("menus/base/titleEnter")));
		titleText.animation.addByPrefix("idle", "Press Enter to Begin", 24);
		titleText.animation.addByPrefix("press", "ENTER PRESSED", 24);
		titleText.animation.play("idle");

		if(!initializedTransitions)
			initTransitions();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		Conductor.position += elapsed * 1000;

		if(controls.ACCEPT) {
			CoolUtil.playSound(Paths.sound("menus/confirmMenu"));
			FlxG.camera.flash(0xFFFFFFFF, 1);
		}
	}

	override public function beatHit(curBeat:Int) {
		logo.animation.play("bump", true);
		gfDance.animation.play((curBeat % 2 == 0) ? "danceLeft" : "danceRight");
		super.beatHit(curBeat);
	}
}
