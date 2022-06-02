package;

typedef SwagSection =
{
	var startTime:Float;
	var endTime:Float;
	var sectionNotes:Array<Array<Dynamic>>;
	var ?betterSectionNotes:Array<NoteInSection>; // JOELwindows7: Hi! this is dictionary notes in section like above but better.
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var ?gfSection:Bool; // JOELwindows7: here when GF plays instead. note, must hit section keeps accounted for turn. e.g. if must hit & gf = gf allied, otherwise gf is mad, etc.
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
	var CPUAltAnim:Bool;
	var playerAltAnim:Bool;
}

class Section
{
	public var startTime:Float = 0;
	public var endTime:Float = 0;
	public var sectionNotes:Array<Array<Dynamic>> = [];
	public var betterSectionNotes:Array<NoteInSection> = []; // JOELwindows7: also joins here just in case
	public var changeBPM:Bool = false;
	public var bpm:Float = 0;

	public var lengthInSteps:Int = 16;
	public var typeOfSection:Int = 0;
	public var mustHitSection:Bool = true;
	public var gfSection:Bool = false; // JOELwindows7: here gf section.

	/**
	 *	Copies the first section into the second section!
	 */
	public static var COPYCAT:Int = 0;

	public function new(lengthInSteps:Int = 16)
	{
		this.lengthInSteps = lengthInSteps;
	}
}

// JOELwindows7: psst hey! also note in the section. YES!!! make it JSONed dictionary instead of Array<Dynamic> ugh confusing!

/**
 * Notes in the section
 * @author JOELwindows7
 */
typedef NoteInSection =
{
	// inspire this from how note info array works in charting state and more.
	var strumTime:Float;
	var noteData:Int;
	var sustainLength:Int;
	var isAlt:Bool;
	var beat:Float;
	var noteType:Int; // IDEA: make noteType string. becomes ID such as `default`, `powerUp`, `mine`, etc.
	var noteTypeId:String; // okay fine let's just do it now.
	var hitsoundPath:String;
	var ?vowelType:Int; // radpas1231's a i u e o vowel classification. this choses mouth type in the animation for lip-sync effect.
}
