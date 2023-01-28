package states.menus;

import states.MusicBeat.MusicBeatState;

class StoryMenuState extends MusicBeatState {
	public var curSelected:Int = 0;

	override public function create() {
		super.create();

		if(!runDefaultCode) return;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if(!runDefaultCode) return;

		if(controls.BACK) {
			CoolUtil.playMenuSFX(CANCEL);
			FlxG.switchState(new MainMenuState());
		}
	}
}