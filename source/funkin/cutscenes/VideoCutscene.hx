package funkin.cutscenes;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera;
import openfl.utils.Assets;

class VideoCutscene extends Cutscene {
    var path:String;
    var localPath:String;

    #if VIDEO_CUTSCENES
    var videoSprite:VideoSprite;
    #end
    var cutsceneCamera:FlxCamera;
    
    public function new(path:String, callback:Void->Void) {
        super(callback);
        localPath = Assets.getPath(this.path = path);
    }

    override function create() {
        super.create();
        
        cutsceneCamera = new FlxCamera();
        cutsceneCamera.bgColor = 0;
        FlxG.cameras.add(cutsceneCamera, false);
        
        #if VIDEO_CUTSCENES
        videoSprite = new VideoSprite();
        videoSprite.finishCallback = close;
        videoSprite.cameras = [cutsceneCamera];
        videoSprite.antialiasing = true;
        videoSprite.setGraphicSize(1280, 720);
        videoSprite.updateHitbox();
        add(videoSprite);
        
        videoSprite.playVideo(localPath, false);
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