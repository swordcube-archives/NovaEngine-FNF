package objects;

import flixel.FlxCamera;

class FNFCamera extends FlxCamera {
    public function new(x:Int = 0, y:Int = 0, w:Int = 0, h:Int = 0, z:Float = 0) {
        super(x, y, w, h, z);
        bgColor = 0x0;
    }
}