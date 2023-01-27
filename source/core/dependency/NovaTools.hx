package core.dependency;

class NovaTools {
    public static function playMenuMusic(?name:String = "freakyMenu", ?volume:Float = 1.0, ?fadeInVolume:Null<Float>, ?fadeInDuration:Float = 1.0) {
        CoolUtil.playMusic(Paths.music(name), volume, true, Paths.ini('music/$name'), fadeInVolume, fadeInDuration);
    }
}