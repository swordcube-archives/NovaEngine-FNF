package states.menus;

import states.menus.options.visual.*;
import states.menus.options.PageSubState;

class GameplayModifiers extends PageSubState {
    override function create() {
        super.create();
        bg.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        bg.alpha = 0.6;

        script.call("onPreGenerateTabs", []);
		tabs = ["Modifiers"];
		script.call("onGenerateTabs", []);

		script.call("onPreGenerateOptions", []);
		options = [
			"Modifiers" => [
				new Checkbox(
                    "Autoplay", 
                    "Hits all of the notes for you during gameplay.", 
                    "autoplay"
                ),
				new Number(
                    "Health Gain Mult",
                    "Adjust if you want a lot or a little bit of health gain when hitting notes.",
                    "healthGainMultiplier", 
                    "x", // makes it display shit like 1x
                    0.1, 
                    5, 
                    0.1, 
                    1
                ),
                new Number(
                    "Health Loss Mult",
                    "Adjust if you want a lot or a little bit of health loss when missing notes.",
                    "healthLossMultiplier", 
                    "x",
                    0.1, 
                    5, 
                    0.1, 
                    1
                )
			],
		];
		script.call("onGenerateOptions", []);
    }
}