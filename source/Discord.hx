package;

#if FEATURE_DISCORD
import Sys.sleep;
import discord_rpc.DiscordRpc;

using StringTools;

// JOELwindows7: time to yoink BOLO https://github.com/BoloVEVO/Kade-Engine-Public/blame/stable/source/Discord.hx
class DiscordClient
{
	public static var modesArray:Array<String> = ['Simplified', 'Detailed']; // JOELwindows7: BOLO discord mode yey
	public static var instance:DiscordClient; // JOELwindows7: not sure if this secure or not. I mean, this only do presence that's it. idk..

	// nah, everything here are static. maybe one day there're more non-static things, I guess?? yeah.

	public function new()
	{
		trace("Discord Client starting...");
		DiscordRpc.start({
			// JOELwindows7: move Client ID to constants
			clientID: Perkedel.API_DISCORD_CLIENT_ID, // change this to what ever the fuck you want lol
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			// trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
		instance = null; // JOELwindows7: empty it out!
	}

	static function onReady()
	{
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: "fridaynightfunkin"
		});
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			instance = new DiscordClient();
		});
		trace("Discord Client initialized");
	}

	// JOELwindows7: BOLO get rich presence mode
	public static function getRCPmode()
	{
		return modesArray;
	}

	// JOELwindows7: & by ID integer
	public static function getRCPmodeByID(id:Int)
	{
		return modesArray[id];
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float)
	{
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}

		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: 'icon',
			largeImageText: "fridaynightfunkin",
			smallImageKey: smallImageKey,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});

		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}
}
#end
