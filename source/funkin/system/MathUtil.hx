package funkin.system;

import flixel.math.FlxMath;

class MathUtil {
    public static function fixedLerp(initialValue:Float, finalValue:Float, ratio:Float) {
        return FlxMath.lerp(initialValue, finalValue, fpsAdjust(ratio));
    }

    public static function fpsAdjust(num:Float) {
        return FlxG.elapsed / (1/60) * num;
    }
}