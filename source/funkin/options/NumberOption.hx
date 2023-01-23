package funkin.options;

class NumberOption extends OptionTemplate {
    public var onChange:Float->Void;

    public var minimum:Float;
    public var maximum:Float;
    public var increment:Float;
    public var decimals:Int;

    public function new(name:String, description:String, option:Null<String>, minimum:Float, maximum:Float, increment:Float, ?decimals:Int = 0, ?onChange:Float->Void) {
        super(name, description, option);
        this.minimum = minimum;
        this.maximum = maximum;
        this.increment = increment;
        this.decimals = decimals;
        this.onChange = onChange;
    }
}