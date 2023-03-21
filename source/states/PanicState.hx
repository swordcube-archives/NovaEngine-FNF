package states;

import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxState;

/**
 * The state the game switches to when a crash would normally happen.
 * Allows you to restart the game.
 */
class PanicState extends FlxState {
    public var errorString:String;

    public function new(errorString:String) {
        super();
        this.errorString = errorString;
    }

    override function create() {
        super.create();

        var spacing:Float = 30;

        var text = new FlxText(0, 60, 0, "A fatal error has occured!", 32);
        text.setFormat(Paths.font("vcr.ttf"), 32);
        text.alignment = CENTER;
        text.screenCenter(X);
        text.color = FlxColor.RED;
        text.y += spacing;
        add(text);

        var text = new FlxText(0, 30, 0, errorString, 24);
        text.setFormat(Paths.font("vcr.ttf"), 24);
        text.alignment = CENTER;
        text.screenCenter();
        text.y += spacing;
        add(text);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if(FlxG.keys.justPressed.SPACE)
            CoolUtil.openURL("https://github.com/swordcube/NovaEngine-FNF");

        if(FlxG.keys.justPressed.ESCAPE)
            FlxG.resetGame();
    }
}
