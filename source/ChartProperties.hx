/*
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2022 Perkedel
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
package;

import flixel.addons.ui.FlxUITabMenu;

/* Chart properties window
 * 
 * @author JOELwindows7
 */
class ChartProperties extends CoreSubState
{
    var tabOfIt = [
        {name:"This", label:"This chart"},
        {name:"Metadata", label:"Metadata"},
        {name:"Lyrics", label:"Lyrics"},
    ];
    var UI_properties:FlxUITabMenu;

    function buildUI()
    {
        UI_properties = new FlxUITabMenu(null, tabOfIt, null, false);
        installCallbacks();
    }

    function installCallbacks()
    {

    }

    override function create()
    {
        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}