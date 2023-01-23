package funkin.menus;

import flixel.FlxState;
import funkin.ui.TextMenuItem;
import flixel.math.FlxMath;
import funkin.ui.TextMenuList;
import funkin.system.MusicBeatState;
import funkin.menus.options.*;

typedef StateData = {
    var state:Class<FlxState>;
    var ?args:Array<Dynamic>;
}

class OptionsMenuState extends MusicBeatState {
    public var bg:FlxSprite;
    public var grpCategories:TextMenuList;

    public static var stateData:StateData;

    public var curSelected:Int = 0;

    override function create() {
        super.create();

        DiscordRPC.changePresence(
			"In the Options Menu", 
			null
		);

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
        script.call("onPreGenerateOptions");
        grpCategories.createItem("Preferences", () -> openSubState(new PreferencesSubState()));
        grpCategories.createItem("Appearance", () -> openSubState(new AppearanceSubState()));
        grpCategories.createItem("Controls", () -> trace("L"));
        grpCategories.createItem("Exit", () -> exit());
        script.call("onGenerateOptions");
        // ^^^ ----------------------------------------------

        grpCategories.centerItems();
        changeSelection();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (!runDefaultCode || (grpCategories != null && grpCategories.isSelecting)) return;

        if(controls.BACK) exit();
        if(controls.UI_UP_P) changeSelection(-1);
        if(controls.UI_DOWN_P) changeSelection(1);
        if(controls.ACCEPT) {
            grpCategories.selectItem(curSelected);
            CoolUtil.playMenuSFX(CONFIRM);
        }
    }

    public function exit() {
        CoolUtil.playMenuSFX(CANCEL);
        if(stateData != null) {
            FlxG.switchState(Type.createInstance(stateData.state, stateData.args != null ? stateData.args : []));
            stateData = null;
        } else
            FlxG.switchState(new MainMenuState());
    }

    public function changeSelection(?change:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + change, 0, grpCategories.length - 1);
        grpCategories.forEach((text:TextMenuItem) -> {
            text.alpha = (curSelected == text.ID) ? 1 : 0.6;
        });
        CoolUtil.playMenuSFX(SCROLL);
    }
}