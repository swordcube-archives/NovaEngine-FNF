package funkin.system;

class ModHandler {
    public static function init() {
        #if MOD_SUPPORT
        if(FlxG.save.data.currentMod != null)
            Paths.currentMod = FlxG.save.data.currentMod;
        else {
            FlxG.save.data.currentMod = Paths.currentMod;
            FlxG.save.flush();
        }
        #end
    }
}