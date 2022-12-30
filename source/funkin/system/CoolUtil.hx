package funkin.system;

import haxe.io.Path;
import funkin.system.IniParser.IniSection;
import funkin.system.IniParser.Ini;

using StringTools;

class CoolUtil {
    /**
     * Plays a menu sound effect.
     * 
     * 0 = Scrolling,
     * 1 = Confirming,
     * 2 = Cancelling
     * 
     * @param id The ID of the menu sound to play.
     * @param volume The volume of the sound.
     */
    public static function playMenuSFX(id:Int = 0, ?volume:Float = 1.0) {
        FlxG.sound.play(switch(id) {
            case 1: Paths.sound("menus/confirmMenu");
            case 2: Paths.sound("menus/cancelMenu");
            default: Paths.sound("menus/scrollMenu");
        }, volume);
    }

    /**
     * Plays music from a path. If an INI file with the same name as the music exists in the same location as the music;
     * 
     * It loads it and sets the BPM from the Sound section.
     * 
     * @param path The path to the music.
     * @param volume The initial volume of the music.
     * @param looped Whether or not the music loops.
     * @param fadeInVolume (Optional) The volume the music should fade in to. If not specified, the volume will remain at it's initial value.
     * @param fadeInDuration (Optional) How long the music should fade in for. Defaults to 1 second if not specified.;
     */
    public static function playMusic(path:String, ?volume:Float = 1.0, ?looped:Bool = true, ?fadeInVolume:Null<Float>, ?fadeInDuration:Float = 1.0) {
        FlxG.sound.playMusic(path, volume, looped);
        if(fadeInVolume != null)
            FlxG.sound.music.fadeIn(fadeInDuration, volume, fadeInVolume);

        var ini:Ini = IniParser.parse(OpenFLAssets.getText(path.replace("."+Path.extension(path), ".ini")));

        // If the "Sound" section doesn't exist, Stop the function right here
        if(!ini.exists("Sound")) return;

        var section:IniSection = ini["Sound"];

        // Set the Conductor's BPM if the "BPM" property exists
        if(section.exists("BPM"))
            Conductor.bpm = Std.parseFloat(section["BPM"]);
    }
}