package;

import openfl.events.KeyboardEvent;
import core.Controls;
import flixel.FlxState;
import openfl.ui.Keyboard;

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

        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (e:KeyboardEvent) -> {
            switch(e.keyCode) {
                // Allow F11 to fullscreen the game because Alt + Enter is kinda stinky >:(
                case Keyboard.F11: FlxG.fullscreen = !FlxG.fullscreen;
            }
        });

        FlxG.switchState(new states.menus.TitleState());
    }
}