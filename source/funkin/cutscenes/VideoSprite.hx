package funkin.cutscenes;

#if VIDEO_CUTSCENES
/**
 * Allows you to play a video on an FlxSprite.
 */
class VideoSprite extends FlxSprite {
    public var bitmap:VideoHandler;

    /**
     * The function that runs when the video finishes playing.
     */
    public var finishCallback(default, set):Void->Void;
    function set_finishCallback(value:Void->Void) {
        finishCallback = value;
        if(bitmap != null) bitmap.finishCallback = value;
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
        if(bitmap != null) bitmap.canvasWidth = value;
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
        if(bitmap != null) bitmap.canvasHeight = value;
        return value;
    }

    public function new(?x:Float = 0, ?y:Float = 0, ?width:Null<Int> = null, ?height:Null<Int> = null) {
        super(x, y);

        if(width == null) width = FlxG.width;
        if(height == null) height = FlxG.height;

        bitmap = new VideoHandler();
        bitmap.finishCallback = finishCallback;
        bitmap.canvasWidth = width;
        bitmap.canvasHeight = height;
    }

    public function play(path:String, ?loop:Bool = false) {
        bitmap.play(path, loop, this);
    }
}
#end