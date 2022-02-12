#if ENABLE_LUA
import llua.LuaL;
import flixel.FlxState;
import Script.LuaScript;

class LuaTest extends FlxState {
    public override function new() {
        super();
        var l = new LuaScript();
        // LuaL.dostring(l.state, "print(\"hey\")");
        l.loadFile("test.lua");
        l.setVariable("test", "lol");
        trace(l.executeFunc("re"));
    }
}
#end