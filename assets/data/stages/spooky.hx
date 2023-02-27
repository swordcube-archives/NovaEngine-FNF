import states.PlayState;
import backend.utilities.FNFSprite;

var halloweewee:FNFSprite;
var _strikeBeat:Int = 0;
var _offset:Int = 0;

function onCreate() {
	defaultCamZoom = 1.05;

	halloweewee = new FNFSprite(-200, -100);
	halloweewee.frames = Paths.getSparrowAtlas('game/stages/spooky/halloween_bg');
	halloweewee.animation.addByPrefix('bg', 'halloweem bg0', 0, false);
	halloweewee.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	halloweewee.playAnim('bg');
	add(halloweewee);
}

function onBeatHit(beat) {
	if (FlxG.random.bool(10) && beat > _strikeBeat + _offset)
		lightning();
}

function lightning() {
	FlxG.sound.play(Paths.soundRandom('game/thunder/', 1, 2));
	halloweewee.playAnim('lightning');

	_strikeBeat = curBeat;
	_offset = FlxG.random.int(8, 24);

	bf.animTimer = gf.animTimer = 0.5;
	bf.playAnim('scared', true);
	gf.playAnim('scared', true);
	bf.specialAnim = gf.specialAnim = true;
}
