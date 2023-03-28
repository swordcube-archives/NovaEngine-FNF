package music.events;

import flixel.FlxCamera;

class ScreenShake extends SongEvent {
    public var camera:String;
    public var intensity:Float;
    public var duration:Float;

    public function new(camera:String, intensity:Float, ?duration:Float = 1) {
        super("Screen Shake");
        this.camera = camera;
        this.intensity = intensity;
        this.duration = duration;

        this.parameters = [camera, intensity, duration];
    }

    override function fire() {
        if(fired) return;
        super.fire();

        var cameraObj:FlxCamera = null;
        switch(camera.toLowerCase()) {
            case "hud": cameraObj = game.camHUD;
            case "other": cameraObj = game.camOther;
            default: cameraObj = game.camGame;
        }
    
        // If the camera is null, don't try to do anything else
        if(cameraObj == null) return;
    
        cameraObj.shake(intensity, duration);
    }
}