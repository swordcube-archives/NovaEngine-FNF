package core.utilities;

class CoolUtil {
	/**
	 * Gets the last item in `array` and returns it.
	 * @param array The array to get the item from.
	 */
     public static function last<T>(array:Array<T>):T {
		if(array.length < 1) return null;
		return array[array.length-1];
	}

	public static function addZeros(str:String, num:Int) {
		while(str.length < num) str = '0${str}';
		return str;
	}

	/**
	 * Converts bytes into a human-readable format `(Examples: 1b, 256kb, 1024mb, 2048gb, 4096tb)`
	 * @param num The bytes to convert.
	 * @return String
	 */
	public static function getSizeLabel(size:Float):String {
		var labels = ["B", "KB", "MB", "GB", "TB"];
		var rSize:Float = size;
		var label:Int = 0;
		while(rSize > 1024 && label < labels.length-1) {
			label++;
			rSize /= 1024;
		}
		return '${Std.int(rSize) + "." + addZeros(Std.string(Std.int((rSize % 1) * 100)), 2)}${labels[label]}';
	}

	/**
		Splits `text` into an array of multiple strings.
		@param text    The string to split
		@author swordcube
	**/
	public inline static function listFromText(text:String):Array<String> {
		var daList:Array<String> = text.trim().split('\n');
		for (i in 0...daList.length) daList[i] = daList[i].trim();
		return daList;
	}

	/**
	 * Trims everything in an array of strings and returns it.
	 * @param a The array to modify.
	 * @return Array<String>
	 */
	 public inline static function trimArray(a:Array<String>):Array<String> {
		var f:Array<String> = [];
		for(i in a) f.push(i.trim());
		return f;
	}

	/**
	 * Opens a instance of your default browser and navigates to `url`.
	 * @param url The URL to open.
	 */
	public inline static function openURL(url:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [url, "&"]);
		#else
		FlxG.openURL(url);
		#end
	}

	/**
	 * Splits `string` using `delimeter` and then converts all items in the array into an `Int` and returns it.
	 * @param string The string to split.
	 * @param delimeter The character to use for splitting.
	 * @return Array<Int>
	 * @author Leather128
	 */
	public inline static function splitInt(string:String, delimeter:String):Array<Int> {
		string = string.trim();
		var splitReturn:Array<Int> = [];
		if(string.length > 0) {
			var splitString:Array<String> = string.split(delimeter);
			for (string in splitString) splitReturn.push(Std.parseInt(string.trim()));
		}
		return splitReturn;
	}
}
