package states.menus.options.visual;

import objects.fonts.Alphabet;

class List extends Option {
    public var value(default, set):String;
    private function set_value(v:String) {
        if(isModded) {
            @:privateAccess
            Reflect.setField(SettingsAPI.__save.data, saveData, v);
        } else
            Reflect.setField(SettingsAPI, saveData, v);

        valueTxt.text = v;
        return value = v;
    }

    public var arrows:Alphabet;
    public var valueTxt:Alphabet;

    public var values:Array<String> = [];
    public var callback:String->Void;

    public function new(text:String, description:String, saveData:String, values:Array<String>, ?callback:String->Void) {
        super(text, description, saveData);
        this.values = values;
        this.callback = callback;

        var value:String = "???";
        if(Reflect.field(SettingsAPI, saveData) != null)
            value = Reflect.field(SettingsAPI, saveData);

        @:privateAccess {
            if(Reflect.field(SettingsAPI.__save.data, saveData) != null && Reflect.field(SettingsAPI, saveData) == null) {
                value = Reflect.field(SettingsAPI.__save.data, saveData);
                isModded = true;
            }
        }

        add(arrows = new Alphabet(0, 0, Default, "<        >"));
        add(valueTxt = new Alphabet(0, 0, Default, "???"));

        this.value = value;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        arrows.alpha = valueTxt.alpha = alphabet.alpha;
        arrows.setPosition(alphabet.x + (alphabet.width + 40), alphabet.y);
        valueTxt.setPosition(arrows.x + ((arrows.width - valueTxt.width) * 0.5), arrows.y);
    }
}