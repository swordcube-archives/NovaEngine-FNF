package flixel.util;

import flixel.addons.ui.FlxUICheckBox;

class FlxTools {
    public static inline function makeCheckbox(?x:Float = 0, ?y:Float = 0, ?title:String = "Checkbox", ?checked:Bool = false, ?labelWidth:Int = 100) {
        var checkbox:FlxUICheckBox = new FlxUICheckBox(x, y, null, null, title, labelWidth);
        checkbox.checked = checked;
        return checkbox;
    }
}