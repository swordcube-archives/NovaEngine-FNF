package music.events;

import objects.Character;
import music.events.ChangeCharacter.CharacterType;

class HeyEvent extends SongEvent {
    public var character:CharacterType;
    public var animTimer:Float;

    public function new(character:CharacterType, ?animTimer:Float = 0.6) {
        super("Hey!");
        this.character = character;
        this.animTimer = animTimer;
    }

    override function fire() {
        if(fired) return;
        super.fire();

        var heyCharacter:Character = switch(character) {
            case DAD, OPPONENT: game.dad;
            case GIRLFRIEND, SPECTATOR, GF: game.gf;
            case BOYFRIEND, PLAYER, BF: game.boyfriend;
            default: null;
        };

        if(heyCharacter == null)
            return Logs.trace("Invalid character set to play a Hey/Cheer animation for! No character will play an animation.", ERROR);

        heyCharacter.playAnim(heyCharacter.animation.exists("hey") ? "hey" : "cheer", true);
        heyCharacter.specialAnim = true;
        heyCharacter.animTimer = animTimer;
    }
}