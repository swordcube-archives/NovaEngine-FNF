package funkin.interfaces;

interface IBeatReciever {
    public function beatHit(beat:Int):Void;
    public function stepHit(step:Int):Void;
    public function sectionHit(step:Int):Void;
}