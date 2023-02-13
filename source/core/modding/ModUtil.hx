package core.modding;

import core.modding.Metadata;

class ModUtil {
    public static var fallbackMetadata:Metadata = null;
    public static final fallbackMod:String = "Friday Night Funkin'";

    public static var currentMod:String = fallbackMod;
    public static var currentMetadata:Metadata = null;

    public static function init() {
        fallbackMetadata = currentMetadata = {
            name: "???",
            description: "Mod could not be loaded correctly, either a \"pack.json\" file doesn't exist, or this mod doesn't exist as a folder.",
            contributors: [
                {
                    name: "???",
                    role: "???"
                }
            ],
            api_version: Main.engineVersion,
            mod_version: "1.0.0"
        };
    }

    public static function switchToMod(modName:String, ?callback:Void->Void) {
        var metadataJsonPath:String = './mods/$modName/pack.json';
        var metadata:Metadata = fallbackMetadata;

        // If the mod we selected is "Friday Night Funkin'", then try to load metadata from assets
        var defaultMetadataJsonPath:String = './assets/pack.json';
        if(modName == fallbackMod)
            metadata = FileSystem.exists(defaultMetadataJsonPath) ? Json.parse(File.getContent(defaultMetadataJsonPath)) : fallbackMetadata;

        // Try to load metadata from the mods folder
        if(FileSystem.exists(metadataJsonPath))
            metadata = Json.parse(File.getContent(metadataJsonPath));
        
        currentMetadata = metadata;

        currentMod = modName;
        if(callback != null)
            callback();
    }
}