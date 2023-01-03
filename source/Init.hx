package;

import funkin.windows.WindowsAPI;
import funkin.system.AudioSwitchFix;
import funkin.system.Preferences;
import funkin.game.ChartLoader;
import funkin.game.PlayState;
import funkin.system.Controls;
import funkin.system.ModHandler;
import funkin.scripting.ScriptHandler;
import funkin.system.Conductor;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import flixel.FlxState;

class Init extends FlxState {
    public static var controls:Controls;

    override function create() {
        super.create();

        FlxG.save.bind("mainSave", "FunkinForever");

        Console.init();
        AudioSwitchFix.init();
		WindowsAPI.setDarkMode(true);

        FlxSprite.defaultAntialiasing = true;
        FlxG.fixedTimestep = false;
        FlxG.signals.preStateCreate.add(function(state:FlxState) {
            Conductor.reset();

            @:privateAccess
            Preferences.__save.bind("preferencesSave", "FunkinForever");

            Assets.cache.clear();
            LimeAssets.cache.clear();
            Polymod.clearCache();
            #if MOD_SUPPORT
            Console.info("UNLOADING ALL MODS!");
            Polymod.unloadAllMods();
            Console.info("LOADING ALL ACTIVE MODS!");
            Polymod.loadMods(ModHandler.getDirectories());
            Console.info("LOADED ALL ACTIVE MODS SUCCESSFULLY!");
            #end

            #if cpp
            cpp.vm.Gc.run(true);
            #else
            openfl.system.System.gc();
            #end
        });

        // Initialize transitions
        var diamond = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;

        FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.4, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
            new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
        FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.4, new FlxPoint(0, 1),
            {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

        // Flixel is questionable
        if(FlxG.save.data.volume != null)
            FlxG.sound.volume = FlxG.save.data.volume;

        Preferences.init();

        Conductor.init();
        ScriptHandler.init();

        ModHandler.init();

        Polymod.init({
            modRoot: "mods",
            dirs: ModHandler.getDirectories(),
            errorCallback: function(error:polymod.Polymod.PolymodError) {
                switch(error.severity) {
                    case ERROR:
                        Console.error(error.message);
                    default:
                }
            },
            framework: OPENFL, // because FLIXEL doesn't work
            frameworkParams: {
                assetLibraryPaths: [
                    "songs" => "songs",
                    "videos" => "videos"
                ]
            }
        });

        controls = new Controls();

        PlayState.SONG = ChartLoader.load(FNF, Paths.chart("tutorial"));

        FlxG.switchState(new funkin.menus.TitleScreen());
    }
}