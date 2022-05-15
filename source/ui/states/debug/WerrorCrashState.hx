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

package ui.states.debug;

#if crashdumper
import crashdumper.CrashDumper;
import crashdumper.SessionData;
#end

class WerrorCrashState extends CoreState
{
	#if crashdumper
	var crashDumper:CrashDumper;

	public function new(crashDumpering:CrashDumper)
	{
		this.crashDumper = crashDumpering;
		super();
	}

	override function create()
	{
		super.create();

		@:privateAccess {
			#if flash
			setSectionTitle('WERROR: ${crashDumper.theError}');
			#else
			setSectionTitle('WERROR: ${crashDumper.theError.error}');
			#end
		}
		setContentText('Oh No! WERROR!:\n${crashDumper.errorMessageStr()}');
	}
	#else
	public function new(crashDumpering:Dynamic)
	{
		super();
	}

	override function create()
	{
		super.create();
		setSectionTitle('Force Majeur');
		setContentText('Oh No! WERROR!:\n${'crash dumper unavailable. Did you disabled it in Project.xml?!'}');
	}
	#end

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		// TODO: button to restart & quit.
	}
}
