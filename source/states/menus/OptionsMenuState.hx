package states.menus;

import flixel.math.FlxMath;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.fonts.Alphabet;
import states.MusicBeat.MusicBeatState;
import flixel.util.FlxSignal.FlxTypedSignal;
import states.menus.options.*;

class OptionsMenuState extends MusicBeatState {
	public var bg:FNFSprite;
	public var pages:PageGroup;

	public var curSelected:Int = 0;

	public var selectedSomethin:Bool = false;

	override public function create() {
		super.create();

		if(!runDefaultCode) return;

		if(FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			NovaTools.playMenuMusic("freakyMenu");

		add(bg = new FNFSprite().loadGraphic(Paths.image("menus/base/menuBGDesat")));
		bg.scale.set(1.2, 1.2);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.color = 0xFFC456D3;

		add(pages = new PageGroup());

		call("onAddPages", []);

		// VVV -- ADD PAGES HERE!!! -------------------------------------------
		pages.createItem("Preferences", () -> openSubState(new PreferencesMenu()));
		pages.createItem("Appearance", () -> {
			trace("GOING TO APPEARANCE PAGE");
		});
		pages.createItem("Controls", () -> {
			trace("GOING TO CONTROLS PAGE");
		});
		pages.createItem("Exit", () -> FlxG.switchState(new MainMenuState()));
		// ^^^ ----------------------------------------------------------------

		call("onAddPagesPost", []);

		for (i => member in pages.members) {
			member.screenCenter();
			member.y += 90 * i;
			member.y -= (90 * (pages.length - 1)) * 0.5;
		}

		changeSelection(0, true);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if(!runDefaultCode || selectedSomethin) return;

		changeSelection((controls.UI_DOWN_P ? 1 : 0) + (controls.UI_UP_P ? -1 : 0));

		if(controls.BACK) {
			CoolUtil.playMenuSFX(CANCEL);
			FlxG.switchState(new MainMenuState());
		}

		if(controls.ACCEPT) pages.members[curSelected].select();
	}

	public function changeSelection(change:Int, force:Bool = false) {
		if (change == 0 && !force)
			return;

		curSelected = FlxMath.wrap(curSelected + change, 0, pages.length - 1);
		pages.forEach((page:PageItem) -> {
			page.alpha = (curSelected == page.ID) ? 1 : 0.6;
		});
	}
}

class PageGroup extends FlxTypedGroup<PageItem> {
    public function createItem(text:String, onSelect:Void->Void) {
        var item = new PageItem(0, (70 * length) + 30, Bold, text);
        item.onSelect.add(onSelect);
        item.ID = length;
        add(item);
        return item;
    }
}

class PageItem extends Alphabet {
    public var onSelect = new FlxTypedSignal<Void->Void>();
    public function select() {
		FlxFlicker.flicker(this, 0.7, 0.1, true, true, (flicker:FlxFlicker) -> onSelect.dispatch());
	}
}