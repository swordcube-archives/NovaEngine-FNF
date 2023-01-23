package funkin.menus;

import funkin.utilities.ModHandler;
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
    var bg:FlxSprite;
    var mods:Array<String> = [Paths.fallbackMod];
    var modConfigs:Array<ModMetadata> = [];
    var alphabets:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;

    override function create() {
        super.create();

        Polymod.reload();
        
        bg = new FlxSprite(0, 0).makeGraphic(1, 1, 0xFF000000);
        bg.scale.set(FlxG.width, FlxG.height);
        bg.updateHitbox();
        bg.scrollFactor.set();
        bg.alpha = 0;
        add(bg);

        FlxTween.tween(bg, {alpha: 0.5}, 0.25, {ease: FlxEase.cubeOut});

        #if MOD_SUPPORT
        for(modFolder in FileSystem.readDirectory('./mods')) {
            if (FileSystem.isDirectory('./mods/$modFolder') && !modFolder.startsWith(".") && FileSystem.exists('./mods/$modFolder/_polymod_meta.json'))
                mods.push(modFolder);
        }
        #end

        alphabets = new FlxTypedGroup<Alphabet>();
        var i:Int = 0;
        for(mod in mods) {
            // "assets" folder is technically not a mod! So we can't load metadata for it!
            if(i == 0) {
                addModToList("Friday Night Funkin'");
                i++;
                continue;
            }

            // However the "mods" folder has mods in it that DO have metadata!
            // So we can like, continue on!!
            try {
                #if docs
                var metadata:Dynamic = null;
                #else
                var metadata:ModMetadata = ModHandler.metadatas[i-1];
                #end
                if(metadata == null)
                    throw "Mod config is null";
                else {
                    addModToList(metadata.title);
                    modConfigs.push(metadata);
                }
            } catch(e) {
                Console.error('mods/$mod has an invalid "_polymod_meta.json" file! - ${e.details()}');
            }
            i++;
        }
        add(alphabets);
        changeSelection();
    }

    public function addModToList(title:String) {
        var a = new Alphabet(0, 0, Bold, title);
        a.isMenuItem = true;
        a.scrollFactor.set();
        a.targetY = alphabets.length;
        alphabets.add(a);
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
            Assets.cache.clear();
            LimeAssets.cache.clear();
            #if polymod
            Polymod.clearCache();
            #end
            ModHandler.switchMod(mods[curSelected]);
            DiscordRPC.reloadJsonData();
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

        CoolUtil.playMenuSFX(SCROLL);
    }
}