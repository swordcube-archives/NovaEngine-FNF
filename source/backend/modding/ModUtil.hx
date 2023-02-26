package backend.modding;

import backend.modding.Metadata;

class ModUtil {
    public static var metadatas:Array<Metadata> = [];

    public static var fallbackMetadata:Metadata = null;
    public static final fallbackMod:String = "Friday Night Funkin'";

    public static var currentMod:String = fallbackMod;
    public static var currentMetadata:Metadata = null;

    public static var metadataMap:Map<String, Metadata> = [];

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
        var metadata:Metadata = fallbackMetadata;

        #if MOD_SUPPORT
        var metadataJsonPathSource:String = '${Paths.backPath}mods/$modName/pack.json';
        var metadataJsonPath:String = './mods/$modName/pack.json';

        // If the mod we selected is "Friday Night Funkin'", then try to load metadata from assets
        var defaultMetadataJsonPath:String = './assets/pack.json';
        if(modName == fallbackMod)
            metadata = FileSystem.exists(defaultMetadataJsonPath) ? Json.parse(File.getContent(defaultMetadataJsonPath)) : fallbackMetadata;

        // Try to load metadata from the mods folder
        if(FileSystem.exists(metadataJsonPathSource))
            metadata = Json.parse(File.getContent(metadataJsonPathSource));

        if(FileSystem.exists(metadataJsonPath))
            metadata = Json.parse(File.getContent(metadataJsonPath));
        #end
        
        currentMetadata = metadata;
        currentMod = modName;
        ScriptHandler.preset.set("mod", currentMod);

        FlxG.save.data.currentMod = modName;
        FlxG.save.flush();

        if(callback != null)
            callback();
    }

    public static function refreshMetadatas() {
        var funkinMetadata = Paths.json("pack", fallbackMod);
        metadataMap = [fallbackMod => funkinMetadata];
        metadatas = [funkinMetadata];

        #if MOD_SUPPORT
        var foldersToCheck:Array<String> = [
            '${Paths.backPath}mods',
            "./mods"
        ];

        for(ogFolder in foldersToCheck) {
            if(!FileSystem.exists(ogFolder)) continue;

            var folderList = FileSystem.readDirectory(ogFolder);

            for(folder in folderList) {
                var folderPath:String = '$ogFolder/$folder';
                var packJsonPath:String = '$folderPath/pack.json';

                if(!FileSystem.isDirectory(folderPath) || !FileSystem.exists(packJsonPath) || metadataMap.exists(folder))
                    continue;
                
                var jsonData:Metadata = Json.parse(File.getContent(packJsonPath));
                metadataMap.set(folder, jsonData);
                metadatas.push(jsonData);
            }
        }
        #end
    }
}