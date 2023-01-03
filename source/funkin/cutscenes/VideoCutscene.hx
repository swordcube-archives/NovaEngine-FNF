package funkin.cutscenes;

import flixel.FlxCamera;

class VideoCutscene extends Cutscene {
    var path:String;

    #if VIDEO_CUTSCENES
    var video:VideoSprite;
    #end
    var cutsceneCamera:FlxCamera;

    public function new(path:String, callback:Void->Void) {
        super(callback);
        this.path = path;
    }

    override function create() {
        super.create();
        
        cutsceneCamera = new FlxCamera();
        cutsceneCamera.bgColor = 0;
        FlxG.cameras.add(cutsceneCamera, false);
        
        #if VIDEO_CUTSCENES
        video = new VideoSprite();
        video.finishCallback = close;
        video.playVideo(Assets.getPath(path));
        video.cameras = [cutsceneCamera];
        add(video);
        #end

        cameras = [cutsceneCamera];
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        #if !VIDEO_CUTSCENES
        close();
        #end
    }
    override function destroy() {
        FlxG.cameras.remove(cutsceneCamera, true);
        super.destroy();
    }
}