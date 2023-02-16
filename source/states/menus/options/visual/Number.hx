package states.menus.options.visual;

import objects.fonts.Alphabet;

class Number extends Option {
    /**
     * Whether or not this option was softcoded via a mod.
     */
    public var isModded:Bool = false;

    public var saveData:String;

    public var value(default, set):Float;
    private function set_value(v:Float) {
        if(isModded) {
            @:privateAccess
            Reflect.setField(SettingsAPI.__save.data, saveData, v);
        } else
            Reflect.setField(SettingsAPI, saveData, v);

        valueTxt.text = Std.string(v);
        return value = v;
    }

    public var arrows:Alphabet;
    public var valueTxt:Alphabet;

    public var minimum:Float;
    public var maximum:Float;
    public var increment:Float;
    public var decimals:Int;
    public var callback:Float->Void;

    public function new(text:String, saveData:String, minimum:Float, maximum:Float, increment:Float, decimals:Int, ?callback:Float->Void) {
        super(text);
        this.saveData = saveData;
        this.minimum = minimum;
        this.maximum = maximum;
        this.increment = increment;
        this.decimals = decimals;
        this.callback = callback;

        var value:Float = 0;
        if(Reflect.field(SettingsAPI, saveData) != null)
            value = Reflect.field(SettingsAPI, saveData);

        @:privateAccess {
            if(Reflect.field(SettingsAPI.__save.data, saveData) != null && Reflect.field(SettingsAPI, saveData) == null) {
                value = Reflect.field(SettingsAPI.__save.data, saveData);
                isModded = true;
            }
        }

        add(arrows = new Alphabet(0, 0, Default, "<        >"));
        add(valueTxt = new Alphabet(0, 0, Default, "0"));

        arrows.color = valueTxt.color = 0xFF000000;

        this.value = value;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        arrows.alpha = valueTxt.alpha = alphabet.alpha;
        arrows.setPosition(alphabet.x + (alphabet.width + 100), alphabet.y);
        valueTxt.setPosition(arrows.x + ((arrows.width - valueTxt.width) * 0.5), arrows.y);
    }
}