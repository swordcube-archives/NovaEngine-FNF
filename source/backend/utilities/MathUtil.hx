package backend.utilities;

import flixel.math.FlxMath;

class MathUtil {
    /**
     * Basically just `FlxMath.lerp` but not fps dependant lol
     * @param a The initial value
     * @param b The value to lerp to
     * @param v The speed that the lerp occurs at
     * @param fpsDependant Whether or not the lerp is fps dependant
     */
    public static inline function lerp(a:Float, b:Float, v:Float, ?fpsDependant:Bool = false) {
        return FlxMath.lerp(a, b, FlxMath.bound((!fpsDependant ? Main.framerateAdjust(v) : v), 0, 1));
    }
}