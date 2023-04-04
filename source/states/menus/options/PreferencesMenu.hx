package states.menus.options;

import states.menus.options.visual.*;

class PreferencesMenu extends PageSubState {
	override function create() {
		super.create();

        if(!runDefaultCode) return;

        FlxG.sound.play(Paths.sound("game/hitsound"), 0);

		call("onPreGenerateTabs", []);
		tabs = ["Gameplay", "Appearance", "Tools", "Miscellaneous", "Experimental"];
		call("onGenerateTabs", []);

		call("onPreGenerateOptions", []);
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
                new Checkbox(
                    "Ghost Tapping", 
                    "Prevents you from missing when pressing keys while no notes can be hit.", 
                    "ghostTapping"
                ),
                new Checkbox(
                    "Miss Sounds", 
                    "Whether or not a sound should play when missing a note during gameplay.", 
                    "missSounds"
                ),
                new Checkbox(
                    "Disable Reset Button", 
                    "Whether or not pressing your RESET bind should kill you instantly during gameplay.", 
                    "disableResetButton"
                ),
				new Number(
                    "Hitsound Volume",
                    "Adjust how loud you want hitsounds to be.",
                    "hitsoundVolume", 
                    "%", // makes it display shit like 75%
                    0, 
                    100, 
                    5, 
                    0,
                    (value:Float) -> {
                        var controls = SettingsAPI.controls;
                        var justPressed:Bool = (controls.UI_LEFT_P || controls.UI_RIGHT_P);
                        if(justPressed)
                            FlxG.sound.play(Paths.sound("game/hitsound"), value / 100);
                    },
                    false
                ),
				new Number(
                    "Note Offset",
                    "Adjust how late your notes spawn.\nNegative = Early - Positive = Late",
                    "noteOffset",
                    "ms", 
                    -10000, 
                    10000, 
                    5, 
                    0
                ),
				new Number(
                    "Scroll Speed",
                    "Adjust how fast or slow the notes scroll during gameplay.\n0 = Chart's scroll speed",
                    "scrollSpeed",
                    "", 
                    0, 
                    10, 
                    0.1, 
                    1
                ),
                new List(
                    "Scroll Type",
                    "Choose how you want the scroll speed of notes to be applied.",
                    "scrollType",
                    ["Multiplier", "Constant"]
                )
			],
			"Appearance" => [
                new Checkbox(
                    "FPS Counter", 
                    "Whether or not you want the FPS to show up at the top left corner of the window.", 
                    "fpsCounter",
                    (value:Bool) -> Main.fpsOverlay.visible = value
                ),
                new Checkbox(
                    "Note Splashes", 
                    "Whether or not you want a particle effect to appear when you get a \"SiCK!!\" after hitting a note.", 
                    "noteSplashes"
                ),
				new Checkbox(
                    "Antialiasing", 
                    "Gives the game a slight performance boost when disabled at the cost of worse looking graphics.", 
                    "antialiasing"
                ),
                new Checkbox(
                    "Opaque Sustains", 
                    "Whether or not sustain notes should be made opaque during gameplay.", 
                    "opaqueSustains"
                ),
                new List(
                    "Judgement Camera",
                    "Choose what camera you want the ratings & combo to be on.",
                    "judgementCamera",
                    ["World", "HUD"]
                ),
				new Checkbox(
					"Subtitles",
					"If enabled, shows subtitles on songs like Monster or Winter Horrorland.",
					"subtitles"
				),
				new Number(
					"Subtitle Size",
					"The subtitle's size, if enabled.",
					"subtitleSize",
					"",
					10,
					55,
					1,
					0
				)
			],
			"Tools" => [
				new Custom(
                    "Callback Test", 
                    "yeah", 
                    () -> FlxG.switchState(new states.menus.FreeplayState())
                )
			],
            "Miscellaneous" => [
                new Checkbox( 
                    "Auto Pause",
                    "Whether or not the game should pause when the window is unfocused.",
                    "autoPause",
                    (value:Bool) -> FlxG.autoPause = value
                ),
                new Checkbox(
                    "Funny Volume Beep",
                    "make the volume beeping go funny pitch",
                    "funnyVolumeBeep"
                ),
                new Number(
                    "FPS Cap", 
                    "Adjust how high your FPS can go.",
                    "fpsCap",
                    " FPS", // makes it display shit like 120 FPS
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
            "Experimental" => [
                new Checkbox(
                    "Preload Notes",
                    "Preloads all of the notes when the gameplay loads in.\nDisable this setting to allow the notes to spawn as the song goes on.",
                    "preloadNotes"
                )
            ]
		];
		call("onGenerateOptions", []);
	}
}
