package funkin.game;

import funkin.system.Conductor;

class Judgement {
    public var name:String = "sick";
    public var msTiming:Float = 0;
    public var score:Int = 0;
    public var accuracyGain:Float = 0;

    public function new(name:String, msTiming:Float, score:Int, accuracyGain:Float) {
        this.name = name;
        this.msTiming = msTiming;
        this.score = score;
        this.accuracyGain = accuracyGain;
    }
}

class Rank {
    public var name:String = "S+";
    public var accuracyRequired:Float = 100;

    public function new(name:String, accuracyRequired:Float) {
        this.name = name;
        this.accuracyRequired = accuracyRequired;
    }
}

class Ranking {
    public static final judgements:Array<Judgement> = [
        new Judgement("sick", 0, 350, 1),
        new Judgement("good", 45, 200, 0.7),
        new Judgement("bad",  85, 100, 0.3),
        new Judgement("shit", 100, 50,  0),
    ];

    public static final ranks:Array<Rank> = [
        new Rank("S+", 1),
        new Rank("S",  0.9),
        new Rank("A",  0.8),
        new Rank("B",  0.7),
        new Rank("C",  0.6),
        new Rank("D",  0.5),
        new Rank("E",  0.4),
        new Rank("F",  0.3),
        new Rank("L",  0),
    ];

    public static function judgeTime(strumTime:Float) {
        for(judgement in judgements) {
            if(strumTime <= Conductor.position + judgement.msTiming)
                return judgement;
        }
        return judgements.last();
    }

    public static function getRank(accuracy:Float) {
        for(rank in ranks) {
            if(accuracy >= rank.accuracyRequired)
                return rank.name;
        }
        return "N/A";
    }
}