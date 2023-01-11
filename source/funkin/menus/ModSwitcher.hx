package funkin.menus;

import funkin.system.ModHandler;
import funkin.system.MusicBeatSubstate;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import funkin.ui.Alphabet;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

class ModSwitcher extends MusicBeatSubstate {
    var mods:Array<String> = [Paths.fallbackMod];
    var alphabets:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;

    override function create() {
        super.create();
        
        var bg = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFF000000);
        bg.scale.set(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.scrollFactor.set();
        bg.alpha = 0;
        add(bg);

        FlxTween.tween(bg, {alpha: 0.5}, 0.25, {ease: FlxEase.cubeOut});

        #if MOD_SUPPORT
        for(modFolder in FileSystem.readDirectory('./mods')) {
            if (FileSystem.isDirectory('./mods/$modFolder') && !modFolder.startsWith("."))
                mods.push(modFolder);
        }
        #end

        alphabets = new FlxTypedGroup<Alphabet>();
        for(mod in mods) {
            var a = new Alphabet(0, 0, Bold, mod);
            a.isMenuItem = true;
            a.scrollFactor.set();
            alphabets.add(a);
        }
        add(alphabets);
        changeSelection();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(controls.UI_UP_P) changeSelection(-1);
        if(controls.UI_DOWN_P) changeSelection(1);

        if(controls.BACK) close();

        if (controls.ACCEPT) {
            FlxG.sound.music.stop();
            CoolUtil.playMenuSFX(1);
            Polymod.clearCache();
            ModHandler.switchMod(mods[curSelected]);
            FlxG.resetState();
            close();
        }
    }

    public function changeSelection(change:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + change, 0, alphabets.length-1);

        for(i => alphabet in alphabets.members) {
            alphabet.alpha = 0.6;
            alphabet.targetY = i - curSelected;
        }
        alphabets.members[curSelected].alpha = 1;

        CoolUtil.playMenuSFX(0);
    }
}