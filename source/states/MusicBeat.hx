package states;

import core.dependency.ScriptHandler;
import flixel.addons.ui.FlxUISubState;
import flixel.addons.ui.FlxUIState;

class MusicBeatState extends FlxUIState implements MusicHandler {
    public var controls(get, never):Controls;
    function get_controls() return SettingsAPI.controls;

    public var curBeat(get, never):Int;
    private function get_curBeat() return Conductor.curBeat;

    public var preciseBeat(get, never):Float;
    private function get_preciseBeat() return Conductor.preciseBeat;

    public var curStep(get, never):Int;
    private function get_curStep() return Conductor.curStep;

    public var preciseStep(get, never):Float;
    private function get_preciseStep() return Conductor.preciseStep;

    public var curSection(get, never):Int;
    private function get_curSection() return Conductor.curSection;

    public var scriptName:String;
    public var scriptParameters:Array<Dynamic> = [];

    public var script:ScriptModule;

    public var runDefaultCode:Bool = true;

    public function new(?scriptName:String = null, ?scriptParameters:Array<Dynamic>) {
        super();
        if(scriptName == null)
            scriptName = this.getClassName().split(".").last();

        if(scriptParameters == null)
            scriptParameters = [];
        
        this.scriptName = scriptName;
        this.scriptParameters = scriptParameters;
    }

    public function call(name:String, args:Array<Dynamic>, ?defaultReturn:Dynamic = null):Dynamic {
		if (script == null) return defaultReturn;
		return script.call(name, args);
	}

    override function create() {
        super.create();

        transIn = FlxTransitionableState.defaultTransIn;
        transOut = FlxTransitionableState.defaultTransOut;

        Conductor.onBeatHit.add(beatHit);
        Conductor.onStepHit.add(stepHit);
        Conductor.onSectionHit.add(sectionHit);

        script = ScriptHandler.loadModule(Paths.script('data/states/$scriptName'));
        script.setParent(this);
        call("new", []);
        call("onCreate", scriptParameters);
    }

    override function createPost() {
        super.createPost();
        call("onCreatePost", []);
    }

    override function tryUpdate(elapsed:Float):Void {
        if (persistentUpdate || subState == null) {
            call("onPreUpdate", [elapsed]);
            update(elapsed);
            call("onUpdatePost", [elapsed]);
        }

        if (_requestSubStateReset) {
            _requestSubStateReset = false;
            resetSubState();
        }

        if (subState != null)
            subState.tryUpdate(elapsed);
    }

    public var fixedUpdateTimer:Float = 0;
    public var fixedUpdateTime:Float = 1 / 60;

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.F5) {
            if(Std.isOfType(FlxG.state, ModState))
                FlxG.switchState(new ModState(this.scriptName, this.scriptParameters));
            else
                FlxG.resetState();
        }

        fixedUpdateTimer += elapsed;
        if(fixedUpdateTimer >= fixedUpdateTime)
            fixedUpdate(fixedUpdateTimer);
        
        call("onUpdate", [elapsed]);

        super.update(elapsed);

        if(fixedUpdateTimer >= fixedUpdateTime) {
            fixedUpdatePost(fixedUpdateTimer);
            fixedUpdateTimer = 0;
        }
    }

    public function fixedUpdate(elapsed:Float) {
        call("onFixedUpdate", [elapsed]);
    }

    public function fixedUpdatePost(elapsed:Float) {
        call("onFixedUpdatePost", [elapsed]);
    }

	public function beatHit(value:Int) {
        for(m in members) {
            if(m != null && m is MusicHandler)
                cast(m, MusicHandler).beatHit(value);
        }
        call("onBeatHit", [value]);
    }

	public function stepHit(value:Int) {
        for(m in members) {
            if(m != null && m is MusicHandler)
                cast(m, MusicHandler).stepHit(value);
        }
        call("onStepHit", [value]);
    }

	public function sectionHit(value:Int) {
        for(m in members) {
            if(m != null && m is MusicHandler)
                cast(m, MusicHandler).sectionHit(value);
        }
        call("onSectionHit", [value]);
    }

    override function destroy() {
        Conductor.onBeatHit.remove(beatHit);
        Conductor.onStepHit.remove(stepHit);
        Conductor.onSectionHit.remove(sectionHit);

        super.destroy();
    }
}

// fuck you
typedef MusicBeatSubState = MusicBeatSubstate;

class MusicBeatSubstate extends FlxUISubState implements MusicHandler {
    public var controls(get, never):Controls;
    function get_controls() return SettingsAPI.controls;

    public var curBeat(get, never):Int;
    private function get_curBeat() return Conductor.curBeat;

    public var preciseBeat(get, never):Float;
    private function get_preciseBeat() return Conductor.preciseBeat;

    public var curStep(get, never):Int;
    private function get_curStep() return Conductor.curStep;

    public var preciseStep(get, never):Float;
    private function get_preciseStep() return Conductor.preciseStep;

    public var curSection(get, never):Int;
    private function get_curSection() return Conductor.curSection;

    public var scriptName:String;
    public var scriptParameters:Array<Dynamic> = [];

    public var script:ScriptModule;

    public var runDefaultCode:Bool = true;

    public function new(?scriptName:String = null, ?scriptParameters:Array<Dynamic>) {
        super();
        if(scriptName == null)
            scriptName = this.getClassName().split(".").last();

        if(scriptParameters == null)
            scriptParameters = [];
        
        this.scriptName = scriptName;
        this.scriptParameters = scriptParameters;
    }

    public function call(name:String, ?args:Array<Dynamic>, ?defaultReturn:Dynamic = null):Dynamic {
		if (script == null) return defaultReturn;
		return script.call(name, args);
	}

    override function create() {
        super.create();

        Conductor.onBeatHit.add(beatHit);
        Conductor.onStepHit.add(stepHit);
        Conductor.onSectionHit.add(sectionHit);

        script = ScriptHandler.loadModule(Paths.script('data/substates/$scriptName'));
        script.setParent(this);
        call("new", []);
        call("onCreate", scriptParameters);
    }

    override function createPost() {
        super.createPost();
        call("onCreatePost", []);
    }

    override function tryUpdate(elapsed:Float):Void {
        if (persistentUpdate || subState == null) {
            call("onPreUpdate", [elapsed]);
            update(elapsed);
            call("onUpdatePost", [elapsed]);
        }

        if (_requestSubStateReset) {
            _requestSubStateReset = false;
            resetSubState();
        }

        if (subState != null)
            subState.tryUpdate(elapsed);
    }

    public var fixedUpdateTimer:Float = 0;
    public var fixedUpdateTime:Float = 1 / 60;

    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.F5)
            FlxG.resetState();

        fixedUpdateTimer += elapsed;
        if(fixedUpdateTimer >= fixedUpdateTime)
            fixedUpdate(fixedUpdateTimer);
        
        call("onUpdate", [elapsed]);

        super.update(elapsed);

        if(fixedUpdateTimer >= fixedUpdateTime) {
            fixedUpdatePost(fixedUpdateTimer);
            fixedUpdateTimer = 0;
        }
    }

    public function fixedUpdate(elapsed:Float) {
        call("onFixedUpdate", [elapsed]);
    }

    public function fixedUpdatePost(elapsed:Float) {
        call("onFixedUpdatePost", [elapsed]);
    }

	public function beatHit(value:Int) {
        for(m in members) {
            if(m != null && m is MusicHandler)
                cast(m, MusicHandler).beatHit(value);
        }
        call("onBeatHit", [value]);
    }

	public function stepHit(value:Int) {
        for(m in members) {
            if(m != null && m is MusicHandler)
                cast(m, MusicHandler).stepHit(value);
        }
        call("onStepHit", [value]);
    }

	public function sectionHit(value:Int) {
        for(m in members) {
            if(m != null && m is MusicHandler)
                cast(m, MusicHandler).sectionHit(value);
        }
        call("onSectionHit", [value]);
    }

    override function destroy() {
        Conductor.onBeatHit.remove(beatHit);
        Conductor.onStepHit.remove(stepHit);
        Conductor.onSectionHit.remove(sectionHit);

        super.destroy();
    }
}