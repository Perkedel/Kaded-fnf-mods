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

// JOELwindows7: yoink from https://github.com/EnigmaEngine/EnigmaEngine/blob/stable/source/funkin/util/input/GestureUtil.hx
/*
 * GestureUtil.hx
 * Contains utility functions for dealing with gestures.
 * Currently only supports tap and swipe, if you need pan/zoom/rotate see here:
 * @see https://gitlab.com/wikiti-random-stuff/roxlib/-/blob/master/com/roxstudio/haxe/gesture/RoxGestureAgent.hx
 */
package utils.input;

import ui.components.input.IInteractable;
import ui.components.input.InteractableSprite;
import flixel.math.FlxPoint;
import flixel.FlxG;
import flixel.input.mouse.FlxMouseEventManager;

// #if !web
class GestureUtil
{
	// JOELwindows7: Oh no.. lots of changes!
	static var mouseEvent:FlxMouseEventManager;

	public static function initMouseControls()
	{
		mouseEvent = new FlxMouseEventManager();
		// FlxG.plugins.add(new FlxMouseEventManager());
		FlxG.plugins.add(mouseEvent);
	}

	/**
	 * Use these to handle gesture callbacks on a sprite.
	 * @param target 
	 */
	public static function addGestureCallbacks(target:InteractableSprite)
	{
		var mouseDownEvent = function(t:InteractableSprite)
		{
			trace('MouseDownEvent');
			@:privateAccess
			t.onJustPressed(FlxG.mouse.getScreenPosition());
		}
		var mouseUpEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicks;
			t.onJustReleased(FlxG.mouse.getScreenPosition(), pressTime);
		}
		var mouseOverEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			t.onJustHoverEnter(FlxG.mouse.getScreenPosition());
		}
		var mouseOutEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			t.onJustHoverExit(FlxG.mouse.getScreenPosition());
		}
		var rightMouseDownEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			t.onJustPressedRight(FlxG.mouse.getScreenPosition());
		}
		var rightMouseUpEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicksRight;
			t.onJustReleasedRight(FlxG.mouse.getScreenPosition(), pressTime);
		}
		var middleMouseDownEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			t.onJustPressedMiddle(FlxG.mouse.getScreenPosition());
		}
		var middleMouseUpEvent = function(t:InteractableSprite)
		{
			@:privateAccess
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicksMiddle;
			t.onJustReleasedMiddle(FlxG.mouse.getScreenPosition(), pressTime);
		}

		// FlxMouseEventManager.add(target, mouseDownEvent, mouseUpEvent, mouseOverEvent, mouseOutEvent, false, true, true, [LEFT]);
		// FlxMouseEventManager.add(target, rightMouseDownEvent, rightMouseUpEvent, null, null, false, true, true, [RIGHT]);
		// FlxMouseEventManager.add(target, middleMouseDownEvent, middleMouseUpEvent, null, null, false, true, true, [MIDDLE]);
		mouseEvent.add(target, mouseDownEvent, mouseUpEvent, mouseOverEvent, mouseOutEvent, false, true, true, [LEFT]);
		mouseEvent.add(target, rightMouseDownEvent, rightMouseUpEvent, null, null, false, true, true, [RIGHT]);
		mouseEvent.add(target, middleMouseDownEvent, middleMouseUpEvent, null, null, false, true, true, [MIDDLE]);
	}

	public static function handleGestureState(target:IInteractable, inputData:GestureStateData):GestureStateData
	{
		var mousePos = FlxG.mouse.getScreenPosition();
		var outputData:GestureStateData = {
			leftClickGestureStart: inputData.leftClickGestureStart,
		};

		if (FlxG.mouse.justPressed)
		{
			outputData.leftClickGestureStart = mousePos;
			target.onJustPressed(mousePos);
		}
		if (FlxG.mouse.justPressedMiddle)
		{
			target.onJustPressedMiddle(mousePos);
		}
		if (FlxG.mouse.justPressedRight)
		{
			target.onJustPressedRight(mousePos);
		}

		if (FlxG.mouse.justReleased)
		{
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicks;
			if (GestureUtil.isValidSwipe(inputData.leftClickGestureStart, mousePos))
				target.onJustSwiped(inputData.leftClickGestureStart, mousePos, pressTime,
					GestureUtil.getSwipeDirection(inputData.leftClickGestureStart, mousePos));

			outputData.leftClickGestureStart = null;
			target.onJustReleased(mousePos, pressTime);
		}
		if (FlxG.mouse.justReleasedMiddle)
		{
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicksMiddle;
			target.onJustReleasedMiddle(mousePos, pressTime);
		}
		if (FlxG.mouse.justReleasedRight)
		{
			var pressTime = FlxG.game.ticks - FlxG.mouse.justPressedTimeInTicksRight;
			target.onJustReleasedRight(mousePos, pressTime);
		}

		return outputData;
	}

	/**
	 * Defines the difference between a tap and a swipe.
	 * A swipe is longer than this many pixels, in screen space.
	 */
	static final SWIPE_DISTANCE_THRESHOLD = 10;

	public static function isValidSwipe(start:FlxPoint, end:FlxPoint)
	{
		if (start == null || end == null)
			return false;
		return start.distanceTo(end) >= SWIPE_DISTANCE_THRESHOLD;
	}

	/**
	 * You can swipe within 45 degrees of a direction for it to count.
	 */
	static final SWIPE_THRESHOLD:Float = 45;

	static final SWIPE_THRESHOLD_N_NE:Float = SWIPE_THRESHOLD / 2;
	static final SWIPE_THRESHOLD_NE_E:Float = SWIPE_THRESHOLD_N_NE + SWIPE_THRESHOLD;
	static final SWIPE_THRESHOLD_E_SE:Float = SWIPE_THRESHOLD_NE_E + SWIPE_THRESHOLD;
	static final SWIPE_THRESHOLD_SE_S:Float = SWIPE_THRESHOLD_E_SE + SWIPE_THRESHOLD;
	static final SWIPE_THRESHOLD_N_NW:Float = -1 * SWIPE_THRESHOLD / 2;
	static final SWIPE_THRESHOLD_NW_W:Float = SWIPE_THRESHOLD_NW_W - SWIPE_THRESHOLD;
	static final SWIPE_THRESHOLD_W_SW:Float = SWIPE_THRESHOLD_W_SW - SWIPE_THRESHOLD;
	static final SWIPE_THRESHOLD_SW_S:Float = SWIPE_THRESHOLD_SW_S - SWIPE_THRESHOLD;

	public static function getSwipeDirection(start:FlxPoint, end:FlxPoint)
	{
		var swipeAngle = start.angleBetween(end);
		if (SWIPE_THRESHOLD_N_NW < swipeAngle && swipeAngle < SWIPE_THRESHOLD_N_NE)
		{
			return NORTH;
		}
		if (SWIPE_THRESHOLD_N_NE < swipeAngle && swipeAngle < SWIPE_THRESHOLD_NE_E)
		{
			return NORTHEAST;
		}
		if (SWIPE_THRESHOLD_NE_E < swipeAngle && swipeAngle < SWIPE_THRESHOLD_E_SE)
		{
			return EAST;
		}
		if (SWIPE_THRESHOLD_E_SE < swipeAngle && swipeAngle < SWIPE_THRESHOLD_SE_S)
		{
			return SOUTHEAST;
		}

		if (SWIPE_THRESHOLD_NW_W < swipeAngle && swipeAngle < SWIPE_THRESHOLD_N_NW)
		{
			return NORTHWEST;
		}

		if (SWIPE_THRESHOLD_W_SW < swipeAngle && swipeAngle < SWIPE_THRESHOLD_NW_W)
		{
			return WEST;
		}
		if (SWIPE_THRESHOLD_SW_S < swipeAngle && swipeAngle < SWIPE_THRESHOLD_W_SW)
		{
			return SOUTHWEST;
		}

		// South is either -180 or 180 so the easiest way is to make it the fallback.
		return SOUTH;
	}
}
// #end

enum SwipeDirection
{
	NORTH;
	NORTHEAST;
	NORTHWEST;
	SOUTH;
	SOUTHEAST;
	SOUTHWEST;
	EAST;
	WEST;
}

/**
 * Put this variable on an object to help it keep track of things that tapped it.
 */
typedef GestureStateData =
{
	var ?leftClickGestureStart:FlxPoint;
}
