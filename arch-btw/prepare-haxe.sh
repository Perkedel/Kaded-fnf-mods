#!/bin/bash

# JOELwindows7: prepare haxe stuffs
# copy from GitHub runner script!

# first install Haxe.
# sudo pacman -S haxe # already a dependency

# then setup things
mkdir -p ~/haxe/lib
haxelib setup ~/haxe/lib

# now get all libraries needed
haxe -version
echo "new Psych's found-way of auto install all libraries"
echo 'https://github.com/ShadowMario/FNF-PsychEngine/blob/main/hmm.json'
haxelib install hmm
haxelib run hmm install
echo 'you should have all done.'

# additionally try to rebuild everything
haxe -version
# haxelib update --always
haxelib run lime setup flixel -y
haxelib run lime setup -y
haxelib run lime rebuild extension-webm linux
haxelib run lime rebuild systools linux
haxelib run lime rebuild yagp linux
haxelib list

# Don't forget the placeholder API key files
# wget https://gist.github.com/JOELwindows7/ba79db473ab5e4765293fb19c62240cb/raw/d5fc74359ec9ae272003c5d715d04b4dbbd7810d/GJkeys.hx
# mv ./GJkeys.hx ./source/GJKeys.hx