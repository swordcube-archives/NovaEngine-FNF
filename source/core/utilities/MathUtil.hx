package core.utilities;

import flixel.math.FlxMath;

class MathUtil {
    public static inline function lerp(a:Float, b:Float, v:Float, ?framerateAdjust:Bool = true) {
        return FlxMath.lerp(a, b, FlxMath.bound((framerateAdjust ? Main.framerateAdjust(v) : v), 0, 1));
    }
}