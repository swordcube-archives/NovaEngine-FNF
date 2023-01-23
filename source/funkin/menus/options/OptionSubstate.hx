package funkin.menus.options;

import flixel.effects.FlxFlicker;
import flixel.math.FlxMath;
import funkin.ui.UIArrow;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText;
import funkin.ui.Checkbox;
import funkin.ui.Alphabet;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import funkin.system.MusicBeatSubstate;
import funkin.options.*;

class OptionSubstate extends MusicBeatSubstate {
    public var curSelected:Int = 0;

    public var grpTitles:FlxTypedGroup<Alphabet>;
    public var grpCategories:FlxTypedGroup<Alphabet>;

    public var checkboxMap:Map<Int, Checkbox> = [];
    public var valueTextMap:Map<Int, Alphabet> = [];

    public var controlTextMap:Map<Int, Array<Alphabet>> = [];

    public var categories:Array<String> = [];
    public var options:Map<String, Array<Dynamic>> = [];
    public var generalOptions:Array<Dynamic> = [];

    public var amountOfOptions:Int = 0;
    public var camFollow:FlxObject;

    public var bg:FlxSprite;

    public var bindSelected:Int = 0;
    public var canInteract:Bool = true;

    public var descBox:FlxSprite;
    public var descText:FlxText;

    function initOptionTypes() {
        script.set("BoolOption", BoolOption);
        script.set("ListOption", ListOption);
        script.set("NumberOption", NumberOption);
    }

    override function create() {
        super.create();
        FlxG.state.persistentUpdate = false;
        FlxG.state.persistentDraw = true;

        persistentUpdate = persistentDraw = false;
        
		bg = new FlxSprite().loadGraphic(Paths.image('menus/menuBGDesat'));
        bg.color = 0xFFDB4CEE;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
        bg.scrollFactor.set();
		add(bg);

        add(grpTitles = new FlxTypedGroup<Alphabet>());
        add(grpCategories = new FlxTypedGroup<Alphabet>());

        var optionID:Int = 0;
        var bullShit:Int = 0;
        for(category in categories) {
            if(bullShit > 0) bullShit++;
            var pos:FlxPoint = new FlxPoint(90, bullShit * 85);
            var alphabet = new Alphabet(pos.x, pos.y, Bold, category);
            alphabet.screenCenter(X);
            grpCategories.add(alphabet);
            bullShit += 2;

            for(item in options[category]) {
                var pos:FlxPoint = new FlxPoint(90, bullShit * 85);
                var alphabet = new Alphabet(pos.x, pos.y, Bold, item.name);
                alphabet.ID = optionID;
                grpTitles.add(alphabet);

                switch(Type.getClassName(Type.getClass(item)).split(".").last()) {
                    case "BoolOption":
                        alphabet.x += 130;

                        var saveData:String = item.option != null ? item.option : item.name;
                        var box = new Checkbox(pos.x - 100, pos.y - 50, OptionsAPI.get(saveData));
                        box.tracked = alphabet;
                        box.trackingMode = LEFT;
                        box.trackingOffset.set(-100, -40);
                        box.ID = optionID;
                        checkboxMap[optionID] = box;
                        add(box);

                    case "NumberOption", "ListOption":
                        alphabet.x += 80;

                        var arrow = new UIArrow(0, 0, false);
                        arrow.tracked = alphabet;
                        arrow.trackingMode = LEFT;
                        arrow.trackingOffset.set(-(arrow.width + 5), -10);
                        arrow.control = "UI_LEFT";
                        arrow.ID = optionID;
                        arrow.onJustPressed = function() {
                            if(curSelected == arrow.ID)
                                arrow.playAnim("press");
                        }
                        add(arrow);

                        var arrow = new UIArrow(0, 0, true);
                        arrow.tracked = alphabet;
                        arrow.trackingMode = RIGHT;
                        arrow.trackingOffset.set(5, -10);
                        arrow.control = "UI_RIGHT";
                        arrow.ID = optionID;
                        arrow.onJustPressed = function() {
                            if(curSelected == arrow.ID)
                                arrow.playAnim("press");
                        }
                        add(arrow);

                        var saveData:String = item.option != null ? item.option : item.name;
                        var valText = new Alphabet(alphabet.x + (alphabet.width + 80), alphabet.y, Bold, OptionsAPI.get(saveData));
                        valText.ID = optionID;
                        valueTextMap[optionID] = valText;
                        add(valText);
                }
                generalOptions.push(item);
                amountOfOptions++;
                optionID++;
                bullShit++;
            }
        }

        descBox = new FlxSprite(30, FlxG.height - 65).makeGraphic(FlxG.width - 60, 1, FlxColor.BLACK);
        descBox.alpha = 0.8;
        descBox.scrollFactor.set();
        add(descBox);
    
        descText = new FlxText(descBox.x + 5, descBox.y + 5, descBox.width - 10, "Description goes here lim foaw\nsdfhusufdhhAWslkjfhjsdlkjsfdhjlkjlk");
        descText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, FlxTextAlign.CENTER);
        descText.scrollFactor.set();
        add(descText);

        camFollow = new FlxObject(0,0,1,1);
        add(camFollow);
        FlxG.camera.follow(camFollow, null, 0.16);
        changeSelection();
    }

    var holdTimer:Float = 0.0;

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(canInteract) {
            if(controls.UI_UP_P) changeSelection(-1);
            if(controls.UI_DOWN_P) changeSelection(1);

            if(controls.UI_LEFT || controls.UI_RIGHT) {
                holdTimer += elapsed;
                if(controls.UI_LEFT_P || controls.UI_RIGHT_P || holdTimer > 0.5) {
                    var option:Dynamic = generalOptions[curSelected];
                    var saveData:String = option.option != null ? option.option : option.name;
                    switch(Type.getClassName(Type.getClass(option)).split(".").last()) {
                        case "NumberOption":
                            var value:Float = OptionsAPI.get(saveData);
                            value += controls.UI_LEFT ? -option.increment : option.increment;
                            value = FlxMath.bound(FlxMath.roundDecimal(value, option.decimals), option.minimum, option.maximum);
                            OptionsAPI.set(saveData, value);
                            valueTextMap[curSelected].text = value+"";
                            if(option.onChange != null) option.onChange(value);

                            if(controls.UI_LEFT_P || controls.UI_RIGHT_P)
                                CoolUtil.playMenuSFX(SCROLL);

                        case "ListOption":
                            var value:String = OptionsAPI.get(saveData);
                            var index:Int = option.values.indexOf(value);
                            var inc:Int = controls.UI_LEFT ? -1 : 1;
                            index = Std.int(FlxMath.bound(index+inc, 0, option.values.length-1));
                            OptionsAPI.set(saveData, option.values[index]);
                            valueTextMap[curSelected].text = option.values[index]+"";
                            if(option.onChange != null) option.onChange(option.values[index]);

                            if(controls.UI_LEFT_P || controls.UI_RIGHT_P)
                                CoolUtil.playMenuSFX(SCROLL);
                    }
                    if(holdTimer > 0.5) holdTimer = 0.425;
                }
            } else holdTimer = 0;

            if(controls.ACCEPT) {
                var option:Dynamic = generalOptions[curSelected];
                var saveData:String = option.option != null ? option.option : option.name;
                switch(Type.getClassName(Type.getClass(option)).split(".").last()) {
                    case "BoolOption":
                        var casted:BoolOption = cast option;
                        OptionsAPI.set(saveData, !OptionsAPI.get(saveData));
                        checkboxMap[curSelected].value = OptionsAPI.get(saveData);
                        if(OptionsAPI.get("Flashing Lights"))
                            FlxFlicker.flicker(grpTitles.members[curSelected], 0.7, 0.1, true, false);
                        if(casted.onChange != null) casted.onChange(cast OptionsAPI.get(saveData));
                        CoolUtil.playMenuSFX(CONFIRM);
                }
            }
            if(controls.BACK) goBack();
        }
    }

    public function goBack() {
        camFollow.setPosition(0, 0);
        FlxG.camera.scroll.set(0, 0);
        FlxG.camera.follow(null, null, 0);
        CoolUtil.playMenuSFX(CANCEL);
        close();
    }

    function changeSelection(change:Int = 0) {
        if(amountOfOptions <= 0) return;

        curSelected = FlxMath.wrap(curSelected + change, 0, amountOfOptions-1);

        grpTitles.forEach(function(a:Alphabet) {
            a.alpha = curSelected == a.ID ? 1 : 0.6;
            var val = valueTextMap[a.ID];
            if(val != null) val.alpha = a.alpha;
            var val = controlTextMap[a.ID];
            if(val != null) {
                for(cum => ass in val)
                    ass.alpha = (curSelected == a.ID && bindSelected == cum) ? 1 : 0.6;
            }
            if(curSelected == a.ID)
                camFollow.setPosition(0, a.y + 85);
        });
        camFollow.screenCenter(X);

        descText.text = generalOptions[curSelected].description;
        descBox.scale.y = descText.height + 10;
        descBox.updateHitbox();
        descBox.y = FlxG.height - (descBox.height + 15);
        descText.y = descBox.y + 3;
        descText.text += "\n     ";

        CoolUtil.playMenuSFX(SCROLL);
    }
}