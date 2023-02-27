package states.menus.options;

import flixel.text.FlxText;
import objects.fonts.Alphabet;
import flixel.math.FlxMath;
import states.menus.options.visual.*;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxBasic;
import states.MusicBeat.MusicBeatSubstate;

// TODO: MAKE MODDED OPTIONS WORK USING REFLECT!!!!

class PageSubState extends MusicBeatSubstate {
	public var bg:FNFSprite;
	public var grpOptions:OptionGroup;

	public var tabs:Array<String> = [];
	public var options:Map<String, Array<Option>> = [];	

	public var curTab:Int = 0;
	public var curSelected:Int = 0;

	public var changingTab:Bool = false;

	public var tabStrip:FNFSprite;
	public var tabName:Alphabet;
	public var tabArrows:Alphabet;

	public var tabIndicatorBox:FNFSprite;
	public var tabIndicatorTxt:FlxText;

	public var tabSwitchingStatus(get, never):String;
	private function get_tabSwitchingStatus() {
		return (changingTab) ? "Press [TAB] to stop switching tabs" : "Press [TAB] to start switching tabs";
	}

	public function initOptionTypes() {
		script.set("Checkbox", Checkbox);
		script.set("Number", Number);
		script.set("Custom", Custom);
		script.set("List", List);
		script.set("Option", Option);
	}
	
    override function create() {
        super.create();
		
		initOptionTypes();

		if(!runDefaultCode) return;

		add(bg = new FNFSprite().loadGraphic(Paths.image("menus/base/menuBGDesat")));
		bg.scale.set(1.1, 1.1);
		bg.updateHitbox();
		bg.screenCenter();
		bg.color = 0xFFea71fd;

		add(grpOptions = new OptionGroup());

		add(tabStrip = new FNFSprite(0, FlxG.height).makeGraphic(FlxG.width, 100, 0xFF000000));
		tabStrip.y -= tabStrip.height;

		add(tabName = new Alphabet(0, tabStrip.y + (tabStrip.height * 0.5), Bold, "penis"));
		tabName.screenCenter(X);
		tabName.y -= (tabName.height) * 0.5;
		tabName.alpha = 0.6;

		add(tabArrows = new Alphabet(0, tabStrip.y + (tabStrip.height * 0.5), Bold, "<                        >"));
		tabArrows.screenCenter(X);
		tabArrows.y -= (tabArrows.height) * 0.5;
		tabArrows.alpha = 0.35;

		add(tabIndicatorBox = new FNFSprite(FlxG.width, 20).makeGraphic(450, 40, 0xFF000000));
		tabIndicatorBox.x -= tabIndicatorBox.width;
		tabIndicatorBox.alpha = 0.6;

		add(tabIndicatorTxt = new FlxText(tabIndicatorBox.x + 10, tabIndicatorBox.y + 8, 0, tabSwitchingStatus, 12));
		tabIndicatorTxt.setFormat(Paths.font("vcr.ttf"), 20, 0xFFFFFFFF, RIGHT, OUTLINE, 0xFF000000);
		tabIndicatorTxt.borderSize = 2;

		for(obj in [bg, tabStrip, tabName, tabArrows, tabIndicatorBox, tabIndicatorTxt])
			obj.scrollFactor.set();
    }

	override function switchTo(state:flixel.FlxState) {
		SettingsAPI.save();
		return super.switchTo(state);
	}

	override function close() {
		SettingsAPI.save();
		super.close();
	}

	override function createPost() {
		changeTab(0, true);
		if(tabs.length < 2) {
			for(obj in [tabStrip, tabName, tabArrows, tabIndicatorBox, tabIndicatorTxt])
				obj.visible = false;
		}
		super.createPost();
	}

	public var holdTimer:Float = 0;

    override public function update(elapsed:Float) {
		super.update(elapsed);

		if(!runDefaultCode) return;

		if(FlxG.keys.justPressed.TAB && tabs.length > 1) {
			changingTab = !changingTab;
			tabIndicatorTxt.text = tabSwitchingStatus;
			changeSelection(0, true);
		}

		tabStrip.alpha = (changingTab) ? 0.6 : 0.3;
		tabName.alpha = (changingTab) ? 1 : 0.5;
		tabArrows.alpha = (changingTab) ? 0.3 : 0.15;
		
		if(changingTab)
			changeTab((controls.UI_RIGHT_P ? 1 : 0) + (controls.UI_LEFT_P ? -1 : 0));
		else {
			changeSelection((controls.UI_DOWN_P ? 1 : 0) + (controls.UI_UP_P ? -1 : 0));
			if(controls.ACCEPT) grpOptions.members[curSelected].select();
		}

		if(controls.UI_LEFT || controls.UI_RIGHT) {
			holdTimer += elapsed;

			var justPressed:Bool = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
			var playSelectSound:Bool = true;

			if(justPressed || holdTimer > 0.5) {
				switch(grpOptions.members[curSelected].getClassName().split(".").last()) {
					case "Number":
						var option:Number = cast grpOptions.members[curSelected];
						var increment:Float = (controls.UI_LEFT) ? -option.increment : option.increment;
						option.value = FlxMath.roundDecimal(FlxMath.bound(option.value + increment, option.minimum, option.maximum), option.decimals);
						option.update(0);
						playSelectSound = option.playSelectSound;

						if(option.callback != null)
							option.callback(option.value);

					case "List":
						var option:List = cast grpOptions.members[curSelected];
						var increment:Float = (controls.UI_LEFT) ? -1 : 1;
						var index:Int = Std.int(FlxMath.bound(option.values.indexOf(option.value) + increment, 0, option.values.length - 1));

						option.value = option.values[index];
						option.update(0);

						if(option.callback != null)
							option.callback(option.value);
				}
				if(holdTimer > 0.5) holdTimer = 0.435;
			}

			if(justPressed && playSelectSound)
				CoolUtil.playMenuSFX(SCROLL);
		} else
			holdTimer = 0;

		if(controls.BACK) {
			SettingsAPI.save();
			CoolUtil.playMenuSFX(CANCEL);
			close();
		}
	}

	public function changeSelection(change:Int, force:Bool = false) {
		if (change == 0 && !force)
			return;

		curSelected = FlxMath.wrap(curSelected + change, 0, grpOptions.length - 1);
		grpOptions.forEach((option:Option) -> {
			option.alphabet.alpha = ((curSelected == option.alphabet.ID) ? 1 : 0.6) * (changingTab ? 0.6 : 1);
			option.alphabet.targetY = (option.alphabet.ID - curSelected);
			option.update(0);
		});
		CoolUtil.playMenuSFX(SCROLL);
	}

	public function changeTab(change:Int, force:Bool = false) {
		if (change == 0 && !force)
			return;

		curTab = FlxMath.wrap(curTab + change, 0, tabs.length - 1);
		grpOptions.clear();

		for(option in options[tabs[curTab]])
			grpOptions.add(option);

		for(i => option in grpOptions.members) {
			option.alphabet.isMenuItem = true;
			option.alphabet.ID = i;
			option.alphabet.targetY = i;
			option.alphabet.setPosition(0, i * 30);
			option.scrollFactor.set();
		}

		curSelected = 0;
		changeSelection(0, true);
		
		tabName.text = tabs[curTab];
		tabName.screenCenter(X);

		CoolUtil.playMenuSFX(SCROLL);
	}

	override function destroy() {
		for(tab in options) {
			for(option in tab) {
				option.kill();
				option.destroy();
			}
		}
		super.destroy();
	}
}

class OptionGroup extends FlxTypedGroup<Option> {
	override public function add(object:Option) {
		object.y += 30 * length;
		return super.add(object);
	}
}