import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup;

/**
 * Credit Fades in out for seasonal series e.g.
 * @author JOELwindows7
 */
class CreditRollout extends FlxTypedGroup<FlxText>{
    public var textTitle:FlxText;
    public var textName:FlxText;
    public var textRole:FlxText;
    var linesOfThem:Array<String>; //lines of the credit roll
    var indexening:Int = 0;
    var currentLineSet:Array<String>; //each line has 3 strings here
    var interval:Float = 3;
    var started:Bool = false;
    var runsOnce:Bool = false;

    public function new(){
        super();
    }

    public function build(){
        textTitle = new FlxText(100, FlxG.height-150, 0, "Title", 24);
        textTitle.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        textTitle.scrollFactor.set();
        textTitle.alpha = 0;

        textName = new FlxText(100, FlxG.height-125, 0, "Lorem Ipsum", 48);
        textName.setFormat(Paths.font("vcr.ttf"), 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        textName.scrollFactor.set();
        textName.alpha = 0;

        textRole = new FlxText(100, FlxG.height-75, 0, "Dolor sit", 18);
        textRole.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        textRole.scrollFactor.set();
        textRole.alpha = 0;

        add(textTitle);
        add(textName);
        add(textRole);
    }

    public function loadCreditData(path,?onceRun:Bool = false){
        runsOnce = onceRun;
        indexening = 0;
        try{
            linesOfThem = CoolUtil.coolTextFile(path);
        } catch(e){
            FlxG.log.error("Could not load Cool credit text " + path);
            FlxG.log.error(e);
            linesOfThem = ["Error:404:Credit Text file not found",
                "Error:Check Path:" + path,
                "Error:Message:" + e
        ];
        }
        currentLineSet = linesOfThem[indexening].split(":");

        updateTexts();
        //fadeInAgainPls();
    }

    public function startRolling(){
        started = true;
        fadeInAgainPls();
        new FlxTimer().start(interval, function(tmr:FlxTimer){
            fadeToOther();
        }, 0);
    }

    public function stopRolling(){
        started = false;
    }

    public function fadeToOther(isPrevious:Bool = true, duration:Float = .5){
        FlxTween.tween(textTitle, {alpha: 0},duration,{
            ease: FlxEase.quadInOut,
            onComplete: function(twn:FlxTween)
            {
                
            }
        });

        FlxTween.tween(textName, {alpha: 0},duration,{
            ease: FlxEase.quadInOut,
            onComplete: function(twn:FlxTween)
            {
                
            }
        });

        FlxTween.tween(textRole, {alpha: 0},duration,{
            ease: FlxEase.quadInOut,
            onComplete: function(twn:FlxTween)
            {
                
            }
        });

        if(started)
            new FlxTimer().start(duration, function(twn:FlxTimer){
                changeLine(indexening+1);
                fadeInAgainPls(duration);
            });
    }

    function fadeInAgainPls(duration:Float = 0.5){
        if(started)
        {
            FlxTween.tween(textTitle, {alpha: 1},duration,{
                ease: FlxEase.quadInOut,
                onComplete: function(twn:FlxTween)
                {
                    
                }
            });

            FlxTween.tween(textName, {alpha: 1},duration,{
                ease: FlxEase.quadInOut,
                onComplete: function(twn:FlxTween)
                {
                    
                }
            });

            FlxTween.tween(textRole, {alpha: 1},duration,{
                ease: FlxEase.quadInOut,
                onComplete: function(twn:FlxTween)
                {
                    
                }
            });
        }
    }

    public function changeLine(which:Int = 0){
        indexening = which;
        if(indexening > linesOfThem.length-1){
            indexening = 0;
            if(runsOnce) stopRolling();
        }
        if(indexening < 0) indexening = linesOfThem.length-1;
        currentLineSet = linesOfThem[indexening].split(":");

        updateTexts();
    }

    function updateTexts(){
        if(textTitle != null) textTitle.text = currentLineSet[0];
        if(textName != null) textName.text = currentLineSet[1];
        if(textRole != null) textRole.text = currentLineSet[2];
    }

    // override function create(){
        
    //     super.create();
    // }
}