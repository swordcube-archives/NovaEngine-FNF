package core.song;

class Judgement {
    public var name:String;
    public var timing:Float;
    public var showSplash:Bool;

    public function new(name:String, timing:Float, showSplash:Bool) {
        this.name = name;
        this.timing = timing;
        this.showSplash = showSplash;
    }
}

class Rank {
    public var name:String;
    public var accuracyRequired:Float;

    public function new(name:String, accuracyRequired:Float) {
        this.name = name;
        this.accuracyRequired = accuracyRequired;
    }
}

class Ranking {
    public static var judgements:Array<Judgement> = [
        new Judgement("sick", 45, true),
        new Judgement("good", 75, false),
        new Judgement("bad",  90, false),
        new Judgement("shit", 135, false)
    ];

    public static var ranks:Array<Rank> = [
        new Rank("S+", 100),
        new Rank("S",  90),
        new Rank("A",  80),
        new Rank("B",  70),
        new Rank("C",  60),
        new Rank("D",  50),
        new Rank("E",  40),
        new Rank("F",  30),
        new Rank("L",  20)
    ];

    public static function judgementFromTime(time:Float):Judgement {
        for(judge in judgements) {
            if(judge.timing >= Math.abs(time))
                return judge;
        }
        return judgements.last();
    }

    public static function rankFromAccuracy(accuracy:Float):Rank {
        for(rank in ranks) {
            if(rank.accuracyRequired >= accuracy)
                return rank;
        }
        return ranks.last();
    }
}