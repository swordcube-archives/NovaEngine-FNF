package funkin.system;

import flixel.util.typeLimit.OneOfTwo;

class ModHandler {
    public static var activeMods:Array<Array<OneOfTwo<String, Bool>>> = [];

    public static function init() {
        #if sys
        var modsDir:String = '${Sys.getCwd()}mods/';

        if(FlxG.save.data.activeMods != null) {
            activeMods = FlxG.save.data.activeMods;
            if(FileSystem.exists(modsDir)) {
                for(item in FileSystem.readDirectory(modsDir)) {
                    if(FileSystem.isDirectory(modsDir+item)) {
                        if(!(activeMods.contains([item, true]) || activeMods.contains([item, false])))
                            activeMods.push([item, true]);
                    }
                }
            }
        } else {
            if(FileSystem.exists(modsDir)) {
                for(item in FileSystem.readDirectory(modsDir)) {
                    if(FileSystem.isDirectory(modsDir+item)) {
                        if(!activeMods.contains([item, true]))
                            activeMods.push([item, true]);
                    }
                }
            }
        }
        
        FlxG.save.data.activeMods = activeMods;
        FlxG.save.flush();
        #end
    }

    public static function getDirectories(?activeOnly:Bool = true) {        
        var activeMods:Array<String> = [];
        #if sys
        var modsDir:String = '${Sys.getCwd()}mods/';

        for(mod in ModHandler.activeMods) {
            if(activeOnly) {
                if(mod[1]) activeMods.push(mod[0]);
            } else
                activeMods.push(mod[0]);
        }

        if(FileSystem.exists(modsDir)) {
            for(item in FileSystem.readDirectory(modsDir)) {
                if(FileSystem.isDirectory(modsDir+item)) {
                    if(!(ModHandler.activeMods.contains([item, true]) || ModHandler.activeMods.contains([item, false]))) {
                        ModHandler.activeMods.push([item, true]);
                        activeMods.push(item);
                    }
                }
            }
        }
        #end
        return activeMods;
    }

    public static function getActive(mod:String) {
        for(i => m in activeMods) {
            if(mod == m[0]) return activeMods[i][1];
        }
        return false;
    }

    public static function setActive(mod:String, ?value:Bool = true) {
        for(i => m in activeMods) {
            if(mod == m[0]) {
                activeMods[i][1] = value;
                break;
            }
        }
        return value;
    }
}