package states.menus;

import backend.modding.ModUtil;
import flixel.text.FlxText;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.effects.FlxFlicker;
import flixel.FlxState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import backend.utilities.FNFSprite.AnimationContext;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import states.MusicBeat.MusicBeatState;

class MainMenuState extends MusicBeatState {
	public var bg:FNFSprite;
	public var magenta:FNFSprite;

	public var menuItems:MainMenuGroup;

	public var curSelected:Int = 0;
    public var camFollow:FlxObject;

	override public function create() {
		super.create();

		if(FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			NovaTools.playMenuMusic("freakyMenu");

		if(!runDefaultCode) return;

		add(bg = new FNFSprite().loadGraphic(Paths.image("menus/base/menuBG")));
		bg.scale.set(1.2, 1.2);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, 0.17);

		add(magenta = new FNFSprite().loadGraphic(Paths.image("menus/base/menuBGDesat")));
		magenta.scale.copyFrom(bg.scale);
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.scrollFactor.copyFrom(bg.scrollFactor);
		magenta.color = 0xFFfd719b;
        magenta.visible = false;

		add(menuItems = new MainMenuGroup());

		// VVV -- ADD MENU ITEMS HERE!!! --------------------------------------
		menuItems.createItem("story mode", () -> FlxG.switchState(new StoryMenuState()));
		menuItems.createItem("freeplay", () -> FlxG.switchState(new FreeplayState()));
		menuItems.createItem("options", () -> FlxG.switchState(new OptionsMenuState()));
		// ^^^ ----------------------------------------------------------------

		for (i => member in menuItems.members) {
			member.x = FlxG.width * 0.5;
			member.screenCenter(Y);
			member.y += 160 * i;
			member.y -= (160 * (menuItems.length - 1.5)) * 0.5;
		}

		var modMetaData = ModUtil.metadataMap.get(ModUtil.currentMod);
		
		if(modMetaData == null)
			modMetaData = ModUtil.metadataMap.get(ModUtil.fallbackMod);

		var engineString:String = (
			'${Main.engineName} v${Main.engineVersion}\n'+
			'${modMetaData.name} - Press ${CoolUtil.keyToString(Controls.controlsList["SWITCH_MOD"][0])} to switch mods'
		);
		var engineText = new FlxText(5, FlxG.height, 0, engineString);
		engineText.setFormat(Paths.font("vcr.ttf"), 16, 0xFFFFFFFF, LEFT, OUTLINE, 0xFF000000);
		engineText.scrollFactor.set();
		engineText.y -= engineText.height;
		add(engineText);

        add(camFollow = new FlxObject(menuItems.members[curSelected].x, menuItems.members[curSelected].y, 1, 1));
        FlxG.camera.follow(camFollow, null, 0.06);

		changeSelection(0, true);
	}

	public var selectedSomethin:Bool = false;

	public function selectItem() {
        var button:MainMenuButton = menuItems.members[curSelected];

        if(button.flicker) {
            selectedSomethin = true;
            CoolUtil.playMenuSFX(CONFIRM);

            FlxFlicker.flicker(magenta, 1.1, 0.15, false, false, (flick:FlxFlicker) -> {
                menuItems.forEachAlive((spr:MainMenuButton) -> {
                    FlxTween.tween(spr, {alpha: 0}, 0.4, {ease: FlxEase.quadOut});
                });
                new FlxTimer().start(0.4, (tmr:FlxTimer) -> button.accept());
            });
            FlxFlicker.flicker(button, 1, 0.06, false, false);
        } else
            button.accept();
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if(!runDefaultCode || selectedSomethin) return;

		changeSelection((controls.UI_DOWN_P ? 1 : 0) + (controls.UI_UP_P ? -1 : 0));

		if(controls.BACK) {
			CoolUtil.playMenuSFX(CANCEL);
			FlxG.switchState(new TitleState());
		}

		if(controls.SWITCH_MOD) {
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new ModSwitcher());
		}

        if(controls.ACCEPT) selectItem();
	}

	public function changeSelection(change:Int, force:Bool = false) {
		if (change == 0 && !force)
			return;

		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);

		menuItems.forEachAlive((button:MainMenuButton) -> {
			button.playAnim((curSelected == button.ID) ? "selected" : "idle");
		});

        camFollow.setPosition(menuItems.members[curSelected].x, menuItems.members[curSelected].y);
		CoolUtil.playMenuSFX(SCROLL);
	}
}

class MainMenuGroup extends FlxTypedGroup<MainMenuButton> {
	public function createItem(name:String, onAccept:Void->Void, ?flicker:Bool = true) {
		var item:MainMenuButton = new MainMenuButton().loadAtlas(Paths.getSparrowAtlas('menus/base/mainmenu/$name'));
		item.animation.addByPrefix("idle", "idle", 24);
		item.animation.addByPrefix("selected", "selected", 24);
		item.animation.play("idle");
		item.accept = onAccept;
        item.flicker = flicker;
        item.scrollFactor.set();
		item.ID = length;
		add(item);
		return item;
	}
}

class MainMenuButton extends FNFSprite {
	public var accept:Void->Void;
    public var flicker:Bool = true;

	override function playAnim(name:String, force:Bool = false, context:AnimationContext = NORMAL, frame:Int = 0) {
		super.playAnim(name, force, context, frame);
		origin.set(frameWidth * 0.5, frameHeight * 0.5);
		offset.copyFrom(origin);
	}

	override function loadAtlas(Data:FlxAtlasFrames) {
		super.loadAtlas(Data);
		return this;
	}
}
