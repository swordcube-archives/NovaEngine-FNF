#if !macro
import flixel.FlxG;
#if MOD_SUPPORT
import polymod.Polymod;
#end
import funkin.system.DiscordRPC;
import funkin.system.Paths;
import funkin.system.Console;
import funkin.system.CoolUtil;
import funkin.system.MathUtil;
import flixel.util.FlxColor;
import openfl.utils.Assets as OpenFLAssets;
import lime.utils.Assets as LimeAssets;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import funkin.system.Preferences;
using funkin.system.CoolUtil; 
#end

import tjson.TJSON as Json;