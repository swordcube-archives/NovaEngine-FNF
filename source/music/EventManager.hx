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
            case "Add Camera Zoom":     new AddCameraZoom(Std.parseFloat(rawEvent.parameters[0]), Std.parseFloat(rawEvent.parameters[1]));
            case "Change Character":    new ChangeCharacter(charFromString(rawEvent.parameters[0]), rawEvent.parameters[1]);
            case "Change Scroll Speed": new ChangeScrollSpeed(rawEvent.parameters[0], Std.parseFloat(rawEvent.parameters[1]), Std.parseFloat(rawEvent.parameters[2]));
            case "Set GF Speed":        new SetGFSpeed(Std.parseInt(rawEvent.parameters[0]));
            case "Hey!", "Hey":         new HeyEvent(charFromString(rawEvent.parameters[0]), Std.parseFloat(rawEvent.parameters[1]));
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