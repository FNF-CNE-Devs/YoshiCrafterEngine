package options.screens;

import flixel.FlxG;
import EngineSettings.Settings;

class MiscMenu extends OptionScreen {
    public override function create() {
        options = [
            {
                name: "Auto Check for Updates",
                desc: "If enabled, will automatically look for updates, and prompt you if one is available.\nDisable if the antivirus blocks the engine.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.checkForUpdates);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.checkForUpdates = !Settings.engineSettings.data.checkForUpdates);},
            },
            {
                name: "Green Screen Mode",
                desc: "If enabled, will show a green screen behind the GUI, for green screen videos.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.greenScreenMode);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.greenScreenMode = !Settings.engineSettings.data.greenScreenMode);},
            },
            {
                name: "Hide OG songs",
                desc: "If enabled, will hide the original songs from the freeplay menu.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.hideOriginalGame);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.hideOriginalGame = !Settings.engineSettings.data.hideOriginalGame);},
            },
            {
                name: "Auto Pause",
                desc: "If disabled, the game will no longer pause when it loses focus.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.autopause);},
                onSelect: function(e) {FlxG.autoPause = e.check(Settings.engineSettings.data.autopause = !Settings.engineSettings.data.autopause);},
            },
            {
                name: "Separate mods in freeplay",
                desc: "If disabled, will only list the selected mod's songs.",
                value: "",
                onCreate: function(e) {e.check(!Settings.engineSettings.data.freeplayShowAll);},
                onSelect: function(e) {e.check(!(Settings.engineSettings.data.freeplayShowAll = !Settings.engineSettings.data.freeplayShowAll));},
            },
            {
                name: "Auto add new mods",
                desc: "If enabled, will automatically add new installed mods once game gains focus again.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.autoSwitchToLastInstalledMod);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.autoSwitchToLastInstalledMod = !Settings.engineSettings.data.autoSwitchToLastInstalledMod);},
            },
            {
                name: "Show FPS counter",
                desc: "If enabled, will show a counter with the current FPS.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.fps_showFPS);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.fps_showFPS = !Settings.engineSettings.data.fps_showFPS);},
            },
            {
                name: "Show Memory",
                desc: "If enabled, will show a counter with the current memory amount.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.fps_showMemory);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.fps_showMemory = !Settings.engineSettings.data.fps_showMemory);},
            },
            {
                name: "Show Memory Peak",
                desc: "If enabled, will show the maximum amount of memory the game reached.",
                value: "",
                onCreate: function(e) {e.check(Settings.engineSettings.data.fps_showMemoryPeak);},
                onSelect: function(e) {e.check(Settings.engineSettings.data.fps_showMemoryPeak = !Settings.engineSettings.data.fps_showMemoryPeak);},
            },
            {
                name: "Use legacy charter",
                desc: "If enabled, will use the old charter instead of the new one (no longer supported).",
                value: "",
                onCreate: function(e) {e.check(!Settings.engineSettings.data.yoshiCrafterEngineCharter);},
                onSelect: function(e) {e.check(!(Settings.engineSettings.data.yoshiCrafterEngineCharter = !Settings.engineSettings.data.yoshiCrafterEngineCharter));},
            }
        ];
        super.create();
    }
}