# Yoshi Engine - Lua Documentation
## How to use Lua in Yoshi Engine ?
This page covers up the new Lua update, and how to use the new language.
The language communicates with the engine this way :

Using the `set`, `get`, `call` and `createClass` functions, the language can edit values in the `variables` map, which is the same as the hscript global variables, for example :
```haxe
function create() {
    PlayState.health = 1;
}
```
in Lua would be :
```lua
function create()
    set("PlayState.health", 1)
end
```
This is the syntax for a simple health change. We'll see how we can push it further

## The `set` command.
Syntax :
`set(path, value)`

`path`: "Path" to the value (ex : `"PlayState.health"`)

`value`: New value (can be anything.)

To use a global value that can't be translated in lua, use `"$value"` for the value parameter.

For example, `set("PlayState.health", "$newHealth")`

## The `get` command.
Syntax :
`get(path, ?globalValue)`

`path`: "Path" to the value (ex : `"PlayState.health"`)

`?global`: If set, will set the result value to the global variable of that name, and returns true.

Example usage :
```lua
function create()
    get("PlayState.health", "health")
    set("health", 1.5)
    set("PlayState.health", "$health")
end
```

## The `call` command.
Syntax : `call(path, ?globalVar, ?args)`

`path`: "Path" of the function (example : `PlayState.dad.playAnim`)
`globalVar`: Will set the value to the