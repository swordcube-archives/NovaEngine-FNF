package states.menus.options;

import states.MusicBeat.MusicBeatSubstate;

class ControlsMenu extends MusicBeatSubstate {
    public var bg:FNFSprite;

	public var categories:Array<String> = ["Notes", "UI", "Engine"];

    override function create() {
        super.create();

        if(!runDefaultCode) return;

		add(bg = new FNFSprite().loadGraphic(Paths.image("menus/base/menuBGDesat")));
		bg.scale.set(1.2, 1.2);
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xFFC456D3;
    }

    override public function update(elapsed:Float) {
		super.update(elapsed);

		if(!runDefaultCode) return;

		if(controls.BACK) {
			CoolUtil.playMenuSFX(CANCEL);
			close();
		}
	}
}