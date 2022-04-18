import flixel.FlxG;
#if FEATURE_MODCORE
import polymod.backends.OpenFLBackend;
import polymod.backends.PolymodAssets.PolymodAssetType;
import polymod.format.ParseRules.LinesParseFormat;
import polymod.format.ParseRules.TextFileFormat;
import polymod.Polymod;
#end

/**
 * Okay now this is epic.
 * JOELwindows7: also steal stuff from the Enigma engine itself! lol!
 * https://github.com/EnigmaEngine/EnigmaEngine/blob/stable/source/funkin/behavior/mods/ModCore.hx
 */
class ModCore
{
	/**
	 * The current API version.
	 * Must be formatted in Semantic Versioning v2; <MAJOR>.<MINOR>.<PATCH>.
	 * 
	 * Remember to increment the major version if you make breaking changes to mods!
	 */
	static final API_VERSION = "0.1.0";

	static final MOD_DIRECTORY = "mods";

	public static function initialize() // JOELwindows7: enigma is loadAllMods()
	{
		#if FEATURE_MODCORE
		Debug.logInfo("Initializing ModCore...");
		loadModsById(getModIds());
		CarryAround.raiseModAlreadyLoaded();
		#else
		Debug.logInfo("ModCore not initialized; not supported on this platform.");
		#end
	}

	// JOELwindows7: enigma, here to load only some mods.
	public static function loadConfiguredMods()
	{
		#if FEATURE_MODCORE
		Debug.logInfo("Initializing ModCore (using user config)...");
		Debug.logTrace('  User mod config: ${FlxG.save.data.modConfig}');
		var userModConfig = getConfiguredMods();
		loadModsById(userModConfig);
		CarryAround.raiseModAlreadyLoaded();
		#else
		Debug.logInfo("ModCore not initialized; not supported on this platform.");
		#end

	}

	// JOELwindows7: here the more enigma.

	/**
	 * If the user has configured an order of mods to load, returns the list of mod IDs in order.
	 * Otherwise, returns a list of ALL installed mods in alphabetical order.
	 * @return The mod order to load.
	 */
	public static function getConfiguredMods():Array<String>
	{
		var rawSaveData = FlxG.save.data.modConfig;

		if (rawSaveData != null)
		{
			var modEntries = rawSaveData.split('~');
			return modEntries;
		}
		else
		{
			// Mod list not in save!
			return null;
		}
	}

	public static function saveModList(loadedMods:Array<String>)
	{
		Debug.logInfo('Saving mod configuration...');
		var rawSaveData = loadedMods.join('~');
		Debug.logTrace(rawSaveData);
		FlxG.save.data.modConfig = rawSaveData;
		var result = FlxG.save.flush();
		if (result)
			Debug.logInfo('Mod configuration saved successfully.');
		else
			Debug.logWarn('Failed to save mod configuration.');
	}

	#if FEATURE_MODCORE
	public static function loadModsById(ids:Array<String>)
	{
		Debug.logInfo('Attempting to load ${ids.length} mods...');
		var loadedModList = polymod.Polymod.init({
			// Root directory for all mods.
			modRoot: MOD_DIRECTORY,
			// The directories for one or more mods to load.
			dirs: ids,
			// Framework being used to load assets. We're using a CUSTOM one which extends the OpenFL one.
			framework: CUSTOM,
			// The current version of our API.
			apiVersion: API_VERSION,
			// Call this function any time an error occurs.
			errorCallback: onPolymodError,
			// Enforce semantic version patterns for each mod.
			// modVersions: null,
			// A map telling Polymod what the asset type is for unfamiliar file extensions.
			// extensionMap: [],

			frameworkParams: buildFrameworkParams(),

			// Use a custom backend so we can get a picture of what's going on,
			// or even override behavior ourselves.
			customBackend: ModCoreBackend,

			// List of filenames to ignore in mods. Use the default list to ignore the metadata file, etc.
			ignoredFiles: Polymod.getDefaultIgnoreList(),

			// Parsing rules for various data formats.
			parseRules: buildParseRules(),
		});

		Debug.logInfo('Mod loading complete. We loaded ${loadedModList.length} / ${ids.length} mods.');

		for (mod in loadedModList)
			Debug.logTrace('  * ${mod.title} v${mod.modVersion} [${mod.id}]');

		var fileList = Polymod.listModFiles("IMAGE");
		Debug.logInfo('Installed mods have replaced ${fileList.length} images.');
		for (item in fileList)
			Debug.logTrace('  * $item');

		fileList = Polymod.listModFiles("TEXT");
		Debug.logInfo('Installed mods have replaced ${fileList.length} text files.');
		for (item in fileList)
			Debug.logTrace('  * $item');

		fileList = Polymod.listModFiles("MUSIC");
		Debug.logInfo('Installed mods have replaced ${fileList.length} music files.');
		for (item in fileList)
			Debug.logTrace('  * $item');

		fileList = Polymod.listModFiles("SOUND");
		Debug.logInfo('Installed mods have replaced ${fileList.length} sound files.');
		for (item in fileList)
			Debug.logTrace('  * $item');

		// JOELwindows7: extra types too, video
		fileList = Polymod.listModFiles("VIDEO");
		Debug.logInfo('Installed mods have replaced ${fileList.length} videos.');
		for (item in fileList)
			Debug.logTrace('  * $item');

		// JOELwindows7: and fonts. maybe there's more
		fileList = Polymod.listModFiles("FONT");
		Debug.logInfo('Installed mods have replaced ${fileList.length} font files.');
		for (item in fileList)
			Debug.logTrace('  * $item');

		// JOELwindows7: okay unknown file types what do you want?!
		fileList = Polymod.listModFiles("UNKNOWN");
		Debug.logInfo('Installed mods have replaced ${fileList.length} unknown files.');
		for (item in fileList)
			Debug.logTrace('  * $item');
	}

	static function getModIds():Array<String>
	{
		Debug.logInfo('Scanning the mods folder...');
		var modMetadata = Polymod.scan(MOD_DIRECTORY);
		Debug.logInfo('Found ${modMetadata.length} mods when scanning.');
		var modIds = [for (i in modMetadata) i.id];
		return modIds;
	}

	// JOELwindows7: more yoinks too yey! enigma

	/**
	 * Returns true if there are mods to load in the mod folder,
	 * and false if there aren't (or mods aren't supported).
	 * @return A boolean value.
	 */
	public static function hasMods():Bool
	{
		#if FEATURE_MODCORE
		return getAllMods().length > 0;
		#else
		return false;
		#end
	}

	public static function getAllMods():Array<ModMetadata>
	{
		Debug.logInfo('Scanning the mods folder...');
		var modMetadata = Polymod.scan(MOD_DIRECTORY);
		Debug.logInfo('Found ${modMetadata.length} mods when scanning.');
		return modMetadata;
	}

	public static function getAllModIds():Array<String>
	{
		var modIds = [for (i in getAllMods()) i.id];
		return modIds;
	}

	static function buildParseRules():polymod.format.ParseRules
	{
		var output = polymod.format.ParseRules.getDefault();
		// Ensure TXT files have merge support.
		output.addType("txt", TextFileFormat.LINES);

		// JOELwindows7: pls help idk how to add lua & stuffs!!!
		output.addType("lua", TextFileFormat.PLAINTEXT);
		// output.addType("hx", TextFileFormat.PLAINTEXT);
		output.addType("hscript", TextFileFormat.PLAINTEXT); // Ohups! here enigma hscript too!!!

		// You can specify the format of a specific file, with file extension.
		// output.addFile("data/introText.txt", TextFileFormat.LINES)
		return output;
	}

	static inline function buildFrameworkParams():polymod.FrameworkParams
	{
		return {
			// JOELwindows7: wtf man,
			/*
				```
				...
					0:00.06 [INFO ] (ModCore/getModIds#95): Scanning the mods folder...
					0:00.08 [INFO ] (ModCore/getModIds#97): Found 1 mods when scanning.
					0:00.09 [INFO ] (ModCore/loadModsById#37): Attempting to load 1 mods...
					0:00.10 [WARN ] Could not find mod icon file: "mods/introMod/_polymod_icon.png"
					0:00.11 [INFO ]  user specified CUSTOM
					0:00.11 [TRACE] (ModCoreBackend/new#167): Initialized custom asset loader backend.
					0:00.12 [WARN ] (ModCoreBackend/clearCache#173): Custom asset cache has been cleared.
					0:00.13 [ERROR] Preparing to load mod mods/introMod
					0:00.14 [ERROR] Done loading mod mods/introMod
					0:00.15 [ERROR] Your Lime/OpenFL configuration is using custom asset libraries, and you provided frameworkParams in Polymod.init(), but we couldn't find a match for this asset library: (week7)
					PS C:\Users\joelr\Documents\starring codes\Haxe Projects\Kaded-fnf-mods> 
				```
			 */
			// JOELwindows7: Just what the peck?! also add Enigma yoinkeh stuffs
			assetLibraryPaths: [
				"default" => "./preload", // ./preload
				"sm" => "./sm",
				"songs" => "./songs",
				"shared" => "./",
				"tutorial" => "./tutorial",
				"scripts" => "./scripts",
				"week1" => "./week1",
				"week2" => "./week2",
				"week3" => "./week3",
				"week4" => "./week4",
				"week5" => "./week5",
				"week6" => "./week6",
				"week7" => "./week7",
				"week8" => "./week8",
				"week9" => "./week9",
				"week10" => "./week10",
				"week11" => "./week11",
				"week12" => "./week12",
				"week13" => "./week13",
				"week14" => "./week14",
				"week15" => "./week15",
				"weeks" => "./weeks",
				"thief" => "./thief",
				"videos" => "./videos",
				"preload_odysee" => "./preload_odysee",
				"preload_thief" => "./preload_thief",
				"fonts" => "./fonts",
				"bonusWeek" => "./bonusWeek",
				"week-1" => "./week-1",
				"exclude" => "./exclude",
				"week5720NG" => "./week5720NG",
			]
		}
	}

	static function onPolymodError(error:PolymodError):Void
	{
		// Perform an action based on the error code.
		switch (error.code)
		{
			// JOELwindows7: more werror messages! & Advanced readout
			case MOD_LOAD_PREPARE:
				Debug.logInfo('PREPARE when ${error.origin}: ${error.message}', null);
			case MOD_LOAD_DONE:
				Debug.logInfo('DONE when ${error.origin}: ${error.message}', null);
			// case MOD_LOAD_FAILED:
			case MISSING_ICON:
				Debug.logWarn('When ${error.origin}, a mod is missing an icon, will load anyways but please add one : ${error.message}', null);
			// case "parse_mod_version":
			// case "parse_api_version":
			// case "parse_mod_api_version":
			// case "missing_mod":
			// case "missing_meta":
			// case "missing_icon":
			// case "version_conflict_mod":
			// case "version_conflict_api":
			// case "version_prerelease_api":
			// case "param_mod_version":
			// case "framework_autodetect":
			// case "framework_init":
			// case "undefined_custom_backend":
			// case "failed_create_backend":
			// case "merge_error":
			// case "append_error":
			default:
				// Log the message based on its severity.
				switch (error.severity)
				{
					// JOELwindows7: advanced readout now yey
					case NOTICE:
						Debug.logInfo('NOTICE ${error.code} when ${error.origin}: ${error.message}', null);
					case WARNING:
						Debug.logWarn('WARNING ${error.code} when ${error.origin}: ${error.message}', null);
					case ERROR:
						Debug.logError('WERROR ${error.code} when ${error.origin}: ${error.message}', null);
				}
		}
	}
	#end
}

#if FEATURE_MODCORE
class ModCoreBackend extends OpenFLBackend
{
	public function new()
	{
		super();
		Debug.logTrace('Initialized custom asset loader backend.');
	}

	public override function clearCache()
	{
		super.clearCache();
		Debug.logWarn('Custom asset cache has been cleared.');
	}

	public override function exists(id:String):Bool
	{
		Debug.logTrace('Call to ModCoreBackend: exists($id)');
		return super.exists(id);
	}

	public override function getBytes(id:String):lime.utils.Bytes
	{
		Debug.logTrace('Call to ModCoreBackend: getBytes($id)');
		return super.getBytes(id);
	}

	public override function getText(id:String):String
	{
		Debug.logTrace('Call to ModCoreBackend: getText($id)');
		return super.getText(id);
	}

	public override function list(type:PolymodAssetType = null):Array<String>
	{
		Debug.logTrace('Listing assets in custom asset cache ($type).');
		return super.list(type);
	}
}
#end
