package backend.scripting;

import states.PlayState;
import backend.scripting.lua.LuaUtil;
#if linc_luajit
import haxe.DynamicAccess;
import cpp.Callable;
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
import llua.Macro.*;
#end
import lime.app.Application;
import backend.dependency.ScriptHandler;

/**
 * The class used for handling Lua functionality.
 * @author YoshiCrafter29 + Srt
 */
class LuaScript extends ScriptModule {
	static var currentLua:LuaScript;

	#if linc_luajit
	static var workaroundCallable:Callable<llua.State.StatePointer->Int> = Callable.fromStaticFunction(instanceWorkAround);
	var luaState:State;
	#end
	
	var script:Dynamic = {parent: null};

	/**
	 * The array containing the special vars so lua can utilize them by getting the location used in the `__special_id` field.
	 */
	var specialVars:Array<Dynamic> = [];

	public function new(path:String, fileName:String = "lua") {
		super(path, fileName);

		#if linc_luajit
		luaState = LuaL.newstate();
		LuaL.openlibs(luaState);
		Lua.register_hxtrace_func(Callable.fromStaticFunction(luaTrace));
		Lua.register_hxtrace_lib(luaState);

		Lua.newtable(luaState);
		var tableIndex = Lua.gettop(luaState); // The variable position of the table. Used for paring the metatable with this table.
		Lua.pushvalue(luaState, tableIndex);

		LuaL.newmetatable(luaState, "__scriptMetatable");
		var metatableIndex = Lua.gettop(luaState); // The variable position of the table. Used for setting the functions inside this metatable.
		Lua.pushvalue(luaState, metatableIndex);

		Lua.pushstring(luaState, '__index'); // This is a function in the metatable that is called when you to get a var that doesn't exist.
		Lua.pushcfunction(luaState, Callable.fromStaticFunction(callIndex));
		Lua.settable(luaState, metatableIndex);

		Lua.pushstring(luaState, '__newindex'); // This is a function in the metatable that is called when you to set a var that was originally null.
		Lua.pushcfunction(luaState, Callable.fromStaticFunction(callNewIndex));
		Lua.settable(luaState, metatableIndex);

		Lua.pushstring(luaState, '__call'); // This is a function in the metatable that is called when you call a function inside the table.
		Lua.pushcfunction(luaState, Callable.fromStaticFunction(callMetatableCall));
		Lua.settable(luaState, metatableIndex);

		Lua.setmetatable(luaState, tableIndex);

		LuaL.newmetatable(luaState, "__enumMetatable");
		var enumMetatableIndex = Lua.gettop(luaState); // The variable position of the table. Used for setting the functions inside this metatable.
		Lua.pushvalue(luaState, metatableIndex);

		Lua.pushstring(luaState, '__index'); // This is a function in the metatable that is called when you to get a var that doesn't exist.
		Lua.pushcfunction(luaState, Callable.fromStaticFunction(callEnumIndex));
		Lua.settable(luaState, enumMetatableIndex);

		Lua.pushstring(luaState, '__call'); // This is a function in the metatable that is called when you to get a var that doesn't exist.
		Lua.pushcfunction(luaState, Callable.fromStaticFunction(callEnumIndex));
		Lua.settable(luaState, enumMetatableIndex);

		script = {
			"import": importClass,
			"path": path,
			"fileName": fileName,
			"parent": parent
		};

		Lua.newtable(luaState);
		var scriptTableIndex = Lua.gettop(luaState);
		Lua.pushvalue(luaState, scriptTableIndex);
		Lua.setglobal(luaState, "script");

		Lua.pushstring(luaState, '__special_id'); // This is a helper var in the table that is used by the conversion functions to detect a special var.
		Lua.pushinteger(luaState, 0);
		Lua.settable(luaState, scriptTableIndex);
		specialVars.push(script);

		LuaL.getmetatable(luaState, "__scriptMetatable");
		Lua.setmetatable(luaState, scriptTableIndex);

		for(name => value in ScriptHandler.preset)
            set(name, value);

		set("parent", parent);
		#end
    }

    override public function load() {
		#if linc_luajit
		var lastLua:LuaScript = currentLua;
		currentLua = this;

		script = {
			"import": importClass,
			"path": path,
			"fileName": fileName,
			"parent": parent
		};
		specialVars[0] = script;

		// idk how else to allow splitting string like a normal lua function
		// callbacks are dumb >:(
		LuaL.dostring(luaState, LuaUtil.STRING_HELPER);

		var code:String = File.getContent(path);
		var replaceMap:Map<String, String> = [
			// really stupid workaround for from functions
			// returning the wrong colors
			// everything else i tried didn't work
			"FlxColor:fromRGB(" => "FlxColor:new():setRGB(",
			"FlxColor:fromRGBFloat(" => "FlxColor:new():setRGBFloat(",
			"FlxColor:fromHSV(" => "FlxColor:new():setHSV(",
			"FlxColor:fromHSB(" => "FlxColor:new():setHSB(",
			"FlxColor:fromCMYK(" => "FlxColor:new():setCMYK("
		];
		for(from => to in replaceMap)
			code = code.replace(from, to);

        if (LuaL.dostring(luaState, code) != 0) {
			var error = Lua.tostring(luaState, -1);
            var msg:String = 'Lua file at path: $path couldn\'t be ran! Here\'s the error message:\n$error';

            WindowUtil.showMessage("Error occured on LUA file! ("+fileName+")", msg, MSG_ERROR);
            #if windows
            Application.current.window.alert(msg);
            #end
		}
		currentLua = lastLua;
		#end
    }

	override public function trace(v:Dynamic) {
		Logs.trace('$fileName: $v', TRACE);
	}

	static inline function luaTrace(s:String):Int {
		#if linc_luajit
		Logs.trace('${currentLua.fileName}: Lua Value: $s - Haxe Value: ${currentLua.fromLua(-2)}', TRACE);
		#end
		return 0;
	}

	override public function set(name:String, newValue:Dynamic) {
		#if linc_luajit
		var lastLua:LuaScript = currentLua;
		currentLua = this;
		toLua(newValue);
		Lua.setglobal(luaState, name);
		currentLua = lastLua;
		#end
	}

	override public function setParent(parent:Dynamic) {
		#if linc_luajit
		var lastLua:LuaScript = currentLua;
		currentLua = this;
		script = {
			"import": importClass,
			"path": path,
			"fileName": fileName,
			"parent": this.parent = parent
		};
		set("parent", parent);
		
		specialVars[0] = script;
		currentLua = lastLua;
		#end
	}

	override public function call(name:String, ?params:Array<Dynamic>):Dynamic {
		#if linc_luajit
		if(params == null) params = [];
		var lastLua:LuaScript = currentLua;
		currentLua = this;
		script = {
			"import": importClass,
			"path": path,
			"fileName": fileName,
			"parent": parent
		};
		specialVars[0] = script;
		try {
			Lua.settop(luaState, 0);
			Lua.getglobal(luaState, name); // Finds the function from the script.

			if (!Lua.isfunction(luaState, -1))
				return null;

			// Pushes the parameters of the script.
			var nparams:Int = 0;
			if (params != null && params.length > 0) {
				nparams = params.length;
				for (val in params)
					toLua(val);
			}

			// Calls the function of the script. If it does not return 0, will trace what went wrong.
			if (Lua.pcall(luaState, nparams, 1, 0) != 0) {
				if(functionsErrored[name] != true) {
					WindowUtil.showMessage('Error occured while running function ($name)', '${Lua.tostring(luaState, -1)}', MSG_ERROR);
					functionsErrored[name] = true;
				}
				return null;
			}

			// Grabs and returns the result of the function.
			var v = fromLua(Lua.gettop(luaState));
			Lua.settop(luaState, 0);
			currentLua = lastLua;
			return v;
		} catch(e) {
			if(functionsErrored[name] != true) {
				WindowUtil.showMessage('Error occured trying to run lua function ($name)', '$e', MSG_ERROR);
				functionsErrored[name] = true;
			}
		}
		currentLua = lastLua;
		#end
		return null;
	}

	public override function setPublicMap(map:Map<String, Dynamic>) {
        PlayState.current.global = map;
    }

	// A map of functions that have already shown an error
	// used for functions like onUpdate that execute every frame
	// and thus could error every frame
	public var functionsErrored:Map<String, Bool> = [];

	#if linc_luajit
	// These functions are here because Callable seems like it wants an int return and whines when you do a non static function.
	static function callIndex(state:StatePointer):Int {
		return staticToFunc(currentLua.luaState, 0);
	}

	static function callNewIndex(state:StatePointer):Int {
		return staticToFunc(currentLua.luaState, 1);
	}

	static function callMetatableCall(state:StatePointer):Int {
		return staticToFunc(currentLua.luaState, 2);
	}

	static function callEnumIndex(state:StatePointer):Int {
		return staticToFunc(currentLua.luaState, 3);
	}

	static function staticToFunc(state:State, funcNum:Int) {
		var returnVars = [];
		var functions:Array<Dynamic> = [
			currentLua.index,
			currentLua.newIndex,
			currentLua.metatableCall,
			currentLua.enumIndex
		];

		// Making the params for the function.
		var nparams:Int = Lua.gettop(state);
		var params:Array<Dynamic> = [for (i in 0...nparams) currentLua.fromLua(-nparams + i)];

		var funcParams = [for (i in 2...params.length) params[i]];
		params.splice(2, params.length);
		params.push(funcParams);

		if (funcNum == 1)
			params[2] = params[2][0];

		// Calling the function. If it catches something, will trace what went wrong.
		var returned:Dynamic = null;
		try {
			returned = functions[funcNum](params[0], params[1], params[2]);
		} catch (e) {
			WindowUtil.showMessage('Error occured on Lua file (${currentLua.fileName})', '$e', MSG_ERROR);
		}
		Lua.settop(state, 0);

		// Pushes the result of the function into the array used to return 1 or 0 and to the lua script itself.
		if (returnVars.length <= 0 && returned != null)
			returnVars.push(returned);
		for (e in returnVars)
			currentLua.toLua(e);

		return returnVars.length;
	}

	// These three functions are the actual functions that the metatable use.
	// Without these, object oriented lua wouldn't work at all.
	public function index(object:Dynamic, property:Any, ?uselessValue:Any):Dynamic {
		if (object is Array && property is Int)
			return object[cast(property, Int)];

		var grabbedProperty:Dynamic = null;

		if (object != null && (grabbedProperty = Reflect.getProperty(object, cast(property, String))) != null)
            return grabbedProperty;
        return null;
	}
    public function newIndex(object:Dynamic, property:Any, value:Dynamic) {
		if (object is Array && property is Int) {
			object[cast(property, Int)] = value;
			return null;
		}

		if (object != null)
			Reflect.setProperty(object, cast(property, String), value);
        return null;
    }
	public function metatableCall(func:Dynamic, object:Dynamic, ?params:Array<Any>) {
		var funcParams = (params != null && params.length > 0) ? params : [];

		if (object != null && func != null && Reflect.isFunction(func))
            return Reflect.callMethod(object, func, funcParams);
        return null;
	}
	public function enumIndex(object:Enum<Dynamic>, value:String, ?params:Array<Any>):EnumValue {
		var funcParams = (params != null && params.length > 0) ? params : [];
		var enumValue:EnumValue;

		enumValue = object.createByName(value, funcParams);
		if (object != null && enumValue != null)
            return enumValue;
        return null;
	}

	/**
	 * Converts a lua variable to haxe. Used for lua function returns.
	 * @param stackPos The position of the lua variable.
	 */
	public function fromLua(stackPos:Int, ?inTable:Bool = false):Dynamic {
		var ret:Any = null;
		var vtype:Int = Lua.type(luaState, stackPos);
		switch (vtype) {
			case Lua.LUA_TNIL:
				ret = null;
			case Lua.LUA_TBOOLEAN:
				ret = Lua.toboolean(luaState, stackPos);
			case Lua.LUA_TNUMBER:
				ret = Lua.tonumber(luaState, stackPos);
			case Lua.LUA_TSTRING:
				ret = Lua.tostring(luaState, stackPos);
			case Lua.LUA_TTABLE:
				ret = toHaxeObj(stackPos);
			case Lua.LUA_TFUNCTION:
				if (Lua.tocfunction(luaState, stackPos) != workaroundCallable) {
					var ref = LuaL.ref(luaState, Lua.LUA_REGISTRYINDEX);

					if (inTable) {
						Logs.trace("FUNCTIONS MAY NOT BE USED IN TABLES AS THEY CRASH THE GAME.\nIf you're trying to add `onComplete` to a tween, (most common use for local funcs)\ndo `tween.onComplete = func` instead please.", ERROR);
						return null;
					}

					ret = Reflect.makeVarArgs((params:Array<Dynamic>) -> {
						var lastLua:LuaScript = currentLua;
						currentLua = this;

						script = { //Overriding `set_parent` wasnt working for me soo.....
							"import": importClass,
							"path": path,
							"fileName": fileName,
							"parent": parent
						};
						specialVars[0] = script;

						Lua.settop(luaState, 0);
						Lua.rawgeti(luaState, Lua.LUA_REGISTRYINDEX, ref);

						if (Lua.isfunction(luaState, -1)) {
							//Pushes the parameters of the script.
							var nparams:Int = 0;
							if (params != null && params.length > 0) {
								nparams = params.length;
								for (val in params)
									toLua(val);
							}

							//Calls the function of the script. If it does not return 0, will trace what went wrong.
							if (Lua.pcall(luaState, nparams, 1, 0) != 0)
								Logs.trace('Lua Function(LOCAL) Error: ${Lua.tostring(luaState, -1)}', ERROR);
						}

						currentLua = lastLua;
					});
				}
			default:
				ret = null;
				trace("return value not supported\nvalue: "+stackPos+"\ntype: "+vtype);
		}

		// This is to check if the object has a special field and converts it back if so.
		if (ret is Dynamic && Reflect.hasField(ret, "__special_id")) // Special Var.
			return specialVars[Reflect.field(ret, "__special_id")];
		return ret;
	}

	/**
	 * Converts any value into a lua variable.
	 * Automatically calls `Lua.push[var-type]` so all you need to do is call `Lua.setglobal` or `Lua.settable`.
	 * @param val                The value to convert.
	 */
	 public function toLua(val:Any) {
		var varType = Type.typeof(val);

		switch (varType) {
			case Type.ValueType.TNull:
				Lua.pushnil(luaState);
			case Type.ValueType.TBool:
				Lua.pushboolean(luaState, val);
			case Type.ValueType.TInt:
				Lua.pushinteger(luaState, cast(val, Int));
			case Type.ValueType.TFloat:
				Lua.pushnumber(luaState, val);
			case Type.ValueType.TClass(String):
				Lua.pushstring(luaState, cast(val, String));
			case Type.ValueType.TClass(Array):
				var location = specialVars.indexOf(val);
				if (location < 0) {
					location = specialVars.length;
					specialVars.push(val);
				}

				Lua.newtable(luaState);
				var tableIndex = Lua.gettop(luaState); //The variable position of the table. Used for paring the metatable with this table and attaching variables.

				Lua.pushstring(luaState, '__special_id'); //This is a helper var in the table that is used by the conversion functions to detect a special var.
				Lua.pushinteger(luaState, location);
				Lua.settable(luaState, tableIndex);

                LuaL.getmetatable(luaState, "__scriptMetatable");
				Lua.setmetatable(luaState, tableIndex);
			case Type.ValueType.TObject:
				var location = specialVars.indexOf(val);
				if (location < 0) {
					location = specialVars.length;
					specialVars.push(val);
				}
	
				Lua.newtable(luaState);
				var tableIndex = Lua.gettop(luaState); //The variable position of the table. Used for paring the metatable with this table and attaching variables.
	
				Lua.pushstring(luaState, '__special_id'); //This is a helper var in the table that is used by the conversion functions to detect a special var.
				Lua.pushinteger(luaState, location);
				Lua.settable(luaState, tableIndex);

				//Idk why it thinks static classes are objects but ok.
				var className:String = Type.getClassName(val);
				if (className != null) {
					Lua.pushstring(luaState, "new"); //This implements the work around function to create the class instance.
					Lua.pushcfunction(luaState, workaroundCallable);
					Lua.rawset(luaState, tableIndex);
				}
	
				LuaL.getmetatable(luaState, "__scriptMetatable");
				Lua.setmetatable(luaState, tableIndex);

				return true;
			default: //Didn't fit any of the var types. Assuming it's an instance/pointer, reating table, and attaching table to metatable.
				var location = specialVars.indexOf(val);
				if (location < 0) {
					location = specialVars.length;
					specialVars.push(val);
				}

				Lua.newtable(luaState);
				var tableIndex = Lua.gettop(luaState); //The variable position of the table. Used for paring the metatable with this table and attaching variables.

				Lua.pushstring(luaState, '__special_id'); //This is a helper var in the table that is used by the conversion functions to detect a special var.
				Lua.pushinteger(luaState, location);
				Lua.settable(luaState, tableIndex);

                LuaL.getmetatable(luaState, "__scriptMetatable");
				Lua.setmetatable(luaState, tableIndex);

				return false;
		}

		return true;
	}

	/**
	 * TBH, this is copy-pasted from Codename which I think was copy-pasted from the convert class.
	 */
	public function toHaxeObj(i:Int):Any {
		var count = 0;
		var array = true;

		loopTable(luaState, i, {
			if (array) {
				if (Lua.type(luaState, -2) != Lua.LUA_TNUMBER)
					array = false;
				else {
					var index = Lua.tonumber(luaState, -2);
					if (index < 0 || Std.int(index) != index)
						array = false;
				}
			}
			count++;
		});

		return if (count == 0) {
			{};
		} else if (array) {
			var v = [];
			loopTable(luaState, i, {
				var index = Std.int(Lua.tonumber(luaState, -2)) - 1;
				v[index] = fromLua(-1, true);
			});
			cast v;
		} else {
			var v:DynamicAccess<Any> = {};
			loopTable(luaState, i, {
				switch Lua.type(luaState, -2) {
					case t if (t == Lua.LUA_TSTRING): v.set(Lua.tostring(luaState, -2), fromLua(-1, true));
					case t if (t == Lua.LUA_TNUMBER): v.set(Std.string(Lua.tonumber(luaState, -2)), fromLua(-1, true));
				}
			});
			cast v;
		}
	}

	/**
	 * A function that is constantly overriden to workaround the fact that class constructor functions work weridly and that you can only push cpp functions.
	 */
	static function instanceWorkAround(state:StatePointer):Int {
		var returnVars = [];

		// Making the params for the function.
		var nparams:Int = Lua.gettop(currentLua.luaState);
		var params:Array<Dynamic> = [for (i in 0...nparams) currentLua.fromLua(-nparams + i)];

		var funcParams = [for (i in 1...params.length) params[i]];
		params.splice(1, params.length);
		params.push(funcParams);

		// Calling the function.
		var returned:Dynamic = null;
		try {
			returned = Type.createInstance(params[0], params[1]);
		} catch (e) {
			Logs.trace("Lua Instance Creation Error: " + e.details(), ERROR);
		}
		Lua.settop(currentLua.luaState, 0);

		// Pushes the result of the function into the lua script  and the array used to return 1 or 0.
		if (returnVars.length <= 0 && returned != null)
			returnVars.push(returned);
		for (e in returnVars)
			currentLua.toLua(e);

		return returnVars.length;
	}

	/**
	 * The function utilized for adding classes to lua.
	 * @param path                  The path to the class.
	 * @param varName               [OPTIONAL] The name to set the class to.
	 */
	function importClass(path:String, ?varName:String) {
		var importedClass = Type.resolveClass(path);
		var importedEnum = Type.resolveEnum(path);
		if (importedClass != null) {
			var location = specialVars.indexOf(importedClass);
			if (location < 0) {
				location = specialVars.length;
				specialVars.push(importedClass);
			}

			var trimmedName = (varName != null) ? varName : path.substr(path.lastIndexOf(".") + 1, path.length);

			Lua.newtable(luaState);
			var tableIndex = Lua.gettop(luaState); // The variable position of the table. Used for paring the metatable with this table and attaching variables.
			Lua.pushvalue(luaState, tableIndex);
			Lua.setglobal(luaState, trimmedName);

			Lua.pushstring(luaState, '__special_id'); // This is a helper var in the table that is used by the conversion functions to detect a special var.
			Lua.pushinteger(luaState, location);
			Lua.settable(luaState, tableIndex);

			Lua.pushstring(luaState, "new"); // This implements the work around function to create the class instance.
			Lua.pushcfunction(luaState, workaroundCallable);
			Lua.rawset(luaState, tableIndex);

			LuaL.getmetatable(luaState, "__scriptMetatable");
			Lua.setmetatable(luaState, tableIndex);
		} else if (importedEnum != null) {
			var location = specialVars.indexOf(importedEnum);
			if (location < 0) {
				location = specialVars.length;
				specialVars.push(importedEnum);
			}

			var trimmedName = (varName != null) ? varName : path.substr(path.lastIndexOf(".") + 1, path.length);

			Lua.newtable(luaState);
			var tableIndex = Lua.gettop(luaState); // The variable position of the table. Used for paring the metatable with this table.
			Lua.pushvalue(luaState, tableIndex);
			Lua.setglobal(luaState, trimmedName);

			Lua.pushstring(luaState, '__special_id'); // This is a helper var in the table that is used by the conversion functions to detect a class.
			Lua.pushinteger(luaState, location);
			Lua.settable(luaState, tableIndex);

			LuaL.getmetatable(luaState, "__enumMetatable");
			Lua.setmetatable(luaState, tableIndex);
		} else {
			Logs.trace('Error occured on Lua script ($fileName) trying to import a class/enum: Unable to find class/enum from path "$path".', ERROR);
		}
	}
	#end

	override function destroy() {
		#if linc_luajit
		Lua.close(luaState);
		luaState = null;
		#end
		super.destroy();
	}
}
