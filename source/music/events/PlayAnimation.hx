package music.events;

import objects.Character;
import music.events.ChangeCharacter.CharacterType;

class PlayAnimation extends SongEvent {
    public var character:CharacterType;
    public var animation:String;

    public function new(character:CharacterType, animation:String) {
        super("Play Animation");
        this.character = character;
        this.animation = animation;
    }

    override function fire() {
        if(fired) return;
        super.fire();

        var characterToAnimate:Character = switch(character) {
            case DAD, OPPONENT: game.dad;
            case GIRLFRIEND, SPECTATOR, GF: game.gf;
            case BOYFRIEND, PLAYER, BF: game.boyfriend;
            default: null;
        };

        if(characterToAnimate == null)
            return Logs.trace("Invalid character set to play an animation for! No character will play an animation.", ERROR);

        characterToAnimate.playAnim(animation, true);
        characterToAnimate.specialAnim = true;
    }
}