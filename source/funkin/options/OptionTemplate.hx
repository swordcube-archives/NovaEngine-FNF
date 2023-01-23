package funkin.options;

class OptionTemplate {
    public var name:String;
    public var description:String;
    public var option:Null<String>;

    public function new(name:String, description:String, option:Null<String>) {
        this.name = name;
        this.description = description;
        this.option = option;
    }
}