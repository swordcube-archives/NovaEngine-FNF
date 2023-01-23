package funkin.menus;

import funkin.ui.TextMenuItem;
import flixel.math.FlxMath;
import funkin.ui.TextMenuList;
import funkin.system.MusicBeatState;

class OptionsMenuState extends MusicBeatState {
    public var bg:FlxSprite;
    public var grpCategories:TextMenuList;

    public var curSelected:Int = 0;

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

        add(grpCategories = new TextMenuList(true, true));

        // VVV ADD CATEGORIES HERE!!!! ----------------------
        grpCategories.createItem("Preferences", () -> trace("missingno? nah bro, foundyes."));
        grpCategories.createItem("Appearance", () -> trace("u ugly"));
        grpCategories.createItem("Controls", () -> trace("L"));
        grpCategories.createItem("Exit", () -> trace("did you accidentally go to the options?"));
        // ^^^ ----------------------------------------------

        grpCategories.centerItems();
        changeSelection();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (!runDefaultCode || (grpCategories != null && grpCategories.isSelecting)) return;

        if(controls.BACK) FlxG.switchState(new MainMenuState());
        if(controls.UI_UP_P) changeSelection(-1);
        if(controls.UI_DOWN_P) changeSelection(1);
        if(controls.ACCEPT) {
            grpCategories.selectItem(curSelected);
            CoolUtil.playMenuSFX(1);
        }
    }

    public function changeSelection(?change:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + change, 0, grpCategories.length - 1);
        grpCategories.forEach((text:TextMenuItem) -> {
            text.alpha = (curSelected == text.ID) ? 1 : 0.6;
        });
        CoolUtil.playMenuSFX();
    }
}