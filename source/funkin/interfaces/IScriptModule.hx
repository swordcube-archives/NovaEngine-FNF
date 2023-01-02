package funkin.interfaces;

interface IScriptModule {
    public function load():Void;
    public function reload():Void;
    public function onCreate(path:String):Void;
    public function get(variable:String):Dynamic;
    public function set(variable:String, value:Dynamic):Dynamic;
    public function setFunc(variable:String, value:Dynamic):Dynamic;
    public function setParent(classInstance:Dynamic):Void;
    public function call(method:String, ?parameters:Array<Dynamic>):Dynamic;
}