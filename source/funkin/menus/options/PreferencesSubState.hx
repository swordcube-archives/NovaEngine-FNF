package funkin.menus.options;

import core.api.WindowsAPI;
import funkin.options.*;

class PreferencesSubState extends OptionSubstate {
    override function create() {
        initOptionTypes();
        script.call("onPreGenerateOptions");
        categories = [
            "Gameplay Settings",
            "Meta Settings"
        ];
        options = [
            "Gameplay Settings" => [
                new BoolOption(
                    "Downscroll",
                    "Whether or not you want the notes to scroll down instead of up.",
                    null
                ),
                new BoolOption(
                    "Centered Notefield",
                    "Centers your notes and hides the opponent's notes.",
                    null
                ),
                new BoolOption(
                    "Ghost Tapping",
                    "Allows you to press notes that don't exist without getting misses.",
                    null
                ),
                new BoolOption(
                    "Miss Sounds",
                    "Whether or not a sound should play when missing a note.",
                    null
                ),
                #if windows
                new BoolOption(
                    "Dark Titlebar",
                    "Whether or not the title bar should be dark.",
                    null,
                    (value:Bool) -> {
                        WindowsAPI.setDarkMode(value);
                    }
                ),
                #end
                new BoolOption(
                    "Display Accuracy",
                    "Whether or not to display your accuracy along with your score.",
                    null
                ),
                new ListOption(
                    "Show Cutscenes",
                    "Adjust if you want cutscenes to play in Story Mode only, Freeplay only, Both, or Never.",
                    null,
                    ["Story", "Freeplay", "Both", "Never"]
                ),
                new ListOption(
                    "Scroll Type",
                    "Changes how \"Scroll Speed\" is applied.\n\nMultiplier = Add on to the song's scroll speed.\nConstant = Set the song's scroll speed directly.",
                    null,
                    ["Multiplier", "Constant"]
                ),
                new NumberOption(
                    "Scroll Speed",
                    "Adjust how slow or fast you want the notes to scroll. Change \"Scroll Type\" to change how this speed should be applied.",
                    null,
                    0,
                    10,
                    0.1,
                    1
                )
            ],
            
            "Meta Settings" => [
                new BoolOption(
                    "Auto Pause",
                    "Whether or not the game should automatically pause when the window is unfocused.",
                    null,
                    (value:Bool) -> {
                        FlxG.autoPause = value;
                    }
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
                ),
                new BoolOption(
                    "FPS Counter",
                    "Whether or not the game should display your framerate at the top left of the screen.",
                    null
                ),
                new BoolOption(
                    "Memory Counter",
                    "Whether or not the game should display your memory usage at the top left of the screen.",
                    null
                )
            ]
        ];
        script.call("onGenerateOptions");

        super.create();
    }
}