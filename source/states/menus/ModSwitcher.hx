package states.menus;

import core.modding.Metadata;
import core.modding.ModUtil;
import states.MusicBeat.MusicBeatSubstate;
import flixel.math.FlxMath;
import flixel.group.FlxGroup.FlxTypedGroup;
import objects.fonts.Alphabet;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import objects.TrackingSprite;
import flixel.FlxG;

using StringTools;

class ModSwitcher extends MusicBeatSubstate {
    var bg:FlxSprite;
    var mods:Array<String> = [ModUtil.fallbackMod];

    var grpMods:FlxTypedGroup<Alphabet>;
    var grpIcons:FlxTypedGroup<TrackingSprite>;

    var curSelected:Int = 0;

    override function create() {
        super.create();
        
        bg = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFF000000);
        bg.scale.set(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.scrollFactor.set();
        bg.alpha = 0;
        add(bg);

        FlxTween.tween(bg, {alpha: 0.5}, 0.25, {ease: FlxEase.cubeOut});

        // Loading the list of mods (only loads base game if mod support is disabled)
        #if MOD_SUPPORT
        if(FileSystem.exists('./mods')) {
            for(modFolder in FileSystem.readDirectory('./mods')) {
                if (FileSystem.isDirectory('./mods/$modFolder') && !modFolder.startsWith(".") && FileSystem.exists('./mods/$modFolder/pack.json'))
                    mods.push(modFolder);
            }
        }
        #end

        add(grpMods = new FlxTypedGroup<Alphabet>());
        add(grpIcons = new FlxTypedGroup<TrackingSprite>());

        for(i => mod in mods) {
            // Makes sure the first mod is always base game
            if(i == 0) {
                addModToList("Friday Night Funkin'", ModUtil.fallbackMod);
                continue;
            }

            // Actually adding other mods
            try {
                #if docs
                var metadata:Dynamic = null;
                #else
                var metadata:Metadata = ModUtil.metadatas[i-1];
                #end
                if(metadata == null)
                    throw "Mod config is null";
                else
                    addModToList(metadata.name, mod);
            } catch(e) {
                Logs.trace('mods/$mod has an invalid "pack.json" file! - ${e.details()}', ERROR);
                mods.remove(mod);
            }
        }

        curSelected = mods.indexOf(ModUtil.currentMod);
        if(curSelected <= -1) curSelected = 0;
        changeSelection();
    }

    public function addModToList(name:String, raw:String) {
        var modName = new Alphabet(100, (70 * grpMods.length) + 30, Bold, name);
        modName.isMenuItem = true;
        modName.scrollFactor.set();
        modName.targetY = grpMods.length;
        modName.xAdd += 100;
        grpMods.add(modName);

        var modIcon = new TrackingSprite(modName.x, modName.y).loadGraphic(Paths.image("../pack", false, raw));
        modIcon.tracked = modName;
        modIcon.trackingMode = LEFT;
        modIcon.trackingOffset.set(-120, -20);
        modIcon.scrollFactor.set();
        modIcon.setGraphicSize(100, 100);
        modIcon.updateHitbox();
        grpIcons.add(modIcon);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if(controls.UI_UP_P) changeSelection(-1);
        if(controls.UI_DOWN_P) changeSelection(1);

        if(controls.BACK) close();

        if(controls.ACCEPT) {
            FlxG.sound.music.fadeOut(0.25, 0, function(_) {
                FlxG.sound.music.stop();
            });
            ModUtil.switchToMod(mods[curSelected], () -> {
                FlxG.resetState();
                close();
            });
        }
    }

    public function changeSelection(change:Int = 0) {
        curSelected = FlxMath.wrap(curSelected + change, 0, grpMods.length-1);

        for(i => alphabet in grpMods.members) {
            alphabet.alpha = (curSelected == i) ? 1 : 0.6;
            alphabet.targetY = i - curSelected;
        }

        CoolUtil.playMenuSFX(SCROLL);
    }
}