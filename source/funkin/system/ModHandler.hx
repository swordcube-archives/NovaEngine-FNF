package funkin.system;

class ModHandler {
    /**
     * Switches the currently loaded Polymod mod to whatever you specify.
     * 
     * You should do `Polymod.clearCache()` before running this function! 
     * 
     * @param toMod The mod to switch to. `Paths.currentMod` gets set to this.
     */
    public static function switchMod(toMod:String) {
        Polymod.unloadAllMods();
        Polymod.loadMod(Paths.currentMod = toMod);   
    }
}