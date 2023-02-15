package states.menus.options.visual;

import objects.ui.Checkbox as CheckboxSprite;

class Checkbox extends Option {
    public var checkbox:CheckboxSprite;
    
    public function new(text:String, saveData:String) {
        super(text);

        alphabet.x += 150;

        var value:Bool = false;
        if(Reflect.field(SettingsAPI, saveData) != null)
            value = Reflect.field(SettingsAPI, saveData);

        @:privateAccess {
            if(Reflect.field(SettingsAPI.__save, saveData) != null)
                value = Reflect.field(SettingsAPI.__save, saveData);
        }

        add(checkbox = new CheckboxSprite(-160, -30, value));
    }
}