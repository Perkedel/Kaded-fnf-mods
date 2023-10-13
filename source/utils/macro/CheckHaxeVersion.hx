package utils.macro;

// JOELwindows7: https://github.com/Altronix-Team/FNF-AltronixEngine/blob/main/source/macros/CheckHaxeVersion.hx
class CheckHaxeVersion
{
    #if macro
	public static macro function checkHaxeVersion():haxe.macro.Expr.ExprOf<Int>
	{
		#if (haxe < "4.3.0")
		Context.fatalError("Your Haxe version is older than 4.3.0. Please install the latest version of Haxe!",
			Context.makePosition({min: 0, max: 0, file: "Last Funkin Moment"}));
		#end
		return macro $v{Context.definedValue("haxe_ver")};
	}
    #end
}
