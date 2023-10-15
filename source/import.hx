import Paths;
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
// JOELwindows7: also CoreState & CoreSubState
import CoreState;
// flixel
import flixel.FlxG;
import Debug;
// import core.*;
// import data.*;
import flixel.FlxG;
// JOELwindows7: Altronix manually import just all of them
// JOELwindows7: wait, do not manually import all!
// import utils.*;
// import animateatlas.*;
// import behavior.*;
// import experiments.*;
// import ndll.*;
// import plugins.*;
// import smTools.*;
import Paths;
import flixel.FlxSprite;
#end
// JOELwindows7: the threadening
import utils.Threading;
// JOELwindows7: Altronix uses YAML
// #if FEATURE_YAML
import yaml.Yaml;

// JOELwindows7: NEW haxiomic's console fancy print!!!
// import Console;
// #end
// JOELwindows7: everybody will eventually use StringTools, why not globalize that use then?
using StringTools;
// JOELwindows7: Altronix usings!!!
using hx.strings.Strings;
using utils.ConvertUtil;
// JOELwindows7: Actually, everything!
using hx.strings.Char;
using hx.strings.AnyAsString;
using hx.strings.CharIterator;
using hx.strings.Pattern;
using hx.strings.RandomStrings;
using hx.strings.RandomStrings;
using hx.strings.String8;
using hx.strings.StringBuilder;
