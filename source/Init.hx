package;

import core.Controls;
import flixel.FlxState;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import openfl.system.System;

class Init extends FlxState {
    override function create() {
        Logs.init();
        Controls.init();
        SettingsAPI.init();
        Conductor.init();
        ScriptHandler.init();

        FlxG.fixedTimestep = false;

        FlxG.signals.preStateCreate.add((state:FlxState) -> {
            Paths.assetCache.clear();
            Assets.cache.clear();
            LimeAssets.cache.clear();
            System.gc();
            
            Controls.load();
            SettingsAPI.load();
            Conductor.reset();
            FlxSprite.defaultAntialiasing = SettingsAPI.antialiasing;
        });

        FlxG.switchState(new states.menus.TitleState());
    }
}