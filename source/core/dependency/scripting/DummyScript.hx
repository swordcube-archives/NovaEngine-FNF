package core.dependency.scripting;

import core.dependency.ScriptHandler;

/**
 * The class used for handling non-existent/incompatible scripts.
 */
class DummyScript extends ScriptModule {
    public function new(path:String, fileName:String = "dummy") {
        super(path, fileName);
        Logs.trace('Either the script at path: $path couldn\'t be found, or this script is unsupported! Dummy script loaded instead.', ERROR);
    }
}