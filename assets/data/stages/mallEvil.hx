import states.PlayState;
import backend.utilities.FNFSprite;
import flixel.tweens.FlxTween;

var bg:FNFSprite;
var evilTree:FNFSprite;
var evilSnow:FNFSprite;

function stageImage(lmao:String) {
	return Paths.image('game/stages/mall/' + lmao);
}

function onCreate() {
	add(bg = new FNFSprite(-400, -500).loadGraphic(stageImage('evilBG')));
	bg.setGraphicSize(Std.int(bg.width * 0.8));
	bg.updateHitbox();

	add(evilTree = new FNFSprite(300, -300).loadGraphic(stageImage('evilTree')));
	evilTree.scrollFactor.set(0.2, 0.2);

	add(evilSnow = new FNFSprite(-200, 700).loadGraphic(stageImage('evilSnow')));
}

function onCreatePost() {
	boyfriend.x += 320;
	dad.y -= 80;
}

function onSongStart() {
	FlxTween.num(bg.scrollFactor.x, 0.2, (Conductor.crochet / 1000) * 4, {
		ease: FlxEase.quadInOut
	}, function(num) {
		bg.scrollFactor.set(num, num);
	});
}
