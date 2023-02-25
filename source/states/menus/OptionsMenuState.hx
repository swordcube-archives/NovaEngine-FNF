package states.menus;

import backend.scripting.events.CancellableEvent;
import flixel.math.FlxMath;
import flixel.effects.FlxFlicker;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.fonts.Alphabet;
import states.MusicBeat.MusicBeatState;
import flixel.util.FlxSignal.FlxTypedSignal;
import states.menus.options.*;

typedef StateData = {
    var state:Class<flixel.FlxState>;
    var ?args:Array<Dynamic>;
}

class OptionsMenuState extends MusicBeatState {
	public static var stateData:StateData;
	
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
		bg.scale.set(1.1, 1.1);
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xFFea71fd;

		add(pages = new PageGroup());

		var event = script.event("onAddPages", new CancellableEvent());

		if(!event.cancelled) {
			// VVV -- ADD PAGES HERE!!! -------------------------------------------
			pages.createItem("Preferences", () -> openMenu(new PreferencesMenu()));
			pages.createItem("Controls", () -> openMenu(new ControlsMenu()));
			pages.createItem("Exit", () -> exit());
			// ^^^ ----------------------------------------------------------------
		}

		script.event("onAddPagesPost", event);

		for (i => member in pages.members) {
			member.screenCenter();
			member.y += 90 * i;
			member.y -= (90 * (pages.length - 1)) * 0.5;
		}

		changeSelection(0, true);
	}

	public function openMenu(substate:flixel.FlxSubState) {
		persistentUpdate = false;
		persistentDraw = false;
		openSubState(substate);
	}

	public function selectPage() {
		pages.members[curSelected].select();
	}

	public function exit() {
        CoolUtil.playMenuSFX(CANCEL);
        if(stateData != null) {
            FlxG.switchState(Type.createInstance(stateData.state, stateData.args != null ? stateData.args : []));
            stateData = null;
        } else
            FlxG.switchState(new MainMenuState());
    }

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if(!runDefaultCode || selectedSomethin) return;

		changeSelection((controls.UI_DOWN_P ? 1 : 0) + (controls.UI_UP_P ? -1 : 0));

		if(controls.BACK) {
			persistentUpdate = false;
			persistentDraw = true;
			exit();
		}

		if(controls.ACCEPT) selectPage();
	}

	public function changeSelection(change:Int, force:Bool = false) {
		if (change == 0 && !force)
			return;

		curSelected = FlxMath.wrap(curSelected + change, 0, pages.length - 1);
		pages.forEach((page:PageItem) -> {
			page.alpha = (curSelected == page.ID) ? 1 : 0.6;
		});
		CoolUtil.playMenuSFX(SCROLL);
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
		CoolUtil.playMenuSFX(CONFIRM);
		FlxFlicker.flicker(this, 0.7, 0.1, true, true, (flicker:FlxFlicker) -> onSelect.dispatch());
	}
}