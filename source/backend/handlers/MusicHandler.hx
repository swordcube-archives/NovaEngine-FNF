package backend.handlers;

interface MusicHandler {
    public function beatHit(value:Int):Void;
    public function stepHit(value:Int):Void;
    public function measureHit(value:Int):Void;
}