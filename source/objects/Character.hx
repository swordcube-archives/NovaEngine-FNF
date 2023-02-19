package objects;

import core.utilities.FNFSprite.AnimationContext;
import flixel.util.FlxColor;
import core.song.Conductor;
import flixel.addons.effects.FlxTrail;
import core.dependency.ScriptHandler;
import haxe.xml.Access;
import flixel.math.FlxPoint;
import flixel.FlxCamera;
import flixel.math.FlxRect;
import flixel.FlxG;

using StringTools;

// Typedefs
// Psych

@:dox(hide)
typedef PsychCharacter = {
	var animations:Array<PsychCharacterAnimation>;
	var no_antialiasing:Bool;
	var image:String;
	var position:Array<Float>;
	var healthicon:String;
	var flip_x:Bool;
	var healthbar_colors:Array<Int>; // psych colors work with rgb
	var camera_position:Array<Float>;
	var sing_duration:Float;
	var scale:Float;
}

@:dox(hide)
typedef PsychCharacterAnimation = {
	var offsets:Array<Float>;
	var loop:Bool;
	var anim:String;
	var fps:Int;
	var name:String;
	var indices:Null<Array<Int>>;
}

// Yoshi

@:dox(hide)
typedef YoshiCharacter = {
	var arrowColors:Array<String>; // Unused
	var camOffset:YoshiCharPosShit;
	var globalOffset:YoshiCharPosShit;
	var healthbarColor:String;
	var flipX:Bool;
	var anims:Array<YoshiCharacterAnimation>;
	var danceSteps:Array<String>;
	var antialiasing:Bool;
	var healthIconSteps:Array<Array<Int>>; // I don't know exactly what this does, but it's gonna go unused because
	// the way health icons work in plasma is different from yoshi
	var scale:Float;
}

@:dox(hide)
typedef YoshiCharPosShit = {
	var x:Float;
	var y:Float;
}

@:dox(hide)
typedef YoshiCharacterAnimation = {
	var indices:Null<Array<Int>>;
	var x:Float;
	var y:Float;
	var anim:String;
	var loop:Bool;
	var name:String;
	var framerate:Int;
}

class Character extends FNFSprite implements MusicHandler {
	public static var DEFAULT_CHARACTER:String = "bf";

	/**
	 * The name of the currently loaded character.
	 */
	public var curCharacter:String = "";

	/**
	 * The character to load when you lose all of your health.
	 */
	public var deathCharacter:String = "bf-dead";

	/**
	 * The icon used for the health bar.
	 */
	public var healthIcon:String = "face";

	/**
	 * The color used for the left or right sides of the health bar.
	 */
	public var healthBarColor:Null<FlxColor> ;

	public var idleSuffix:String = "";

	public var curDanceStep:Int = 0;

	/**
	 * Allows you to have multiple animations when the character dances.
	 */
	public var danceSteps:Array<String> = ["idle"];

	/**
	 * Controls if the character can dance or not.
	 */
	public var canDance:Bool = true;

	/**
	 * Whether or not the character will automatically dance to the beat of the song.
	 * Turn off if you want to manually manage dancing in a script.
	 */
	public var danceOnBeat:Bool = true;

	/**
	 * Controls if the character acts like Boyfriend (Like only going back to idle when you release a note)
	 */
	public var isPlayer:Bool = false;

	public var isTruePlayer:Bool = false;

	/**
	 * Controls how long the character can hold down a note for before going back to idle.
	 */
	public var singDuration:Float = 4;

	public var animTimer:Float = 0;
	public var holdTimer:Float = 0.0;

	public var specialAnim:Bool = false;
	public var debugMode:Bool = false;

	public var stunned:Bool = false;
	public var initialized:Bool = false;

	/**
		The X and Y offset of this character's camera position.
	**/
	public var cameraOffset:FlxPoint = new FlxPoint(0, 0);

	/**
		The X and Y offset of this character's position.
	**/
	public var positionOffset:FlxPoint = new FlxPoint(0, 0);

	/**
		The character's original scale from when it was loaded.
	**/
	public var ogScale:FlxPoint = new FlxPoint(0, 0);

	/**
	 * The trail that goes behind this character.
	 */
	public var trail:FlxTrail;

	public var playerOffsets:Bool = false;

	/**
	 * The character's script.
	 */
	public var script:ScriptModule;

	/**
	 * The name of the character's spritesheet.
	 */
	public var spritesheet:String = "spritesheet";

	var __baseFlipped:Bool = false;
	var __antialiasing:Bool = true;

	public var specialAnims:Array<String> = [];

	public function new(?x:Float = 0, ?y:Float = 0, ?character:String = "bf", ?isPlayer:Bool = false) {
		super(x, y);
		this.isPlayer = isPlayer;
        loadCharacter(character);
	}

	/**
	 * Returns if a character exists.
	 * @param name The character to check.
	 */
	public static function charExists(name:String, ?mod:Null<String>) {
		return FileSystem.exists(Paths.getPath('data/characters/$name'));
	}

	/**
	 * Preloads a character called `name`.
	 * @param name The character to preload.
	 */
	public static function preloadCharacter(name:String) {
		var cachedGuyPerson = new Character(0, 0, false).loadCharacter(name);
		FlxG.state.add(cachedGuyPerson);
		cachedGuyPerson.kill();
	}

	public function loadCharacter(name:String) {
		if(!charExists(name) && charExists(DEFAULT_CHARACTER))
			return loadCharacter(DEFAULT_CHARACTER);

		curCharacter = name;

		// Loading the character's script
		if (script != null) {
			script.destroy();
			script = null;
		}
		script = ScriptHandler.loadModule(Paths.script('data/characters/$curCharacter/script'));
		script.set("character", this);
        script.call("onCreate", []);

		// Player offset shit, don't worry bout it
		if (isPlayer != playerOffsets) {
			// Swap left and right animations
			CoolUtil.switchAnimFrames(animation.getByName('singRIGHT'), animation.getByName('singLEFT'));
			CoolUtil.switchAnimFrames(animation.getByName('singRIGHTmiss'), animation.getByName('singLEFTmiss'));

			// Swap left and right animations
			switchOffset('singLEFT', 'singRIGHT');
			switchOffset('singLEFTmiss', 'singRIGHTmiss');
		}
		if (isPlayer)
			flipX = !flipX;

		__baseFlipped = flipX;
		dance();

		return this;
	}

	// i have this so people can port characters from psych easier
	// don't murder me shadowmario
	// thanks
	public function loadPsych(?mod:Null<String>) {
		// Error handling
		var jsonPath:String = Paths.json('data/characters/$curCharacter/config', true);
		if (!FileSystem.exists(jsonPath))
			return Logs.trace('Occured on character: $curCharacter | The JSON config file doesn\'t exist!', ERROR);

		// JSON Data
		var data:PsychCharacter = Json.parse(File.getContent(jsonPath));

		// Loading frames
		var spritesheetPath:String = 'characters/${data.image}';
		loadAtlas(Paths.getSparrowAtlas(spritesheetPath));

		spritesheet = curCharacter;

		antialiasing = !data.no_antialiasing ? SettingsAPI.antialiasing : false;
		__antialiasing = !data.no_antialiasing;
		singDuration = data.sing_duration;
		healthIcon = data.healthicon;
		flipX = data.flip_x;
		playerOffsets = isPlayer;
		isTruePlayer = false;

		deathCharacter = curCharacter + "-dead";
		if (!charExists(deathCharacter))
			deathCharacter = "bf-dead";

		for (anim in data.animations) {
			if (anim.indices != null && anim.indices.length > 1)
				animation.addByIndices(anim.anim, anim.name, anim.indices, "", anim.fps, anim.loop);
			else
				animation.addByPrefix(anim.anim, anim.name, anim.fps, anim.loop);

			addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
		}

		positionOffset.set(data.position[0], data.position[1]);
		cameraOffset.set(data.camera_position[0], data.camera_position[1]);

		this.scale.set(data.scale, data.scale);
		ogScale.set(this.scale.x, this.scale.y);
		updateHitbox();

		scrollFactor.set(1, 1);

		var rgb:Array<Int> = data.healthbar_colors;
		healthBarColor = FlxColor.fromRGB(rgb[0], rgb[1], rgb[2]);

		// Dance Steps moment
		danceSteps = (animation.exists("danceLeft") && animation.exists("danceRight")) ? ["danceLeft", "danceRight"] : ["idle"];
	}

	public function loadYoshi(?mod:Null<String>) {
		// Error handling
		var jsonPath:String = Paths.json('data/characters/$curCharacter/config', true);
		if (!FileSystem.exists(jsonPath))
			return Logs.trace('Occured on character: $curCharacter | The JSON config file doesn\'t exist!', ERROR);

		// JSON Data
		var data:YoshiCharacter = Json.parse(File.getContent(jsonPath));

		// Loading frames
		var spritesheetPath:String = 'characters/$curCharacter';
		loadAtlas(Paths.getSparrowAtlas(spritesheetPath));

		spritesheet = curCharacter;

		antialiasing = data.antialiasing ? SettingsAPI.antialiasing : false;
		__antialiasing = data.antialiasing;
		singDuration = 4;
		healthIcon = curCharacter;
		flipX = data.flipX;
		playerOffsets = isPlayer;
		isTruePlayer = false;

		deathCharacter = curCharacter + "-dead";
		if (!charExists(deathCharacter))
			deathCharacter = "bf-dead";

		for (anim in data.anims) {
			if (anim.indices != null && anim.indices.length > 1)
				animation.addByIndices(anim.name, anim.anim, anim.indices, "", anim.framerate, anim.loop);
			else
				animation.addByPrefix(anim.name, anim.anim, anim.framerate, anim.loop);

			addOffset(anim.name, anim.x, anim.y);
		}

		positionOffset.set(data.globalOffset.x, data.globalOffset.y);
		cameraOffset.set(data.camOffset.x, data.camOffset.y);

		this.scale.set(data.scale, data.scale);
		ogScale.set(this.scale.x, this.scale.y);
		updateHitbox();

		scrollFactor.set(1, 1);

		healthBarColor = FlxColor.fromString(data.healthbarColor);

		// Dance Steps moment
		danceSteps = (data.danceSteps != null && data.danceSteps.length > 1) ? data.danceSteps : ["idle"];
	}

	public function loadXML(?mod:Null<String>) {
		var charXmlPath:String = Paths.xml('data/characters/$curCharacter/config', true);

        if(!FileSystem.exists(charXmlPath))
            return Logs.trace('Occured on character: $curCharacter | The XML doesn\'t exist!', ERROR);

		// Load the intial XML Data.
		var xml:Xml = Xml.parse(File.getContent(charXmlPath)).firstElement();
		if (xml == null)
			return Logs.trace('Occured on character: $curCharacter | Either the XML doesn\'t exist or the "character" node is missing!', ERROR);

		var data:Access = new Access(xml);

		var atlasType:String = "SPARROW";
		if (data.has.atlasType)
			atlasType = data.att.atlasType;

		var spritesheetName:String = data.has.sprite ? data.att.sprite : curCharacter;

		// might eventually add texture atlas??!?
		switch (atlasType.toLowerCase()) {
			default:
				loadAtlas(Paths.getSparrowAtlas('characters/$spritesheetName'));
		}

		spritesheet = spritesheetName;
		antialiasing = data.has.antialiasing ? (data.att.antialiasing == 'true' ? SettingsAPI.antialiasing : false) : SettingsAPI.antialiasing;
		__antialiasing = data.has.antialiasing ? data.att.antialiasing == 'true' : true;
		singDuration = data.has.singDuration ? Std.parseFloat(data.att.singDuration) : 4.0;
		healthIcon = data.has.icon ? data.att.icon : curCharacter;
		flipX = data.att.flipX == "true";
		playerOffsets = data.has.isPlayer && data.att.isPlayer == "true";
		isTruePlayer = playerOffsets;

		deathCharacter = data.has.deathCharacter ? data.att.deathCharacter : "bf-dead";

		// Load animations
		var animations_node:Access = data.node.anims; // <- This is done to make the code look cleaner (aka instead of data.node.animations.nodes.animation)

		for (anim in animations_node.nodes.anim) {
			// Add the animation
			if (anim.has.indices && anim.att.indices.split(",").length > 1)
				animation.addByIndices(anim.att.name, anim.att.anim, CoolUtil.splitInt(anim.att.indices, ","), "", Std.parseInt(anim.att.fps),
					anim.has.loop ? anim.att.loop == "true" : false);
			else
				animation.addByPrefix(anim.att.name, anim.att.anim, Std.parseInt(anim.att.fps), 
                    anim.has.loop ? anim.att.loop == "true" : false);

			if (anim.has.specialAnim && anim.att.specialAnim == "true")
				specialAnims.push(anim.att.name);

			addOffset(anim.att.name, Std.parseFloat(anim.att.x), Std.parseFloat(anim.att.y));
		}

		// Load miscellaneous attributes
		positionOffset.set(data.has.x ? Std.parseFloat(data.att.x) : 0, data.has.y ? Std.parseFloat(data.att.y) : 0);
		cameraOffset.set(data.has.camX ? Std.parseFloat(data.att.camX) : 0, data.has.camY ? Std.parseFloat(data.att.camY) : 0);

        if(data.hasNode.scale) {
            var scale:Access = data.node.scale;
            this.scale.set(Std.parseFloat(scale.att.x), Std.parseFloat(scale.att.y));
            ogScale.set(this.scale.x, this.scale.y);
            updateHitbox();
        }
        else {
            this.scale.set(1, 1);
            ogScale.set(this.scale.x, this.scale.y);
            updateHitbox();
        }

        if(data.hasNode.scrollFactor) {
            var scrollFactor:Access = data.node.scrollFactor;
		    this.scrollFactor.set(scrollFactor.has.x ? Std.parseFloat(scrollFactor.att.x) : 1, scrollFactor.has.y ? Std.parseFloat(scrollFactor.att.y) : 1);
        }

        if(data.hasNode.healthColor) {
            var healthColor:Access = data.node.healthColor;
            if (healthColor.has.hex && healthColor.att.hex != "")
                healthBarColor = FlxColor.fromString(healthColor.att.hex);
            else {
                var rgb = CoolUtil.splitInt(healthColor.att.rgb, ",");
                healthBarColor = FlxColor.fromRGB(rgb[0], rgb[1], rgb[2]);
            }
        }

		// Dance Steps moment
		danceSteps = data.has.danceSteps ? data.att.danceSteps.split(",") : ["idle"];
		for (i in 0...danceSteps.length)
			danceSteps[i] = danceSteps[i].trim();
	}

	public function switchOffset(anim1:String, anim2:String) {
		if (!animation.exists(anim1) || !animation.exists(anim2))
			return;
		var old = animOffsets[anim1];
		animOffsets[anim1] = animOffsets[anim2];
		animOffsets[anim2] = old;
	}

	public function getCameraPosition() {
		var midpoint = getMidpoint();
		return FlxPoint.get(midpoint.x
			+ (isPlayer ? -100 : 150)
			+ positionOffset.x
			+ cameraOffset.x, midpoint.y
			- 100
			+ positionOffset.y
			+ cameraOffset.y);
	}

	// VVV CODE FROM CODENAME ENGINE!!!
	// I HAVE NO IDEA WHAT IT DOES OTHER THAN CORRECTING PLAYER OFFSETS!!!
	var __reverseDrawProcedure:Bool = false;

	public override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect {
		if (__reverseDrawProcedure) {
			scale.x *= -1;
			var bounds = super.getScreenBounds(newRect, camera);
			scale.x *= -1;
			return bounds;
		}
		return super.getScreenBounds(newRect, camera);
	}

	public override function draw() {
		if ((isPlayer != playerOffsets) != (flipX != __baseFlipped)) {
			__reverseDrawProcedure = true;

			flipX = !flipX;
			scale.x *= -1;
			super.draw();
			flipX = !flipX;
			scale.x *= -1;

			__reverseDrawProcedure = false;
		} else
			super.draw();
	}

	// YOSHICRAFTER29 MADE THIS 🙏
	// ^^^

	override function update(elapsed:Float) {
		super.update(elapsed);
		script.call("onUpdate", [elapsed]);

		if(!debugMode) {
			if (animTimer > 0) {
				animTimer -= elapsed;
				if (animTimer <= 0) {
					if (specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer') {
						specialAnim = false;
						dance();
					}
					animTimer = 0;
				}
			} else if (specialAnim && ((animation.curAnim != null && animation.curAnim.finished) || (animation.curAnim == null))) {
				specialAnim = false;
				dance();
			}

			if (animation.curAnim != null && animation.name.startsWith('sing'))
				holdTimer += elapsed * FlxG.sound.music.pitch;

			if (lastAnimContext == SING && holdTimer >= Conductor.stepCrochet * singDuration * 0.0011) {
				dance();
				holdTimer = 0;
			}

			if (animation.curAnim != null && animation.curAnim.finished && animation.exists(animation.name + '-loop'))
				playAnim(animation.curAnim.name + '-loop');

			if (danceSteps.length > 1 && animation.name == 'hairFall' && (animation.curAnim != null && animation.curAnim.finished))
				playAnim(danceSteps[1]);
		}

		script.call("onUpdatePost", [elapsed]);
	}

	override function playAnim(anim:String, force:Bool = false, ?context:AnimationContext = NORMAL, frame:Int = 0) {
		super.playAnim(anim, force, context, frame);

		if (animation.exists(anim) && animOffsets.exists(anim)) {
			specialAnim = specialAnims.contains(anim);

            if(anim.startsWith("sing")) lastAnimContext = SING;

			var daOffset = animOffsets.get(anim);
			rotOffset.set(daOffset.x, daOffset.y);
		}
        if(lastAnimContext == SING) holdTimer = 0;

		offset.set(positionOffset.x * (isPlayer != playerOffsets ? 1 : -1), -positionOffset.y);
	}

	var danced:Bool = false;

	public function beatHit(beat:Int) {
		if(!alive) return;
		script.call("onBeatHit", [beat]);
        if(lastAnimContext != SING && danceOnBeat) dance();
		script.call("onBeatHitPost", [beat]);
	}

	public function stepHit(step:Int) {
		if(!alive) return;
		script.call("onStepHit", [step]);
        script.call("onStepHitPost", [step]);
	}

    public function sectionHit(section:Int) {
		if(!alive) return;
		script.call("onSectionHit", [section]);
        script.call("onSectionPost", [section]);
	}

	public function dance() {
		if (specialAnim || !canDance) return;
		if ((animation.curAnim != null && !animation.curAnim.name.startsWith("hair")) || animation.curAnim == null) {
			danced = !danced;

			if (danceSteps.length > 1) {
				if (curDanceStep > danceSteps.length - 1)
					curDanceStep = 0;

				if (danceSteps[curDanceStep] == "idle")
					playAnim(animation.exists(danceSteps[curDanceStep]+idleSuffix) ? danceSteps[curDanceStep]+idleSuffix : danceSteps[curDanceStep]);
				else
					playAnim(danceSteps[curDanceStep]);

				curDanceStep++;
			} else {
				if (danceSteps.length > 0) {
					if (danceSteps[0] == "idle")
						playAnim(animation.exists(danceSteps[0]+idleSuffix) ? danceSteps[0]+idleSuffix : danceSteps[0]);
					else
						playAnim(danceSteps[0]);
				}
			}
		}
	}
}
