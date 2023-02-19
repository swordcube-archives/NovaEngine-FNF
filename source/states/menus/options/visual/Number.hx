package states.menus.options.visual;

import objects.fonts.Alphabet;

class Number extends Option {
    public var value(default, set):Float;
    private function set_value(v:Float) {
        if(isModded) {
            @:privateAccess
            Reflect.setField(SettingsAPI.__save.data, saveData, v);
        } else
            Reflect.setField(SettingsAPI, saveData, v);

        valueTxt.text = Std.string(v) + textSuffix;
        return value = v;
    }

    public var playSelectSound:Bool;
    public var textSuffix:String;

    public var arrows:Alphabet;
    public var valueTxt:Alphabet;

    public var minimum:Float;
    public var maximum:Float;
    public var increment:Float;
    public var decimals:Int;
    public var callback:Float->Void;

    public function new(text:String, description:String, saveData:String, ?textSuffix:String, minimum:Float, maximum:Float, increment:Float, decimals:Int, ?callback:Float->Void, ?playSelectSound:Bool = true) {
        super(text, description, saveData);

        if(textSuffix == null) textSuffix = "";
        this.textSuffix = textSuffix;
        this.playSelectSound = playSelectSound;

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
        arrows.setPosition(alphabet.x + (alphabet.width + 40), alphabet.y);
        valueTxt.setPosition(arrows.x + ((arrows.width - valueTxt.width) * 0.5), arrows.y);
    }
}