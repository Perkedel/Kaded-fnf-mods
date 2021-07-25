package plugins.systems;

class ScanPlatform{

    /**
     * Read what platform are you at
     * @author JOELwindows7
     * @return String the total platform words in this scan
     */
    public static function getPlatform():String{
        var sayTotal:String = "";

        #if debug
        trace("you're debug");
        sayTotal += " debug";
        #end

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

        trace("In total, you're: " + sayTotal);
        return sayTotal;
    }
}