package music.events;

import states.PlayState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import objects.ui.StrumLine;

class ChangeScrollSpeed extends SongEvent {
    var speedTweens = [
        null,
        null
    ];

    public var strumLine:String;
    public var mult:Float;
    public var duration:Float;

    public function new(strumLine:String, mult:Float, ?duration:Float = 1) {
        super("Change Scroll Speed");
        this.strumLine = strumLine;
        this.mult = mult;
        this.duration = duration;
    }

    override function fire() {
        if(fired) return;
        super.fire();

        // If you set the scroll speed type to be constant, don't run the event
        if(SettingsAPI.scrollType.toLowerCase() == "constant") return;

        var tweenID:Int = 0;
        var strums:StrumLine;
        switch(strumLine.toLowerCase()) {
            case "opponent": strums = game.cpuStrums; tweenID = 0;
            default: strums = game.playerStrums; tweenID = 1;
        }
    
        // If the strum line is null, don't try to do anything else
        if(strums == null) return;
    
        var newValue:Float = PlayState.SONG.scrollSpeed * SettingsAPI.scrollSpeed * mult;
    
        if(speedTweens[tweenID] != null) speedTweens[tweenID].cancel();
        speedTweens[tweenID] = FlxTween.tween(strums, {noteSpeed: newValue}, duration, {ease: FlxEase.linear, onComplete: (twn:FlxTween) -> {
            speedTweens[tweenID] = null;
        }});
    }
}