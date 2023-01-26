package states.menus;

import states.MusicBeat.MusicBeatState;

class TitleState extends MusicBeatState {
	public var logo:FNFSprite;

	override public function create() {
		super.create();

		add(logo = new FNFSprite(-150, -100).loadAtlas(Paths.getSparrowAtlas("menus/base/logoBumpin")));
		logo.animation.addByPrefix("bump", "logo bumpin", 24, false);
		logo.animation.play("bump");
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		
		Conductor.position += elapsed * 1000;
	}

	override public function beatHit(curBeat:Int) {
		logo.animation.play("bump", true);
		super.beatHit(curBeat);
	}
}
