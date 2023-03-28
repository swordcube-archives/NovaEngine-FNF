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

        this.parameters = [character, animation];
    }

    override function fire() {
        if(fired) return;
        super.fire();

        var characterToAnimate:Character = switch(character) {
            case OPPONENT: game.dad;
            case SPECTATOR: game.gf;
            case PLAYER: game.boyfriend;
            default: null;
        };

        if(characterToAnimate == null)
            return Logs.trace("Invalid character set to play an animation for! No character will play an animation.", ERROR);

        characterToAnimate.playAnim(animation, true);
        characterToAnimate.specialAnim = true;
    }
}