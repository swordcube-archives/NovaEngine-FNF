package funkin.game;

import funkin.system.Conductor;

@:dox(hide) class Judgement {
    public var name:String = "sick";
    public var msTiming:Float = 0;
    public var score:Int = 0;
    public var accuracyGain:Float = 0;
    public var showSplash:Bool = true;

    public function new(name:String, msTiming:Float, score:Int, accuracyGain:Float, showSplash:Bool) {
        this.name = name;
        this.msTiming = msTiming;
        this.score = score;
        this.accuracyGain = accuracyGain;
        this.showSplash = showSplash;
    }
}

@:dox(hide) class Rank {
    public var name:String = "S+";
    public var accuracyRequired:Float = 1;
    public var color:FlxColor = FlxColor.WHITE;

    public function new(name:String, accuracyRequired:Float, color:FlxColor) {
        this.name = name;
        this.accuracyRequired = accuracyRequired;
        this.color = color;
    }
}

class Ranking {
    public static final judgements:Array<Judgement> = [
        new Judgement("sick", 25, 350, 1,   true),
        new Judgement("good", 45, 200, 0.7, false),
        new Judgement("bad",  85, 100, 0.3, false),
        new Judgement("shit", 100, 50, 0,   false),
    ];

    public static final ranks:Array<Rank> = [
        new Rank("S+", 1,   0xFF00CCFF),
        new Rank("S",  0.9, 0xFF00FD69),
        new Rank("A",  0.8, 0xFF33FF00),
        new Rank("B",  0.7, 0xFF9DFF00),
        new Rank("C",  0.6, 0xFFFFEE00),
        new Rank("D",  0.5, 0xFFFFAE00),
        new Rank("E",  0.4, 0xFFFF9900),
        new Rank("F",  0.3, 0xFFFF6600),
        new Rank("L",  0,   0xFFFF0000),
    ];
    public static final unknownRank:Rank = new Rank("N/A", -1, 0xFF888888);

    public static function judgeTime(strumTime:Float) {
        for(judgement in judgements) {
            if(Math.abs(strumTime) <= Conductor.position + judgement.msTiming)
                return judgement;
        }
        return judgements.last();
    }

    public static function getRank(accuracy:Float) {
        for(rank in ranks) {
            if(accuracy >= rank.accuracyRequired)
                return rank.name;
        }
        return unknownRank.name;
    }

    public static function getRankData(accuracy:Float) {
        for(rank in ranks) {
            if(accuracy >= rank.accuracyRequired)
                return rank;
        }
        return unknownRank;
    }
}