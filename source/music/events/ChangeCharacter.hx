package music.events;

import flixel.util.typeLimit.OneOfTwo;
import states.PlayState;

enum abstract CharacterType(Int) to Int from Int {
    var OPPONENT = 0;
    var SPECTATOR = 1;
    var PLAYER = 2;
}

class ChangeCharacter extends SongEvent {
    public var toModify:CharacterType;
    public var characterName:String;

    public function new(toModify:CharacterType, characterName:String) {
        super("Change Character");
        this.toModify = toModify;
        this.characterName = characterName;

        this.parameters = [toModify, characterName];
    }

    override function fire() {
        if(fired) return;
        super.fire();

        switch(toModify) {
            case CharacterType.OPPONENT:
                if(game.dad != null)
                    game.dad.loadCharacter(characterName);

                game.iconP2.loadIcon((game.dad != null) ? game.dad.healthIcon : PlayState.SONG.opponent);
                game.positionIcons();

            case CharacterType.SPECTATOR:
                if(game.gf != null)
                    game.gf.loadCharacter(characterName);

            case CharacterType.PLAYER:
                if(game.boyfriend != null)
                    game.boyfriend.loadCharacter(characterName);
                
                game.iconP1.loadIcon((game.boyfriend != null) ? game.boyfriend.healthIcon : PlayState.SONG.player);
                game.positionIcons();

            default:
                Logs.trace("Invalid character set to modify! No character will be changed.", ERROR);
        }

        var healthBarColors = [
			(game.dad != null && game.dad.healthBarColor != null) ? game.dad.healthBarColor : 0xFFFF0000,
			(game.boyfriend != null && game.boyfriend.healthBarColor != null) ? game.boyfriend.healthBarColor : 0xFF66FF33
		];
		game.healthBar.createFilledBar(healthBarColors[0], healthBarColors[1]);
        game.healthBar.updateBar();
        game.updateCamera();
    }
}