package funkin.system;

import flixel.graphics.FlxGraphic;

class FunkinAssets {
    public static function generateCountdownAssets(skin:String):Map<String, FlxGraphic> {
        return [
            "ready" => graphicFromPath(Paths.image('game/countdown/$skin/ready')),
            "set"   => graphicFromPath(Paths.image('game/countdown/$skin/set')),
            "go"    => graphicFromPath(Paths.image('game/countdown/$skin/go')),
        ];
    }

    public static function graphicFromPath(path:String):FlxGraphic {
        return FlxGraphic.fromBitmapData(OpenFLAssets.getBitmapData(path), false, path, false);
    }
}