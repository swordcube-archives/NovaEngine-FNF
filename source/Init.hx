package;

import openfl.events.KeyboardEvent;
import core.Controls;
import flixel.FlxState;
import openfl.ui.Keyboard;
import core.modding.ModUtil;

class Init extends FlxState {
    override function create() {
        Logs.init();
        Controls.init();
        SettingsAPI.init();
        Conductor.init();
        ScriptHandler.init();
        ModUtil.init();

        FlxG.fixedTimestep = false;

        FlxG.signals.preStateCreate.add((state:FlxState) -> {
            ModUtil.refreshMetadatas();
            CoolUtil.clearCache();
            
            Controls.load();
            SettingsAPI.load();
            Conductor.reset();
            
            FlxSprite.defaultAntialiasing = SettingsAPI.antialiasing;
        });
        FlxG.keys.preventDefaultKeys = [TAB];

        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (e:KeyboardEvent) -> {
            switch(e.keyCode) {
                // Allow F11 to fullscreen the game because Alt + Enter is kinda stinky >:(
                case Keyboard.F11: FlxG.fullscreen = !FlxG.fullscreen;
            }
        });

        ModUtil.switchToMod("test", () -> {
            trace("penis balls");
        });
        FlxG.switchState(new states.menus.TitleState());
    }
}