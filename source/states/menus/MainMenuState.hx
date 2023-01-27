package states.menus;

import states.MusicBeat.MusicBeatState;

class MainMenuState extends MusicBeatState {
    public var bg:FNFSprite;

    override public function create() {
		super.create();

        add(bg = new FNFSprite().loadGraphic(Paths.image("menus/base/menuBG")));
        bg.scale.set(1.2, 1.2);
        bg.updateHitbox();
        bg.screenCenter();
        bg.scrollFactor.set(0, 0.17);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

        if(controls.BACK) {
            FlxG.sound.play(Paths.sound("menus/cancelMenu"));
            FlxG.switchState(new TitleState());
        }
	}
}