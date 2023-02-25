#if !macro
import flixel.FlxG;
import flixel.FlxSprite;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import haxe.Json;
import flixel.addons.transition.FlxTransitionableState;

import backend.*;
import backend.dependency.*;
import backend.utilities.*;
import backend.handlers.*;
import backend.song.*;

using backend.utilities.CoolUtil;
#end

using StringTools;