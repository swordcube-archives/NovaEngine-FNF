package;

import lime.app.Application;
import openfl.events.KeyboardEvent;
import backend.Controls;
import flixel.FlxState;
import openfl.ui.Keyboard;
import backend.modding.ModUtil;

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

            FlxG.sound.muteKeys = Controls.controlsList["VOLUME_MUTE"];
            FlxG.sound.volumeUpKeys = Controls.controlsList["VOLUME_UP"];
            FlxG.sound.volumeDownKeys = Controls.controlsList["VOLUME_DOWN"];
            
            FlxSprite.defaultAntialiasing = SettingsAPI.antialiasing;
        });
        FlxG.keys.preventDefaultKeys = [TAB];

        FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (e:KeyboardEvent) -> {
            switch(e.keyCode) {
                // Allow F11 to fullscreen the game because Alt + Enter is kinda stinky >:(
                case Keyboard.F11: FlxG.fullscreen = !FlxG.fullscreen;
            }
        });

        Application.current.onExit.add((exitCode:Int) -> {
            SettingsAPI.save();
            Controls.save();
        });
        SettingsAPI.load();
        
        Main.setFPSCap(SettingsAPI.fpsCap);
        FlxG.autoPause = SettingsAPI.autoPause;
        Main.fpsOverlay.visible = SettingsAPI.fpsCounter;

        var mod:String = ModUtil.currentMod;
        if(FlxG.save.data.currentMod != null)
            mod = FlxG.save.data.currentMod;

        ModUtil.switchToMod(mod);
        FlxG.switchState(new states.menus.TitleState());
    }
}