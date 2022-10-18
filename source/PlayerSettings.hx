package;

import Controls;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.util.FlxSignal;

// import ui.DeviceManager;
// import props.Player;
class PlayerSettings
{
	static public var numPlayers(default, null) = 0;
	static public var numAvatars(default, null) = 0;
	static public var player1(default, null):PlayerSettings;
	static public var player2(default, null):PlayerSettings;
	static public var players(default, null):Array<PlayerSettings> = []; // JOELwindows7: I wonder if we can add it up this.

	#if (haxe >= "4.0.0")
	static public final onAvatarAdd = new FlxTypedSignal<PlayerSettings->Void>();
	static public final onAvatarRemove = new FlxTypedSignal<PlayerSettings->Void>();
	#else
	static public var onAvatarAdd = new FlxTypedSignal<PlayerSettings->Void>();
	static public var onAvatarRemove = new FlxTypedSignal<PlayerSettings->Void>();
	#end

	public var id(default, null):Int;

	#if (haxe >= "4.0.0")
	public final controls:Controls;
	#else
	public var controls:Controls;
	#end

	// public var avatar:Player;
	// public var camera(get, never):PlayCamera;

	function new(id, scheme)
	{
		this.id = id;
		this.controls = new Controls('player$id', scheme);
	}

	public function setKeyboardScheme(scheme)
	{
		controls.setKeyboardScheme(scheme);
	}

	static public function init():Void
	{
		if (player1 == null)
		{
			player1 = new PlayerSettings(0, Solo);
			++numPlayers;
		}

		var numGamepads = FlxG.gamepads.numActiveGamepads;
		if (numGamepads > 0)
		{
			var gamepad = FlxG.gamepads.getByID(0);
			if (gamepad == null)
				throw 'Unexpected null gamepad. id:0';

			player1.controls.addDefaultGamepad(0);

			// JOELwindows7: add to our array first
			players[0] = player1;
		}

		if (numGamepads > 1)
		{
			if (player2 == null)
			{
				player2 = new PlayerSettings(1, None);
				++numPlayers;
			}

			var gamepad = FlxG.gamepads.getByID(1);
			if (gamepad == null)
				throw 'Unexpected null gamepad. id:1';

			player2.controls.addDefaultGamepad(1);

			// JOELwindows7: add to our array first
			players[1] = player2;
		}

		// JOELwindows7: and okay we should try to get every gamepads possible
		if (numGamepads > 2)
			for (i in 2...numGamepads)
			{
				if (players[i] == null)
				{
					players[i] = new PlayerSettings(i, None);
					++numPlayers;
				}

				var gamepad = FlxG.gamepads.getByID(i);
				if (gamepad == null)
					throw 'Unexpected null gamepad. id:$i';

				players[i].controls.addDefaultGamepad(i);
			}

		// DeviceManager.init();
	}

	static public function reset()
	{
		player1 = null;
		player2 = null;
		// JOELwindows7: also reset our array pls.
		for (i in 0...players.length)
			players[i] = null;
		numPlayers = 0;
	}
}
