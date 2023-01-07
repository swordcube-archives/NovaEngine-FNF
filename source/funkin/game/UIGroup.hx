package funkin.game;

import flixel.group.FlxGroup;

class UIGroup extends FlxGroup {
	/**
	 * CPU/Opponent strums.
	 */
	public var cpuStrums:StrumLine;

	/**
	 * Player strums.
	 */
	public var playerStrums:StrumLine;

	// -------------------------------------------------------------------------------------------- //

	public function new() {
		super();

		var SONG = PlayState.SONG;

		add(cpuStrums = new StrumLine(0, 50, SONG.keyAmount).generateReceptors().positionReceptors(true));
		add(playerStrums = new StrumLine(0, 50, SONG.keyAmount, true).generateReceptors().positionReceptors(false));

        for(receptor in cpuStrums.receptors.members) {
            receptor.animation.finishCallback = function(name:String) {
                if(name == "confirm") receptor.playAnim("static");
            };
        }
	}
}
