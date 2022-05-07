package flixel;

import lime.app.Application;
import openfl.display.Sprite;

class TextInput {
    public var inputText:Array<String> = [];

    public function onTextInput(key:String) {
        inputText.push(key);
    }
    public function new() {
		Application.current.window.onTextInput.add(onTextInput);
    }
    
    public function reset() {
        inputText = [];
    }
}