package music.events;

class SetGFSpeed extends SongEvent {
    public var speed:Int;

    public function new(speed:Int) {
        super("Set GF Speed");
        this.speed = speed;

        this.parameters = [speed];
    }

    override function fire() {
        if(fired) return;
        super.fire();

        game.gfSpeed = speed;
    }
}