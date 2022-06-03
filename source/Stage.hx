package;

import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import tjson.TJSON;
import haxe.Json;
import PlayState;
import flixel.FlxCamera;
import flixel.util.typeLimit.OneOfTwo;
import flixel.util.typeLimit.OneOfFour;
import flixel.addons.effects.FlxTrail;
import StagechartState;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.addons.effects.chainable.FlxWaveEffect;
// JOELwindows7: use ki's filesystemer?
// import filesystem.File;
// Adds candy I/O (read/write/append) extension methods onto File
// using filesystem.FileTools;
// JOELwindows7: okay how about vegardit's filesystemer?
import hx.files.*;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import DokiDoki;

using StringTools;

class Stage extends MusicBeatState
{
	public var curStage:String = '';
	public var camZoom:Float; // The zoom of the camera to have at the start of the game
	public var hideLastBG:Bool = false; // True = hide last BGs and show ones from slowBacks on certain step, False = Toggle visibility of BGs from SlowBacks on certain step
	// Use visible property to manage if BG would be visible or not at the start of the game
	public var tweenDuration:Float = 2; // How long will it tween hiding/showing BGs, variable above must be set to True for tween to activate
	public var toAdd:Array<Dynamic> = []; // Add BGs on stage startup, load BG in by using "toAdd.push(bgVar);"
	// Layering algorithm for noobs: Everything loads by the method of "On Top", example: You load wall first(Every other added BG layers on it), then you load road(comes on top of wall and doesn't clip through it), then loading street lights(comes on top of wall and road)
	public var swagBacks:Map<String,
		Dynamic> = []; // Store BGs here to use them later (for example with slowBacks, using your custom stage event or to adjust position in stage debug menu(press 8 while in PlayState with debug build of the game))
	// JOELwindows7: why the peck Dynamic? you obviously know it's gonna be FlxSprite. Peck, because it errors for special function found in child class based on FlxSprite even.
	public var swagGroup:Map<String, FlxTypedGroup<Dynamic>> = []; // Store Groups
	// public var swagGroup:Map<String, FlxTypedGroup<OneOfFour<Character,BackgroundDancer,BackgroundGirls,OneOfTwo<FlxSprite,Dynamic>>>> = []; // Store Groups //JOELwindows7: ultimate attempt
	// JOELwindows7: that too, why Dynamic?! Everyone would fill those with FlxSprite exclusively.
	public var animatedBacks:Array<FlxSprite> = []; // Store animated backgrounds and make them play animation(Animation must be named Idle!! Else use swagGroup/swagBacks and script it in stepHit/beatHit function of this file!!)
	public var layInFront:Array<Array<FlxSprite>> = [[], [], []]; // BG layering, format: first [0] - in front of GF, second [1] - in front of opponent, third [2] - in front of boyfriend(and technically also opponent since Haxe layering moment)
	public var slowBacks:Map<Int,
		Array<FlxSprite>> = []; // Change/add/remove backgrounds mid song! Format: "slowBacks[StepToBeActivated] = [Sprites,To,Be,Changed,Or,Added];"

	public var swagColors:Map<String, FlxColor> = []; // JOELwindows7: store color for which bg name

	// JOELwindows7: global backgrounder. to prioritize add() in order after all variable has been filled with instances
	var bgAll:FlxTypedGroup<FlxSprite>;
	var stageFrontAll:FlxTypedGroup<FlxSprite>;
	var stageCurtainAll:FlxTypedGroup<FlxSprite>;
	var trailAll:FlxTypedGroup<FlxTrail>;

	// JOELwindows7: okeh globalize those special bg var thingy anyways.
	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyCityLightsEvent:FlxTypedGroup<BGSprite>; // JOELwindows7: psyched stuffening
	var phillyCityLightsEventTween:FlxTween; // JOELwindows7: psyched stuffening

	public var executeStageScript = false; // JOELwindows7: for stage lua scripter
	public var executeStageHscript = false;

	public var colorableGround:FlxSprite; // JOELwindows7: the colorable sprite thingy
	public var originalColor:FlxColor = FlxColor.WHITE; // JOELwindows7: store the original color for chroma screen and RGB lightings
	public var isChromaScreen:Bool = false; // JOELwindows7: whether this is a Chroma screen or just RGB lightings.

	public var blammedLightsBlack:FlxSprite; // JOELwindows7: black screen for blammed lights Psyched
	public var blammedLightsBlackTween:FlxTween; // JOELwindows7: and the tween for it.
	public var sha:FlxSprite; // JOELwindows7: shader image sprite for the kem0x Nexus Engine stuff

	// if chroma screen, then don't invisiblize, instead turn it back to original color!
	// JOELwindows7: arraying them seems won't work at all. so let's make them separateroid instead.
	public var multicolorableGround:FlxTypedGroup<FlxSprite>; // JOELwindows7: the colorable sprite thingy
	public var multiOriginalColor:Array<FlxColor> = [FlxColor.WHITE]; // JOELwindows7: store the original color for chroma screen and RGB lightings
	public var multiIsChromaScreen:Array<Bool> = [false]; // JOELwindows7: whether this is a Chroma screen or just RGB lightings.
	public var multiColorable:Array<Bool> = [false];

	// JOELwindows7: flag to let stage or whatever override camFollow position
	public var overrideCamFollowP1:Bool = false;
	public var overrideCamFollowP2:Bool = false;
	public var manualCamFollowPosP1:Array<Float> = [0, 0];
	public var manualCamFollowPosP2:Array<Float> = [0, 0];

	// JOELwindows7: other flags toggle switch too
	public var blammedLightGoing:Bool = false;

	// BGs still must be added by using toAdd Array for them to show in game after slowBacks take effect!!
	// BGs still must be added by using toAdd Array for them to show in game after slowBacks take effect!!
	// All of the above must be set or used in your stage case code block!!
	// JOELwindows7: wtf, where's default position????!!!
	// why do I have to do this every character????
	// JOELwindows7: add to here pls. here NULL-bf, NULL-gf, NULL-dad for default fallbacks
	// OI!! Float pls!!
	public var positions:Map<String, Map<String, Array<Float>>> = [
		// Assign your characters positions on stage here!
		'halloween' => ['spooky' => [100, 300], 'monster' => [100, 200], 'NULL-dad' => [100, 300]],
		'philly' => ['pico' => [100, 400], 'NULL-dad' => [100, 400]],
		'limo' => ['bf-car' => [1030, 230], 'NULL-bf' => [1030, 230]],
		'mall' => [
			'bf-christmas' => [970, 450],
			'parents-christmas' => [-400, 100],
			'NULL-bf' => [970, 450],
			'NULL-dad' => [-400, 100]
		],
		'mallEvil' => [
			'bf-christmas' => [1090, 450],
			'monster-christmas' => [100, 150],
			'NULL-bf' => [1090, 450],
			'NULL-dad' => [100, 150]
		],
		'school' => [
			'gf-pixel' => [580, 430],
			'bf-pixel' => [970, 670],
			'senpai' => [250, 460],
			'senpai-angry' => [250, 460],
			'NULL-bf' => [970, 670],
			'NULL-gf' => [580, 430],
			'NULL-dad' => [250, 460],
		],
		'schoolEvil' => [
			'gf-pixel' => [580, 430],
			'bf-pixel' => [970, 670],
			'spirit' => [-50, 200],
			'NULL-bf' => [970, 670],
			'NULL-gf' => [580, 430],
			'NULL-dad' => [-50, 200]
		],
		'tankStage' => [
			// JOELwindows7: the week 7 interpreto.
			'bf' => [810, 450],
			'gf-tankman' => [200, 75],
			'tankman' => [20, 380],
			'NULL-bf' => [810, 450],
			'NULL-gf' => [200, 75],
			'NULL-dad' => [20, 380],
		],
		'tankStage2' => [
			// JOELwindows7: the week 7 interpreto.
			'bf-holding-gf' => [810, 450],
			'picoSpeaker' => [310, -25],
			'tankman' => [20, 380],
			'NULL-bf' => [810, 450],
			'NULL-gf' => [310, -25],
			'NULL-dad' => [20, 380],
		],
		'theShift' => [
			// JOELwindows7: sky bbpanzu
			// no, I swear, he directly set it to exact position!
			'bf' => [828.75, 265.65],
			'gf' => [359.7, -37.95],
			'gf-crucified' => [359.7, -37.95],
			'sky' => [30.15, 37.95],
			'sky-annoyed' => [30.15, 37.95],
			'NULL-bf' => [828.75, 265.65],
			'NULL-gf' => [359.7, -37.95],
			'NULL-dad' => [30.15, 37.95]
		],
		'theShift2' => [
			// JOELwindows7: sky bbpanzu
			// no, I swear, he directly set it to exact position!
			'bf' => [828.75, 265.65],
			'gf' => [359.7, -37.95],
			'gf-crucified' => [479.3, -56.1],
			'sky' => [30.15, 37.95],
			'sky-annoyed' => [30.15, 37.95],
			'NULL-bf' => [828.75, 265.65],
			'NULL-gf' => [359.7, -37.95],
			'NULL-dad' => [30.15, 37.95]
		],
		'theManifest' => [
			// JOELwindows7: sky bbpanzu
			// no, I swear, he directly set it to exact position!
			'bf' => [828.75, 265.65],
			'gf' => [359.7, -37.95],
			'gf-crucified' => [479.3, -56.1],
			'sky' => [119.3, 93.9],
			'sky-annoyed' => [119.3, 93.9],
			'sky-mad' => [119.3, 93.9],
			'NULL-bf' => [828.75, 265.65],
			'NULL-gf' => [479.3, -56.1],
			'NULL-dad' => [119.3, 93.9]
		],
		'pizza' => [
			// JOELwindows7: copilot lol!
			'bf-pizza' => [1030, 230],
			'NULL-bf' => [1030, 230]
		],
		'jakartaFair' => [
			'hookx' => [-95, 100],
			'gf-ht' => [290, 80],
			'bf' => [1020, 450],
			'bf-covid' => [1020, 450],
			'NULL-bf' => [1020, 450],
			'NULL-gf' => [290, 80],
			'NULL-dad' => [-95, 100]
		],
		'qmoveph' => [
			'hookx' => [0, 100],
			'gf-ht' => [-10, 0],
			'bf' => [1070, 450],
			'bf-covid' => [1070, 450],
			'NULL-bf' => [1070, 450],
			'NULL-gf' => [400, 130],
			'NULL-dad' => [0, 100]
		],
		'cruelThesis' => ['NULL-bf' => [1070, 500], 'NULL-gf' => [400, 130], 'NULL-dad' => [-100, 150]],
		'lapanganParalax' => ['NULL-bf' => [970, 450], 'NULL-gf' => [400, 130], 'NULL-dad' => [0, 100]],
		'blank' => ['NULL-bf' => [1270, 450], 'NULL-gf' => [400, 30], 'NULL-dad' => [100, 100]],
		'greenscreen' => ['NULL-bf' => [1270, 450], 'NULL-gf' => [400, 30], 'NULL-dad' => [100, 100]],
		'bluechroma' => ['NULL-bf' => [1270, 450], 'NULL-gf' => [400, 30], 'NULL-dad' => [100, 100]],
		'semple' => ['NULL-bf' => [1270, 450], 'NULL-gf' => [400, 30], 'NULL-dad' => [100, 100]],
		'whitening' => ['NULL-bf' => [1270, 450], 'NULL-gf' => [400, 30], 'NULL-dad' => [100, 100]],
		'kuning' => ['NULL-bf' => [1270, 450], 'NULL-gf' => [400, 30], 'NULL-dad' => [100, 100]],
		'blood' => ['NULL-bf' => [1270, 450], 'NULL-gf' => [400, 30], 'NULL-dad' => [100, 100]],
		'NULL' => ['NULL-bf' => [770, 450], 'NULL-gf' => [400, 130], 'NULL-dad' => [100, 100]] // JOELwindows7: default fallback, don't change!
	];

	// JOELwindows7: moar yoink from luckydog7 with the week7 yoink
	public var tankWatchtower:FlxSprite;
	public var tankRolling:FlxSprite;
	public var tankmanRun:FlxTypedGroup<TankmenBG>;
	// tankbop shit
	public var tankBop1:FlxSprite;
	public var tankBop2:FlxSprite;
	public var tankBop3:FlxSprite;
	public var tankBop4:FlxSprite;
	public var tankBop5:FlxSprite;
	public var tankBop6:FlxSprite;

	// end of tankbop
	public var picoStep:Ps;
	public var tankStep:Ts;

	// JOELwindows7: sky bbpanzu
	public var shiftbg:FlxSprite;
	public var floor:FlxSprite;

	// end of sky bbpanzu

	public function addThe(object:Dynamic, mapName:String, layFront:Bool = false, whichLayerFront:Int = 0)
	{
		swagBacks[mapName] = object;
		if (layFront)
			layInFront[whichLayerFront].push(object)
		else
			toAdd.push(object);
	}

	public function new(daStage:String)
	{
		// JOELwindows7: add BgAll here boys
		swagGroup['bgAll'] = new FlxTypedGroup<FlxSprite>();

		super();
		this.curStage = daStage;
		camZoom = 1.05; // Don't change zoom here, unless you want to change zoom of every stage that doesn't have custom one
		if (PlayStateChangeables.Optimize)
			return;

		trace("Load da stage here ya"); // JOELwindows7: wtf happened

		// JOELwindows7: init blammed light first
		blammedLightsBlack = new FlxSprite(FlxG.width * -0.5, FlxG.height * -0.5);
		blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		blammedLightsBlack.alpha = 0;
		phillyCityLights = new FlxTypedGroup<FlxSprite>();
		phillyCityLightsEvent = new FlxTypedGroup<BGSprite>();

		if (PlayState.SONG != null && PlayState.SONG.useCustomStage)
		{
			// JOELwindows7: Here's the switchover!
			initDaCustomStage(PlayState.SONG.stage);
		}
		else
			switch (daStage)
			{
				case 'halloween':
					{
						var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

						var halloweenBG = new FlxSprite(-200, -80);
						halloweenBG.frames = hallowTex;
						halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
						halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
						halloweenBG.animation.play('idle');
						halloweenBG.antialiasing = FlxG.save.data.antialiasing;
						swagBacks['halloweenBG'] = halloweenBG;
						toAdd.push(halloweenBG);
					}
				case 'philly':
					{
						var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.loadImage('philly/sky', 'week3'));
						bg.scrollFactor.set(0.1, 0.1);
						bg.antialiasing = FlxG.save.data.antialiasing;
						swagBacks['bg'] = bg;
						toAdd.push(bg);

						var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.loadImage('philly/city', 'week3'));
						city.scrollFactor.set(0.3, 0.3);
						city.setGraphicSize(Std.int(city.width * 0.85));
						city.updateHitbox();
						city.antialiasing = FlxG.save.data.antialiasing;
						swagBacks['city'] = city;
						toAdd.push(city);

						phillyCityLights = new FlxTypedGroup<FlxSprite>();
						// phillyCityLights = new FlxTypedGroup<BGSprite>(); // JOELwindows7: okeh idk man.
						if (FlxG.save.data.distractions)
						{
							swagGroup['phillyCityLights'] = phillyCityLights;
							toAdd.push(phillyCityLights);
						}

						for (i in 0...5)
						{
							var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.loadImage('philly/win' + i, 'week3'));
							// var light:BGSprite = new BGSprite(city.x).loadGraphic(Paths.loadImage('philly/win' + i, 'week3'));
							light.scrollFactor.set(0.3, 0.3);
							light.visible = false;
							light.setGraphicSize(Std.int(light.width * 0.85));
							light.updateHitbox();
							light.antialiasing = FlxG.save.data.antialiasing;
							phillyCityLights.add(light);
						}

						var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.loadImage('philly/behindTrain', 'week3'));
						streetBehind.antialiasing = FlxG.save.data.antialiasing;
						swagBacks['streetBehind'] = streetBehind;
						toAdd.push(streetBehind);

						var phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.loadImage('philly/train', 'week3'));
						phillyTrain.antialiasing = FlxG.save.data.antialiasing;
						if (FlxG.save.data.distractions)
						{
							swagBacks['phillyTrain'] = phillyTrain;
							toAdd.push(phillyTrain);
						}

						// JOELwindows7: buddy, you forgot to put the train sound in week3 special folder
						// No wonder the train cannot come. it missing that sound.
						// remember, the trains position depends on the sound playback position!
						trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'shared'));
						FlxG.sound.list.add(trainSound);
						// there, I've copied the train_passes ogg & mp3 into the week3/sounds .
						// yay it works.
						// Oh. Kade moved it somehow.

						// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

						// JOELwindows7: first, install blammed lights. Psyched blammed lights yey
						// https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/PlayState.hx
						// addThe(blammedLightsBlack, 'blammedLightsBlack');

						var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.loadImage('philly/street', 'week3'));
						street.antialiasing = FlxG.save.data.antialiasing;
						swagBacks['street'] = street;
						toAdd.push(street);
					}
				case 'limo':
					{
						camZoom = 0.90;

						var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.loadImage('limo/limoSunset', 'week4'));
						skyBG.scrollFactor.set(0.1, 0.1);
						skyBG.antialiasing = FlxG.save.data.antialiasing;
						swagBacks['skyBG'] = skyBG;
						toAdd.push(skyBG);

						var bgLimo:FlxSprite = new FlxSprite(-200, 480);
						bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo', 'week4');
						bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
						bgLimo.animation.play('drive');
						bgLimo.scrollFactor.set(0.4, 0.4);
						bgLimo.antialiasing = FlxG.save.data.antialiasing;
						swagBacks['bgLimo'] = bgLimo;
						toAdd.push(bgLimo);

						var fastCar:FlxSprite;
						fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.loadImage('limo/fastCarLol', 'week4'));
						fastCar.antialiasing = FlxG.save.data.antialiasing;
						fastCar.visible = false;

						if (FlxG.save.data.distractions)
						{
							var grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
							swagGroup['grpLimoDancers'] = grpLimoDancers;
							toAdd.push(grpLimoDancers);

							for (i in 0...5)
							{
								var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
								dancer.scrollFactor.set(0.4, 0.4);
								grpLimoDancers.add(dancer);
								swagBacks['dancer' + i] = dancer;
							}

							swagBacks['fastCar'] = fastCar;
							layInFront[2].push(fastCar);
							resetFastCar();
						}

						var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.loadImage('limo/limoOverlay', 'week4'));
						overlayShit.alpha = 0.5;
						// add(overlayShit);

						// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

						// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

						// overlayShit.shader = shaderBullshit;

						var limoTex = Paths.getSparrowAtlas('limo/limoDrive', 'week4');

						var limo = new FlxSprite(-120, 550);
						limo.frames = limoTex;
						limo.animation.addByPrefix('drive', "Limo stage", 24);
						limo.animation.play('drive');
						limo.antialiasing = FlxG.save.data.antialiasing;
						layInFront[0].push(limo);
						swagBacks['limo'] = limo;
					}
				case 'mall':
					{
						camZoom = 0.80;

						var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.loadImage('christmas/bgWalls', 'week5'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(0.2, 0.2);
						bg.active = false;
						bg.setGraphicSize(Std.int(bg.width * 0.8));
						bg.updateHitbox();
						swagBacks['bg'] = bg;
						toAdd.push(bg);

						var upperBoppers = new FlxSprite(-240, -90);
						upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
						upperBoppers.animation.addByPrefix('idle', "Upper Crowd Bob", 24, false);
						upperBoppers.antialiasing = FlxG.save.data.antialiasing;
						upperBoppers.scrollFactor.set(0.33, 0.33);
						upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
						upperBoppers.updateHitbox();
						if (FlxG.save.data.distractions)
						{
							swagBacks['upperBoppers'] = upperBoppers;
							toAdd.push(upperBoppers);
							animatedBacks.push(upperBoppers);
						}

						var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.loadImage('christmas/bgEscalator', 'week5'));
						bgEscalator.antialiasing = FlxG.save.data.antialiasing;
						bgEscalator.scrollFactor.set(0.3, 0.3);
						bgEscalator.active = false;
						bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
						bgEscalator.updateHitbox();
						swagBacks['bgEscalator'] = bgEscalator;
						toAdd.push(bgEscalator);

						var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.loadImage('christmas/christmasTree', 'week5'));
						tree.antialiasing = FlxG.save.data.antialiasing;
						tree.scrollFactor.set(0.40, 0.40);
						swagBacks['tree'] = tree;
						toAdd.push(tree);

						var bottomBoppers = new FlxSprite(-300, 140);
						bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
						bottomBoppers.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
						bottomBoppers.antialiasing = FlxG.save.data.antialiasing;
						bottomBoppers.scrollFactor.set(0.9, 0.9);
						bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
						bottomBoppers.updateHitbox();
						if (FlxG.save.data.distractions)
						{
							swagBacks['bottomBoppers'] = bottomBoppers;
							toAdd.push(bottomBoppers);
							animatedBacks.push(bottomBoppers);
						}

						var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.loadImage('christmas/fgSnow', 'week5'));
						fgSnow.active = false;
						fgSnow.antialiasing = FlxG.save.data.antialiasing;
						swagBacks['fgSnow'] = fgSnow;
						toAdd.push(fgSnow);

						var santa = new FlxSprite(-840, 150);
						santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
						santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
						santa.antialiasing = FlxG.save.data.antialiasing;
						if (FlxG.save.data.distractions)
						{
							swagBacks['santa'] = santa;
							toAdd.push(santa);
							animatedBacks.push(santa);
						}
					}
				case 'mallEvil':
					{
						var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.loadImage('christmas/evilBG', 'week5'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(0.2, 0.2);
						bg.active = false;
						bg.setGraphicSize(Std.int(bg.width * 0.8));
						bg.updateHitbox();
						swagBacks['bg'] = bg;
						toAdd.push(bg);

						var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.loadImage('christmas/evilTree', 'week5'));
						evilTree.antialiasing = FlxG.save.data.antialiasing;
						evilTree.scrollFactor.set(0.2, 0.2);
						swagBacks['evilTree'] = evilTree;
						toAdd.push(evilTree);

						var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.loadImage("christmas/evilSnow", 'week5'));
						evilSnow.antialiasing = FlxG.save.data.antialiasing;
						swagBacks['evilSnow'] = evilSnow;
						toAdd.push(evilSnow);
					}
				case 'school':
					{
						// defaultCamZoom = 0.9;

						var bgSky = new FlxSprite().loadGraphic(Paths.loadImage('weeb/weebSky', 'week6'));
						bgSky.scrollFactor.set(0.1, 0.1);
						swagBacks['bgSky'] = bgSky;
						toAdd.push(bgSky);

						var repositionShit = -200;

						var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.loadImage('weeb/weebSchool', 'week6'));
						bgSchool.scrollFactor.set(0.6, 0.90);
						swagBacks['bgSchool'] = bgSchool;
						toAdd.push(bgSchool);

						var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.loadImage('weeb/weebStreet', 'week6'));
						bgStreet.scrollFactor.set(0.95, 0.95);
						swagBacks['bgStreet'] = bgStreet;
						toAdd.push(bgStreet);

						var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.loadImage('weeb/weebTreesBack', 'week6'));
						fgTrees.scrollFactor.set(0.9, 0.9);
						swagBacks['fgTrees'] = fgTrees;
						toAdd.push(fgTrees);

						var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
						var treetex = Paths.getPackerAtlas('weeb/weebTrees', 'week6');
						bgTrees.frames = treetex;
						bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
						bgTrees.animation.play('treeLoop');
						bgTrees.scrollFactor.set(0.85, 0.85);
						swagBacks['bgTrees'] = bgTrees;
						toAdd.push(bgTrees);

						var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
						treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals', 'week6');
						treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
						treeLeaves.animation.play('leaves');
						treeLeaves.scrollFactor.set(0.85, 0.85);
						swagBacks['treeLeaves'] = treeLeaves;
						toAdd.push(treeLeaves);

						var widShit = Std.int(bgSky.width * 6);

						bgSky.setGraphicSize(widShit);
						bgSchool.setGraphicSize(widShit);
						bgStreet.setGraphicSize(widShit);
						bgTrees.setGraphicSize(Std.int(widShit * 1.4));
						fgTrees.setGraphicSize(Std.int(widShit * 0.8));
						treeLeaves.setGraphicSize(widShit);

						fgTrees.updateHitbox();
						bgSky.updateHitbox();
						bgSchool.updateHitbox();
						bgStreet.updateHitbox();
						bgTrees.updateHitbox();
						treeLeaves.updateHitbox();

						var bgGirls = new BackgroundGirls(-100, 190);
						bgGirls.scrollFactor.set(0.9, 0.9);

						// JOELwindows7: zo not forogot
						// if (PlayState.SONG.songId.toLowerCase() == 'roses')
						if (GameplayCustomizeState.freeplaySong == 'roses' || GameplayCustomizeState.freeplaySong == 'roses-midi')
						{
							if (FlxG.save.data.distractions)
								bgGirls.getScared();
						}

						bgGirls.setGraphicSize(Std.int(bgGirls.width * CoolUtil.daPixelZoom));
						bgGirls.updateHitbox();
						if (FlxG.save.data.distractions)
						{
							swagBacks['bgGirls'] = bgGirls;
							toAdd.push(bgGirls);
						}
					}
				case 'schoolEvil':
					{
						var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
						var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

						var posX = 400;
						var posY = 200;

						var bg:FlxSprite = new FlxSprite(posX, posY);
						bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool', 'week6');
						bg.animation.addByPrefix('idle', 'background 2', 24);
						bg.animation.play('idle');
						bg.scrollFactor.set(0.8, 0.9);
						bg.scale.set(6, 6);
						swagBacks['bg'] = bg;
						toAdd.push(bg);

						/* 
							var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.loadImage('weeb/evilSchoolBG'));
							bg.scale.set(6, 6);
							// bg.setGraphicSize(Std.int(bg.width * 6));
							// bg.updateHitbox();
							add(bg);
							var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(Paths.loadImage('weeb/evilSchoolFG'));
							fg.scale.set(6, 6);
							// fg.setGraphicSize(Std.int(fg.width * 6));
							// fg.updateHitbox();
							add(fg);
							wiggleShit.effectType = WiggleEffectType.DREAMY;
							wiggleShit.waveAmplitude = 0.01;
							wiggleShit.waveFrequency = 60;
							wiggleShit.waveSpeed = 0.8;
						 */

						// bg.shader = wiggleShit.shader;
						// fg.shader = wiggleShit.shader;

						/* 
							var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
							var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);
							// Using scale since setGraphicSize() doesnt work???
							waveSprite.scale.set(6, 6);
							waveSpriteFG.scale.set(6, 6);
							waveSprite.setPosition(posX, posY);
							waveSpriteFG.setPosition(posX, posY);
							waveSprite.scrollFactor.set(0.7, 0.8);
							waveSpriteFG.scrollFactor.set(0.9, 0.8);
							// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
							// waveSprite.updateHitbox();
							// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
							// waveSpriteFG.updateHitbox();
							add(waveSprite);
							add(waveSpriteFG);
						 */
					}
				// JOELwindows7: Finally, week 7 yoinkeh. big shout out also to luckydog7 for the help with the Android port yeah!
				case 'tankStage':
					{
						curStage = 'tankStage';
						camZoom = 0.9;
						var sky:FlxSprite = new FlxSprite(-400, -400).loadGraphic(Paths.image('tankSky'));
						sky.scrollFactor.set(0, 0);
						sky.antialiasing = true;
						sky.setGraphicSize(Std.int(sky.width * 1.5));
						// add(sky);
						addThe(sky, 'sky');

						var clouds:FlxSprite = new FlxSprite(FlxG.random.int(-700, -100), FlxG.random.int(-20, 20)).loadGraphic(Paths.image('tankClouds'));
						clouds.scrollFactor.set(0.1, 0.1);
						clouds.velocity.x = FlxG.random.float(5, 15);
						clouds.antialiasing = true;
						clouds.updateHitbox();
						// add(clouds);
						addThe(clouds, 'clouds');

						var mountains:FlxSprite = new FlxSprite(-300, -20).loadGraphic(Paths.image('tankMountains'));
						mountains.scrollFactor.set(0.2, 0.2);
						mountains.setGraphicSize(Std.int(1.2 * mountains.width));
						mountains.updateHitbox();
						mountains.antialiasing = true;
						// add(mountains);
						addThe(mountains, 'mountains');

						var buildings:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('tankBuildings'));
						buildings.scrollFactor.set(0.3, 0.3);
						buildings.setGraphicSize(Std.int(buildings.width * 1.1));
						buildings.updateHitbox();
						buildings.antialiasing = true;
						// add(buildings);
						addThe(buildings, 'buildings');

						var ruins:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('tankRuins'));
						ruins.scrollFactor.set(0.35, 0.35);
						ruins.setGraphicSize(Std.int(ruins.width * 1.1));
						ruins.updateHitbox();
						ruins.antialiasing = true;
						// add(ruins);
						addThe(ruins, 'ruins');

						var smokeLeft:FlxSprite = new FlxSprite(-200, -100);
						smokeLeft.frames = Paths.getSparrowAtlas('smokeLeft');
						smokeLeft.animation.addByPrefix('idle', 'SmokeBlurLeft ', 24, true);
						smokeLeft.scrollFactor.set(0.4, 0.4);
						smokeLeft.antialiasing = true;
						smokeLeft.animation.play('idle');

						// add(smokeLeft);
						addThe(smokeLeft, 'smokeLeft');

						var smokeRight:FlxSprite = new FlxSprite(1100, -100);
						smokeRight.frames = Paths.getSparrowAtlas('smokeRight');
						smokeRight.animation.addByPrefix('idle', 'SmokeRight ', 24, true);
						smokeRight.scrollFactor.set(0.4, 0.4);
						smokeRight.antialiasing = true;
						smokeRight.animation.play('idle');

						// add(smokeRight);
						addThe(smokeRight, 'smokeRight');

						var tankWatchtower:FlxSprite = new FlxSprite(100, 120);
						tankWatchtower.frames = Paths.getSparrowAtlas('tankWatchtower');
						tankWatchtower.animation.addByPrefix('bop', 'watchtower gradient color instance 1', 24, true);
						tankWatchtower.scrollFactor.set(0.5, 0.5);
						tankWatchtower.antialiasing = true;

						// add(tankWatchtower);
						addThe(tankWatchtower, 'tankWatchtower');

						tankRolling = new FlxSprite(300, 300);
						tankRolling.frames = Paths.getSparrowAtlas('tankRolling');
						tankRolling.animation.addByPrefix('idle', 'BG tank w lighting ', 24, true);
						tankRolling.scrollFactor.set(0.5, 0.5);
						tankRolling.antialiasing = true;
						tankRolling.animation.play('idle');
						// add(tankRolling);
						addThe(tankRolling, 'tankRolling');

						var ground:FlxSprite = new FlxSprite(-420, -150).loadGraphic(Paths.image('tankGround'));
						ground.scrollFactor.set();
						ground.antialiasing = true;
						ground.setGraphicSize(Std.int(ground.width * 1.15));
						ground.scrollFactor.set(1, 1);

						ground.updateHitbox();
						// add(ground);
						addThe(ground, 'ground');

						tankBop1 = new FlxSprite(-500, 650);
						tankBop1.frames = Paths.getSparrowAtlas('tank0');
						tankBop1.animation.addByPrefix('bop', 'fg tankhead far right instance 1', 24);
						tankBop1.scrollFactor.set(1.7, 1.5);
						tankBop1.antialiasing = true;

						tankBop2 = new FlxSprite(-300, 750);
						tankBop2.frames = Paths.getSparrowAtlas('tank1');
						tankBop2.animation.addByPrefix('bop', 'fg tankhead 5 instance 1', 24);
						tankBop2.scrollFactor.set(2.0, 0.2);
						tankBop2.antialiasing = true;

						tankBop3 = new FlxSprite(450, 940);
						tankBop3.frames = Paths.getSparrowAtlas('tank2');
						tankBop3.animation.addByPrefix('bop', 'foreground man 3 instance 1', 24);
						tankBop3.scrollFactor.set(1.5, 1.5);
						tankBop3.antialiasing = true;

						tankBop4 = new FlxSprite(1300, 1200);
						tankBop4.frames = Paths.getSparrowAtlas('tank3');
						tankBop4.animation.addByPrefix('bop', 'fg tankhead 4 instance 1', 24);
						tankBop4.scrollFactor.set(3.5, 2.5);
						tankBop4.antialiasing = true;

						tankBop5 = new FlxSprite(1300, 900);
						tankBop5.frames = Paths.getSparrowAtlas('tank4');
						tankBop5.animation.addByPrefix('bop', 'fg tankman bobbin 3 instance 1', 24);
						tankBop5.scrollFactor.set(1.5, 1.5);
						tankBop5.antialiasing = true;

						tankBop6 = new FlxSprite(1620, 700);
						tankBop6.frames = Paths.getSparrowAtlas('tank5');
						tankBop6.animation.addByPrefix('bop', 'fg tankhead far right instance 1', 24);
						tankBop6.scrollFactor.set(1.5, 1.5);
						tankBop6.antialiasing = true;

						// JOELwindows7: use layfront!
						addThe(tankBop1, 'tankBop1', true, 2);
						addThe(tankBop2, 'tankBop2', true, 2);
						addThe(tankBop3, 'tankBop3', true, 2);
						addThe(tankBop4, 'tankBop4', true, 2);
						addThe(tankBop5, 'tankBop5', true, 2);
						addThe(tankBop6, 'tankBop6', true, 2);

						tankWatchtower.animation.play('bop');
						tankBop1.animation.play('bop');
						tankBop2.animation.play('bop');
						tankBop3.animation.play('bop');
						tankBop4.animation.play('bop');
						tankBop5.animation.play('bop');
						tankBop6.animation.play('bop');
					}
				case 'tankStage2':
					{
						curStage = 'tankStage2';
						camZoom = 0.9;

						// picoStep = Json.parse(openfl.utils.Assets.getText(Paths.json('stress/picospeaker')));
						// tankStep = Json.parse(openfl.utils.Assets.getText(Paths.json('stress/tankSpawn')));
						// JOELwindows7: No! use the new TJSONer! idk..
						picoStep = TJSON.parse(openfl.utils.Assets.getText(Paths.json('songs/${PlayState.SONG.songId}/picospeaker')));
						tankStep = TJSON.parse(openfl.utils.Assets.getText(Paths.json('songs/${PlayState.SONG.songId}/tankSpawn')));

						var sky:FlxSprite = new FlxSprite(-400, -400).loadGraphic(Paths.image('tankSky'));
						sky.scrollFactor.set(0, 0);
						sky.antialiasing = true;
						sky.setGraphicSize(Std.int(sky.width * 1.5));
						// add(sky);
						addThe(sky, 'sky');

						var clouds:FlxSprite = new FlxSprite(FlxG.random.int(-700, -100), FlxG.random.int(-20, 20)).loadGraphic(Paths.image('tankClouds'));
						clouds.scrollFactor.set(0.1, 0.1);
						clouds.velocity.x = FlxG.random.float(5, 15);
						clouds.antialiasing = true;
						clouds.updateHitbox();
						// add(clouds);
						addThe(clouds, 'clouds');

						var mountains:FlxSprite = new FlxSprite(-300, -20).loadGraphic(Paths.image('tankMountains'));
						mountains.scrollFactor.set(0.2, 0.2);
						mountains.setGraphicSize(Std.int(1.2 * mountains.width));
						mountains.updateHitbox();
						mountains.antialiasing = true;
						// add(mountains);
						addThe(mountains, 'mountains');

						var buildings:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('tankBuildings'));
						buildings.scrollFactor.set(0.3, 0.3);
						buildings.setGraphicSize(Std.int(buildings.width * 1.1));
						buildings.updateHitbox();
						buildings.antialiasing = true;
						// add(buildings);
						addThe(buildings, 'buildings');

						var ruins:FlxSprite = new FlxSprite(-200, 0).loadGraphic(Paths.image('tankRuins'));
						ruins.scrollFactor.set(0.35, 0.35);
						ruins.setGraphicSize(Std.int(ruins.width * 1.1));
						ruins.updateHitbox();
						ruins.antialiasing = true;
						// add(ruins);
						addThe(ruins, 'ruins');

						var smokeLeft:FlxSprite = new FlxSprite(-200, -100);
						smokeLeft.frames = Paths.getSparrowAtlas('smokeLeft');
						smokeLeft.animation.addByPrefix('idle', 'SmokeBlurLeft ', 24, true);
						smokeLeft.scrollFactor.set(0.4, 0.4);
						smokeLeft.antialiasing = true;
						smokeLeft.animation.play('idle');

						// add(smokeLeft);
						addThe(smokeLeft, 'smokeLeft');

						var smokeRight:FlxSprite = new FlxSprite(1100, -100);
						smokeRight.frames = Paths.getSparrowAtlas('smokeRight');
						smokeRight.animation.addByPrefix('idle', 'SmokeRight ', 24, true);
						smokeRight.scrollFactor.set(0.4, 0.4);
						smokeRight.antialiasing = true;
						smokeRight.animation.play('idle');

						// add(smokeRight);
						addThe(smokeRight, 'smokeRight');

						var tankWatchtower:FlxSprite = new FlxSprite(100, 120);
						tankWatchtower.frames = Paths.getSparrowAtlas('tankWatchtower');
						tankWatchtower.animation.addByPrefix('bop', 'watchtower gradient color instance 1', 24, true);
						tankWatchtower.scrollFactor.set(0.5, 0.5);
						tankWatchtower.antialiasing = true;

						// add(tankWatchtower);
						addThe(tankWatchtower, 'tankWatchtower');

						tankRolling = new FlxSprite(300, 300);
						tankRolling.frames = Paths.getSparrowAtlas('tankRolling');
						tankRolling.animation.addByPrefix('idle', 'BG tank w lighting ', 24, true);
						tankRolling.scrollFactor.set(0.5, 0.5);
						tankRolling.antialiasing = true;
						tankRolling.animation.play('idle');
						// add(tankRolling);
						addThe(tankRolling, 'tankRolling');
						tankmanRun = new FlxTypedGroup<TankmenBG>();
						// JOELwindows7: add at least one object instance!
						// for (i in 0...10)
						// {
						var tankmanRunEmpty = new TankmenBG();
						tankmanRunEmpty.resetShit(FlxG.random.int(630, 730) * -1, 255, true, 1, 1.5);
						tankmanRunEmpty.kill();
						var tankmanRunEmpty2 = new TankmenBG();
						tankmanRunEmpty2.resetShit(FlxG.random.int(1500, 1700) * 1, 275, false, 1, 1.5);
						tankmanRunEmpty2.kill();
						tankmanRun.add(tankmanRunEmpty); // so that we can recycle one member.
						tankmanRun.add(tankmanRunEmpty2); // again just in case.
						// }
						// add(tankmanRun);
						addThe(tankmanRun, 'tankmanRun');

						var ground:FlxSprite = new FlxSprite(-420, -150).loadGraphic(Paths.image('tankGround'));
						ground.scrollFactor.set();
						ground.antialiasing = true;
						ground.setGraphicSize(Std.int(ground.width * 1.15));
						ground.scrollFactor.set(1, 1);

						ground.updateHitbox();
						// add(ground);
						addThe(ground, 'ground');

						tankBop1 = new FlxSprite(-500, 650);
						tankBop1.frames = Paths.getSparrowAtlas('tank0');
						tankBop1.animation.addByPrefix('bop', 'fg tankhead far right instance 1', 24);
						tankBop1.scrollFactor.set(1.7, 1.5);
						tankBop1.antialiasing = true;

						tankBop2 = new FlxSprite(-300, 750);
						tankBop2.frames = Paths.getSparrowAtlas('tank1');
						tankBop2.animation.addByPrefix('bop', 'fg tankhead 5 instance 1', 24);
						tankBop2.scrollFactor.set(2.0, 0.2);
						tankBop2.antialiasing = true;

						tankBop3 = new FlxSprite(450, 940);
						tankBop3.frames = Paths.getSparrowAtlas('tank2');
						tankBop3.animation.addByPrefix('bop', 'foreground man 3 instance 1', 24);
						tankBop3.scrollFactor.set(1.5, 1.5);
						tankBop3.antialiasing = true;

						tankBop4 = new FlxSprite(1300, 1200);
						tankBop4.frames = Paths.getSparrowAtlas('tank3');
						tankBop4.animation.addByPrefix('bop', 'fg tankhead 4 instance 1', 24);
						tankBop4.scrollFactor.set(3.5, 2.5);
						tankBop4.antialiasing = true;

						tankBop5 = new FlxSprite(1300, 900);
						tankBop5.frames = Paths.getSparrowAtlas('tank4');
						tankBop5.animation.addByPrefix('bop', 'fg tankman bobbin 3 instance 1', 24);
						tankBop5.scrollFactor.set(1.5, 1.5);
						tankBop5.antialiasing = true;

						tankBop6 = new FlxSprite(1620, 700);
						tankBop6.frames = Paths.getSparrowAtlas('tank5');
						tankBop6.animation.addByPrefix('bop', 'fg tankhead far right instance 1', 24);
						tankBop6.scrollFactor.set(1.5, 1.5);
						tankBop6.antialiasing = true;

						// JOELwindows7: use layfront!
						addThe(tankBop1, 'tankBop1', true, 2);
						addThe(tankBop2, 'tankBop2', true, 2);
						addThe(tankBop3, 'tankBop3', true, 2);
						addThe(tankBop4, 'tankBop4', true, 2);
						addThe(tankBop5, 'tankBop5', true, 2);
						addThe(tankBop6, 'tankBop6', true, 2);

						tankWatchtower.animation.play('bop');
						tankBop1.animation.play('bop');
						tankBop2.animation.play('bop');
						tankBop3.animation.play('bop');
						tankBop4.animation.play('bop');
						tankBop5.animation.play('bop');
						tankBop6.animation.play('bop');
					}
				// JOELwindows7: da bbpanzu sky. sorry, people. KitsuneSkulls turns out to be a bad guy. Not Micheal's fault! We wish Rodrigo had it instead, idk..
				case 'theShift':
					{
						// daPixelZoom = 1;
						// defaultCamZoom = 0.9;
						camZoom = 0.9;
						curStage = 'theShift';
						shiftbg = new FlxSprite(-388.05, -232);
						shiftbg.frames = Paths.getSparrowAtlas("sky/bg_normal");
						shiftbg.animation.addByIndices("idle", "bg", [5], "", 24, false);
						shiftbg.animation.addByPrefix("bop", "bg", 24, false);
						// shiftbg.animation.addByPrefix("manifest", "bgBOOM", 24, false);
						shiftbg.animation.play("idle");

						shiftbg.updateHitbox();
						shiftbg.antialiasing = true;
						shiftbg.scrollFactor.set(0, 1);
						addThe(shiftbg, 'shiftbg');
					}
				case 'theShift2':
					{
						// daPixelZoom = 1;
						// defaultCamZoom = 0.9;
						camZoom = 0.9;
						curStage = 'theShift2';
						shiftbg = new FlxSprite(-388.05, -232);
						shiftbg.frames = Paths.getSparrowAtlas("sky/bg_annoyed");
						shiftbg.animation.addByIndices("idle", "bg2", [5], "", 24, false);
						shiftbg.animation.addByPrefix("bop", "bg2", 24, false);
						shiftbg.animation.addByPrefix("manifest", "bgBOOM", 24, false);
						shiftbg.animation.play("idle");

						shiftbg.updateHitbox();
						shiftbg.antialiasing = true;
						shiftbg.scrollFactor.set(0, 1);
						addThe(shiftbg, 'shiftbg');
					}
				case 'theManifest':
					{
						// daPixelZoom = 1;
						// defaultCamZoom = 0.9;
						camZoom = 0.9;
						curStage = 'theManifest';
						shiftbg = new FlxSprite(-388.05, -232);
						shiftbg.frames = Paths.getSparrowAtlas("sky/bg_manifest");
						shiftbg.animation.addByIndices("idle", "bg_manifest", [5], "", 24, false);
						shiftbg.animation.addByPrefix("bop", "bg_manifest", 24, false);
						shiftbg.animation.play("idle");
						shiftbg.updateHitbox();
						shiftbg.antialiasing = true;
						shiftbg.scrollFactor.set(0.4, 0.4);
						addThe(shiftbg, 'shiftbg');

						floor = new FlxSprite(-1053.1, -464.7);
						floor.frames = Paths.getSparrowAtlas("sky/floorManifest");
						floor.animation.addByIndices("idle", "floorManifest", [5], "", 24, false);
						floor.animation.addByPrefix("bop", "floorManifest", 24, false);
						floor.animation.play("idle");
						floor.updateHitbox();
						floor.antialiasing = true;
						floor.scrollFactor.set(0.9, 0.9);
						addThe(floor, 'floor');
					}
				// JOELwindows7: start init LFM stage
				case 'jakartaFair':
					{
						// JOELwindows7:
						/*
							Jakarta fair, ayo ke Jakarta Fair
							Ajang arena pameran dan hiburan

							ayo kita pergi kesana, rekreasi sekaligus berbelanja
							belanja terlengkap di Jakarta fair...

							ayo kita, ke Jakarta fair. ayo kita ke Jakarta fair. Kemayoran!!!
						 */

						// defaultCamZoom = 0.9;
						camZoom = 0.9;
						curStage = 'jakartaFair';
						var bgActualOffset_x = -150;
						var bgActualOffset_y = -100;
						var bg:FlxSprite = new FlxSprite(bgActualOffset_x + -500,
							bgActualOffset_y + -100).loadGraphic(Paths.image('jakartaFair/jakartaFairBgBehindALL'));
						bg.setGraphicSize(Std.int(bg.width * 1.2), Std.int(bg.height * 1.2));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(.9, .9);
						bg.active = false;
						addThe(bg, 'bg');

						var stageFront:FlxSprite = new FlxSprite(-500, -100).loadGraphic(Paths.image('jakartaFair/jakartaFairBgInsideBooth'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.2), Std.int(stageFront.height * 1.2));
						stageFront.updateHitbox();
						stageFront.antialiasing = FlxG.save.data.antialiasing;
						stageFront.scrollFactor.set(1, 1);
						stageFront.active = false;
						addThe(stageFront, 'stageFront');

						// Now for the colorable ceiling!
						colorableGround = new FlxSprite(-500, -100).loadGraphic(Paths.image('jakartaFair/jakartaFairBgColorableRoof'));
						colorableGround.setGraphicSize(Std.int(colorableGround.width * 1.2), Std.int((colorableGround.height * 1.2)));
						colorableGround.updateHitbox();
						colorableGround.antialiasing = FlxG.save.data.antialiasing;
						colorableGround.scrollFactor.set(1, 1);
						colorableGround.active = false;
						colorableGround.color.setRGB(1, 1, 1, 0);
						addThe(colorableGround, 'colorableGround');
						isChromaScreen = false; // the ceiling is RGB light!
						originalColor = colorableGround.color; // store the default color!
						colorableGround.visible = false; // Hide the RGB light first before begin!

						// now back to final closest to the camera.
						var stageCurtains:FlxSprite = new FlxSprite(-500, -100).loadGraphic(Paths.image('jakartaFair/jakartaFairBgRearSpeakers'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 1.2), Std.int(stageFront.height * 1.2));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = FlxG.save.data.antialiasing;
						stageCurtains.scrollFactor.set(1.5, 1.5);
						stageCurtains.active = false;
						addThe(stageCurtains, 'stageCurtains', true, 2);
					}
				case 'qmoveph':
					{
						// defaultCamZoom = 0.9;
						camZoom = 0.9;
						curStage = 'qmoveph';
						var bg:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('qmoveph/DefaultBackground'));
						bg.setGraphicSize(Std.int(bg.width * 1.1), Std.int(bg.height * 1.1));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(0.9, 0.9);
						bg.active = false;
						addThe(bg, 'bg');
					}
				case 'cruelThesis':
					{
						// JOELwindows7: LOL Van Elektronishe with Cruel Angel Thesis lol Evangelion
						// defaultCamZoom = 0.9;
						camZoom = 0.9;
						curStage = 'cruelThesis';
						var bg:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('VanElektronische/VanElektronische_corpThesis'));
						bg.setGraphicSize(Std.int(bg.width * 1.2), Std.int(bg.height * 1.2));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(0.9, 0.9);
						bg.active = false;
						addThe(bg, 'bg');
					}
				case 'lapanganParalax':
					{
						// defaultCamZoom = 0.9;
						camZoom = 0.9;
						curStage = 'lapanganParalax';
						var bg:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('lapanganParalax/Bekgron'));
						bg.setGraphicSize(Std.int(bg.width * 1.2), Std.int(bg.height * 1.2));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(0.3, 0.3);
						bg.active = false;
						addThe(bg, 'bg');

						var bg2:FlxSprite = new FlxSprite(-200, -150).loadGraphic(Paths.image('lapanganParalax/Betwaangron'));
						bg2.setGraphicSize(Std.int(bg2.width * 1.2), Std.int(bg2.height * 1.2));
						bg2.antialiasing = FlxG.save.data.antialiasing;
						bg2.scrollFactor.set(0.5, 0.5);
						bg2.active = false;
						addThe(bg2, 'bg2');

						var bg3:FlxSprite = new FlxSprite(-200, -50).loadGraphic(Paths.image('lapanganParalax/Betweengron'));
						bg3.setGraphicSize(Std.int(bg3.width * 1.2), Std.int(bg3.height * 1.2));
						bg3.antialiasing = FlxG.save.data.antialiasing;
						bg3.scrollFactor.set(0.7, 0.7);
						bg3.active = false;
						addThe(bg3, 'bg3');

						var stageFront:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('lapanganParalax/Midgron'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.2), Std.int(stageFront.height * 1.2));
						stageFront.updateHitbox();
						stageFront.antialiasing = FlxG.save.data.antialiasing;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						addThe(stageFront, 'stageFront');

						var stageCurtains:FlxSprite = new FlxSprite(-200, -100).loadGraphic(Paths.image('lapanganParalax/Forgron'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 1.2), Std.int(stageCurtains.height * 1.2));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = FlxG.save.data.antialiasing;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;
						addThe(stageCurtains, 'stageCurtains', true, 2);
					}
				case 'blank':
					{
						// defaultCamZoom = 0.5;
						camZoom = 0.5;
						curStage = 'blank';
						// JOELwindows7: Just blank. nothing.
						// chroma key color is #000000 . well, it's hard, yes,
						// so if you need chroma key, you should green screen instead.
					}
				case 'greenscreen':
					{
						// defaultCamZoom = 0.5;
						camZoom = 0.5;
						curStage = 'greenscreen';
						// JOELwindows7: turns out you can generate graphic with Make Graphic!
						// it is even there on the FlxSprite construction wow!
						// read function of `schoolIntro`. there's a variable called `red` which is the FlxSprite of full red.
						// so, now you can chroma key full green!
						// heh what the peck man? GREEN is #008000 (dim green)!?? but LIME is #00FF00 (full green)?!? really bro?!
						// you confused me!!! the true green was supposed to be full green #00FF00 what the peck, Flixel?!
						colorableGround = new FlxSprite(-800, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.LIME);
						colorableGround.setGraphicSize(Std.int(colorableGround.width * 5), Std.int(colorableGround.height * 5));
						colorableGround.updateHitbox();
						colorableGround.antialiasing = FlxG.save.data.antialiasing;
						colorableGround.scrollFactor.set(0.1, 0.1);
						colorableGround.active = false;
						addThe(colorableGround, 'colorableGround');
						originalColor = colorableGround.color; // store the original color first!
						isChromaScreen = true; // The background is chroma screen
					}
				case 'bluechroma':
					{
						// JOELwindows7: same as greenscreen but blue. not to be confused with blue screen of death!
						// defaultCamZoom = 0.5;
						camZoom = 0.5;
						curStage = 'bluechroma';
						colorableGround = new FlxSprite(-800, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.BLUE);
						colorableGround.setGraphicSize(Std.int(colorableGround.width * 5), Std.int(colorableGround.height * 5));
						colorableGround.updateHitbox();
						colorableGround.antialiasing = FlxG.save.data.antialiasing;
						colorableGround.scrollFactor.set(0.1, 0.1);
						colorableGround.active = false;
						addThe(colorableGround, 'colorableGround');
						originalColor = colorableGround.color; // store the original color first!
						isChromaScreen = true; // The background is chroma screen
					}
				case 'semple':
					{
						// JOELwindows7: Stuart Semple is multidisciplinary Bristish artist! A painter, and more.
						// He is famous for the pinkest color you've ever seen.
						// https://culturehustle.com/products/pink-50g-powdered-paint-by-stuart-semple
						// and peck Anish Kapoor.
						// defaultCamZoom = 0.5;
						camZoom = 0.5;
						curStage = 'semple';
						// JOELwindows7: to me, that pinkest pink looks like magenta! at least on screen. idk how about in person
						// because no camera has the ability to capture way over Pink Semple had.
						colorableGround = new FlxSprite(-800, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.MAGENTA);
						colorableGround.setGraphicSize(Std.int(colorableGround.width * 5), Std.int(colorableGround.height * 5));
						colorableGround.updateHitbox();
						colorableGround.antialiasing = FlxG.save.data.antialiasing;
						colorableGround.scrollFactor.set(0.1, 0.1);
						colorableGround.active = false;
						addThe(colorableGround, 'colorableGround');
						originalColor = colorableGround.color; // store the original color first!
						isChromaScreen = true; // The background is chroma screen
					}
				case 'whitening':
					{
						// JOELwindows7: This looks familiar. oh no.
						// anyway. USE THIS SCREEN IF YOU WANT TO CHANGE COLOR with FULL RGB!
						// BEST SCREEN FOR FULL RGB COLOR!!!
						// defaultCamZoom = 0.5;
						camZoom = 0.5;
						curStage = 'whitening';
						// JOELwindows7: guys, pls don't blamm me. it's nothing to do. let's assume it's purely coincidental.
						colorableGround = new FlxSprite(-800, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.WHITE);
						colorableGround.setGraphicSize(Std.int(colorableGround.width * 5), Std.int(colorableGround.height * 5));
						colorableGround.updateHitbox();
						colorableGround.antialiasing = FlxG.save.data.antialiasing;
						colorableGround.scrollFactor.set(0.1, 0.1);
						colorableGround.active = false;
						addThe(colorableGround, 'colorableGround');
						originalColor = colorableGround.color; // store the original color first!
						isChromaScreen = true; // The background is chroma screen
					}
				case 'kuning':
					{
						// JOELwindows7: yellow this one out
						// defaultCamZoom = 0.5;
						camZoom = 0.5;
						curStage = 'kuning';
						colorableGround = new FlxSprite(-800, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.YELLOW);
						colorableGround.setGraphicSize(Std.int(colorableGround.width * 5), Std.int(colorableGround.height * 5));
						colorableGround.updateHitbox();
						colorableGround.antialiasing = FlxG.save.data.antialiasing;
						colorableGround.scrollFactor.set(0.1, 0.1);
						colorableGround.active = false;
						addThe(colorableGround, 'colorableGround');
						originalColor = colorableGround.color; // store the original color first!
						isChromaScreen = true; // The background is chroma screen
					}
				case 'blood':
					{
						// JOELwindows7: red screen
						// defaultCamZoom = 0.5;
						camZoom = 0.5;
						curStage = 'blood';
						colorableGround = new FlxSprite(-800, -500).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.RED);
						colorableGround.setGraphicSize(Std.int(colorableGround.width * 5), Std.int(colorableGround.height * 5));
						colorableGround.updateHitbox();
						colorableGround.antialiasing = FlxG.save.data.antialiasing;
						colorableGround.scrollFactor.set(0.1, 0.1);
						colorableGround.active = false;
						addThe(colorableGround, 'colorableGround');
						originalColor = colorableGround.color; // store the original color first!
						isChromaScreen = true; // The background is chroma screen
					}
				// JOELwindows7: end init LFM stage
				default:
					{
						camZoom = 0.9;
						curStage = 'stage';
						var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.loadImage('stageback', 'shared'));
						bg.antialiasing = FlxG.save.data.antialiasing;
						bg.scrollFactor.set(0.9, 0.9);
						bg.active = false;
						swagBacks['bg'] = bg;
						toAdd.push(bg);

						var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.loadImage('stagefront', 'shared'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = FlxG.save.data.antialiasing;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						swagBacks['stageFront'] = stageFront;
						toAdd.push(stageFront);

						// JOELwindows7: reinstall stage light and this time, I added bloom yay!
						var stageLight:FlxSprite = new FlxSprite(-100, -80).loadGraphic(Paths.image('stage_light'));
						stageLight.setGraphicSize(Std.int(stageLight.width * 1), Std.int(stageLight.height * 1));
						stageLight.updateHitbox();
						stageLight.antialiasing = FlxG.save.data.antialiasing;
						stageLight.scrollFactor.set(1.3, 1.3);
						stageLight.active = false;

						// JOELwindows7: here's the bloom of that lighting
						colorableGround = new FlxSprite(-100, -80).loadGraphic(Paths.image('stage_light_bloom'));
						colorableGround.setGraphicSize(Std.int(colorableGround.width * 2), Std.int(colorableGround.height * 2));
						colorableGround.updateHitbox();
						colorableGround.antialiasing = FlxG.save.data.antialiasing;
						colorableGround.scrollFactor.set(1.3, 1.3);
						colorableGround.active = false;

						// JOELwindows7: make sure order is correct
						addThe(colorableGround, 'colorableGround');
						addThe(stageLight, 'stageLight');
						colorableGround.visible = false; // initially off for performer safety.

						var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.loadImage('stagecurtains', 'shared'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = FlxG.save.data.antialiasing;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;

						swagBacks['stageCurtains'] = stageCurtains;
						toAdd.push(stageCurtains);

						// JOELwindows7: here kem0x's shader background yey
						// yoink from https://github.com/kem0x/Nexus-Engine/blob/master/source/Stage.hx
						/*
							sha = new ShaderBackground("test", 0, 0, FlxG.width, FlxG.height);
							sha.setGraphicSize(Std.int(sha.width * 1.4));
							sha.updateHitbox();
							swagBacks['sha'] = sha;
							toAdd.push(sha);
							sha.alpha = 0;
						 */
					}
			}

		// JOELwindows7: additional things to be thought of
		additionalCreateFlxSprites();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!PlayStateChangeables.Optimize)
		{
			switch (curStage)
			{
				case 'philly':
					if (trainMoving)
					{
						trainFrameTiming += elapsed;

						if (trainFrameTiming >= 1 / 24)
						{
							updateTrainPos();
							trainFrameTiming = 0;
						}
					}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
				// JOELwindows7: week 7 tank rolling pls
				case 'tankStage':
					moveTank();
				case 'tankStage2':
					moveTank();
			}
		}
	}

	override function stepHit()
	{
		super.stepHit();

		if (!PlayStateChangeables.Optimize)
		{
			var array = slowBacks[curStep];
			if (array != null && array.length > 0)
			{
				if (hideLastBG)
				{
					for (bg in swagBacks)
					{
						if (!array.contains(bg))
						{
							var tween = FlxTween.tween(bg, {alpha: 0}, tweenDuration, {
								onComplete: function(tween:FlxTween):Void
								{
									bg.visible = false;
								}
							});
						}
					}
					for (bg in array)
					{
						bg.visible = true;
						FlxTween.tween(bg, {alpha: 1}, tweenDuration);
					}
				}
				else
				{
					for (bg in array)
						bg.visible = !bg.visible;
				}
			}

			// JOELwindows7: incoming! week7 yoink! yey luckydog7
			// picoSpeaker and running tankmen

			// if (PlayState.SONG.songId == 'stress')
			// {
			// 	// RIGHT
			// 	for (i in 0...picoStep.right.length)
			// 	{
			// 		if (curStep == picoStep.right[i])
			// 		{
			// 			PlayState.gf.playAnim('shoot' + FlxG.random.int(1, 2), true);
			// 			// var tankmanRunner:TankmenBG = new TankmenBG();
			// 		}
			// 	}
			// 	// LEFT
			// 	for (i in 0...picoStep.left.length)
			// 	{
			// 		if (curStep == picoStep.left[i])
			// 		{
			// 			PlayState.gf.playAnim('shoot' + FlxG.random.int(3, 4), true);
			// 		}
			// 	}
			// 	// Left tankspawn
			// 	for (i in 0...tankStep.left.length)
			// 	{
			// 		if (curStep == tankStep.left[i])
			// 		{
			// 			var tankmanRunner:TankmenBG = new TankmenBG();
			// 			tankmanRunner.resetShit(FlxG.random.int(630, 730) * -1, 255, true, 1, 1.5);

			// 			tankmanRun.add(tankmanRunner);
			// 		}
			// 	}

			// 	// Right spawn
			// 	for (i in 0...tankStep.right.length)
			// 	{
			// 		if (curStep == tankStep.right[i])
			// 		{
			// 			var tankmanRunner:TankmenBG = new TankmenBG();
			// 			tankmanRunner.resetShit(FlxG.random.int(1500, 1700) * 1, 275, false, 1, 1.5);
			// 			tankmanRun.add(tankmanRunner);
			// 		}
			// 	}
			// }
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (FlxG.save.data.distractions && animatedBacks.length > 0)
		{
			for (bg in animatedBacks)
				bg.animation.play('idle', true);
		}

		if (!PlayStateChangeables.Optimize)
		{
			switch (curStage)
			{
				case 'halloween':
					if (FlxG.random.bool(Conductor.bpm > 320 ? 100 : 10) && curBeat > lightningStrikeBeat + lightningOffset)
					{
						if (FlxG.save.data.distractions)
						{
							lightningStrikeShit();
							trace('spooky');
						}

						// JOELwindows7: above is not my code. but idea!
						// for Gravis Ultrasound demo, RAIN.MID. you can manually lightning strike as the beat almost drop.
					}
				case 'school':
					if (FlxG.save.data.distractions)
					{
						swagBacks['bgGirls'].dance();
					}
				case 'limo':
					if (FlxG.save.data.distractions)
					{
						swagGroup['grpLimoDancers'].forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});

						if (FlxG.random.bool(10) && fastCarCanDrive)
							fastCarDrive();
					}
				case "philly":
					if (FlxG.save.data.distractions)
					{
						if (!trainMoving)
							trainCooldown += 1;

						if (curBeat % 4 == 0)
						{
							var phillyCityLights = swagGroup['phillyCityLights'];
							phillyCityLights.forEach(function(light:FlxSprite)
							{
								light.visible = false;
							});

							curLight = FlxG.random.int(0, phillyCityLights.length - 1);

							phillyCityLights.members[curLight].visible = true;
							// phillyCityLights.members[curLight].alpha = 1;
						}
					}

					if (curBeat % 8 == 4 && FlxG.random.bool(Conductor.bpm > 320 ? 150 : 30) && !trainMoving && trainCooldown > 8)
					{
						if (FlxG.save.data.distractions)
						{
							trainCooldown = FlxG.random.int(-4, 0);
							trainStart();
							trace('train');
						}
					}
			}
		}
	}

	// Variables and Functions for Stages
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var curLight:Int = 0;
	var curLightEvent:Int = 0; // JOELwindows7 Psyched blammed things

	// JOELwindows7: make public for lua modchart
	public function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2, 'shared'));
		swagBacks['halloweenBG'].animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (PlayState.boyfriend != null)
		{
			PlayState.boyfriend.playAnim('scared', true);
			PlayState.gf.playAnim('scared', true);
		}
		else
		{
			GameplayCustomizeState.boyfriend.playAnim('scared', true);
			GameplayCustomizeState.gf.playAnim('scared', true);
		}

		// JOELwindows7: Psyched camera flash
		if (FlxG.save.data.flashing)
		{
			FlxG.camera.flash(FlxColor.WHITE, .6);
		}

		// JOELwindows7: shock fear Heartbeat jumps
		// PlayState.instance.increaseHR(PlayState.instance.fearShockAdd[0][PlayState.instance.heartTierIsRightNow[0]], 0);
		// PlayState.instance.increaseHR(PlayState.instance.fearShockAdd[2][PlayState.instance.heartTierIsRightNow[2]], 2);
		// PlayState.boyfriend
		PlayState.boyfriend.stimulateHeart(-1, HeartStimulateType.FEAR);
		PlayState.gf.stimulateHeart(-1, HeartStimulateType.FEAR);

		// JOELwindows7: vibrate controllers
		Controls.vibrate(0, 100);
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var trainSound:FlxSound;

	// JOELwindows7: make public for lua modchart
	public function trainStart():Void
	{
		if (FlxG.save.data.distractions)
		{
			trainMoving = true;
			trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;

				if (PlayState.gf != null)
					PlayState.gf.playAnim('hairBlow');
				else
					GameplayCustomizeState.gf.playAnim('hairBlow');
			}

			if (startedMoving)
			{
				var phillyTrain = swagBacks['phillyTrain'];
				phillyTrain.x -= 400;

				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}
	}

	// JOELwindows7: Psyched blammed lights
	// https://github.com/ShadowMario/FNF-PsychEngine/blob/main/source/PlayState.hx
	public function blammedLights(lightId:Int):Void
	{
		if (Math.isNaN(lightId))
			lightId = 0;

		if (FlxG.save.data.distractions)
		{
			if (lightId > 0 && curLightEvent != lightId)
			{
				Debug.logTrace('Blammed light ON Light ID ${lightId}');
				if (lightId > 5)
					lightId = FlxG.random.int(1, 5, [curLightEvent]);

				var color:Int = 0xffffffff;
				switch (lightId)
				{
					case 1: // Blue
						color = 0xff31a2fd;
					case 2: // Green
						color = 0xff31fd8c;
					case 3: // Pink
						color = 0xfff794f7;
					case 4: // Red
						color = 0xfff96d63;
					case 5: // Orange
						color = 0xfffba633;
				}
				curLightEvent = lightId;

				if (blammedLightsBlack.alpha == 0)
				{
					if (blammedLightsBlackTween != null)
					{
						blammedLightsBlackTween.cancel();
					}
					blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 1}, 1, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							blammedLightsBlackTween = null;
						}
					});

					var chars:Array<Character> = [PlayState.boyfriend, PlayState.gf, PlayState.dad];
					for (i in 0...chars.length)
					{
						if (chars[i].colorTween != null)
						{
							chars[i].colorTween.cancel();
						}
						chars[i].colorTween = FlxTween.color(chars[i], 1, FlxColor.WHITE, color, {
							onComplete: function(twn:FlxTween)
							{
								chars[i].colorTween = null;
							},
							ease: FlxEase.quadInOut
						});
					}
				}
				else
				{
					if (blammedLightsBlackTween != null)
					{
						blammedLightsBlackTween.cancel();
					}
					blammedLightsBlackTween = null;
					blammedLightsBlack.alpha = 1;

					var chars:Array<Character> = [PlayState.boyfriend, PlayState.gf, PlayState.dad];
					for (i in 0...chars.length)
					{
						if (chars[i].colorTween != null)
						{
							chars[i].colorTween.cancel();
						}
						chars[i].colorTween = null;
					}
					PlayState.dad.color = color;
					PlayState.boyfriend.color = color;
					PlayState.gf.color = color;
				}

				if (curStage == 'philly')
				{
					if (phillyCityLightsEvent != null)
					{
						phillyCityLightsEvent.forEach(function(spr:BGSprite)
						{
							spr.visible = false;
						});
						if (phillyCityLightsEvent.members[lightId - 1] != null)
						{
							// JOELwindows7: Yo, this crashes here! Null object reference
							phillyCityLightsEvent.members[lightId - 1].visible = true;
							phillyCityLightsEvent.members[lightId - 1].alpha = 1;
						}
					}
				}
			}
			else
			{
				if (blammedLightsBlack.alpha != 0)
				{
					if (blammedLightsBlackTween != null)
					{
						blammedLightsBlackTween.cancel();
					}
					blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 0}, 1, {
						ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							blammedLightsBlackTween = null;
						}
					});
				}

				if (curStage == 'philly')
				{
					// JOELwindows7: pls don't forget safety!
					if (phillyCityLights != null)
					{
						phillyCityLights.forEach(function(spr:FlxSprite) // JOELwindows7: this gotta be changed
						{
							spr.visible = false;
						});
					}
					if (phillyCityLightsEvent != null)
					{
						phillyCityLightsEvent.forEach(function(spr:BGSprite)
						{
							spr.visible = false;
						});
					}

					var memb:FlxSprite = new FlxSprite();
					// JOELwindows7: I believe this also Null object reference too.
					if (phillyCityLightsEvent.members[curLightEvent - 1] != null)
						memb = phillyCityLightsEvent.members[curLightEvent - 1];
					if (memb != null)
					{
						memb.visible = true;
						memb.alpha = 1;
						if (phillyCityLightsEventTween != null)
							phillyCityLightsEventTween.cancel();

						phillyCityLightsEventTween = FlxTween.tween(memb, {alpha: 0}, 1, {
							onComplete: function(twn:FlxTween)
							{
								phillyCityLightsEventTween = null;
							},
							ease: FlxEase.quadInOut
						});
					}
				}

				var chars:Array<Character> = [PlayState.boyfriend, PlayState.gf, PlayState.dad];
				for (i in 0...chars.length)
				{
					if (chars[i].colorTween != null)
					{
						chars[i].colorTween.cancel();
					}
					chars[i].colorTween = FlxTween.color(chars[i], 1, chars[i].color, FlxColor.WHITE, {
						onComplete: function(twn:FlxTween)
						{
							chars[i].colorTween = null;
						},
						ease: FlxEase.quadInOut
					});
				}

				curLight = 0;
				curLightEvent = 0;
			}
		}
	}

	// JOELwindows7: make public for lua modchart
	public function trainReset():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (PlayState.gf != null)
			{
				PlayState.gf.playAnim('hairFall');
				// JOELwindows7: gf goes dead silent afterward. work around pls
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					PlayState.gf.playAnim('danceRight');
					PlayState.gf.dance();
				});
			}
			else
			{
				GameplayCustomizeState.gf.playAnim('hairFall');
				// JOELwindows7: gf goes dead silent afterward. work around pls
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					GameplayCustomizeState.gf.playAnim('danceRight');
					GameplayCustomizeState.gf.dance();
				});
			}

			swagBacks['phillyTrain'].x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	var fastCarCanDrive:Bool = true;

	// JOELwindows7: make public for lua modchart
	public function resetFastCar():Void
	{
		if (FlxG.save.data.distractions)
		{
			var fastCar = swagBacks['fastCar'];
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCar.visible = false;
			fastCarCanDrive = true;
		}
	}

	// JOELwindows7: make public for lua modchart
	public function fastCarDrive()
	{
		if (FlxG.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1, 'shared'), 0.7);

			swagBacks['fastCar'].visible = true;
			swagBacks['fastCar'].velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	// JOELwindows7: week 7 tank rolling
	var tankX = 400;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);

	function moveTank()
	{
		tankAngle += FlxG.elapsed * tankSpeed;
		tankRolling.angle = tankAngle - 90 + 15;
		tankRolling.x = tankX + 1500 * FlxMath.fastCos(FlxAngle.asRadians(tankAngle + 180));
		tankRolling.y = 1300 + 1100 * FlxMath.fastSin(FlxAngle.asRadians(tankAngle + 180));
	}

	function again()
	{
		tankRolling.x = 300;
		tankRolling.y = 300;
		moveTank();
	}

	// JOELwindows7: They see me rolling, they, okeh stop.
	// JOELwindows7: init stagefile
	public var customStage:SwagStage;

	var useStageScript:Bool = false; // JOELwindows7: flag to start try the stage Lua script

	public var attemptStageScript:Bool = false; // JOELwindows7: flag to start prepare stage script after all stuffs loaded

	function loadStageFile(path:String)
	{
		customStage = StageChart.loadFromJson(path);
		if (customStage != null)
		{
			useStageScript = customStage.useStageScript;
			// halloweenLevel = customStage.isHalloween;
		}
	}

	function spawnStageImages(daData:SwagStage)
	{
		for (i in 0...customStage.backgroundImages.length)
		{
			var dataBg:SwagBackground = customStage.backgroundImages[i];
			var anBgThing:FlxSprite = new FlxSprite(dataBg.position[0], dataBg.position[1]);
			multiColorable[i] = dataBg.colorable;
			trace("spawning bg " + dataBg.callName);
			if (dataBg.generateMode)
			{
				anBgThing.makeGraphic(Std.int(dataBg.size[0]), Std.int(dataBg.size[1]), FlxColor.fromString(dataBg.initColor));
				multiIsChromaScreen[i] = true;
			}
			else
			{
				if (dataBg.isXML)
				{
					anBgThing.frames = Paths.getSparrowAtlas("stage/" + CoolUtil.toCompatCase(PlayState.SONG.stage) + "/" + dataBg.graphic);
					anBgThing.animation.addByPrefix(dataBg.frameXMLName, dataBg.prefixXMLName, dataBg.frameRate, dataBg.mirrored);
				}
				else
				{
					anBgThing.loadGraphic(Paths.image("stages/" + CoolUtil.toCompatCase(PlayState.SONG.stage) + "/" + dataBg.graphic));
				}
				anBgThing.setGraphicSize(Std.int(anBgThing.width * dataBg.scale[0]), Std.int(anBgThing.height * dataBg.scale[1]));
				if (dataBg.colorable)
				{
					anBgThing.color = FlxColor.fromString(dataBg.initColor);
				}
			}
			// anBgThing.setPosition(dataBg.position[0],dataBg.position[1]);
			anBgThing.active = dataBg.active;
			anBgThing.antialiasing = dataBg.antialiasing && FlxG.save.data.antialiasing;
			anBgThing.scrollFactor.set(dataBg.scrollFactor[0], dataBg.scrollFactor[1]);
			anBgThing.ID = i;
			anBgThing.updateHitbox();
			// multiOriginalColor[i] = anBgThing.color;
			swagColors[dataBg.callName] = anBgThing.color;

			// bgAll.add(anBgThing);
			addThe(anBgThing, dataBg.callName, dataBg.layInFrontNow, dataBg.inFrontOfWhich);
			anBgThing.visible = dataBg.initVisible;

			// if(trailAll != null){
			// 	if(dataBg.hasTrail){
			// 		var trailing = new FlxTrail(anBgThing, null, 4, 24, 0.3, 0.069);
			// 		trailing.ID = i;
			// 		trailAll.add(trailing);
			// 	}
			// }
		}
	}

	// JOELwindows7: when stage is using Lua script
	public function spawnStageScript(daPath:String)
	{
		#if FEATURE_LUAMODCHART
		if (executeStageScript)
		{
			trace('stage script: ' + executeStageScript + " - " + Paths.lua(daPath)); // JOELwindows7: check too

			PlayState.stageScript = ModchartState.createModchartState(PlayState.isStoryMode, true, daPath);
			PlayState.stageScript.executeState('loaded', [PlayState.SONG.songId]);
			trace("loaded it up stage lua script");
			PlayState.stageScript.setVar("originalColors", multiOriginalColor);
			PlayState.stageScript.setVar("areChromaScreen", multiIsChromaScreen);
		}
		#end
		if (executeStageHscript)
		{
			trace('stage Hscript: ' + executeStageHscript + " - " + Paths.hscript(daPath)); // JOELwindows7: check too

			PlayState.stageHscript = HaxeScriptState.createModchartState(true, daPath);
			PlayState.stageHscript.executeState('loaded', [PlayState.SONG.songId]);
			trace("loaded it up stage haxe script");
			PlayState.stageHscript.setVar("originalColors", multiOriginalColor);
			PlayState.stageHscript.setVar("areChromaScreen", multiIsChromaScreen);
		}

		trace("Spawned the stage script yeay");
	}

	// JOELwindows7: core starting point for custom stage
	public function initDaCustomStage(stageJsonPath:String)
	{
		var p;
		trace("Lets init da json stage " + stageJsonPath);
		curStage = PlayState.SONG.stage;
		loadStageFile("stages/" + CoolUtil.toCompatCase(PlayState.SONG.stage) + "/" + CoolUtil.toCompatCase(PlayState.SONG.stage));

		if (customStage != null)
		{
			// defaultCamZoom = customStage.defaultCamZoom;
			camZoom = customStage.defaultCamZoom;
			// halloweenLevel = customStage.isHalloween;
			// bgAll = new FlxTypedGroup<FlxSprite>();
			// add(bgAll);
			// trailAll = new FlxTypedGroup<FlxTrail>();
			// add(trailAll);
			#if FEATURE_LUAMODCHART
			executeStageScript = !PlayStateChangeables.Optimize
				&& PlayState.SONG.useCustomStage
				&& customStage.useStageScript
				&& (Paths.doesTextAssetExist(Paths.lua("stage/" + CoolUtil.toCompatCase(PlayState.SONG.stage) + "/stageScript"))
					|| customStage.forceLuaModchart);
			#end
			#if !cpp
			executeStageScript = false;
			#end

			// for hscript pls
			executeStageHscript = !PlayStateChangeables.Optimize
				&& PlayState.SONG.useCustomStage
				&& customStage.useStageScript
				&& (Paths.doesTextAssetExist(Paths.hscript("stage/" + CoolUtil.toCompatCase(PlayState.SONG.stage) + "/stageScript"))
					|| customStage.forceHscriptModchart);
			trace("forced stage Hscript exist is " + Std.string(customStage.forceHscriptModchart));

			if (!customStage.ignoreMainImages)
				spawnStageImages(customStage);
			if (#if ((windows) && cpp) executeStageScript || #end executeStageHscript)
			{
				// spawnStageScript("stages/" + toCompatCase(SONG.stage) +"/stageScript");
				attemptStageScript = true;
			}

			overrideCamFollowP1 = customStage.overrideCamFollowP1;
			overrideCamFollowP2 = customStage.overrideCamFollowP2;
		}
	}

	// JOELwindows7: offset characters
	public function repositionThingsInStage(whatStage:String)
	{
		trace("use Custom Stage Positioners");
		if (customStage != null)
		{
			PlayState.boyfriend.x += customStage.bfPosition[0];
			PlayState.boyfriend.y += customStage.bfPosition[1];
			PlayState.gf.x += customStage.gfPosition[0];
			PlayState.gf.y += customStage.gfPosition[1];
			PlayState.dad.x += customStage.dadPosition[0];
			PlayState.dad.y += customStage.dadPosition[1];
		}
	}

	// JOELwindows7: prepare Colorable bg
	public function prepareColorableBg(useImage:Bool = false, positionX:Null<Float> = -500, positionY:Null<Float> = -500, ?imagePath:String = '',
			?animated:Bool = false, color:Null<FlxColor> = FlxColor.WHITE, width:Int = 1, height:Int = 1, upscaleX:Int = 1, upscaleY:Int = 1,
			antialiasing:Bool = true, scrollFactorX:Float = .5, scrollFactorY:Float = .5, active:Bool = false, callNow:Bool = true, ?unique:Bool = false)
	{
		colorableGround = useImage ? new FlxSprite(positionX,
			positionY).loadGraphic(Paths.image('jakartaFair/jakartaFairBgColorableRoof'), animated, width, height,
			unique) : new FlxSprite(positionX, positionY).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.LIME);
		colorableGround.setGraphicSize(Std.int(colorableGround.width * upscaleX), Std.int(colorableGround.height * upscaleY));
		colorableGround.updateHitbox();
		colorableGround.antialiasing = antialiasing;
		colorableGround.scrollFactor.set(scrollFactorX, scrollFactorY);
		colorableGround.active = active;
		if (callNow)
			addThe(colorableGround, 'colorableGround');
		// originalColor = colorableGround.color;
		swagColors['colorableGround'] = colorableGround.color;
	}

	// JOELwindows7: randomize the color of the colorableGround
	// also default inHowLong is recommended > 0 (not instant) to prevent Epilepsy
	public function randomizeColoring(justOne:Bool = false, toWhichBg:Int = 0, inHowLong:Float = 0.01)
	{
		var red:Float = FlxG.random.float(0.0, 1.0);
		var green:Float = FlxG.random.float(0.0, 1.0);
		var blue:Float = FlxG.random.float(0.0, 1.0);
		// var color = FlxColor.fromRGBFloat(FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0));
		if (swagBacks['colorableGround'] != null)
		{
			// colorableGround.visible = true;
			// colorableGround.color = FlxColor.fromRGBFloat(FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0));
			// colorableGround.color.redFloat = red;
			// colorableGround.color.greenFloat = green;
			// colorableGround.color.blueFloat = blue;
			swagBacks['colorableGround'].visible = true;
			// swagBacks['colorableGround'].color = FlxColor.fromRGBFloat(red, green, blue);
			// swagBacks['colorableGround'].color.redFloat = red;
			// swagBacks['colorableGround'].color.greenFloat = green;
			// swagBacks['colorableGround'].color.blueFloat = blue;
			// FlxTween.color(swagBacks['colorableGround'], inHowLong, swagBacks['colorableGround'].color,
			// 	FlxColor.fromRGBFloat(FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0)), {
			// 		ease: FlxEase.linear
			// 	});
			FlxTween.color(colorableGround, inHowLong, colorableGround.color,
				FlxColor.fromRGBFloat(FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0)), {
					ease: FlxEase.linear
				});
			// trace("now colorable color is " + colorableGround.color.toHexString());
		}
		if (swagGroup['bgAll'] != null)
			if (justOne)
			{
				swagGroup['bgAll'].members[toWhichBg].visible = true;
				swagGroup['bgAll'].members[toWhichBg].color = FlxColor.fromRGBFloat(FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0),
					FlxG.random.float(0.0, 1.0));
				// swagGroup['bgAll'].members[toWhichBg].color.redFloat = FlxG.random.float(0.0, 1.0);
				// swagGroup['bgAll'].members[toWhichBg].color.greenFloat = FlxG.random.float(0.0, 1.0);
				// swagGroup['bgAll'].members[toWhichBg].color.blueFloat = FlxG.random.float(0.0, 1.0);
				FlxTween.color(swagGroup['bgAll'].members[toWhichBg], inHowLong, swagGroup['bgAll'].members[toWhichBg].color,
					FlxColor.fromRGBFloat(FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0)), {
						ease: FlxEase.linear
					});
				/*
					trace("now bg "
						+ Std.string(swagGroup['bgAll'].members[toWhichBg].ID)
						+ " color is "
						+ swagBacks['colorableGround'].color.toHexString());
				 */
			}
			else
			{
				swagGroup['bgAll'].forEach(function(theBg:FlxSprite)
				{
					if (multiColorable[theBg.ID])
					{
						theBg.visible = true;
						// theBg.color = FlxColor.fromRGBFloat(FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0));
						// theBg.color.redFloat = FlxG.random.float(0.0, 1.0);
						// theBg.color.greenFloat = FlxG.random.float(0.0, 1.0);
						// theBg.color.blueFloat = FlxG.random.float(0.0, 1.0);
						FlxTween.color(theBg, inHowLong, theBg.color,
							FlxColor.fromRGBFloat(FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0), FlxG.random.float(0.0, 1.0)), {
								ease: FlxEase.linear
							});
						// trace("now bg " + Std.string(theBg.ID) + " color is " + theBg.color.toHexString());
					}
				});
			}
	}

	// JOELwindows7: copy above, but this let you choose color
	public function chooseColoringColor(color:FlxColor = FlxColor.WHITE, justOne:Bool = true, toWhichBg:Int = 0, inHowLong:Float = 0.01)
	{
		if (swagBacks['colorableGround'] != null)
		{
			swagBacks['colorableGround'].visible = true;
			// swagBacks['colorableGround'].color = color;
			// swagBacks['colorableGround'].color.redFloat = color.redFloat;
			// swagBacks['colorableGround'].color.greenFloat = color.greenFloat;
			// swagBacks['colorableGround'].color.blueFloat = color.blueFloat;
			// FlxTween.color(swagBacks['colorableGround'], inHowLong, swagBacks['colorableGround'].color, color, {ease: FlxEase.linear});
			FlxTween.color(colorableGround, inHowLong, colorableGround.color, color, {ease: FlxEase.linear});
			// colorableGround.color = color;
			// trace("now colorable color is " + swagBacks['colorableGround'].color.toHexString());
		}
		if (swagGroup['bgAll'] != null)
		{
			if (justOne)
			{
				swagGroup['bgAll'].members[toWhichBg].visible = true;
				// swagGroup['bgAll'].members[toWhichBg].color = color;
				// swagGroup['bgAll'].members[toWhichBg].color.redFloat = color.redFloat;
				// swagGroup['bgAll'].members[toWhichBg].color.greenFloat = color.greenFloat;
				// swagGroup['bgAll'].members[toWhichBg].color.blueFloat = color.blueFloat;
				FlxTween.color(swagGroup['bgAll'].members[toWhichBg], inHowLong, swagGroup['bgAll'].members[toWhichBg].color, color, {ease: FlxEase.linear});
				/*
					trace("now bg "
						+ Std.string(swagGroup['bgAll'].members[toWhichBg].ID)
						+ " color is "
						+ swagBacks['colorableGround'].color.toHexString());
				 */
			}
			else
			{
				swagGroup['bgAll'].forEach(function(theBg:FlxSprite)
				{
					if (multiColorable[theBg.ID])
					{
						theBg.visible = true;
						// theBg.color = color;
						// theBg.color.redFloat = color.redFloat;
						// theBg.color.greenFloat = color.greenFloat;
						// theBg.color.blueFloat = color.blueFloat;
						FlxTween.color(theBg, inHowLong, theBg.color, color, {ease: FlxEase.linear});
						// trace("now bg " + Std.string(theBg.ID) + " color is " + theBg.color.toHexString());
					}
				});
			}
		}
	}

	// JOELwindows7: To hide coloring incase you don't need it anymore
	public function hideColoring(justOne:Bool = false, toWhichBg:Int = 0, inHowLong:Float = 0.01)
	{
		if (swagBacks['colorableGround'] != null)
			if (isChromaScreen)
			{
				// swagBacks['colorableGround'].color = originalColor;
				// swagBacks['colorableGround'].color.redFloat = originalColor.redFloat;
				// swagBacks['colorableGround'].color.greenFloat = originalColor.greenFloat;
				// swagBacks['colorableGround'].color.blueFloat = originalColor.blueFloat;
				// FlxTween.color(swagBacks['colorableGround'], inHowLong, swagBacks['colorableGround'].color, originalColor, {ease: FlxEase.linear});
				FlxTween.color(colorableGround, inHowLong, colorableGround.color, originalColor, {ease: FlxEase.linear});
			}
			else
				swagBacks['colorableGround'].visible = false;
		if (swagGroup['bgAll'] != null)
			if (justOne)
			{
				// swagGroup['bgAll'].members[toWhichBg].color = multiOriginalColor[toWhichBg];
				swagGroup['bgAll'].members[toWhichBg].color.redFloat = multiOriginalColor[toWhichBg].redFloat;
				swagGroup['bgAll'].members[toWhichBg].color.greenFloat = multiOriginalColor[toWhichBg].greenFloat;
				swagGroup['bgAll'].members[toWhichBg].color.blueFloat = multiOriginalColor[toWhichBg].blueFloat;
				FlxTween.color(swagGroup['bgAll'].members[toWhichBg], inHowLong, swagGroup['bgAll'].members[toWhichBg].color, multiOriginalColor[toWhichBg],
					{ease: FlxEase.linear});
				if (multiIsChromaScreen[toWhichBg])
					swagGroup['bgAll'].members[toWhichBg].visible = false;
			}
			else
			{
				var counte:Int = 0;
				swagGroup['bgAll'].forEach(function(theBg:FlxSprite)
				{
					// theBg.color = multiOriginalColor[theBg.ID];
					// theBg.color.redFloat = multiOriginalColor[theBg.ID].redFloat;
					// theBg.color.greenFloat = multiOriginalColor[theBg.ID].greenFloat;
					// theBg.color.blueFloat = multiOriginalColor[theBg.ID].greenFloat;
					// FlxTween.color(theBg, inHowLong, theBg.color, multiOriginalColor[theBg.ID],
					FlxTween.color(theBg, inHowLong, theBg.color, multiOriginalColor[theBg.ID], {ease: FlxEase.linear});
					// FlxTween.color(theBg, inHowLong, theBg.color, multiOriginalColor[counte], {ease: FlxEase.linear});
					if (multiIsChromaScreen[theBg.ID])
						// if (multiIsChromaScreen[counte])
						theBg.visible = false;
					counte++;
				});
			}
	}

	// JOELwindows7: for that additional bellow
	var blackbarsTop:FlxSprite;
	var blackbarsBottom:FlxSprite;
	var blackbarHeight:Int = 100;
	var additionalSubCamera:FlxCamera;

	// JOELwindows7: additional system wide FlxSprites

	/**
	 * Psyched Blammed Lights. Initiate turn off the lights & turn on the rave lights.
	 * With this on, the background & objects darkens then followed with fade to discotic color lamps,
	 * all characters color will change to based on chosen color.
	 * Used for songs like Blammed (Psyched Engine), Stadium Rave Spongebob, 
	 * Carameldansen, finger crazy move TikTok meme, etc.
	 * @param lightsId select color of the rave lamp from 1 to 5. 0 is off & go back to normal, & 6 is random color
	 */
	function additionalCreateFlxSprites()
	{
		// Blammed Light block bekgron background
		addThe(blammedLightsBlack, 'blammedLightsBlack');
		// Psyched Blackbars
		blackbarsTop = new FlxSprite(0, 0);
		blackbarsTop.makeGraphic(FlxG.width, blackbarHeight, 0xFF000000);
		blackbarsTop.alpha = 0;
		blackbarsTop.scrollFactor.set();
		blackbarsBottom = new FlxSprite(0, FlxG.height - blackbarHeight);
		blackbarsBottom.makeGraphic(FlxG.width, blackbarHeight, 0xFF000000);
		blackbarsBottom.alpha = 0;
		blackbarsBottom.scrollFactor.set();
		addThe(blackbarsTop, 'blackbarsTop');
		addThe(blackbarsBottom, 'blackbarsBottom');
		blackbarsTop.visible = false;
		blackbarsBottom.visible = false;
		// disappearBlackBar(0.1); // Now delegate their dormant positions yeah!
		// or maybe just pecking do it?
		blackbarsTop.y = -blackbarHeight;
		blackbarsBottom.y = FlxG.height;
	}

	// JOELwindows7: Psyched appear blackbar
	public function appearBlackBar(forHowLong:Float = 2)
	{
		if (blackbarsTop == null || blackbarsBottom == null)
			return;
		blackbarsTop.visible = true;
		blackbarsBottom.visible = true;
		// blackbarsTop.x = -blackbarHeight;
		// blackbarsBottom.x = FlxG.height;
		FlxTween.color(blackbarsTop, forHowLong, blackbarsTop.color, 0xFF000000, {ease: FlxEase.linear});
		FlxTween.color(blackbarsBottom, forHowLong, blackbarsBottom.color, 0xFF000000, {ease: FlxEase.linear});
		FlxTween.tween(blackbarsTop, {y: 0, alpha: .8}, forHowLong, {ease: FlxEase.linear});
		FlxTween.tween(blackbarsBottom, {y: FlxG.height - blackbarHeight, alpha: .8}, forHowLong, {ease: FlxEase.linear});
	}

	// JOELwindows7: Psyched disappear blackbar
	public function disappearBlackBar(forHowLong:Float = 2)
	{
		if (blackbarsTop == null || blackbarsBottom == null)
			return;
		// blackbarsTop.x = 0;
		// blackbarsBottom.x = FlxG.height - blackbarHeight;
		FlxTween.tween(blackbarsTop, {y: -blackbarHeight, alpha: 0}, forHowLong, {
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				blackbarsTop.visible = false;
			}
		});
		FlxTween.tween(blackbarsBottom, {y: FlxG.height, alpha: 0}, forHowLong, {
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				blackbarsBottom.visible = false;
			}
		});
		FlxTween.color(blackbarsTop, forHowLong, blackbarsTop.color, 0xFF000000, {ease: FlxEase.linear});
		FlxTween.color(blackbarsBottom, forHowLong, blackbarsBottom.color, 0xFF000000, {ease: FlxEase.linear});
	}
}
