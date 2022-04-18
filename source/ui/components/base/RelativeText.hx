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

// JOELwindows7: yoink from https://github.com/EnigmaEngine/EnigmaEngine/blob/stable/source/funkin/ui/component/base/RelativeText.hx

/*
 * RelativeText.hx
 * A FlxUIText element with an additional handler for relative positioning.
 */
package ui.components.base;

import flixel.FlxObject;
import flixel.addons.ui.FlxUIText;

class RelativeText extends FlxUIText implements IRelative
{
	public function new(X:Float = 0, Y:Float = 0, Parent:FlxObject = null, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(0, 0, FieldWidth, Text, Size, EmbeddedFont);

		this.parent = Parent;
		this.relativeX = X;
		this.relativeY = Y;
	}
}
