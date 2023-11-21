/**
 * GNU General Public License, Version 3.0
 *
 * Copyright (c) 2021 Perkedel
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

package plugins.systems;

class ScanPlatform
{
	/**
	 * Read what platform are you at
	 * @author JOELwindows7
	 * @return String the total platform words in this scan
	 */
	public static function getPlatform():String
	{
		var sayTotal:String = "";

		#if debug
		trace("you're debug");
		sayTotal += " debug";
		#end
		#if release
		trace("you're relese");
		sayTotal += " release";
		#end
		#if final
		trace("you're final");
		sayTotal += " final";
		#end

		// architecture no number
		#if riscv
		trace("you're RISC-V");
		sayTotal += " riscv";
		#end
		#if ARM64
		trace("you're ARM64");
		sayTotal += " arm64";
		#end

		// base
		#if cpp
		trace("you're C++");
		sayTotal += " C++";
		#end
		#if cs
		trace("you're C#");
		sayTotal += " C#";
		#end
		#if sys
		trace("you're sys");
		sayTotal += " sys";
		#end
		#if nodejs
		trace("you're nodejs");
		sayTotal += " NodeJS";
		#end
		#if phantomjs
		trace("you're phantomjs");
		sayTotal += " PhantomJS";
		#end
		#if emscripten
		trace("you're emscripten");
		sayTotal += " emscripten";
		#end
		#if electron
		trace("you're electron");
		sayTotal += " ElectronJS";
		#end
		#if php
		trace("you're php");
		sayTotal += " PHP";
		#end
		#if flash
		trace("you're SWF");
		sayTotal += " Flash";
		#end
		#if air
		trace("you're air");
		sayTotal += " Air";
		#end
		#if mobile
		trace("you're mobile");
		sayTotal += " mobile";
		#end

		// OS
		#if windows
		trace("you're windows");
		sayTotal += " Windows";
		#end
		#if linux
		trace("you're linux");
		sayTotal += " Linux";
		#end
		#if mac
		trace("you're mac");
		sayTotal += " macOS";
		#end
		#if android
		trace("you're android");
		sayTotal += " Android";
		#end
		#if ios
		trace("you're ios");
		sayTotal += " iOS";
		#end
		#if java
		trace("you're java");
		sayTotal += " Java";
		#end
		#if lua
		trace("you're lua");
		sayTotal += " Lua";
		#end
		#if python
		trace("you're python");
		sayTotal += " Python";
		#end
		#if html5
		trace("you're html5");
		sayTotal += " HTML5";
		#end
		#if neko
		trace("you're neko nyaw");
		sayTotal += " Neko";
		#end
		#if hl
		trace("you're hash link");
		sayTotal += " HashLink";
		#end

		// JOELwindows7: Additionally there maybe more
		#if firefox
		trace("you're firefox OS, no pecking way!");
		sayTotal += " FirefoxOS";
		#end
		#if chrome
		trace("you're chrome OS, no pecking way!");
		sayTotal += " ChromeOS";
		#end
		#if opera
		trace("you're opera OS, no pecking way!");
		sayTotal += " OperaOS";
		#end
		#if ie
		trace("you're internet explorer, wow you're, idk!");
		sayTotal += " IE";
		#end
		#if edge
		trace("you're edge, uhhh ok!");
		sayTotal += " Edge";
		#end
		#if safari
		trace("you're safari, Let us know when can we repair this!");
		sayTotal += " Safari";
		#end
		#if tvos
		trace("you're tvos, no pecking way!");
		sayTotal += " tvOS";
		#end
		#if amiga
		trace("you're Amiga, no pecking way!");
		sayTotal += " Amiga";
		#end

		trace("In total, you're: " + sayTotal);
		return sayTotal;
	}
}
