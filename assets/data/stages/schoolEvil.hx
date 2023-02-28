import backend.utilities.FNFSprite;

var bg:FNFSprite;

function stageSparrow(path:String) { // overwrite 'curStage' variable :)
	return Paths.getSparrowAtlas('game/stages/school/' + path);
}

function onCreate() {
	add(bg = new FNFSprite(400, 200));
	bg.frames = stageSparrow('animatedEvilSchool');
	bg.animation.addByPrefix('idle', 'background 2 instance 1', 24);
	bg.playAnim('idle');
	bg.scrollFactor.set(0.8, 0.9);
	bg.scale.set(6, 6);
	bg.antialiasing = false;
}
