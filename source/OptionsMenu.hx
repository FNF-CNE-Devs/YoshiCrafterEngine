package;

import FreeplayState.FreeplaySong;
import sys.FileSystem;
import flixel.graphics.frames.FlxAtlasFrames;
import ControlsSettingsSubState.ControlsSettingsSub;
import openfl.display.Preloader.DefaultPreloader;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import lime.utils.Assets;
import EngineSettings.Settings;
import Alphabet.AlphaCharacter;

using StringTools;

class FNFOption extends Alphabet {
	public var updateSelected:Float->Void;
	public var checkbox:FlxSprite;
	public var checkboxChecked:Bool = false;
	public var value:Array<AlphaCharacter> = [];
	public var desc:String = "";

	public function new(x:Float, y:Float, text:String, desc:String, updateOnSelected:Float->Void, checkBox:Bool = false, checkBoxChecked:Bool = false, value:String = "") {
		super(x, y, text, true, false, FlxColor.WHITE);
		this.desc = desc;
		this.updateSelected = updateOnSelected;
		if (checkBox) {
			checkbox = new FlxSprite(0, 0);
			checkbox.frames = Paths.getSparrowAtlas("checkboxThingie", "preload");
			checkbox.animation.addByPrefix("checked", "Check Box Selected Static", 30, false);
			checkbox.animation.addByPrefix("unchecked", "Check Box unselected", 30, false);
			checkbox.animation.play("unchecked");
			checkbox.scale.x = checkbox.scale.y = 0.6;
			checkbox.updateHitbox();
			checkbox.animation.play(checkBoxChecked ? "checked" : "unchecked");
			checkbox.antialiasing = true;
			checkbox.x = -checkbox.width * 1.25;
			// checkbox.y = -(members[0].height / 2);
			add(checkbox);
			this.checkboxChecked = checkBoxChecked;
		}
		setValue(value);
	}

	public function check(checked:Bool) {
		if (checkbox != null) {
			// checkbox.animation.play("check", true, !checked);
			checkbox.animation.play(checked ? "checked" : "unchecked", true);
		}
	}

	public function setValue(v:String) {
		// trace(v);
		if (value.length != 0) {
			for (l in value) {
				remove(l);
				l.destroy();
			}
			value = [];
		}
		if (v.length == 0) return;
		var lastLetterPos:Float = 20;
		var i = v.length - 1;
		while (i != -1) {
			var char:String = v.charAt(i);
			// trace(i);
			// trace(char);
			var type = -1;
			// var capital = char.toUpperCase() == char;
			if (Alphabet.AlphaCharacter.alphabet.indexOf(char.toLowerCase()) != -1) type = 0;
			if (Alphabet.AlphaCharacter.numbers.indexOf(char) != -1) type = 1;
			if (Alphabet.AlphaCharacter.symbols.indexOf(char) != -1) type = 2;

			var alphaCharacter:Alphabet.AlphaCharacter = new Alphabet.AlphaCharacter(Std.int(FlxG.width - 120 - lastLetterPos), 20, FlxColor.WHITE);

			alphaCharacter.setGraphicSize(Std.int(alphaCharacter.width * 0.5));
			switch(type) {
				case 0:
					alphaCharacter.createLetter(char);
					alphaCharacter.updateHitbox();
					value.push(alphaCharacter);
					add(alphaCharacter);
					alphaCharacter.y -= 60;
					alphaCharacter.x -= AlphaCharacter.widths[char] != null ? (Std.int(AlphaCharacter.widths[char] / 2)) : Std.int(alphaCharacter.width);
					lastLetterPos += AlphaCharacter.widths[char] != null ? (Std.int(AlphaCharacter.widths[char] / 2)) : Std.int(alphaCharacter.width) + 5;
				case 1:
					alphaCharacter.createNumber(char, true);
					alphaCharacter.updateHitbox();
					value.push(alphaCharacter);
					add(alphaCharacter);
					alphaCharacter.y -= 60;
					lastLetterPos += AlphaCharacter.widths[char] != null ? (Std.int(AlphaCharacter.widths[char] / 2)) : Std.int(alphaCharacter.width) + 5;
				case 2:
					alphaCharacter.createSymbol(char);
					alphaCharacter.updateHitbox();
					value.push(alphaCharacter);
					add(alphaCharacter);
					if (char == ".") {
						alphaCharacter.y -= Std.int(57 / 2);
					}
					lastLetterPos += AlphaCharacter.widths[char] != null ? (Std.int(AlphaCharacter.widths[char] / 2)) : Std.int(alphaCharacter.width) + 5;
				default:
					lastLetterPos += 30;
					alphaCharacter.destroy();
			}
			// lastLetterPos += 10;
			i--;
		}
	}

	public function up(elapsed:Float) {
		// super.update(elapsed);
		// if (checkbox != null)
		// 	if (checkbox.animation.curAnim.finished)
		// 		checkbox.animation.play(checkboxChecked ? "checked" : "unchecked", true);
	}
}
typedef MenuCategory = {
	public var name:String;
	public var description:String;
	public var options:Array<Option>;
	public var center:Bool;
}
typedef Option = {
	public var text:String;
	public var description:String;
	public var updateOnSelected:(Float,FNFOption)->Void;
	public var checkbox:Bool;
	public var checkboxChecked:Void->Bool;
	public var value:Void->String;
}
class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;
	var usable:Bool = false;
	public static var fromFreeplay:Bool = false;

	var menuBGx:Float = 0;
	var menuBGy:Float = 0;
	public var optionsAlphabets:FlxSpriteGroup = new FlxSpriteGroup();

	public function new(x:Float, y:Float, ?transIn, ?transOut) {
		super(transIn, transOut);
		menuBGx = x;
		menuBGy = -y;
	}

	public var desc:FlxText;

	public var settings:Array<MenuCategory> = [

	];
	function addControlsCategory() {
		var kBinds:MenuCategory = {
			name : "Keybinds",
			description : "Change your keybinds here !",
			options : [],
			center : false
		};
		kBinds.options.push({
			text : "[Keybinds]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});
		var controlKeys:Array<Int> = [];
		var it = ModSupport.modConfig.keys();
		while(it.hasNext()) {
			var e = it.next();
			var config = ModSupport.modConfig[e];
			if (config.keyNumbers != null) {
				for (k in config.keyNumbers) {
					if (!controlKeys.contains(k)) controlKeys.push(k);
				}
			}
		}
		haxe.ds.ArraySort.sort(controlKeys, function(x, y) {
			return x - y;
		});
		for (index => value in controlKeys) {
			kBinds.options.push({
				text : Std.string(value) + ' keys',
				description : "Change your keybinds for " + Std.string(value) + " keys charts.",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					if (controls.ACCEPT) {
						// FlxG.switchState(new ControlsSettings(value));
						var s = new ControlsSettingsSub(value, FlxG.camera);
						s.closeCallback = function() {
							o.setValue([for(i in 0...value) ControlsSettingsSub.getKeyName(cast(Reflect.field(Settings.engineSettings.data, 'control_' + value + '_$i'), FlxKey), true)].join(" "));
						};
						openSubState(s);
					}
				},
				checkbox: false,
				checkboxChecked: function() {return false;},
				value: function() {return [for(i in 0...value) ControlsSettingsSub.getKeyName(cast(Reflect.field(Settings.engineSettings.data, 'control_' + value + '_$i'), FlxKey), true)].join(" ");}
			});
		}

		kBinds.options.push({
			text : "[]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});
		settings.push(kBinds);
	}

	function addGameplayCategory() {

		var gameplay:MenuCategory = {
			name : "Gameplay",
			description : "Configure Gameplay settings like botplay, downscroll and scroll speed.",
			options : [],
			center : false
		};
		gameplay.options.push({
			text : "[Gameplay]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});
		gameplay.options.push({
			text : "Downscroll",
			description : "When enabled, makes the note go from up to down instead of down to up.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.downscroll = !Settings.engineSettings.data.downscroll;
					o.checkboxChecked = Settings.engineSettings.data.downscroll;
					o.check(Settings.engineSettings.data.downscroll);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.downscroll;},
			value: function() {return "";}
		});
		gameplay.options.push({
			text : "Middlescroll",
			description : "When enabled, moves your strums to the center, and hides the opponents' ones.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.middleScroll = !Settings.engineSettings.data.middleScroll;
					o.checkboxChecked = Settings.engineSettings.data.middleScroll;
					o.check(Settings.engineSettings.data.middleScroll);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.middleScroll;},
			value: function() {return "";}
		});
		gameplay.options.push({
			text : "Custom scroll speed",
			description : "If enabled, sets the scroll speed value to the desired value for all charts. Defaults to disabled.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.customScrollSpeed = !Settings.engineSettings.data.customScrollSpeed;
					o.checkboxChecked = Settings.engineSettings.data.customScrollSpeed;
					o.check(Settings.engineSettings.data.customScrollSpeed);
				}
				if (controls.LEFT_P) {
					Settings.engineSettings.data.scrollSpeed = round(Settings.engineSettings.data.scrollSpeed - 0.1, 2);
					if (Settings.engineSettings.data.scrollSpeed < 0.1) Settings.engineSettings.data.scrollSpeed = 0.1;

					var str = Std.string(Settings.engineSettings.data.scrollSpeed);
					if (str.indexOf(".") == -1) str += ".0";

					o.setValue(str);
				}
				if (controls.RIGHT_P) {
					Settings.engineSettings.data.scrollSpeed = round(Settings.engineSettings.data.scrollSpeed + 0.1, 2);
					if (Settings.engineSettings.data.scrollSpeed > 10) Settings.engineSettings.data.scrollSpeed = 10;

					var str = Std.string(Settings.engineSettings.data.scrollSpeed);
					if (str.indexOf(".") == -1) str += ".0";

					o.setValue(str);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.customScrollSpeed;},
			value: function() {return Std.string(Settings.engineSettings.data.scrollSpeed).indexOf(".") == -1 ? Std.string(Settings.engineSettings.data.scrollSpeed) + ".0" : Std.string(Settings.engineSettings.data.scrollSpeed);}
		});
		gameplay.options.push({
			text : "Botplay",
			description : "When enabled, will let a bot play the game instead of you. Useful for recording mod showcases.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.botplay = !Settings.engineSettings.data.botplay;
					o.checkboxChecked = Settings.engineSettings.data.botplay;
					o.check(Settings.engineSettings.data.botplay);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.botplay;},
			value: function() {return "";}
		});
		gameplay.options.push({
			text : "GUI scale",
			description : "Sets the main GUI's scale. Defaults to 1.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.LEFT_P) {
					Settings.engineSettings.data.noteScale = round((Settings.engineSettings.data.noteScale * 2) - 0.1, 2) / 2;
					if (Settings.engineSettings.data.noteScale < 0.1) Settings.engineSettings.data.noteScale = 0.1;

					var str = Std.string(Settings.engineSettings.data.noteScale);
					if (str.indexOf(".") == -1) str += ".0";

					o.setValue(str);
				}
				if (controls.RIGHT_P) {
					Settings.engineSettings.data.noteScale = round((Settings.engineSettings.data.noteScale * 2) + 0.1, 2) / 2;
					if (Settings.engineSettings.data.noteScale > 10) Settings.engineSettings.data.noteScale = 10;

					var str = Std.string(Settings.engineSettings.data.noteScale);
					if (str.indexOf(".") == -1) str += ".0";

					o.setValue(str);
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return Std.string(Settings.engineSettings.data.noteScale).indexOf(".") == -1 ? Std.string(Settings.engineSettings.data.noteScale) + ".0" : Std.string(Settings.engineSettings.data.noteScale);}
		});
		gameplay.options.push({
			text : "Accuracy mode",
			description : "Sets the accuracy mode. \"Simple\" means based on the rating, \"Complex\" means based on the press delay.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					var newVar = Settings.engineSettings.data.accuracyMode + 1;
					if (newVar >= ScoreText.accuracyTypesText.length) newVar = 0;
					Settings.engineSettings.data.accuracyMode = newVar;
					o.setValue(ScoreText.accuracyTypesText[newVar]);
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return ScoreText.accuracyTypesText[Settings.engineSettings.data.accuracyMode];}
		});
		gameplay.options.push({
			text : "[]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});

		settings.push(gameplay);
	}

	function addHealthBarRatingCategory() {
		var guiOptions:MenuCategory = {
			name : "GUI Options",
			description : "Configure GUI options like enabling and disabling the timer, accuracy, misses, ect...",
			options : [],
			center : false
		};
		guiOptions.options.push(
		{
			text : "[GUI Options]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});
		guiOptions.options.push({
			text : "Show timer",
			description : "If enabled, shows a timer at the top of the screen displaying the current song's position.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showTimer = !Settings.engineSettings.data.showTimer;
					o.checkboxChecked = Settings.engineSettings.data.showTimer;
					o.check(Settings.engineSettings.data.showTimer);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showTimer;},
			value: function() {return "";}
		});
		guiOptions.options.push({
			text : "Show press delay",
			description : "If enabled, will show the delay in milliseconds above the strums everytime you press.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showPressDelay = !Settings.engineSettings.data.showPressDelay;
					o.checkboxChecked = Settings.engineSettings.data.showPressDelay;
					o.check(Settings.engineSettings.data.showPressDelay);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showPressDelay;},
			value: function() {return "";}
		});
		guiOptions.options.push({
			text : "Show accuracy",
			description : "If enabled, will add your accuracy next to the score.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showAccuracy = !Settings.engineSettings.data.showAccuracy;
					o.checkboxChecked = Settings.engineSettings.data.showAccuracy;
					o.check(Settings.engineSettings.data.showAccuracy);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showAccuracy;},
			value: function() {return "";}
		});
		guiOptions.options.push({
			text : "Show number of misses",
			description : "If enabled, will add the amount of misses next to the score.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showMisses = !Settings.engineSettings.data.showMisses;
					o.checkboxChecked = Settings.engineSettings.data.showMisses;
					o.check(Settings.engineSettings.data.showMisses);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showMisses;},
			value: function() {return "";}
		});
		guiOptions.options.push({
			text : "Show ratings amount",
			description : "If enabled, will add the number of notes hit for each rating at the bottom left of the screen.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showRatingTotal = !Settings.engineSettings.data.showRatingTotal;
					o.checkboxChecked = Settings.engineSettings.data.showRatingTotal;
					o.check(Settings.engineSettings.data.showRatingTotal);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showRatingTotal;},
			value: function() {return "";}
		});
		guiOptions.options.push({
			text : "Show average hit delay",
			description : "If enabled, will add your average delay in milliseconds next to the score.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showAverageDelay = !Settings.engineSettings.data.showAverageDelay;
					o.checkboxChecked = Settings.engineSettings.data.showAverageDelay;
					o.check(Settings.engineSettings.data.showAverageDelay);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showAverageDelay;},
			value: function() {return "";}
		});
		guiOptions.options.push({
			text : "Show rating",
			description : "If enabled, will show your rating next to the score (ex : FC).",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showRating = !Settings.engineSettings.data.showRating;
					o.checkboxChecked = Settings.engineSettings.data.showRating;
					o.check(Settings.engineSettings.data.showRating);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.showRating;},
			value: function() {return "";}
		});
		guiOptions.options.push({
			text : "Animate the info bar",
			description : "If enabled, will \"pop\" the info bar at the bottom of the screen everytime you press a note.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.animateInfoBar = !Settings.engineSettings.data.animateInfoBar;
					o.checkboxChecked = Settings.engineSettings.data.animateInfoBar;
					o.check(Settings.engineSettings.data.animateInfoBar);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.animateInfoBar;},
			value: function() {return "";}
		});
		
		guiOptions.options.push({
			text : "[]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});

		settings.push(guiOptions);
	}

	function addCustomNotesCategory() {
		var customisation:MenuCategory = {
			name : "Customisation",
			description : "Customise and make FNF yours ! Note colors, custom note skins, Boyfriend skins, Girlfriend skins.",
			options : [],
			center : false
		};

		customisation.options.push({
			text : "[Customisation]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});
		customisation.options.push({
			text : "Glow CPU strums",
			description : "Check this to glow CPU strums whenever they hit a note.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.glowCPUStrums = !Settings.engineSettings.data.glowCPUStrums;
					o.checkboxChecked = Settings.engineSettings.data.glowCPUStrums;
					o.check(Settings.engineSettings.data.glowCPUStrums);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.glowCPUStrums;},
			value: function() {return "";}
		});
		customisation.options.push({
			text : "Custom note colors",
			description : "Check this to enable custom note colors.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.customArrowColors = !Settings.engineSettings.data.customArrowColors;
					o.checkboxChecked = Settings.engineSettings.data.customArrowColors;
					o.check(Settings.engineSettings.data.customArrowColors);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.customArrowColors;},
			value: function() {return "";}
		});
		customisation.options.push({
			text : "Transparent note tails",
			description : "If enabled, will make sustain notes (note tails) semi-transparent.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.transparentSubstains = !Settings.engineSettings.data.transparentSubstains;
					o.checkboxChecked = Settings.engineSettings.data.transparentSubstains;
					o.check(Settings.engineSettings.data.transparentSubstains);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.transparentSubstains;},
			value: function() {return "";}
		});
		customisation.options.push({
			text : "Apply notes colors on everyone",
			description : "If checked, will also apply your character note colors to the opponent.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.customArrowColors_allChars = !Settings.engineSettings.data.customArrowColors_allChars;
					o.checkboxChecked = Settings.engineSettings.data.customArrowColors_allChars;
					o.check(Settings.engineSettings.data.customArrowColors_allChars);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.customArrowColors_allChars;},
			value: function() {return "";}
		});
		

		customisation.options.push({
			text : "Customize your arrows",
			description : "Select this to customize your arrow colors.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					FlxG.switchState(new OptionsNotesColors());
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});

		#if sys
			if (sys.FileSystem.exists(Paths.getSkinsPath() + "/notes/")) {
				var skins:Array<String> = [];
				skins.insert(0, "default");
				var sPath = Paths.getSkinsPath();
				for (f in FileSystem.readDirectory('$sPath/notes/')) {
					if (f.endsWith(".png") && !FileSystem.isDirectory('$sPath/notes/$f')) {
						var skinName = f.substr(0, f.length - 4);
						if (FileSystem.exists('$sPath/notes/$skinName.xml')) {
							skins.push(skinName);
						}
					}
				}

				if (skins.indexOf(Settings.engineSettings.data.customArrowSkin) == -1) Settings.engineSettings.data.customArrowSkin = "default";
				var pos:Int = skins.indexOf(Settings.engineSettings.data.customArrowSkin);

				customisation.options.push({
					text : "Arrow skin",
					description : "Select an arrow skin here. To install one, open the \"skins\" folder and follow the instructions in the text file.",
					updateOnSelected: function(elapsed:Float, o:FNFOption) {
						var changed = false;
						if (controls.LEFT_P) {
							pos--;
							changed = true;
						}
						if (controls.RIGHT_P || controls.ACCEPT) {
							pos++;
							changed = true;
						}
						if (changed) {
							if (pos < 0) pos = skins.length - 1;
							if (pos >= skins.length) pos = 0;
							Settings.engineSettings.data.customArrowSkin = skins[pos];
							o.setValue(Settings.engineSettings.data.customArrowSkin);
						}
					},
					checkbox: false,
					checkboxChecked: function() {return false;},
					value: function() {return Settings.engineSettings.data.customArrowSkin;}
				});
			}
			
			var bfSkins:Array<String> = [for (s in sys.FileSystem.readDirectory(Paths.getSkinsPath() + "/bf/")) if (FileSystem.isDirectory('${Paths.getSkinsPath()}/bf/$s')) s];
			bfSkins.insert(0, "default");
			bfSkins.remove("template");
	
			if (bfSkins.indexOf(Settings.engineSettings.data.customBFSkin) == -1) Settings.engineSettings.data.customBFSkin = "default";
			var posBF:Int = bfSkins.indexOf(Settings.engineSettings.data.customBFSkin);
	
			customisation.options.push({
				text : "Boyfriend skin",
				description : "Select a Boyfriend skin from a mod, or from your skins folder.",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					var changed = false;
					if (controls.LEFT_P) {
						posBF--;
						changed = true;
					}
					if (controls.RIGHT_P || controls.ACCEPT) {
						posBF++;
						changed = true;
					}
					if (changed) {
						if (posBF < 0) posBF = bfSkins.length - 1;
						if (posBF >= bfSkins.length) posBF = 0;
						Settings.engineSettings.data.customBFSkin = bfSkins[posBF].toLowerCase();
						o.setValue(Settings.engineSettings.data.customBFSkin);
					}
				},
				checkbox: false,
				checkboxChecked: function() {return false;},
				value: function() {return Settings.engineSettings.data.customBFSkin;}
			});
		

			var gfSkins:Array<String> = [for (s in sys.FileSystem.readDirectory(Paths.getSkinsPath() + "/gf/")) if (FileSystem.isDirectory('${Paths.getSkinsPath()}/gf/$s')) s];
			gfSkins.insert(0, "default");
			gfSkins.remove("template");

			var posGF:Int = gfSkins.indexOf(Settings.engineSettings.data.customGFSkin);
	
			if (gfSkins.indexOf(Settings.engineSettings.data.customGFSkin) == -1) Settings.engineSettings.data.customGFSkin = "default";
	
			customisation.options.push({
				text : "Girlfriend skin",
				description : "Select a Girlfriend skin from a mod, or from your skins folder.",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					var changed = false;
					if (controls.LEFT_P) {
						posGF--;
						changed = true;
					}
					if (controls.RIGHT_P || controls.ACCEPT) {
						posGF++;
						changed = true;
					}
					if (changed) {
						if (posGF < 0) posGF = gfSkins.length - 1;
						if (posGF >= gfSkins.length) posGF = 0;
						Settings.engineSettings.data.customGFSkin = gfSkins[posGF].toLowerCase();
						o.setValue(Settings.engineSettings.data.customGFSkin);
					}
				},
				checkbox: false,
				checkboxChecked: function() {return false;},
				value: function() {return Settings.engineSettings.data.customGFSkin;}
			});
			
		#end

		#if desktop
		customisation.options.push({
			text : "Open skin folder",
			description : "Select this to open the skins folder.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					var p = Paths.getSkinsPath().replace("/", "\\");
					trace(p);
					#if windows
						Sys.command('explorer "$p"');	
					#end
					#if linux
						Sys.command('nautilus', [p]);	
					#end
				}
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});
		#end

		customisation.options.push({
			text : "[]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});

		settings.push(customisation);
	}

	function addPerformanceCategory() {
		var performance:MenuCategory = {
			name : "Optimisation and Performances",
			description : "Optimise the engine with memory and graphics settings.",
			options : [],
			center : false
		};
		performance.options.push({
			text : "[Optimisation and Performances]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});
		
		performance.options.push(
			{
				text : "Freeplay Cooldown",
				description : "If checked, will wait the specified number of seconds in the freeplay menu before automatically playing the song.",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					if (controls.LEFT_P) {
						Settings.engineSettings.data.freeplayCooldown = round(Settings.engineSettings.data.freeplayCooldown - 0.1, 2);
						if (Settings.engineSettings.data.freeplayCooldown < 0) Settings.engineSettings.data.freeplayCooldown = 0;
	
						var str = Std.string(Settings.engineSettings.data.freeplayCooldown);
						if (str.indexOf(".") == -1) str += ".0";
	
						o.setValue(str);
					}
					if (controls.RIGHT_P) {
						Settings.engineSettings.data.freeplayCooldown = round(Settings.engineSettings.data.freeplayCooldown + 0.1, 2);
						if (Settings.engineSettings.data.freeplayCooldown > 10) Settings.engineSettings.data.freeplayCooldown = 10;
	
						var str = Std.string(Settings.engineSettings.data.freeplayCooldown);
						if (str.indexOf(".") == -1) str += ".0";
	
						o.setValue(str);
					}
					if (controls.ACCEPT) {
						Settings.engineSettings.data.autoplayInFreeplay = !Settings.engineSettings.data.autoplayInFreeplay;
						o.check(Settings.engineSettings.data.autoplayInFreeplay);
					}
				},
				checkbox: true,
				checkboxChecked: function() {return Settings.engineSettings.data.autoplayInFreeplay;},
				value: function() {return Std.string(Settings.engineSettings.data.freeplayCooldown).indexOf(".") == -1 ? Std.string(Settings.engineSettings.data.freeplayCooldown) + ".0" : Std.string(Settings.engineSettings.data.freeplayCooldown);}
			});
		
		performance.options.push(
			{
				text : "Maximum Framerate",
				description : "Sets the maximum framerate the game can have. If the value is higher than what's your " + #if desktop "computer" #elseif android "phone/tablet" #else "device" #end + " is capable of, slowdowns during animations may happen.",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					if (controls.LEFT_P || (controls.LEFT && FlxG.keys.pressed.SHIFT)) {
						Settings.engineSettings.data.fpsCap -= 5;
						if (Settings.engineSettings.data.fpsCap < 20) Settings.engineSettings.data.fpsCap = 20;
	
						o.setValue(Settings.engineSettings.data.fpsCap);
						FlxG.drawFramerate = Settings.engineSettings.data.fpsCap;
						FlxG.updateFramerate = Settings.engineSettings.data.fpsCap;
					}
					if (controls.RIGHT_P || (controls.RIGHT && FlxG.keys.pressed.SHIFT)) {
						Settings.engineSettings.data.fpsCap += 5;
						if (Settings.engineSettings.data.fpsCap > 400) Settings.engineSettings.data.fpsCap = 400;
	
						o.setValue(Settings.engineSettings.data.fpsCap);
						FlxG.drawFramerate = Settings.engineSettings.data.fpsCap;
						FlxG.updateFramerate = Settings.engineSettings.data.fpsCap;
					}
				},
				checkbox: false,
				checkboxChecked: function() {return false;},
				value: function() {return Settings.engineSettings.data.fpsCap;}
			});
		performance.options.push({
			text : "Enable antialiasing on videos",
			description : "If checked, will enable antialiasing on MP4 videos (cutscenes, ect...)",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.videoAntialiasing = !Settings.engineSettings.data.videoAntialiasing;
					o.checkboxChecked = Settings.engineSettings.data.videoAntialiasing;
					o.check(Settings.engineSettings.data.videoAntialiasing);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.videoAntialiasing;},
			value: function() {return "";}
		});
		performance.options.push({
			text : "Memory Optimisation",
			description : "If checked, will optimize the memory of the game by clearing the assets.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.memoryOptimization = !Settings.engineSettings.data.memoryOptimization;
					o.checkboxChecked = Settings.engineSettings.data.memoryOptimization;
					o.check(Settings.engineSettings.data.memoryOptimization);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.memoryOptimization;},
			value: function() {return "";}
		});
		#if sys
		performance.options.push({
			text : "Auto clear skin cache",
			description : "If checked, will automatically empty cache after each song.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.emptySkinCache = !Settings.engineSettings.data.emptySkinCache;
					o.checkboxChecked = Settings.engineSettings.data.emptySkinCache;
					o.check(Settings.engineSettings.data.emptySkinCache);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.emptySkinCache;},
			value: function() {return "";}
		});
		performance.options.push({
			text : "Clear skin cache",
			description : "If checked, will optimize the memory of the game.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Paths.clearCache();
					o.setValue("cache deleted");
				}
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});
		#end
		performance.options.push({
			text : "[]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});
		settings.push(performance);
	}

	function addMiscCategory() {
		var misc:MenuCategory = {
			name : "Miscellaneous",
			description : "Other options like Green Screen and hiding original game.",
			options : [],
			center : false
		};
		misc.options.push({
			text : "[Miscellaneous]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});
		misc.options.push({
			text : "Green screen mode",
			description : "When enabled, shows a green screen behind the GUI.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.greenScreenMode = !Settings.engineSettings.data.greenScreenMode;
					o.checkboxChecked = Settings.engineSettings.data.greenScreenMode;
					o.check(Settings.engineSettings.data.greenScreenMode);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.greenScreenMode;},
			value: function() {return "";}
		});
		misc.options.push({
			text : "Hide original game",
			description : "When enabled, hides the base game from the Story Menu and Freeplay if any other mod is present.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.hideOriginalGame = !Settings.engineSettings.data.hideOriginalGame;
					o.checkboxChecked = Settings.engineSettings.data.hideOriginalGame;
					o.check(Settings.engineSettings.data.hideOriginalGame);

					StoryMenuState.loadWeeks();
					FreeplayState.loadFreeplaySongs();
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.hideOriginalGame;},
			value: function() {return "";}
		});
		// misc.options.push({
		// 	text : "Use new charter",
		// 	updateOnSelected: function(elapsed:Float, o:FNFOption) {
		// 		if (controls.ACCEPT) {
		// 			Settings.engineSettings.data.yoshiEngineCharter = !Settings.engineSettings.data.yoshiEngineCharter;
		// 			o.checkboxChecked = Settings.engineSettings.data.yoshiEngineCharter;
		// 			o.check(Settings.engineSettings.data.yoshiEngineCharter);
		// 		}
		// 	},
		// 	checkbox: true,
		// 	checkboxChecked: function() {return Settings.engineSettings.data.yoshiEngineCharter,
		// 	value: ""
		// });
		misc.options.push({
			text : "[]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});
		settings.push(misc);
	}

	function addDeveloperCategory() {
		var dev:MenuCategory = {
			name : "Developer Menu",
			description: "Developer related options.",
			options : [],
			center : false
		};
		dev.options.push({
			text : "[Developer Menu]",
			description : "",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: function() {return false;},
			value: function() {return "";}
		});
		dev.options.push({
			text : "Developer Mode",
			description : "When checked, enables Developer Mode, which gives access to Logs, and autoclears cache after every state change.",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.developerMode = !Settings.engineSettings.data.developerMode;
					o.check(Settings.engineSettings.data.developerMode);
				}
			},
			checkbox: true,
			checkboxChecked: function() {return Settings.engineSettings.data.developerMode;},
			value: function() {return "";}
		});
		settings.push(dev);
	}
	

	function setOptions(?o2:MenuCategory) {
		for (op in optionsAlphabets) {
			remove(op);
			optionsAlphabets.remove(op);
			op.destroy();
		}
		optionsAlphabets.clear();
		usable = false;
		var ops = o2;
		if (ops == null) {
			var s:Array<Option> = [];

			for (mc in settings) {
				s.push({
					text : mc.name,
					description : mc.description,
					value : function() {return "";},
					checkboxChecked: function() {return false;},
					checkbox: false,
					updateOnSelected: function(elapsed, option) {
						if (controls.ACCEPT) {
							setOptions(mc);
							isInCategory = true;
						}
					}
				});
			}

			ops = {
				name: "Main Menu",
				options: s,
				description: "Select an option to continue.",
				center: true
			}
		}
		disabledOptions = [];
		for (i in 0...ops.options.length) {
			var o:Option = ops.options[i];
			var op = null;
			var text = o.text;

			var isTitle = ops.center;
			if (o.text.charAt(0) == "[" && o.text.charAt(o.text.length - 1) == "]") {
				text = o.text.substr(1, o.text.length - 2);
				isTitle = true;
				disabledOptions.push(i);
			}
			op = new FNFOption(0, 0 + (i * 80), text, o.description, function(elapsed:Float) {
				o.updateOnSelected(elapsed, op);
			}, o.checkbox, o.checkboxChecked(), "");
			for (i in 0...op.length) {
				var a = op.members[i];
				if (a != op.checkbox) {
					a.setGraphicSize(Std.int(a.width * 0.75));
					if (isTitle) {
						a.x = ((FlxG.width - 100) / 2) - (40 * ((o.checkbox ? op.length - 1 : op.length) / 2)) + (a.x * 0.75);
					} else {
						a.x = a.x * 0.75;
					}
				}
			}
			op.setValue(o.value());
			op.x += 50;
			if (!isTitle) op.x += 50;
			optionsAlphabets.add(op);
		}

		optionsAlphabets.y = FlxG.height * 3;
		curSelected = -1;
		changeSelection(1, false);
		FlxTween.tween(optionsAlphabets, {y: (FlxG.height / 2) - (69 / 2) - (curSelected * 80)}, 0.5, {ease : FlxEase.cubeInOut, onComplete: function(t) {
			usable = true;
		}});
	}

	
	override function create()
	{
		addControlsCategory();
		addGameplayCategory();
		addHealthBarRatingCategory();
		addCustomNotesCategory();
		addPerformanceCategory();
		addMiscCategory();
		addDeveloperCategory();

		if (FlxG.sound.music != null) {
			FlxG.sound.music.onComplete = null;
			if (!FlxG.sound.music.playing) {
				FlxG.sound.music.play();
				FlxG.sound.music.looped = true;
			}
		}

		// FlxAtlasFrames.fromTexturePackerJson()
		

		var yBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGYoshi'));
		yBG.setGraphicSize(Std.int(yBG.width * 1.1));
		yBG.updateHitbox();
		yBG.screenCenter();
		yBG.y = -menuBGy + 23;
		yBG.antialiasing = true;
		add(yBG);

		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		menuBG.color = 0xFFfd719b;
		// menuBG.color = 0xFF494949;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.y = -menuBGy + 23;
		// menuBG.color.
		menuBG.antialiasing = true;
		add(menuBG);

		// var blackSelectionBar = new FlxSprite(0, (FlxG.height / 2) - (69 / 2)).makeGraphic(Std.int(FlxG.width), 69, new FlxColor(0x88000000));
		// blackSelectionBar.alpha = 0;
		// add(blackSelectionBar);
		optionsAlphabets.scrollFactor.set(0, 0);
		add(optionsAlphabets);
		// FlxTween.tween(menuBG, {"color.red" : 0x49, "color.green" : 0x49, "color.blue" : 0x49}, 0.5, {ease : FlxEase.linear, onComplete: function(t:FlxTween) {
		// 	usable = true;
		// }});
		
		// FlxTween.color(menuBG, 0.5, 0xFFFDE871, 0xFF494949, {ease : FlxEase.cubeInOut, onComplete: function(t:FlxTween) {
		// 	usable = true;
		// }});
		FlxTween.tween(menuBG, {alpha : 0}, 0.5, {onComplete: function(t) {
			usable = true;
			remove(menuBG);
			menuBG.destroy();
		}});
		// FlxTween.tween(blackSelectionBar, {alpha : 1}, 0.5, {ease : FlxEase.cubeInOut});

		// controlsStrings = CoolUtil.coolTextFile(Paths.txt('controls'));

		desc = new FlxText(0, 0, 1280, "Select an option...", 8);
		desc.y = 720;
		desc.setFormat(Paths.font("vcr.ttf"), Std.int(20), FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		desc.antialiasing = true;
		desc.borderSize = 2;
		add(desc);

		setOptions();
		super.create();

		// openSubState(new OptionsSubState());
	}
	var isInCategory = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!usable) return;

		if (controls.BACK) {
			CoolUtil.playMenuSFX(2);
			if (isInCategory) {
				setOptions();
				isInCategory = false;
				return;
			} else {
				if (fromFreeplay)
					FlxG.switchState(new PlayState());
				else
					FlxG.switchState(new MainMenuState());
			}
		}
			
		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);
		
		optionsAlphabets.y = FlxMath.lerp(optionsAlphabets.y, (FlxG.height / 2) - (69 / 2) - (curSelected * 80), CoolUtil.wrapFloat(0.1 / 60 / elapsed, 0, 1));
		

		for (i in 0...optionsAlphabets.members.length) {
			if (optionsAlphabets.members[i] != null) (cast (optionsAlphabets.members[i], FNFOption)).up(elapsed);
		}
		if (optionsAlphabets.members[curSelected] != null) (cast (optionsAlphabets.members[curSelected], FNFOption)).updateSelected(elapsed);
	}

	function waitingInput():Void
	{
		// if (FlxG.keys.getIsDown().length > 0)
		// {
		// 	PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxG.keys.getIsDown()[0].ID, null);
		// }
		// PlayerSettings.player1.controls.replaceBinding(Control)
	}

	var isSettingControl:Bool = false;

	function changeBinding():Void
	{
		if (!isSettingControl)
		{
			isSettingControl = true;
		}
	}

	// https://stackoverflow.com/questions/23689001/how-to-reliably-format-a-floating-point-number-to-a-specified-number-of-decimal
	public static function round(number:Float, ?precision=2): Float
	{
		number *= Math.pow(10, precision);
		return Math.round(number) / Math.pow(10, precision);
	}

	public var disabledOptions:Array<Int> = [];
	// public var ghreuighesioghseuiogseruiogbseruigbseruiogbretgubgiobreg:FlxTween;
	function changeSelection(change:Int = 0, animate:Bool = true)
	{
		#if !switch
		// NGio .logEvent('Fresh');
		#end

		curSelected += change;
		if (curSelected < 0) curSelected = optionsAlphabets.length - 1;
		if (curSelected >= optionsAlphabets.length) curSelected = 0;

		
		while(disabledOptions.contains(curSelected)) {
			curSelected += change;
			if (curSelected < 0) curSelected = optionsAlphabets.length - 1;
			if (curSelected >= optionsAlphabets.length) curSelected = 0;
		}
		for(k=>op in optionsAlphabets.members) {
			if (k == curSelected) {
				op.alpha = 0.45;
				desc.text = cast(op, FNFOption).desc;
				desc.y = 700 - (desc.height);
			} else {
				op.alpha = (disabledOptions.contains(k)) ? 1 : 0.45;
			}
		}
		if (!animate) return;
		// if (ghreuighesioghseuiogseruiogbseruigbseruiogbretgubgiobreg != null) ghreuighesioghseuiogseruiogbseruigbseruiogbretgubgiobreg.cancel();
		// FlxTween.tween(optionsAlphabets, {y: (FlxG.height / 2) - (69 / 2) - (curSelected * 80)}, 0.1, {ease : FlxEase.quadInOut});
		// optionsAlphabets.y = ;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}
}
