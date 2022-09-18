== DROP YOUR CUSTOM STATES SCRIPTS HERE ==

Example Tree:
└───states
    │   My Custom State.hx

Custom States can be switched to this way:

[HAXE]	FlxG.switchState(new ModState("My Custom State"));
[LUA]	switchState("My Custom State", true);

You can also override some of the main game menus by creating a script with the state name.

For example, creating a file named "MainMenuState.hx" will override the Main Menu.