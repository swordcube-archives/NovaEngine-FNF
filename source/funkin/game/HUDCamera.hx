package funkin.game;

import flixel.system.FlxAssets.FlxShader;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import flixel.math.FlxMatrix;
import openfl.display.BitmapData;
import flixel.graphics.frames.FlxFrame;
import flixel.FlxCamera;

class HUDCamera extends FlxCamera {
    public var downscroll(default, set):Bool = false;
    function set_downscroll(v:Bool) {
        return downscroll = flipY = v;
    }

    public override function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false,
        ?shader:FlxShader):Void
    {
        if (downscroll) {
            matrix.scale(1, -1);
            matrix.translate(0, height);
        }
        super.drawPixels(frame, pixels, matrix, transform, blend, smoothing, shader);
    }
}