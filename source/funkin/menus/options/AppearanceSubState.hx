package funkin.menus.options;

import funkin.options.*;

class AppearanceSubState extends OptionSubstate {
    override function create() {
        initOptionTypes();
        script.call("onPreGenerateOptions");
        categories = [
            "Judgements",
            "Notes",
            "Accessibility"
        ];
        options = [
            "Judgements" => [
                new ListOption(
                    "Camera",
                    "Whether or not the ratings & combo should appear on the world camera or the HUD.",
                    "Judgement Camera",
                    ["World", "HUD"]
                ),
                new ListOption(
                    "Counter",
                    "Determines where all of the sicks, goods, bads, shits, and misses you've gotten should show up.\nLeft = Left of the screen, Right = Right of the screen, None = Nowhere on the screen.",
                    "Judgement Counter",
                    ["Left", "Right", "None"]
                )
            ],

            "Notes" => [
                new ListOption(
                    "Sustain Layer",
                    "Whether or not the sustains should go behind the strums/receptors during gameplay.",
                    null,
                    ["Behind", "Front"]
                ),
                new BoolOption(
                    "Note Splashes",
                    "Whether or not a firework-like effect should appear when you get a \"SiCK!!\" on any note during gameplay.",
                    null
                )
            ],
            
            "Accessibility" => [
                new BoolOption(
                    "Flashing Lights",
                    "Whether or not to enable flashing lights. Turn this off if you are sensitive to flashing lights.\n(WARNING: May not work on every mod!!)",
                    null
                ),
                new BoolOption(
                    "Antialiasing",
                    "Whether to not to enable antialiasing. Disabling this helps improve performance a bit.",
                    null
                ),
                new NumberOption(
                    "Framerate Cap",
                    "Adjust how high your framerate can go.",
                    "FPS Cap", // don't feel like renaming this internally fuck u
                    30,
                    1000,
                    10,
                    0,
                    (value:Float) -> {
                        FlxG.stage.frameRate = value;
                    }
                )
            ]
        ];
        script.call("onGenerateOptions");

        super.create();
    }
}