package funkin.menus;

import flixel.text.FlxText;
import flixel.effects.FlxFlicker;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxObject;
import funkin.ui.MenuItem;
import flixel.graphics.frames.FlxAtlasFrames;
import funkin.ui.AtlasMenuItem;
import funkin.ui.MenuTypedList;
import funkin.system.FNFSprite;
import funkin.system.MusicBeatState;

class MainMenuState extends MusicBeatState {
	public var bg:FNFSprite;
    public var magenta:FNFSprite;

    public var menuItems:MainMenuList;
    public var camFollow:FlxObject;

	override function create() {
		super.create();

		if (FlxG.sound.music == null || (FlxG.sound.music != null && !FlxG.sound.music.playing))
			CoolUtil.playMusic(Paths.music("freakyMenu"));

		if (!runDefaultCode) return;

        // Initializing the background
		bg = new FNFSprite().load(IMAGE, Paths.image("menus/menuBG"));
		bg.scale.set(1.2, 1.2);
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set(0, 0.17);
		add(bg);

        magenta = new FNFSprite().load(IMAGE, Paths.image("menus/menuBGDesat"));
		magenta.scale.copyFrom(bg.scale);
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.scrollFactor.copyFrom(bg.scrollFactor);
        magenta.visible = false;
        magenta.color = 0xFFfd719b;
		add(magenta);

        // Initializing the camera
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

        add(menuItems = new MainMenuList());

        menuItems.onChange.add(function(item:MenuItem) {
            camFollow.setPosition(item.getGraphicMidpoint().x, item.getGraphicMidpoint().y);
        });
		menuItems.onAcceptPress.add(function(item:MenuItem) {
			FlxFlicker.flicker(magenta, 1.1, 0.15, false, true);
		});

        // VVV -- ADD MENU ITEMS HERE!! --
		menuItems.createItem(null, null, "story mode", function() {
			startExitState(new StoryMenuState());
		});
		menuItems.createItem(null, null, "freeplay", function() {
			startExitState(new FreeplayState());
		});
        menuItems.createItem(null, null, "credits", function() {
			startExitState(new MusicBeatState());
		});
        menuItems.createItem(null, null, "options", function() {
			startExitState(new MusicBeatState());
		});
        // ^^^ ----------------------------

        var pos:Float = (FlxG.height - 160 * (menuItems.length - 1)) * 0.5;
		for (i in 0...menuItems.length) {
			var item:MainMenuItem = menuItems.members[i];
			item.x = FlxG.width * 0.5;
			item.y = pos + (160 * i);
		}

		var item:MainMenuItem = menuItems.members[0];
		camFollow.setPosition(item.getGraphicMidpoint().x, item.getGraphicMidpoint().y);
        FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit = new FlxText(5, FlxG.height, 0, '${Main.engineName} v${Main.engineVersion}', 16);
		versionShit.scrollFactor.set();
		versionShit.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        versionShit.y -= versionShit.height;
		add(versionShit);
	}

    function startExitState(nextState:flixel.FlxState) {
        menuItems.enabled = false;
        menuItems.forEach(function(item:MainMenuItem) {
            if (menuItems.selectedIndex != item.ID)
                FlxTween.tween(item, { alpha: 0 }, 0.4, { ease: FlxEase.quadOut });
            else
                item.visible = false;
        });
        new FlxTimer().start(0.4, function(tmr:FlxTimer) {
            FlxG.switchState(nextState);
        });
    }

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (!runDefaultCode) return;
        if (_exiting) menuItems.enabled = false;

		if (controls.BACK && menuItems.enabled && !menuItems.busy)
			FlxG.switchState(new TitleState());

		if (FlxG.keys.justPressed.TAB) {
			persistentUpdate = false;
			persistentDraw = true;
			openSubState(new ModSwitcher());
		}
	}
}

class MainMenuItem extends AtlasMenuItem {
	public function new(?x:Float = 0, ?y:Float = 0, name:String, atlas:FlxAtlasFrames, callback:Dynamic) {
		super(x, y, name, atlas, callback);
		this.scrollFactor.set();
	}

	override public function changeAnim(anim:String) {
		super.changeAnim(anim);
		origin.set(frameWidth * 0.5, frameHeight * 0.5);
		offset.copyFrom(origin);
	}
}

class MainMenuList extends MenuTypedList<MainMenuItem> {
	public function new() {
		super(Vertical);
	}

	public function createItem(?x:Float = 0, ?y:Float = 0, name:String, callback:Dynamic = null, fireInstantly:Bool = false) {
		var item:MainMenuItem = new MainMenuItem(x, y, name, Paths.getSparrowAtlas('menus/mainmenu/$name'), callback);
		item.fireInstantly = fireInstantly;
		item.ID = length;
		return addItem(name, item);
	}
}
