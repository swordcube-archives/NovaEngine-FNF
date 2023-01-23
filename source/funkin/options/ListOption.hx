package funkin.options;

class ListOption extends OptionTemplate {
    public var onChange:String->Void;

    public var values:Array<String>;

    public function new(name:String, description:String, option:Null<String>, values:Array<String>, ?onChange:String->Void) {
        super(name, description, option);
        this.values = values;
        this.onChange = onChange;
    }
}