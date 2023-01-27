package core.dependency;

enum abstract LogType(Int) from Int to Int {
    var INFO = 0;
    var WARNING = 1;
    var ERROR = 2;
    var TRACE = 3;
    var VERBOSE = 4;
}

/**
 * A class for printing stuff to the console in a more readable way.
 */
class Logs {
    public static var colors:Map<String, String> = [
		'black'		=> '\033[0;30m',
		'red'		=> '\033[31m',
		'green'		=> '\033[32m',
		'yellow'	=> '\033[33m',
		'blue'		=> '\033[1;34m',
		'magenta'	=> '\033[1;35m',
		'cyan'		=> '\033[0;36m',
		'grey'		=> '\033[0;37m',
		'gray'		=> '\033[0;37m',
		'white'		=> '\033[1;37m',
		'orange'	=> '\033[38;5;214m',
		'reset'		=> '\033[0;37m'
	];
    
    public static function init() {
        haxe.Log.trace = (v, ?pos) -> {
            Logs.trace('${pos.fileName} - Line ${pos.lineNumber}: $v', TRACE);
        };
    }

    public static function trace(value:Dynamic, type:LogType) {
        var time = Date.now();
        var timeStr:String = '${colors["green"]}[${Std.string(time.getHours()).addZeros(2)}:${Std.string(time.getMinutes()).addZeros(2)}:${Std.string(time.getSeconds()).addZeros(2)}] ';

        Sys.println(switch(type) {
            case WARNING: timeStr + colors["yellow"] +  "[ 🟡 WARNING ] " + value + colors["reset"];
            case ERROR:   timeStr + colors["red"] +     "[  🔴 ERROR  ] " + value + colors["reset"];
            case TRACE:   timeStr + colors["gray"] +    "[  ❕ TRACE  ] " + value + colors["reset"];
            case VERBOSE: timeStr + colors["magenta"] + "[ 🟣 VERBOSE ] " + value + colors["reset"];
            default:      timeStr + colors["cyan"] +    "[  🔵 INFO   ] " + value + colors["reset"];
        });
    }
}