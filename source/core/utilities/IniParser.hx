package core.utilities;

using StringTools;

typedef Ini = Map<String, IniSection>;
typedef IniSection = Map<String, String>;

/**
 * A class used for parsing INI files.
 */
@:dox(hide) class IniParser {
    /**
     * Parses raw INI data and returns an `Ini` from it.
     * 
     * An `Ini` is just a `Map<String, Map<String, String>>`.
     * 
     * @param data The raw INI data to parse.
     */
    public static function parse(data:String):Ini {
        // Create a map to store the sections and their key-value pairs
        var sections:Ini = ["Global" => new IniSection()];

        // Split the data into lines
        var lines = data.split("\n");

        // Keep track of the current section
        var currentSection:Null<String> = "Global";

        try {
            // Iterate over each line
            for (line in lines) {
                line = line.trim();

                // Check if the line is a section header
                if (line.charAt(0) == "[" && line.charAt(line.length - 1) == "]") {
                    // Extract the section name from the line
                    currentSection = line.substring(1, line.length - 1);
                    // Initialize an empty map for the key-value pairs in this section
                    sections.set(currentSection, new IniSection());
                }
                // Otherwise, the line is a key-value pair
                else if (currentSection != null) {
                    // Split the line at the first '=' character
                    var parts = line.split("=");
                    if (parts.length == 2) {
                        // Add the key-value pair to the current section
                        sections.get(currentSection).set(parts[0].trim(), parts[1].trim());
                    }
                }
            }
        } catch(e) {
            Logs.trace('Error occured trying to parse INI data: $e', ERROR);
            return new Ini();
        }

        return sections;
    }
}