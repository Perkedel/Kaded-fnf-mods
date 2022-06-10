import Paths;
// JOELwindows7: also CoreState & CoreSubState
import CoreState;
// JOELwindows7:yo, carry arounds!
import utils.CarryAround;
import const.Perkedel;
// JOELwindows7: also MasterEric enigma imports
#if macro
// Imports used only for macros.
// =====================
// COMMONLY USED MODULES
// =====================
// haxe.macro
import haxe.macro.Expr;
import haxe.macro.Context;
#else
// Imports used only outside macros.
// =====================
// COMMONLY USED MODULES
// =====================
// flixel
import flixel.FlxG;
import Debug;
#end
// JOELwindows7: the threadening
import utils.Threading;

// JOELwindows7: everybody will eventually use StringTools, why not globalize that use then?
using StringTools;
