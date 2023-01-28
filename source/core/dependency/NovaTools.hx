package core.dependency;

class NovaTools {
    public static function playMenuMusic(?name:String = "freakyMenu", ?volume:Float = 1.0, ?fadeInVolume:Null<Float>, ?fadeInDuration:Float = 1.0) {
        CoolUtil.playMusic(Paths.music(name), volume, true, Paths.ini('music/$name'), fadeInVolume, fadeInDuration);
    }

    public static function returnSkinAsset(asset:String, assetModifier:String = "base", changeableSkin:String = "default", prefixFolder:String = ""):Dynamic {
        return '${(prefixFolder != null && prefixFolder.length > 0) ? prefixFolder+"/" : ""}$assetModifier/$changeableSkin/$asset';
    }
}