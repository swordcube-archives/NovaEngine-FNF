package game.cutscenes;

/**
 * Allows you to play a video on an FlxSprite.
 */
class VideoSprite extends FlxSprite {
    #if VIDEO_CUTSCENES
    public var bitmap:VideoHandler;
    #end

    /**
     * The function that runs when the video finishes playing.
     */
    public var finishCallback(default, set):Void->Void;
    function set_finishCallback(value:Void->Void) {
        finishCallback = value;
        #if VIDEO_CUTSCENES
        if(bitmap != null) bitmap.finishCallback = value;
        #end
        return value;
    }

    /**
     * The width that this sprite should be at.
     * 
     * Using the standard `width` property will not work.
     */
    public var videoWidth(default, set):Int;
    function set_videoWidth(value:Int):Int {
        videoWidth = value;
        #if VIDEO_CUTSCENES
        if(bitmap != null) bitmap.canvasWidth = value;
        #end
        return value;
    }

    /**
     * The height that this sprite should be at.
     * 
     * Using the standard `height` property will not work.
     */
    public var videoHeight(default, set):Int;
    function set_videoHeight(value:Int):Int {
        videoHeight = value;
        #if VIDEO_CUTSCENES
        if(bitmap != null) bitmap.canvasHeight = value;
        #end
        return value;
    }

    public function new(?x:Float = 0, ?y:Float = 0, ?width:Null<Int> = null, ?height:Null<Int> = null) {
        super(x, y);

        if(width == null) width = FlxG.width;
        if(height == null) height = FlxG.height;

        #if VIDEO_CUTSCENES
        bitmap = new VideoHandler();
        bitmap.finishCallback = finishCallback;
        bitmap.canvasWidth = width;
        bitmap.canvasHeight = height;
        #end
    }

    /**
     * Plays a video from a specified path.
     * @param path The path to the video.
     * @param loop Whether or not the video should loop.
     */
    public function play(path:String, ?loop:Bool = false) {
        #if VIDEO_CUTSCENES
        bitmap.play(path, loop, this);
        #end
        return this;
    }
}