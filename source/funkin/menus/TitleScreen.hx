package funkin.menus;

import funkin.ui.Alphabet;
import funkin.system.Conductor;
import funkin.system.MusicBeatState;
import flixel.FlxSprite;

class TitleScreen extends MusicBeatState {
    var logo:FlxSprite;
    var gf:FlxSprite;
    var titleEnter:FlxSprite;
    
	override function create() {
		super.create();

		CoolUtil.playMusic(Paths.music("freakyMenu"), 0, true, 1, 4);

		gf = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gf.frames = Paths.getSparrowAtlas("menus/titlescreen/gf");
		gf.animation.addByIndices("danceLeft", "gfDance", [for(i in 0...15) i], "", 24, false);
		gf.animation.addByIndices("danceRight", "gfDance", [for(i in 15...30) i], "", 24, false);
        gf.animation.play("danceLeft");
		add(gf);

        logo = new FlxSprite(-150, -100);
		logo.frames = Paths.getSparrowAtlas("menus/titlescreen/logo");
		logo.animation.addByPrefix("bump", "logo bumpin", 24, false);
		logo.animation.play("bump");
		add(logo);

		titleEnter = new FlxSprite(100, FlxG.height * 0.8);
		titleEnter.frames = Paths.getSparrowAtlas("menus/titlescreen/titleEnter");
		titleEnter.animation.addByPrefix("idle", "Press Enter to Begin", 24);
		titleEnter.animation.addByPrefix("press", "ENTER PRESSED", 24);
		titleEnter.animation.play("idle");
		titleEnter.updateHitbox();
		add(titleEnter);
	}

	override function beatHit(beat:Int) {
		logo.animation.play("bump", true);
		gf.animation.play(beat % 2 == 0 ? "danceLeft" : "danceRight");
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if(FlxG.sound.music != null && FlxG.sound.music.playing)
			Conductor.position = FlxG.sound.music.time;

		if(controls.ACCEPT)
			CoolUtil.playMenuSFX(1);
	}
}
