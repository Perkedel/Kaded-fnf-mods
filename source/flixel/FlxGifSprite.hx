package flixel;

import com.yagp.GifDecoder;
import com.yagp.Gif;
import com.yagp.GifPlayer;
import com.yagp.GifPlayerWrapper;
import com.yagp.GifRenderer;
import openfl.utils.ByteArray;
import openfl.utils.Assets;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.utils.AssetType;
import haxe.ValueException;
import flixel.system.FlxGifAsset;
import haxe.io.Bytes;

@:access(openfl.utils.ByteArrayData)
class FlxGifSprite extends FlxSprite
{
	public var gif:Gif;
	public var player:GifPlayer;
	public var ready:Bool = false;

	public function new(GifThing:FlxGifAsset, X:Float = 0, Y:Float = 0, Width:Int = 0, Height:Int = 0)
	{
		super(X, Y);
		if (Width != 0)
		{
			setGraphicSize(Width, Math.floor(height));
		}
		updateHitbox();
		if (Height != 0)
		{
			setGraphicSize(Math.floor(width), Height);
		}
		updateHitbox();
		if (GifThing == null)
			dumb();
		if ((GifThing is String))
		{
			if (!Assets.exists(GifThing, BINARY))
				dumb();
			else
				Assets.loadBytes(GifThing).onComplete(function(byteArr:ByteArray)
				{
					parseByteArr(byteArr);
				}).onError(function(msg)
				{
					throw new ValueException("Kill Yourself :3 Bytes Wont Load!");
				});
		}
		else if ((GifThing is ByteArrayData))
			parseByteArr(GifThing);
		else if ((GifThing is Bytes))
			parseBytes(GifThing);
		else
			dumb();
	}
	
	public function dumb()
	{
		throw new ValueException("Hello, Why Are You Dumb?\nYou Are Supposed To Enter A Valid GIF!");
	}
	
	public function parseByteArr(byteArr:ByteArray)
	{
		gif = GifDecoder.parseByteArray(byteArr);
		createPlayer();
	}
	
	public function parseBytes(bytes:Bytes)
	{
		gif = GifDecoder.parseBytes(bytes);
		createPlayer();
	}
	
	public function createPlayer()
	{
		player = new GifPlayer(gif);
		pixels = player.data;
		ready = true;
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (ready)
		{
			player.update(elapsed);
		}
	}
}