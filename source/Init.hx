package;

import core.Controls;
import flixel.FlxState;

class Init extends FlxState {
    override function create() {
        Logs.init();
        Controls.init();
        SettingsAPI.init();
        Conductor.init();
        ScriptHandler.init();

        FlxG.fixedTimestep = false;

        FlxG.signals.preStateCreate.add((state:FlxState) -> {
            CoolUtil.clearCache();
            
            Controls.load();
            SettingsAPI.load();
            Conductor.reset();
            
            FlxSprite.defaultAntialiasing = SettingsAPI.antialiasing;
        });

        FlxG.switchState(new states.menus.TitleState());
    }
}