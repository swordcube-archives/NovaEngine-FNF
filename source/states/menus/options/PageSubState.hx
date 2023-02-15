package states.menus.options;

import states.menus.options.visual.*;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;
import states.MusicBeat.MusicBeatSubstate;

// TODO: MAKE MODDED OPTIONS WORK USING REFLECT!!!!

class PageSubState extends MusicBeatSubstate {
	public var bg:FNFSprite;
	public var options:OptionGroup;

	public function initOptionTypes() {
		script.set("Checkbox", Checkbox);
		script.set("Option", Option);
	}
	
    override function create() {
        super.create();
		
		initOptionTypes();

		add(bg = new FNFSprite().loadGraphic(Paths.image("menus/base/menuBGDesat")));
		bg.scale.set(1.2, 1.2);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.color = 0xFFC456D3;

		add(options = new OptionGroup());

        if(!runDefaultCode) return;
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

class OptionGroup extends FlxTypedGroup<Option> {
	override public function add(object:Option) {
		object.setPosition(50, 50);
		object.y += 90 * length;
		return super.add(object);
	}
}