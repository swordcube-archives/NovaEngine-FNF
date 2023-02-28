import states.PlayState;
import backend.utilities.CoolUtil;

var bgSky:FlxSprite;
var bgSchool:FlxSprite;
var bgStreet:FlxSprite;
var fgTrees:FlxSprite;
var bgTrees:FlxSprite;
var treeLeaves:FlxSprite;
var bgGirls:FlxSprite;
var bgGirls_danceDir:Bool = false;

function stageSparrow(lmao:String) {
	return Paths.getSparrowAtlas('game/stages/school/' + lmao);
}

function stagePacker(lmao:String) {
	return Paths.getPackerAtlas('game/stages/school/' + lmao);
}

function onCreate() {
	add(bgSky = new FlxSprite().loadGraphic(stageImage('weebSky')));
	bgSky.scrollFactor.set(0.1, 0.1);

	var repositionShit:Int = -200;

	add(bgSchool = new FlxSprite(repositionShit).loadGraphic(stageImage('weebSchool')));
	bgSchool.scrollFactor.set(0.6, 0.9);

	add(bgStreet = new FlxSprite(repositionShit).loadGraphic(stageImage('weebStreet')));
	bgStreet.scrollFactor.set(0.95, 0.95);

	add(fgTrees = new FlxSprite(repositionShit + 170, 130).loadGraphic(stageImage('weebTreesBack')));
	fgTrees.scrollFactor.set(0.9, 0.9);

	add(bgTrees = new FlxSprite(repositionShit - 380, -800));
	bgTrees.frames = stagePacker('weebTrees');
	bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
	bgTrees.animation.play('treeLoop');
	bgTrees.scrollFactor.set(0.85, 0.85);

	add(treeLeaves = new FlxSprite(repositionShit, -40));
	treeLeaves.frames = stageSparrow('petals');
	treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
	treeLeaves.animation.play('leaves');
	treeLeaves.scrollFactor.set(0.85, 0.85);

	var widShit = Std.int(bgSky.width * 6);
	bgSky.setGraphicSize(widShit);
	bgSchool.setGraphicSize(widShit);
	bgStreet.setGraphicSize(widShit);
	bgTrees.setGraphicSize(Std.int(widShit * 1.4));
	fgTrees.setGraphicSize(Std.int(widShit * 0.8));
	treeLeaves.setGraphicSize(widShit);

	bgSky.updateHitbox();
	bgSchool.updateHitbox();
	bgStreet.updateHitbox();
	bgTrees.updateHitbox();
	fgTrees.updateHitbox();
	treeLeaves.updateHitbox();

	add(bgGirls = new FlxSprite(-100, 190));
	bgGirls.frames = stageSparrow('bgFreaks');
	if (PlayState.SONG.name.toLowerCase() == 'roses') {
		bgGirls.animation.addByIndices('danceLeft', 'BG fangirls dissuaded', fillArray(14), "", 24, false);
		bgGirls.animation.addByIndices('danceRight', 'BG fangirls dissuaded', fillArray(30, 15), "", 24, false);
	} else {
		bgGirls.animation.addByIndices('danceLeft', 'BG girls group', fillArray(14), "", 24, false);
		bgGirls.animation.addByIndices('danceRight', 'BG girls group', fillArray(30, 15), "", 24, false);
	}
	bgGirls.animation.play('danceLeft');
	bgGirls.animation.finish();
	bgGirls.scrollFactor.set(0.9, 0.9);
	bgGirls.setGraphicSize(Std.int(bgGirls.width * 6));
	bgGirls.updateHitbox();

	for (i in [bgSky, bgSchool, bgStreet, fgTrees, bgTrees, treeLeaves, bgGirls])
		i.antialiasing = false;
}

function onCreatePost() {
	boyfriend.x += 200;
	boyfriend.y += 220;
	gf.x += 180;
	gf.y += 300;
}

function onBeatHit(beat) {
	bgGirls_danceDir = !bgGirls_danceDir;

	bgGirls.animation.play((bgGirls_danceDir) ? 'danceRight' : 'danceLeft', true);
}

function fillArray(max:Int, ?min:Int = 0) {
	return [for (i in min...max) i];
}
