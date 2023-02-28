import states.PlayState;
import backend.utilities.FNFSprite;

var bg:FNFSprite;
var evilTree:FNFSprite;
var evilSnow:FNFSprite;

function stageImage(lmao:String) {
	return Paths.image('game/stages/mall/' + lmao);
}

function onCreate() {
	stage.bfPos.x += 320;
	stage.dadPos.y -= 80;

	add(bg = new FNFSprite(-400, -500).loadGraphic(stageImage('evilBG')));
	bg.scrollFactor.set(0.2, 0.2);
	bg.setGraphicSize(Std.int(bg.width * 0.8));
	bg.updateHitbox();

	add(evilTree = new FNFSprite(300, -300).loadGraphic(stageImage('evilTree')));
	evilTree.scrollFactor.set(0.2, 0.2);

	add(evilSnow = new FNFSprite(-200, 700).loadGraphic(stageImage('evilSnow')));
}
