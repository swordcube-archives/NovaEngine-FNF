import flixel.addons.effects.FlxTrail;

var trail:FlxTrail;

function onCreate() {
    character.loadXML();

	trail = new FlxTrail(character, null, 4,24,0.3,0.069);
	PlayState.current.add(trail);
}

