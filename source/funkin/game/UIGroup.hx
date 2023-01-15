package funkin.game;

import flixel.text.FlxText;
import funkin.system.Conductor;
import flixel.math.FlxMath;
import funkin.ui.HealthIcon;
import flixel.ui.FlxBar;
import funkin.system.FNFSprite;
import flixel.group.FlxGroup;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
import flixel.text.FlxText.FlxTextFormat;

class UIGroup extends FlxGroup {
	/**
	 * CPU/Opponent strums.
	 */
	public var cpuStrums:StrumLine;

	/**
	 * Player strums.
	 */
	public var playerStrums:StrumLine;

	/**
	 * The background of the health bar.
	 */
	public var healthBarBG:FNFSprite;

	/**
	 * The health bar.
	 */
	public var healthBar:FlxBar;

	/**
	 * The opponent's icon.
	 */
	public var iconP2:HealthIcon;

	/**
	 * The player's icon.
	 */
	public var iconP1:HealthIcon;

	/**
	 * The text used to display stuff like score, misses, accuracy, and more if you want!
	 */
	public var scoreTxt:FlxText;

	/**
	 * Format for your current rank.
	 */
	public var rankFormat = new FlxTextFormatMarkerPair(new FlxTextFormat(0xFF888888, false), "<rank>");

	// -------------------------------------------------------------------------------------------- //

	public function new() {
		super();

		var SONG = PlayState.SONG;
		var game = PlayState.current;

		add(cpuStrums = new StrumLine(0, 50, SONG.keyAmount).generateReceptors().positionReceptors(true));
		add(playerStrums = new StrumLine(0, 50, SONG.keyAmount, true).generateReceptors().positionReceptors(false));

        for(receptor in cpuStrums.receptors.members) {
            receptor.animation.finishCallback = function(name:String) {
                if(name == "confirm") receptor.playAnim("static");
            };
        }

		healthBarBG = new FNFSprite(0, FlxG.height * 0.875).load(IMAGE, Paths.image("game/healthBar"));
		healthBarBG.screenCenter(X);
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8),
			game, 'health', game.minHealth, game.maxHealth);
		healthBar.createFilledBar(
			game.dad != null ? game.dad.healthBarColor : 0xFFFF0000, 
			game.bf != null ? game.bf.healthBarColor : 0xFF66FF33
		);
		add(healthBar);

		add(iconP1 = new HealthIcon(0, healthBar.y, game.bf != null ? game.bf.healthIcon : "face"));
		add(iconP2 = new HealthIcon(0, healthBar.y, game.dad != null ? game.dad.healthIcon : "face"));

		var fart:Float = healthBar.height + 30;
		if(PlayState.current.downscroll) fart *= -1;

		scoreTxt = new FlxText(0, healthBar.y + fart, 0, "nuts");
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		scoreTxt.borderSize = 1.25;
		scoreTxt.text = getScoreText(PlayState.current, Ranking.unknownRank);
		scoreTxt.applyMarkup(scoreTxt.text, [rankFormat]);
		add(scoreTxt);

		for(icon in [iconP2, iconP1]) icon.y -= icon.height * 0.5;
		iconP1.flipX = true;

		Conductor.onBeat.add(beatHit);

		positionIcons();
	}

	function beatHit(beat:Int) {
		for(icon in [iconP2, iconP1]) {
			icon.scale.add(0.2, 0.2);
			icon.updateHitbox();
		}
		positionIcons();
	}

	function getScoreText(game:PlayState, rank:Ranking.Rank) {
		return (
			"Score:"+game.songScore+" • "+
			"Misses:"+game.songMisses+" • "+
			"Accuracy:"+(game.songAccuracy > 0 ? FlxMath.roundDecimal(game.songAccuracy * 100, 2) : 0)+"% [<rank>"+rank.name+"<rank>]"
		);
	}

	override function update(elapsed:Float) {
		var game = PlayState.current;
		var rank = game.songAccuracy > -1 ? Ranking.getRankData(game.songAccuracy) : Ranking.unknownRank;

		scoreTxt.text = getScoreText(game, rank);
		@:privateAccess rankFormat.format.format.color = rank.color;
		scoreTxt.applyMarkup(scoreTxt.text, [rankFormat]);
		scoreTxt.screenCenter(X);

		super.update(elapsed);

		var iconLerp:Float = 0.25;

		for(icon in [iconP2, iconP1]) {
			icon.scale.set(MathUtil.fixedLerp(icon.scale.x, 1, iconLerp), MathUtil.fixedLerp(icon.scale.y, 1, iconLerp));
			icon.updateHitbox();
		}
		positionIcons();
	}

	override function draw() {
		for(icon in [iconP2, iconP1])
			if(PlayState.current.downscroll) icon.offset.y *= -1;
		super.draw();
		for(icon in [iconP2, iconP1])
			if(PlayState.current.downscroll) icon.offset.y *= -1;
	}

	public function positionIcons() {
		var iconOffset:Int = 26;
		iconP1.health = healthBar.percent / 100;
		iconP2.health = 1 - (healthBar.percent / 100);

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
	}
}
