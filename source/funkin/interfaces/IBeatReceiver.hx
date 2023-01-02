package funkin.interfaces;

interface IBeatReceiver {
    public function beatHit(beat:Int):Void;
    public function stepHit(step:Int):Void;
    public function sectionHit(section:Int):Void;
}