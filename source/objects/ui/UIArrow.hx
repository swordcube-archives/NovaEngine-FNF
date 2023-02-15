package objects.ui;

import objects.TrackingSprite;

class UIArrow extends TrackingSprite {
    public var onJustPressed:Void->Void;
    public var onJustReleased:Void->Void;

    public var control:String = "UI_LEFT";

    public function new(x:Float = 0, y:Float = 0, right:Bool = false) {
        super(x, y);
        loadAtlas(Paths.getSparrowAtlas("UI/base/storymenu/storyUI"));
        addAnim("idle", "arrow "+(right ? "right" : "left"));
        addAnim("press", "arrow push "+(right ? "right" : "left"));
        playAnim("idle");

        onJustPressed = () -> {
            playAnim("press");
        };
        onJustReleased = () -> {
            playAnim("idle");
        };
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var controls = SettingsAPI.controls;
        
        var getFunc = Reflect.field(controls, "get_"+control+"_P");
        if(Reflect.field(controls, control+"_P") || (getFunc != null ? getFunc() : null)) onJustPressed();

        var getFunc = Reflect.field(controls, "get_"+control+"_R");
        if(Reflect.field(controls, control+"_R") || (getFunc != null ? getFunc() : null)) onJustReleased();
    }
}