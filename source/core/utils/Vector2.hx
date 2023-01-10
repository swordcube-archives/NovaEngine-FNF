package core.utils;

abstract Vector2(Array<Float>) to Array<Float> from Array<Float> {
    public var x(get, never):Float;
    function get_x():Float {
        return this[0];
    }

    public var y(get, never):Float;
    function get_y():Float {
        return this[1];
    }

    public function new(?x:Float = 0, ?y:Float = 0) {
        this = [x, y];
    }

    public function set(?x:Float = 0, ?y:Float = 0) {
        this[0] = x;
        this[1] = y;
    }

    public function add(?x:Float = 0, ?y:Float = 0) {
        this[0] += x;
        this[1] += y;
    }

    public function subtract(?x:Float = 0, ?y:Float = 0) {
        this[0] -= x;
        this[1] -= y;
    }

    public function reset() {
        this[0] = 0;
        this[1] = 0;
    }
}