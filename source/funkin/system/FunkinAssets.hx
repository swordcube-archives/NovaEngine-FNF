package funkin.system;

import flixel.system.FlxSound;
import flixel.graphics.FlxGraphic;

class FunkinAssets {
    public static function generateCountdownImages(skin:String):Map<String, FlxGraphic> {
        return [
            "ready" => graphicFromPath(Paths.image('game/countdown/$skin/ready')),
            "set"   => graphicFromPath(Paths.image('game/countdown/$skin/set')),
            "go"    => graphicFromPath(Paths.image('game/countdown/$skin/go')),
        ];
    }

    public static function generateCountdownSounds(skin:String):Map<String, FlxSound> {
        return [
            "3"  => FlxG.sound.load(Paths.sound('game/countdown/$skin/intro3')),
            "2"  => FlxG.sound.load(Paths.sound('game/countdown/$skin/intro2')),
            "1"  => FlxG.sound.load(Paths.sound('game/countdown/$skin/intro1')),
            "go" => FlxG.sound.load(Paths.sound('game/countdown/$skin/introGo')),
        ];
    }

    public static function graphicFromPath(path:String):FlxGraphic {
        return FlxGraphic.fromBitmapData(Assets.getBitmapData(path), false, path, false);
    }
}