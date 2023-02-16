package states.menus.options;

import states.menus.options.visual.*;

class PreferencesMenu extends PageSubState {
    override function create() {
        super.create();

        script.call("onAddTabs", []);
        tabs = ["Gameplay", "Appearance", "Tools"];
        script.call("onAddTabsPost", []);

        script.call("onAddOptions", []);
        options = [
            "Gameplay" => [
                new Checkbox("Downscroll", "downscroll"),
                new Checkbox("Centered Notefield", "centeredNotefield"),
                new Number("Note Offset", "noteOffset", -10000, 10000, 0.1, 1)
            ],
            "Appearance" => [
                new Checkbox("Antialiasing", "antialiasing"),
                new Number("FPS Cap", "fpsCap", 10, 1000, 5, 0, (value:Float) -> Main.setFPSCap(Std.int(value))),
                new Checkbox("VSync", "vsync", (value:Bool) -> Main.setFPSCap(SettingsAPI.fpsCap))
            ],
            "Tools" => [
                new Custom("Callback Test", () -> FlxG.switchState(new states.menus.FreeplayState()))
            ]
        ];
        script.call("onAddOptionsPost", []);
    }
}