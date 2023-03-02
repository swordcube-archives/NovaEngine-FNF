package objects.ui;

import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

class SearchBox extends FlxSpriteGroup {
    private var __boxWidth:Int;
    private var __boxHeight:Int;

    public var box:FlxSprite;
    public var icon:FlxSprite;

    public var inputtedText:FlxText;
    public var indicator:FlxSprite;

    public function new(?x:Float, ?y:Float, ?width:Int = 200, ?height:Int = 50) {
        super(x, y);
        __boxWidth = width;
        __boxHeight = height;

        add(box = new FlxSprite().makeGraphic(width, height, 0xFF000000));
        box.alpha = 0.6;

        add(icon = new FlxSprite(10, 10).loadGraphic(Paths.image("UI/base/search")));
        icon.setGraphicSize(height - 20);
        icon.updateHitbox();

        add(indicator = new FlxSprite(10 + (icon.width + 10), 10).makeGraphic(2, height - 20, 0xFFFFFFFF));
    }

    public var indicatorSine:Float = 0;

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(indicator.visible) {
            indicatorSine += 180 * elapsed;
			indicator.alpha = 1 - Math.sin((Math.PI * indicatorSine) / 180);
        }
    }
}