package states.menus.options.visual;

/**
 * This is an option that runs a custom function when any of your `ACCEPT` binds
 * are pressed on it.
 */
class Custom extends Option {
    public var callback:Void->Void;

    public function new(text:String, callback:Void->Void) {
        super(text);
        this.callback = callback;
    }

    override function select() {
        if(callback != null)
            callback();
    }
}