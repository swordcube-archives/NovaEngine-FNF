package game;

import states.PanicState;
import haxe.CallStack;
import haxe.Exception;
import openfl.events.Event;
import flixel.FlxGame;

/**
 * An extension of `FlxGame` that takes you to a crash handler
 * state when a crash would normally happen.
 * 
 * @see https://github.com/BeastlyGabi/FNF-Feather/blob/master/Psych/0001-in-game-crash-handler.patch
 */
class FNFGame extends FlxGame {
    override function create(_:Event) {
        try {
            super.create(_);
        } catch(e:Exception) {
            return onCrash(e);
        }
    }

    override function update() {
        try {
            super.update();
        } catch(e:Exception) {
            return onCrash(e);
        }
    }

    override function draw() {
        try {
            super.draw();
        } catch(e:Exception) {
            return onCrash(e);
        }
    }

    override function onEnterFrame(_:Event) {
        try {
            super.onEnterFrame(_);
        } catch(e:Exception) {
            return onCrash(e);
        }
    }

    override function onFocus(_:Event) {
        try {
            super.onFocus(_);
        } catch(e:Exception) {
            return onCrash(e);
        }
    }

    override function onFocusLost(event:flash.events.Event) {
        try {
            super.onFocusLost(event);
        } catch(e:Exception) {
            return onCrash(e);
        }
    }

    override function onResize(_:Event) {
        try {
            super.onResize(_);
        } catch(e:Exception) {
            return onCrash(e);
        }
    }

    private function onCrash<T:Exception>(e:T) {
        var errorStack:Array<StackItem> = CallStack.exceptionStack(true);

		var fileStack:String = '';
		var controlsText:String = '';
		controlsText += '\nConsider taking a screenshot of this error and reporting it\n';
		controlsText += '\nPress SPACE to go to our GitHub Page\n';
		controlsText += '\nPress ESCAPE to restart the game\n';

        Logs.trace("Error occured: "+e.toString(), ERROR);
		for (item in errorStack) {
			switch (item) {
				case FilePos(s, file, line, column):
					fileStack += '${file} (line ${line})\n';
                    Sys.println('${file} (line ${line})');
				default:
					#if sys
					Sys.println(item);
					#end
			}
		}
        Logs.trace("If the crash handler screen does not show up, Restart your game.", ERROR);

        // we need to switch instantly
        // otherwise we won't go to the state sometimes
        FlxTransitionableState.skipNextTransIn = true;
        FlxTransitionableState.skipNextTransOut = true;
        
        return FlxG.switchState(Type.createInstance(PanicState, [
            '${fileStack}\nCaught: ${e}\n
			${controlsText}'
        ]));
    }
}