package funkin.cutscenes;

/**
 * A class to help you play videos easier.
 */
 class VideoHelper {
    #if (VIDEO_CUTSCENES || docs)
    /**
     * Plays a video at the path of `path`.
     * 
     * Runs `finishCallback` when finished.
     * 
     * @param path The path of the video to play.
     * @param finishCallback The callback that runs when the video finishes.
     * @return VideoHandler
     */
    #else
    /**
     * Runs `finishCallback` when ran.
     * 
     * If you're seeing this, you're coding video support
     * for an unsupported platform!
     * 
     * Thankfully i have handled the problem for you
     * and just run `finishCallback` immediately.
     * The first argument is null so you gotta handle that yourself!!
     */
    #end
    public static function play(path:String, ?finishCallback:#if VIDEO_CUTSCENES VideoHandler #else Dynamic #end->Void):#if VIDEO_CUTSCENES VideoHandler #else Dynamic #end {
        #if VIDEO_CUTSCENES
        var video:VideoHandler = new VideoHandler();
        video.finishCallback = function() {
            if(finishCallback != null)
                finishCallback(video);
        };
        video.playVideo(Paths.video(path));
        return video;
        #else
        Console.error("Video playback isn't supported on this platform!");
        if(finishCallback != null)
            finishCallback(null);
        return null;
        #end
    }

    #if (VIDEO_CUTSCENES || docs)
    /**
     * Plays a video at the path of `path`.
     * 
     * Runs `finishCallback` when finished and returns a `VideoSprite` (FlxSprite that plays a video).
     * 
     * @param path The path of the video to play.
     * @param finishCallback The callback that runs when the video finishes.
     * @return VideoSprite
     */
    #else
    /**
     * Runs `finishCallback` when ran.
     * 
     * If you're seeing this, you're coding video support
     * for an unsupported platform!
     * 
     * Thankfully i have handled the problem for you
     * and just run `finishCallback` immediately.
     * The first argument is null so you gotta handle that yourself!!
     */
    #end
    public static function playOnSprite(path:String, ?finishCallback:#if VIDEO_CUTSCENES VideoSprite #else Dynamic #end->Void):#if VIDEO_CUTSCENES VideoSprite #else Dynamic #end {
        #if VIDEO_CUTSCENES
        var video:VideoSprite = new VideoSprite();
        video.finishCallback = function() {
            if(finishCallback != null)
                finishCallback(video);
        };
        video.playVideo(Paths.video(path));
        return video;
        #else
        Console.error("Video playback isn't supported on this platform!");
        if(finishCallback != null)
            finishCallback(null);
        return null;
        #end
    }
}