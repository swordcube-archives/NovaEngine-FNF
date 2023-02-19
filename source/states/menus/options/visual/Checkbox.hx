package states.menus.options.visual;

import flixel.effects.FlxFlicker;
import objects.ui.Checkbox as CheckboxSprite;

class Checkbox extends Option {
    public var callback:Bool->Void;
    public var checkbox:CheckboxSprite;
    
    public function new(text:String, description:String, saveData:String, ?callback:Bool->Void) {
        super(text, description, saveData);
        this.callback = callback;

        alphabet.x += 120;
        alphabet.xAdd += 120;

        var value:Bool = false;
        if(Reflect.field(SettingsAPI, saveData) != null)
            value = Reflect.field(SettingsAPI, saveData);

        @:privateAccess {
            if(Reflect.field(SettingsAPI.__save.data, saveData) != null && Reflect.field(SettingsAPI, saveData) == null) {
                value = Reflect.field(SettingsAPI.__save.data, saveData);
                isModded = true;
            }
        }

        add(checkbox = new CheckboxSprite(0, 0, value));
        checkbox.tracked = alphabet;
        checkbox.trackingOffset.set(-120, -40);
        checkbox.trackingMode = LEFT;
    }

    override function select() {
        if(isModded) {
            @:privateAccess
            Reflect.setField(SettingsAPI.__save.data, saveData, !Reflect.field(SettingsAPI.__save.data, saveData));
        } else
            Reflect.setField(SettingsAPI, saveData, !Reflect.field(SettingsAPI, saveData));
        
        @:privateAccess
        checkbox.value = (isModded) ? Reflect.field(SettingsAPI.__save.data, saveData) : Reflect.field(SettingsAPI, saveData);

        CoolUtil.playMenuSFX(CONFIRM);
        FlxFlicker.flicker(alphabet, 0.7, 0.1, true, true);

        if(callback != null)
            callback(checkbox.value);
    }
}