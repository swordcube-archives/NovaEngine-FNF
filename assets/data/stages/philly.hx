import states.PlayState;
import flixel.util.FlxColor;
import flixel.FlxG;

var bg:FNFSprite;
var city:FNFSprite;
var light:FNFSprite;
var curLight:Int = -1;
var lightColors:Array<FlxColor> = [0xFF31A2FD, 0xFF31FD8C, 0xFFFB33F5, 0xFFFD4531, 0xFFFBA633];
var streetBehind:FNFSprite;
var phillyTrain:FNFSprite;
var street:FNFSprite;

// train-related shits
var trainSound:FlxSound;
var trainMoving:Bool = false;
var trainFrameTiming:Float = 0;
var trainCars:Int = 8;
var trainFinishing:Bool = false;
var trainCooldown:Int = 0;
var trainStartedMoving:Bool = false;
#if debug
var debugVals:FlxText;
#end

function onCreate() {
	trainSound = new FlxSound().loadEmbedded(Paths.sound('game/philly/train'));
	FlxG.sound.list.add(trainSound);

	add(bg = new FNFSprite(-100).loadGraphic(stageImage('sky')));
	bg.scrollFactor.set(0.1, 0.1);

	add(city = new FNFSprite(-10).loadGraphic(stageImage('city')));
	city.scrollFactor.set(0.3, 0.3);
	city.setGraphicSize(Std.int(city.width * 0.85));
	city.updateHitbox();

	add(light = new FNFSprite().loadGraphic(stageImage('win')));
	light.scrollFactor.set(0.3, 0.3);
	light.setGraphicSize(Std.int(light.width * 0.85));
	light.updateHitbox();
	light.alpha = 0;

	add(streetBehind = new FNFSprite(-40, 50).loadGraphic(stageImage('behindTrain')));

	add(phillyTrain = new FNFSprite(2000, 360).loadGraphic(stageImage('train')));

	add(street = new FNFSprite(-40, streetBehind.y).loadGraphic(stageImage('street')));
}

function onUpdate(elapsed) {
	light.alpha = FlxMath.lerp(light.alpha, 0, /*(Conductor.crochet / 1000) * */ (elapsed * 2));

	if (trainMoving) {
		trainFrameTiming += elapsed;

		if (trainFrameTiming >= 1 / 24) {
			updateTrainPos();
			trainFrameTiming = 0;
		}
	}

	// NOTE maybe remove this? or keep it, it shouldn't run on non-debug builds anyway
	#if debug
	var eee:Array<Dynamic> = [
		['[TRAIN]', ""],
		['moving', trainMoving],
		['started moving', trainStartedMoving],
		['finishing', trainFinishing],
		['cooldown', trainCooldown],
		['frame timing', trainFrameTiming],
		['cars', trainCars],
		['gf special anim', PlayState.current.gf.specialAnim],
		[" ", ""],
		['[LIGHTS]', ""],
		['alpha', light.alpha]
	];

	if (!(PlayState.current.gf.animation.exists('hairBlow') && PlayState.current.gf.animation.exists('hairFall')))
		eee.insert(0, ['[!!!] GF is missing', 'hairBlow and/or hairFall anims !!']);

	for (i in eee)
		FlxG.watch.addQuick(i[0], i[1]);
	#end
}

function onBeatHit(beat) {
	if (beat % 4 == 0) {
		curLight = FlxG.random.int(0, lightColors.length - 1, [curLight]);
		light.color = lightColors[curLight];
		light.alpha = 1;
	}

	if (!trainMoving)
		trainCooldown++;

	if (beat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8) {
		trace('TRAIN - valid');
		trainCooldown = FlxG.random.int(-4, 0);
		trainStart();
	}
}

function updateTrainPos() {
	if (trainSound.time >= 4700) {
		trainStartedMoving = true;

		if (gf.animation.exists('hairBlow'))
			gf.playAnim('hairBlow');
		// gf.specialAnim = true;
	}

	if (trainStartedMoving) {
		phillyTrain.x -= 400;

		if (phillyTrain.x < -2000 && !trainFinishing) {
			phillyTrain.x = -1150;
			--trainCars;

			if (trainCars <= 0)
				trainFinishing = true;
		}

		if (phillyTrain.x < -4000 && trainFinishing)
			trainReset();
	}
}

function trainReset() {
	#if debug trace('TRAIN - reset'); #end

	if (gf.animation.exists('hairFall'))
		gf.playAnim('hairFall');
	// gf.specialAnim = true;

	phillyTrain.x = FlxG.width + 200;
	trainCars = 8;
	trainMoving = trainFinishing = trainStartedMoving = false;
}

function trainStart() {
	#if debug trace('TRAIN - start'); #end

	trainMoving = true;
	if (!trainSound.playing)
		trainSound.play(true);
}
