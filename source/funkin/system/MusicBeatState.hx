package funkin.system;

import funkin.scripting.DummyScript;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIState;
import funkin.interfaces.IBeatReceiver;
import funkin.scripting.ScriptHandler;

class MusicBeatState extends FlxUIState implements IBeatReceiver {
    public var controls(get, never):Controls;

    function get_controls():Controls {
        return Init.controls;
    }
    public var runDefaultCode:Bool = true;

    public var script:ScriptModule;
    public var scriptName:String = null;

    public var canSwitchMods:Bool = true;

    public function new(?scriptName:Null<String>) {
        super();

        this.scriptName = scriptName;
        loadScript();
    }

    public function loadScript() {
        if (script == null || script is DummyScript) {
            var className = this.getClassName();
            var scriptName = this.scriptName != null ? this.scriptName : className.split(".").last();
    
            script = ScriptHandler.loadModule(Paths.script('data/states/$scriptName'));
            script.setParent(this);
            script.load();
        } else
            script.reload();
    }

    override function create() {
        super.create();

        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

        persistentUpdate = false;
        persistentDraw = true;

        Conductor.onBeat.add(beatHit);
        Conductor.onStep.add(stepHit);
        Conductor.onSection.add(sectionHit);

        call("onCreate");
    }

    override function createPost() {
		super.createPost();
		call("onCreatePost");
	}

    public function call(method:String, ?parameters:Array<Dynamic>, ?defaultVal:Dynamic):Dynamic {
		// calls the function on the assigned script
		if (script == null) return defaultVal;
		return script.call(method, parameters);
	}

    override function update(elapsed:Float) {
        var resetState:Bool = FlxG.keys.anyJustPressed([#if web CTRL, THREE #else F3 #end]);
        if (resetState)
            FlxG.resetState();

        if (FlxG.keys.justPressed.F5) {
            loadScript();
            if (script != null && !(script is DummyScript))
                Console.info('State script successfully reloaded');
        }
        call("onUpdate", [elapsed]);
        
        super.update(elapsed);
    }

    override function onFocus() {
        super.onFocus();
        call("onFocus");
    }

    override function onFocusLost() {
        super.onFocusLost();
        call("onFocusLost");
    }

    override public function tryUpdate(elapsed:Float):Void {
        if (persistentUpdate || subState == null) {
            script.call("onPreUpdate", [elapsed]);
            update(elapsed);
            script.call("onUpdatePost", [elapsed]);
        }

        if (_requestSubStateReset) {
            _requestSubStateReset = false;
            resetSubState();
        }

        if (subState != null)
            subState.tryUpdate(elapsed);
    }

    @:dox(hide) public function beatHit(curBeat:Int):Void {
        for(e in members) if (e is IBeatReceiver) cast(e, IBeatReceiver).beatHit(curBeat);
        call("onBeatHit", [curBeat]);
    }

    @:dox(hide) public function stepHit(curStep:Int):Void {
        for(e in members) if (e is IBeatReceiver) cast(e, IBeatReceiver).stepHit(curStep);
        call("onStepHit", [curStep]);
    }

    @:dox(hide) public function sectionHit(curSection:Int) {
        for(e in members) if (e is IBeatReceiver) cast(e, IBeatReceiver).sectionHit(curSection);
        call("onSectionHit", [curSection]);
    }

    override public function destroy() {
		script.call("onDestroy");
		script.call("destroy");
		script.destroy();
		super.destroy();
	}
}