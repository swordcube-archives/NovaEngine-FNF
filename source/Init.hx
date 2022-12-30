package;

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
    override function create() {
        super.create();

        FlxSprite.defaultAntialiasing = true;
        FlxG.fixedTimestep = false;
        FlxG.signals.preStateCreate.add(function(state:FlxState) {
            Conductor.reset();
            Polymod.clearCache();
            Polymod.unloadAllMods();
            Polymod.loadMods([Paths.currentMod]);
        });

        // Initialize transitions
        var diamond = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;

        FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.4, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
            new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
        FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.4, new FlxPoint(0, 1),
            {asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

        Conductor.init();
        ScriptHandler.init();

        // Flixel is questionable
        if(FlxG.save.data.volume != null)
            FlxG.sound.volume = FlxG.save.data.volume;

        FlxG.save.bind("funkinforever-options", "swordcube");

        if(FlxG.save.data.currentMod != null)
            Paths.currentMod = FlxG.save.data.currentMod;
        else {
            FlxG.save.data.currentMod = Paths.currentMod;
            FlxG.save.flush();
        }

        #if MOD_SUPPORT
        Polymod.init({
            modRoot: "mods",
            dirs: [Paths.currentMod],
            errorCallback: function(error:polymod.Polymod.PolymodError) {
                trace(error.message);
            },
            framework: OPENFL, // because FLIXEL doesn't work
            frameworkParams: {
                assetLibraryPaths: [
                    "songs" => "songs"
                ]
            }
        });
        #end

        FlxG.switchState(new funkin.menus.TitleScreen());
    }
}