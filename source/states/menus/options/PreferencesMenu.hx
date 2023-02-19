package states.menus.options;

import states.menus.options.visual.*;

class PreferencesMenu extends PageSubState {
	override function create() {
		super.create();

		script.call("onPreGenerateTabs", []);
		tabs = ["Gameplay", "Appearance", "Tools"];
		script.call("onGenerateTabs", []);

		script.call("onPreGenerateOptions", []);
		options = [
			"Gameplay" => [
				new Checkbox(
                    "Downscroll", 
                    "Makes your notes scroll downwards instead of upwards.", 
                    "downscroll"
                ),
				new Checkbox(
                    "Centered Notefield", 
                    "Centers your notes and hides the opponent's notes", 
                    "centeredNotefield"
                ),
				new Number(
                    "Note Offset",
                    "Adjust how late your notes spawn.\nNegative = Early - Positive = Late",
                    "noteOffset", 
                    -10000, 
                    10000, 
                    0.1, 
                    1
                )
			],
			"Appearance" => [
				new Checkbox(
                    "Antialiasing", 
                    "Gives the game a slight performance boost at the cost of worse looking graphics.", 
                    "antialiasing"
                ),
				new Number(
                    "FPS Cap", 
                    "Adjust how high your FPS can go.",
                    "fpsCap",
                    10, 
                    1000, 
                    5, 
                    0, 
                    (value:Float) -> Main.setFPSCap(Std.int(value))
                ),
				new Checkbox(
                    "VSync", 
                    "Sets the FPS cap to the monitor's refresh rate when enabled.\nDefaults to 60 if the monitor refresh rate couldn't be gotten.",
                    "vsync",
                    (value:Bool) -> Main.setFPSCap(SettingsAPI.fpsCap)
                )
			],
			"Tools" => [
				new Custom(
                    "Callback Test", 
                    "yeah", 
                    () -> FlxG.switchState(new states.menus.FreeplayState())
                )
			]
		];
		script.call("onGenerateOptions", []);
	}
}
