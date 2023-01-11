package funkin.system;

#if discord_rpc
import Sys.sleep;
import discord_rpc.DiscordRpc;
#end

using StringTools;

class DiscordRPC {
	public function new() {
		#if discord_rpc
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "814588678700924999",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true) {
			DiscordRpc.process();
			sleep(2);
			// trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
		#end
	}

	public static function shutdown() {
		#if discord_rpc
		DiscordRpc.shutdown();
		#end
	}

	static function onReady() {
		#if discord_rpc
		DiscordRpc.presence({
			state: null,
			largeImageKey: "icon",
			largeImageText: "Nova Engine"
		});
		#end
	}

	static function onError(_code:Int, _message:String) {
		Console.error('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String) {
		Console.warn('Disconnected! $_code : $_message');
	}

	public static function initialize() {
		#if discord_rpc
		var DiscordDaemon = sys.thread.Thread.create(() -> {
			new DiscordRPC();
		});
		#end
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
		#if discord_rpc
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0) endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: "icon",
			largeImageText: "Nova Engine",
			smallImageKey: smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});
		#end
	}
}