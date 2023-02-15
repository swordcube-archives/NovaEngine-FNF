package states.menus.options;

import states.menus.options.visual.*;

class PreferencesMenu extends PageSubState {
    override function create() {
        super.create();
        script.call("onAddOptions", []);

        options.add(new Option("text only"));
        options.add(new Checkbox("text and checkbox", "downscroll"));

        if(core.modding.ModUtil.currentMod == "test")
            options.add(new Checkbox("modded option test", "test:ModdedOptionTest"));

        script.call("onAddOptionsPost", []);
    }
}