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

package utils;

#if FEATURE_MULTITHREADING
import sys.thread.Mutex;
#end

/**
 * Threading stuffs. Run functions in another threads instead of main thread.
 */
class Threading
{
	/**
	 * Create & run a function in other thread
	 * @param thisThing function to run in another thread (Only accepts no/optional argument & no return)
	 * @param withMutex whether to use included Mutual Execution
	 * @return -> Void, withMutex:Bool = false)
	 *
	 */
	public static function run(thisThing:() -> Void, withMutex:Bool = false)
	{
		#if FEATURE_MULTITHREADING
		if (withMutex)
		{
			var mutex:Mutex = new Mutex();
			sys.thread.Thread.create(function()
			{
				mutex.acquire();
				thisThing();
				mutex.release();
			});
		}
		else
		{
			// sys.thread.Thread.create(thisThing);
			sys.thread.Thread.create(function(){
				thisThing();
			});
		}
		#else
		thisThing();
		#end
	}
}
