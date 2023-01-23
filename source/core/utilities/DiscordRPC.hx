package core.utilities;

import haxe.Json;
import openfl.utils.Assets;
#if DISCORD_RPC
import discord_rpc.DiscordRpc;
import sys.thread.Thread;
import Sys;
import lime.app.Application;
import flixel.system.FlxSound;
#end

class DiscordRPC {
	public static var currentID:String = null;
	public static var discordThread:#if DISCORD_RPC Thread #else Dynamic #end = null;
	public static var ready:Bool = false;
	public static var data:DiscordJson = null;

	public static function init() {
		#if DISCORD_RPC
		reloadJsonData();
		discordThread = Thread.create(function() {
			while (true) {
				while (!ready) {
					Sys.sleep(1 / 60);
				}
				trace("Processing Discord RPC...");
				DiscordRpc.process();
				Sys.sleep(2);
			}
		});

		Application.current.onExit.add(function(exitCode) {
			shutdown();
		});
		#end
	}

	public static function reloadJsonData() {
		#if DISCORD_RPC
		data = {};
		var jsonPath = Paths.json("data/discordRPC");
		if (Paths.exists(jsonPath)) {
			try {
				data = Json.parse(Assets.getText(jsonPath));
			} catch (e) {
				Console.error('Couldn\'t load Discord RPC configuration: ${e.toString()}');
			}
		}
		data.setFieldDefault("clientID", "814588678700924999");
		data.setFieldDefault("logoKey", "icon");
		data.setFieldDefault("logoText", "Nova Engine");

		changeClientID(data.clientID);
		#end
	}

	public static function changePresence(details:String, state:String, ?smallImageKey:String) {
		#if DISCORD_RPC
		changePresenceAdvanced({
			state: state,
			details: details,
			smallImageKey: smallImageKey
		});
		#end
	}

	public static function changePresenceAdvanced(data:#if DISCORD_RPC DiscordPresenceOptions #else Dynamic #end) {
		#if DISCORD_RPC
		if (data == null) return;

		if (data.largeImageKey == null)
			data.largeImageKey = DiscordRPC.data.logoKey;
		if (data.largeImageText == null)
			data.largeImageText = DiscordRPC.data.logoText;

		DiscordRpc.presence(data);
		#end
	}

	public static function changeClientID(id:String) {
		#if DISCORD_RPC
		if (currentID != null)
			DiscordRpc.shutdown();

		ready = false;

		DiscordRpc.start({
			clientID: id,
			onReady: function() {
				trace('Discord RPC started');
				ready = true;
			},
			onError: onError,
			onDisconnected: onDisconnected
		});
		currentID = id;
		#end
	}

	public static function shutdown() {
		#if DISCORD_RPC
		DiscordRpc.shutdown();
		#end
	}

	// HANDLERS
	#if DISCORD_RPC
	static function onError(_code:Int, _message:String) {
		trace('Discord RPC Error: ${_message} (Code: $_code)', ERROR);
	}

	static function onDisconnected(_code:Int, _message:String) {
		trace('Discord RPC Disconnected: ${_message} (Code: $_code)', WARNING);
	}
	#end
}

typedef DiscordJson = {
	var ?clientID:String;
	var ?logoKey:String;
	var ?logoText:String;
}
