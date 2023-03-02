package music;

import music.events.ChangeCharacter.CharacterType;
import music.events.*;
import music.SongFormat;
import flixel.FlxBasic;
import music.events.SongEvent;

class EventList {
    public var time:Float;
    public var events:Array<SongEvent>;

    public function new(time:Float, events:Array<SongEvent>) {
        this.time = time;
        this.events = events;
    }

    public function fire() {
        if(events.length < 1) return;

        for(event in events)
            event.fire();
    }
}

class EventManager extends FlxBasic {
    public var groups:Array<EventList> = [];

    public static inline function generateList(rawEventGroup:EventGroup) {
        return [for(e in rawEventGroup.events) convert(e)];
    }

    /**
     * Converts raw event data from `PlayState.SONG` to a usable event
     * that gets executed during gameplay.
     */
    public static inline function convert(rawEvent:EventData) {
        var event:SongEvent = switch(rawEvent.name) {
            // Built-in engine events
            case "Add Camera Zoom":
                var zoom1:Float = Std.parseFloat(rawEvent.parameters[0]);
                if(Math.isNaN(zoom1)) zoom1 = 0.015;

                var zoom2:Float = Std.parseFloat(rawEvent.parameters[1]);
                if(Math.isNaN(zoom2)) zoom2 = 0.03;

                new AddCameraZoom(zoom1, zoom2);
            case "Change Character":    new ChangeCharacter(charFromString(rawEvent.parameters[0]), rawEvent.parameters[1]);
            case "Change Scroll Speed": new ChangeScrollSpeed(rawEvent.parameters[0], Std.parseFloat(rawEvent.parameters[1]), Std.parseFloat(rawEvent.parameters[2]));
            case "Set GF Speed":        new SetGFSpeed(Std.parseInt(rawEvent.parameters[0]));
            case "Hey!", "Hey":         
                var time:Float = Std.parseFloat(rawEvent.parameters[1]);
                if(Math.isNaN(time)) time = 0.6;

                new HeyEvent(charFromString(rawEvent.parameters[0]), time);
            case "Play Animation":      new PlayAnimation(charFromString(rawEvent.parameters[0]), rawEvent.parameters[1]);
            case "Screen Shake":        new ScreenShake(rawEvent.parameters[0], Std.parseFloat(rawEvent.parameters[1]), Std.parseFloat(rawEvent.parameters[2]));

            // Custom scripted events
            default:                    new CustomEvent(rawEvent.name, rawEvent.parameters);
        }
        return event;
    }

    public static inline function charFromString(string:String):CharacterType {
        return switch(string) {
            case "1", "gf", "girlfriend", "spectator": SPECTATOR;
            case "2", "bf", "boyfriend", "player": PLAYER;
            default: OPPONENT;
        }
    }

    public function add(time:Float, events:Array<SongEvent>) {
        var list = new EventList(time, []);
        for(event in events) event.group = list;
        list.events = events;

        groups.push(list);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(groups.length > 0 && groups[0] != null) {
            while(groups[0] != null && groups[0].time <= Conductor.songPosition)
                groups.shift().fire();
        }
    }

    override function destroy() {
        groups = null;
        super.destroy();
    }
}