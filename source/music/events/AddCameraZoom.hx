package music.events;

class AddCameraZoom extends SongEvent {
    public var gameAmount:Float;
    public var hudAmount:Float;

    public function new(?gameAmount:Float = 0.015, ?hudAmount:Float = 0.03) {
        super("Add Camera Zoom");
        this.gameAmount = gameAmount;
        this.hudAmount = hudAmount;
    }

    override function fire() {
        if(fired) return;
        super.fire();

        game.camGame.zoom += gameAmount;
        game.camHUD.zoom += hudAmount;
    }
}