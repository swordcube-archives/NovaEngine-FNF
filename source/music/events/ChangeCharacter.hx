package music.events;

import flixel.util.typeLimit.OneOfTwo;
import states.PlayState;

enum abstract CharacterType(Int) to Int from Int {
    var DAD = 0;
    var OPPONENT = 1;
    var GIRLFRIEND = 2;
    var GF = 3;
    var SPECTATOR = 4;
    var PLAYER = 5;
    var BOYFRIEND = 6;
    var BF = 7;
}

class ChangeCharacter extends SongEvent {
    public var toModify:OneOfTwo<CharacterType, String>;
    public var characterName:String;

    public function new(toModify:OneOfTwo<CharacterType, String>, characterName:String) {
        super("Change Character");
        this.toModify = toModify;
        this.characterName = characterName;
    }

    override function fire() {
        if(fired) return;
        super.fire();

        if(toModify is String) toModify = cast(toModify, String).toLowerCase();

        switch(toModify) {
            case "dad", "opponent", CharacterType.DAD, CharacterType.OPPONENT:
                if(game.dad != null)
                    game.dad.loadCharacter(characterName);

                game.iconP2.loadIcon((game.dad != null) ? game.dad.healthIcon : PlayState.SONG.opponent);
                game.positionIcons();

            case "gf", "girlfriend", "spectator", CharacterType.GIRLFRIEND, CharacterType.SPECTATOR, CharacterType.GF:
                game.gf.loadCharacter(characterName);

            case "bf", "boyfriend", "player", CharacterType.BOYFRIEND, CharacterType.PLAYER, CharacterType.BF:
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