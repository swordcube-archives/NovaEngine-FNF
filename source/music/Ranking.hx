package music;

import flixel.util.FlxColor;

class Judgement {
    public var name:String;
    public var score:Int;
    public var timing:Float;
    public var accuracy:Float;
    public var health:Float;
    public var showSplash:Bool;

    public function new(name:String, score:Int, timing:Float, accuracy:Float, health:Float, showSplash:Bool) {
        this.name = name;
        this.score = score;
        this.timing = timing;
        this.accuracy = accuracy;
        this.health = health;
        this.showSplash = showSplash;
    }

    public function clone() {
        return new Judgement(name, score, timing, accuracy, health, showSplash);
    }

    public function toString() {
        return name;
    }
}

class Rank {
    public var name:String;
    public var accuracyRequired:Float;
    public var color:FlxColor;

    public function new(name:String, accuracyRequired:Float, color:FlxColor) {
        this.name = name;
        this.accuracyRequired = accuracyRequired;
        this.color = color;
    }

    public function clone() {
        return new Rank(name, accuracyRequired, color);
    }

    public function toString() {
        return name;
    }
}

class Ranking {
    public static var judgements:Array<Judgement> = [
        new Judgement("sick", 350, 45,  1,   0,      true),
        new Judgement("good", 200, 75,  0.7, 0,      false),
        new Judgement("bad",  100, 90,  0.3, 0,      false),
        new Judgement("shit", 50,  135, 0,   -0.175, false)
    ];
    public static var defaultJudgements:Array<Judgement>;

    public static var ranks:Array<Rank> = [
        new Rank("S+", 100, 0xFF00CCFF),
        new Rank("S",  90,  0xFF00FD69),
        new Rank("A",  80,  0xFF33FF00),
        new Rank("B",  70,  0xFF9DFF00),
        new Rank("C",  60,  0xFFFFEE00),
        new Rank("D",  50,  0xFFFFAE00),
        new Rank("E",  40,  0xFFFF9900),
        new Rank("F",  30,  0xFFFF6600),
        new Rank("L",  0,   0xFFFF0000),
    ];
    public static var defaultRanks:Array<Rank>;

    public static function init() {
        defaultJudgements = [for(i in judgements) i.clone()];
        defaultRanks = [for(i in ranks) i.clone()];
    }

    public static function judgementFromTime(time:Float):Judgement {
        for(judge in judgements) {
            if(judge.timing >= Math.abs(time))
                return judge;
        }
        return judgements.last();
    }

    public static function rankFromAccuracy(accuracy:Float):Rank {
        for(rank in ranks) {
            if(accuracy >= rank.accuracyRequired)
                return rank;
        }
        return ranks.last();
    }
}