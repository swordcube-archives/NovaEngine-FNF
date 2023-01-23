package funkin.options;

class BoolOption extends OptionTemplate {
    public var onChange:Bool->Void;

    public function new(name:String, description:String, option:Null<String>, ?onChange:Bool->Void) {
        super(name, description, option);
        this.onChange = onChange;
    }
}