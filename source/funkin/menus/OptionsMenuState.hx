package funkin.menus;

import funkin.system.MusicBeatState;

class OptionsMenuState extends MusicBeatState {
    public var bg:FlxSprite;

    override function create() {
        super.create();

        if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			CoolUtil.playMusic(Paths.music("freakyMenu"));

		if (!runDefaultCode) return;

        add(bg = new FlxSprite().loadGraphic(Paths.image("menus/menuBGDesat")));
        bg.scale.set(1.1, 1.1);
        bg.updateHitbox();
        bg.screenCenter();
        bg.color = 0xFFDB4CEE;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (!runDefaultCode) return;

        if(controls.BACK) FlxG.switchState(new MainMenuState());
    }
}