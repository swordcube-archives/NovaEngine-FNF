package;

import core.api.WindowsAPI;
import core.api.OptionsAPI;
import core.utilities.DiscordRPC;
import funkin.system.AudioSwitchFix;
import funkin.system.Controls;
import funkin.utilities.ModHandler;
import funkin.scripting.ScriptHandler;
import funkin.system.Conductor;
import flixel.math.FlxRect;
import flixel.math.FlxPoint;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.FlxGraphic;
import funkin.game.Note;
import flixel.FlxSprite;
import flixel.FlxState;

class Init extends FlxState {
    public static var controls:Controls;

    override function create() {
        super.create();

        DiscordRPC.initialize();

        FlxG.save.bind("mainSave", "NovaEngine");

        Console.init();
        AudioSwitchFix.init();

        FlxG.keys.preventDefaultKeys = [TAB];

        FlxG.fixedTimestep = false;
        FlxG.signals.preStateCreate.add(function(state:FlxState) {
            Conductor.reset();
            
            @:privateAccess {
                OptionsAPI.init();
                FlxSprite.defaultAntialiasing = OptionsAPI.get("Antialiasing");
            }

            Assets.cache.clear();
            LimeAssets.cache.clear();
            #if polymod
            Polymod.clearCache();
            #end

            #if MOD_SUPPORT
            Polymod.unloadAllMods();
            Polymod.loadMods([Paths.currentMod]);
            #end

            Note.reloadSkins();
            Note.reloadSplashSkins();

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

        OptionsAPI.init();
        FlxSprite.defaultAntialiasing = OptionsAPI.get("Antialiasing");
        FlxG.stage.frameRate = OptionsAPI.get("FPS Cap");

        #if windows
		WindowsAPI.setDarkMode(OptionsAPI.get("Dark Titlebar"));
        #end

        Conductor.init();
        ScriptHandler.init();

        ModHandler.init();

        #if polymod
        Polymod.init({
            modRoot: "mods",
            dirs: [#if MOD_SUPPORT Paths.currentMod #end],
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
        #end

        controls = new Controls();

        FlxG.switchState(new funkin.menus.TitleState());
    }
}