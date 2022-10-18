/*
 * Apache License, Version 2.0
 *
 * Copyright (c) 2021 MasterEric
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at:
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// JOELwindows7: yoink from https://github.com/EnigmaEngine/EnigmaEngine/blob/stable/source/funkin/ui/component/base/RelativeSprite.hx
/*
 * RelativeSprite.hx
 * An FlxSprite which has additional handlers for relative positioning.
 */
package ui.components.base;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

/**
 * This extension of FlxSprite adds the ability to set relativeX and relativeY,
 * to position itself in relation to a parent.
 */
class RelativeSprite extends FlxSprite implements IRelative
{
	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset, ?Parent:FlxObject)
	{
		super(0, 0, SimpleGraphic);

		this.relativeX = X;
		this.relativeY = Y;

		if (Parent != null)
			this.parent = Parent;

		updatePosition();
	}

	public override function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false, Width:Int = 0, Height:Int = 0, Unique:Bool = false,
			?Key:String):RelativeSprite
	{
		super.loadGraphic(Graphic, Animated, Width, Height, Unique, Key);
		// Override to change the return type of the function.
		return this;
	}

	// JOELwindows7: screew this!!! why macro reds in all area of my IDE VScode & compile here?!?!??!?!?
	#if !macro
	public var parent(default, set):FlxObject;

	public function set_parent(value:FlxObject):FlxObject
	{
		// throw new haxe.exceptions.NotImplementedException();
		return this.parent = value;
	}

	public var relativeX(default, set):Float;

	public function set_relativeX(value:Float):Float
	{
		// throw new haxe.exceptions.NotImplementedException();
		return this.relativeX = value;
	}

	public var relativeY(default, set):Float;

	public function set_relativeY(value:Float):Float
	{
		// throw new haxe.exceptions.NotImplementedException();
		return this.relativeY = value;
	}

	public var relativeAngle(default, set):Float;

	public function set_relativeAngle(value:Float):Float
	{
		// throw new haxe.exceptions.NotImplementedException();
		return this.relativeAngle = value;
	}

	function updatePosition()
	{
		if (this.parent != null)
		{
			// Set the absolute X and Y relative to the parent.
			this.x = this.parent.x + this.relativeX;
			this.y = this.parent.y + this.relativeY;
			this.angle = this.parent.angle + this.relativeAngle;
		}
		else
		{
			this.x = this.relativeX;
			this.y = this.relativeY;
		}
	}
	#end
}
