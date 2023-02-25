package backend.utilities;

#if DISCORD_RPC
import Sys.sleep;
import discord_rpc.DiscordRpc;
#end

using StringTools;

class DiscordRPC {
	public static var ready:Bool = false;

	public function new() {
		#if DISCORD_RPC
		ready = false;
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: "814588678700924999",
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});

		while (true) {
			while(!ready) {
				Sys.sleep(1/60);
			}
			DiscordRpc.process();
			sleep(2);
			// trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
		#end
	}

	public static function shutdown() {
		#if DISCORD_RPC
		DiscordRpc.shutdown();
		#end
	}

	static function onReady() {
		#if DISCORD_RPC
		DiscordRpc.presence({
			state: null,
			largeImageKey: "icon",
			largeImageText: "Nova Engine"
		});
		ready = true;
		trace("Discord Client started.");
		#end
	}

	static function onError(_code:Int, _message:String) {
		Logs.trace('Error! $_code : $_message', ERROR);
	}

	static function onDisconnected(_code:Int, _message:String) {
		Logs.trace('Disconnected! $_code : $_message', ERROR);
	}

	public static function initialize() {
		#if DISCORD_RPC
		sys.thread.Thread.create(() -> {
			new DiscordRPC();
		});
		#end
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float) {
		#if DISCORD_RPC
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