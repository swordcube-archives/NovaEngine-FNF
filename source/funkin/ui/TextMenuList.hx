package funkin.ui;

import flixel.group.FlxGroup.FlxTypedGroup;

class TextMenuList extends FlxTypedGroup<TextMenuItem> {
    public var isSelecting:Bool = false;
    public var centerX:Bool = false;
    public var centerY:Bool = false;

    public function new(?centerX:Bool = false, ?centerY:Bool = false) {
        super();

        this.centerX = centerX;
        this.centerY = centerY;
    }

    public function createItem(text:String, func:Void->Void) {
        var item = new TextMenuItem(centerX ? FlxG.width * 0.5 : 0, centerY ? FlxG.height * 0.5 : 0, Bold, text);
        if(centerX) item.x -= item.width * 0.5;
        if(centerY) item.y -= item.height * 0.5;

        item.onSelect.add(() -> {
            isSelecting = false;
            func();
        });
        item.ID = length;
        item.y += length * 90;
        add(item);

        return item;
    }

    public function selectItem(id:Int) {
        isSelecting = true;
        members[id].select();
    }

    public function centerItems() {
        if(!centerY) return;

        var pos = (FlxG.height - 90 * length) * 0.5;
        forEachAlive((text:TextMenuItem) -> {
            text.y = pos + (90 * text.ID);
        });
    }
}