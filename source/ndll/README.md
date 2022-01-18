# WebmHelper ndll

- Since this code is pretty scuffed due to the usage of outdated library, i decided to give it a lil boost by doing some c++ magic.
<br>
- This ndll provides an exposed function that return the frames count of webm file on the disk, utilizing libav.

---

### Usage

- Defined like this:
```haxe
static private var nativeFramecount:String->Int = cpp.Lib.load("webmHelper", "GetFramecount", 1);
```

- Called like this:
```haxe
nativeFramecount(/* Full path to webm file including the .webm */);
```
---

### Building


- Clone vcpkg by doing `git clone https://github.com/Microsoft/vcpkg.git` somewhere on your disk.

- Run `bootstrap-vcpkg.bat`.

- Hold shift and right click in a blank space in the vcpkg folder -> Open powershell here -> paste this `vcpkg integrate install`

- Then `vcpkg install ffmpeg:x64-windows` (change to x32 if you plan building on x32 mode)

- No errors? cool, open webmHelper.vcxproj, set platform to release x64/x32 and build it.

- If everything went smoothly, go to bin folder and you should see something like this ![binImage](https://i.imgur.com/pJnCM3k.png)
Copy those bad boys and paste them in your game root dir (next to the exe file)
**We only need file with dll at the end**

> I am relatively new to haxe (been using it for a week lol) so I am not sure how to make this work as an actual extension, Copy dlls automatically or whatever