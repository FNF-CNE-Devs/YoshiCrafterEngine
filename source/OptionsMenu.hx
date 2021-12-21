package;

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
import LoadSettings.Settings;
import Alphabet.AlphaCharacter;

using StringTools;

class FNFOption extends Alphabet {
	public var updateSelected:Float->Void;
	public var checkbox:FlxSprite;
	public var checkboxChecked:Bool = false;
	public var value:Array<AlphaCharacter> = [];

	public function new(x:Float, y:Float, text:String, updateOnSelected:Float->Void, checkBox:Bool = false, checkBoxChecked:Bool = false, value:String = "") {
		super(x, y, text, true, false, FlxColor.WHITE);
		this.updateSelected = updateOnSelected;
		if (checkBox) {
			checkbox = new FlxSprite(0, 0);
			checkbox.frames = Paths.getSparrowAtlas("checkboxThingie", "preload");
			checkbox.animation.addByPrefix("checked", "Check Box Selected Static", 30, false);
			checkbox.animation.addByPrefix("unchecked", "Check Box unselected", 30, false);
			checkbox.animation.addByPrefix("check", "Check Box selecting animation", 30, false);
			checkbox.animation.play("unchecked");
			checkbox.setGraphicSize(Std.int(checkbox.width * 0.4));
			checkbox.animation.play(checkBoxChecked ? "checked" : "unchecked");
			checkbox.antialiasing = true;
			checkbox.x = -checkbox.width / 1.5;
			checkbox.y = -(members[0].height / 2) - 10;
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
typedef Option = {
	public var text:String;
	public var updateOnSelected:(Float,FNFOption)->Void;
	public var checkbox:Bool;
	public var checkboxChecked:Bool;
	public var value:String;
}
class OptionsMenu extends MusicBeatState
{
	var selector:FlxText;
	var curSelected:Int = 0;
	var usable:Bool = false;
	var fromFreeplay:Bool = false;

	var menuBGx:Float = 0;
	var menuBGy:Float = 0;
	public var optionsAlphabets:FlxSpriteGroup = new FlxSpriteGroup();
	public var options:Array<Option> = [
		
	];
	public var controlKeys:Array<Int> = [
		4, 6, 9
	];

	public function new(x:Float, y:Float, fromFreeplay:Bool = false, ?transIn, ?transOut) {
		super(transIn, transOut);
		menuBGx = x;
		menuBGy = -y;
		this.fromFreeplay = fromFreeplay;
	}

	function addControlsCategory() {
		options.push({
			text : "[Keybinds]",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
		});
		

		for (index => value in controlKeys) {
			options.push({
				text : Std.string(value) + ' keys',
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
				checkboxChecked: false,
				value: [for(i in 0...value) ControlsSettingsSub.getKeyName(cast(Reflect.field(Settings.engineSettings.data, 'control_' + value + '_$i'), FlxKey), true)].join(" ")
			});
		}

		options.push({
			text : "[]",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
		});
	}

	function addGameplayCategory() {

		options.push(
			{
				text : "[Gameplay]",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					
				},
				checkbox: false,
				checkboxChecked: false,
				value: ""
			});
			options.push({
				text : "Downscroll",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					if (controls.ACCEPT) {
						Settings.engineSettings.data.downscroll = !Settings.engineSettings.data.downscroll;
						o.checkboxChecked = Settings.engineSettings.data.downscroll;
						o.check(Settings.engineSettings.data.downscroll);
					}
				},
				checkbox: true,
				checkboxChecked: Settings.engineSettings.data.downscroll,
				value: ""
			});
		options.push(
			{
				text : "Custom scroll speed",
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
				checkboxChecked: Settings.engineSettings.data.customScrollSpeed,
				value: Std.string(Settings.engineSettings.data.scrollSpeed).indexOf(".") == -1 ? Std.string(Settings.engineSettings.data.scrollSpeed) + ".0" : Std.string(Settings.engineSettings.data.scrollSpeed)
			});
		options.push(
			{
				text : "GUI scale",
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
				checkboxChecked: false,
				value: Std.string(Settings.engineSettings.data.noteScale).indexOf(".") == -1 ? Std.string(Settings.engineSettings.data.noteScale) + ".0" : Std.string(Settings.engineSettings.data.noteScale)
			});
		options.push(
			{
				text : "Accuracy mode",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					if (controls.ACCEPT) {
						var newVar = Settings.engineSettings.data.accuracyMode + 1;
						if (newVar >= ScoreText.accuracyTypesText.length) newVar = 0;
						Settings.engineSettings.data.accuracyMode = newVar;
						o.setValue(ScoreText.accuracyTypesText[newVar]);
					}
				},
				checkbox: false,
				checkboxChecked: false,
				value: ScoreText.accuracyTypesText[Settings.engineSettings.data.accuracyMode]
			});
		options.push(
			{
				text : "[]",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					
				},
				checkbox: false,
				checkboxChecked: false,
				value: ""
			});
	}

	function addHealthBarRatingCategory() {
		options.push(
			{
				text : "[GUI Options]",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					
				},
				checkbox: false,
				checkboxChecked: false,
				value: ""
			});
			options.push(
			{
				text : "Text quality level",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					if (controls.LEFT_P) {
						Settings.engineSettings.data.textQualityLevel = round(Settings.engineSettings.data.textQualityLevel - 0.5, 2);
						if (Settings.engineSettings.data.textQualityLevel < 1) Settings.engineSettings.data.textQualityLevel = 1;
	
						var str = Std.string(Settings.engineSettings.data.textQualityLevel);
						if (str.indexOf(".") == -1) str += ".0";
	
						o.setValue(str);
					}
					if (controls.RIGHT_P) {
						Settings.engineSettings.data.textQualityLevel = round(Settings.engineSettings.data.textQualityLevel + 0.5, 2);
						if (Settings.engineSettings.data.textQualityLevel > 2.5) Settings.engineSettings.data.textQualityLevel = 2.5;
	
						var str = Std.string(Settings.engineSettings.data.textQualityLevel);
						if (str.indexOf(".") == -1) str += ".0";
	
						o.setValue(str);
					}
				},
				checkbox: false,
				checkboxChecked: false,
				value: Std.string(Settings.engineSettings.data.textQualityLevel).indexOf(".") == -1 ? Std.string(Settings.engineSettings.data.textQualityLevel) + ".0" : Std.string(Settings.engineSettings.data.textQualityLevel)
			});
			options.push({
				text : "Show timer",
				updateOnSelected: function(elapsed:Float, o:FNFOption) {
					if (controls.ACCEPT) {
						Settings.engineSettings.data.showTimer = !Settings.engineSettings.data.showTimer;
						o.checkboxChecked = Settings.engineSettings.data.showTimer;
						o.check(Settings.engineSettings.data.showTimer);
					}
				},
				checkbox: true,
				checkboxChecked: Settings.engineSettings.data.showTimer,
				value: ""
			});
		options.push({
			text : "Show press delay",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showPressDelay = !Settings.engineSettings.data.showPressDelay;
					o.checkboxChecked = Settings.engineSettings.data.showPressDelay;
					o.check(Settings.engineSettings.data.showPressDelay);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.showPressDelay,
			value: ""
		});
		options.push({
			text : "Show accuracy",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showAccuracy = !Settings.engineSettings.data.showAccuracy;
					o.checkboxChecked = Settings.engineSettings.data.showAccuracy;
					o.check(Settings.engineSettings.data.showAccuracy);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.showAccuracy,
			value: ""
		});
		options.push({
			text : "Show number of misses",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showMisses = !Settings.engineSettings.data.showMisses;
					o.checkboxChecked = Settings.engineSettings.data.showMisses;
					o.check(Settings.engineSettings.data.showMisses);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.showMisses,
			value: ""
		});
		options.push({
			text : "Show average hit delay",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showAverageDelay = !Settings.engineSettings.data.showAverageDelay;
					o.checkboxChecked = Settings.engineSettings.data.showAverageDelay;
					o.check(Settings.engineSettings.data.showAverageDelay);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.showAverageDelay,
			value: ""
		});
		options.push({
			text : "Show rating",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.showRating = !Settings.engineSettings.data.showRating;
					o.checkboxChecked = Settings.engineSettings.data.showRating;
					o.check(Settings.engineSettings.data.showRating);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.showRating,
			value: ""
		});
		options.push({
			text : "Animate the info bar",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.animateInfoBar = !Settings.engineSettings.data.animateInfoBar;
					o.checkboxChecked = Settings.engineSettings.data.animateInfoBar;
					o.check(Settings.engineSettings.data.animateInfoBar);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.animateInfoBar,
			value: ""
		});
		
		options.push({
			text : "[]",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
		});
	}

	function addCustomNotesCategory() {
		options.push({
			text : "[Customisation]",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
		});
		options.push({
			text : "Custom note colors",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.customArrowColors = !Settings.engineSettings.data.customArrowColors;
					o.checkboxChecked = Settings.engineSettings.data.customArrowColors;
					o.check(Settings.engineSettings.data.customArrowColors);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.customArrowColors,
			value: ""
		});
		options.push({
			text : "Transparent substains notes",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.transparentSubstains = !Settings.engineSettings.data.transparentSubstains;
					o.checkboxChecked = Settings.engineSettings.data.transparentSubstains;
					o.check(Settings.engineSettings.data.transparentSubstains);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.transparentSubstains,
			value: ""
		});
		options.push({
			text : "Apply notes colors on everyone",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.customArrowColors_allChars = !Settings.engineSettings.data.customArrowColors_allChars;
					o.checkboxChecked = Settings.engineSettings.data.customArrowColors_allChars;
					o.check(Settings.engineSettings.data.customArrowColors_allChars);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.customArrowColors_allChars,
			value: ""
		});
		

		options.push({
			text : "Customize your arrows",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					FlxG.switchState(new OptionsNotesColors());
				}
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
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

				options.push({
					text : "Arrow skin",
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
							Settings.engineSettings.data.customArrowSkin = skins[pos].toLowerCase().replace("\r", "").trim().replace("\n", "");
							o.setValue(Settings.engineSettings.data.customArrowSkin);
						}
					},
					checkbox: false,
					checkboxChecked: false,
					value: Settings.engineSettings.data.customArrowSkin
				});
			}
			
			var bfSkins:Array<String> = sys.FileSystem.readDirectory(Paths.getSkinsPath() + "/bf/");
	
			if (bfSkins.indexOf(Settings.engineSettings.data.customBFSkin) == -1) Settings.engineSettings.data.customBFSkin = "default";
			var posBF:Int = bfSkins.indexOf(Settings.engineSettings.data.customBFSkin);
	
			options.push({
				text : "Boyfriend skin",
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
				checkboxChecked: false,
				value: Settings.engineSettings.data.customBFSkin
			});
		

			var gfSkins:Array<String> = sys.FileSystem.readDirectory(Paths.getSkinsPath() + "/gf/");
			var posGF:Int = gfSkins.indexOf(Settings.engineSettings.data.customGFSkin);
	
			if (gfSkins.indexOf(Settings.engineSettings.data.customGFSkin) == -1) Settings.engineSettings.data.customGFSkin = "default";
	
			options.push({
				text : "Girlfriend skin",
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
				checkboxChecked: false,
				value: Settings.engineSettings.data.customGFSkin
			});
			
		#end

		#if cpp
		options.push({
			text : "Open skin folder",
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
			checkboxChecked: false,
			value: ""
		});
		#end

		options.push({
			text : "[]",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
		});
	}

	function addPerformanceCategory() {
		options.push({
			text : "[Performance]",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
		});
		
		options.push(
			{
				text : "Freeplay Cooldown",
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
				},
				checkbox: false,
				checkboxChecked: false,
				value: Std.string(Settings.engineSettings.data.freeplayCooldown).indexOf(".") == -1 ? Std.string(Settings.engineSettings.data.freeplayCooldown) + ".0" : Std.string(Settings.engineSettings.data.freeplayCooldown)
			});
		options.push({
			text : "Enable antialiasing on videos",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.videoAntialiasing = !Settings.engineSettings.data.videoAntialiasing;
					o.checkboxChecked = Settings.engineSettings.data.videoAntialiasing;
					o.check(Settings.engineSettings.data.videoAntialiasing);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.videoAntialiasing,
			value: ""
		});
		options.push({
			text : "Memory Optimisation",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.memoryOptimization = !Settings.engineSettings.data.memoryOptimization;
					o.checkboxChecked = Settings.engineSettings.data.memoryOptimization;
					o.check(Settings.engineSettings.data.memoryOptimization);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.memoryOptimization,
			value: ""
		});
		#if sys
		options.push({
			text : "Auto clear skin cache",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.emptySkinCache = !Settings.engineSettings.data.emptySkinCache;
					o.checkboxChecked = Settings.engineSettings.data.emptySkinCache;
					o.check(Settings.engineSettings.data.emptySkinCache);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.emptySkinCache,
			value: ""
		});
		options.push({
			text : "Clear skin cache",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Paths.clearCache();
					o.setValue("cache deleted");
				}
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
		});
		#end
		options.push({
			text : "[]",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
		});
	}

	function addMiscCategory() {
		options.push({
			text : "[Misc]",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
		});
		options.push({
			text : "Green screen mode",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.greenScreenMode = !Settings.engineSettings.data.greenScreenMode;
					o.checkboxChecked = Settings.engineSettings.data.greenScreenMode;
					o.check(Settings.engineSettings.data.greenScreenMode);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.greenScreenMode,
			value: ""
		});
		options.push({
			text : "Botplay",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.botplay = !Settings.engineSettings.data.botplay;
					o.checkboxChecked = Settings.engineSettings.data.botplay;
					o.check(Settings.engineSettings.data.botplay);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.botplay,
			value: ""
		});
		options.push({
			text : "Enable blammed effects",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.blammedEffect = !Settings.engineSettings.data.blammedEffect;
					o.checkboxChecked = Settings.engineSettings.data.blammedEffect;
					o.check(Settings.engineSettings.data.blammedEffect);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.blammedEffect,
			value: ""
		});
		options.push({
			text : "Use new charter",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.yoshiEngineCharter = !Settings.engineSettings.data.yoshiEngineCharter;
					o.checkboxChecked = Settings.engineSettings.data.yoshiEngineCharter;
					o.check(Settings.engineSettings.data.yoshiEngineCharter);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.yoshiEngineCharter,
			value: ""
		});
		options.push({
			text : "[]",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
		});
	}

	function addDeveloperCategory() {
		options.push({
			text : "[Developer Mode]",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
		});
		options.push({
			text : "Developer Mode",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.developerMode = !Settings.engineSettings.data.developerMode;
					o.check(Settings.engineSettings.data.developerMode);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.developerMode,
			value: ""
		});
		options.push({
			text : "Enable character debug mode",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				if (controls.ACCEPT) {
					Settings.engineSettings.data.debugMode = !Settings.engineSettings.data.debugMode;
					o.checkboxChecked = Settings.engineSettings.data.debugMode;
					o.check(Settings.engineSettings.data.debugMode);
				}
			},
			checkbox: true,
			checkboxChecked: Settings.engineSettings.data.debugMode,
			value: ""
		});
		options.push({
			text : "[]",
			updateOnSelected: function(elapsed:Float, o:FNFOption) {
				
			},
			checkbox: false,
			checkboxChecked: false,
			value: ""
		});
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
		
		for (i in 0...options.length) {
			var o:Option = options[i];
			var op = null;
			var text = o.text;

			var isTitle = false;
			if (o.text.charAt(0) == "[" && o.text.charAt(o.text.length - 1) == "]") {
				text = o.text.substr(1, o.text.length - 2);
				isTitle = true;
				disabledOptions.push(i);
			}
			op = new FNFOption(0, 0 + (i * 80), text, function(elapsed:Float) {
				o.updateOnSelected(elapsed, op);
			}, o.checkbox, o.checkboxChecked, "");
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
			op.setValue(o.value);
			op.x += 100;
			optionsAlphabets.add(op);
		}

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

		var blackSelectionBar = new FlxSprite(0, (FlxG.height / 2) - (69 / 2)).makeGraphic(Std.int(FlxG.width), 69, new FlxColor(0x88000000));
		blackSelectionBar.alpha = 0;
		add(blackSelectionBar);
		add(optionsAlphabets);
		// FlxTween.tween(menuBG, {"color.red" : 0x49, "color.green" : 0x49, "color.blue" : 0x49}, 0.5, {ease : FlxEase.linear, onComplete: function(t:FlxTween) {
		// 	usable = true;
		// }});
		
		optionsAlphabets.y = FlxG.height * 3;
		curSelected = -1;
		changeSelection(1, false);
		// FlxTween.color(menuBG, 0.5, 0xFFFDE871, 0xFF494949, {ease : FlxEase.cubeInOut, onComplete: function(t:FlxTween) {
		// 	usable = true;
		// }});
		FlxTween.tween(menuBG, {alpha : 0}, 0.5, {onComplete: function(t) {
			usable = true;
			remove(menuBG);
			menuBG.destroy();
		}});
		FlxTween.tween(optionsAlphabets, {y: (FlxG.height / 2) - (69 / 2) - (curSelected * 80)}, 0.5, {ease : FlxEase.cubeInOut});
		FlxTween.tween(blackSelectionBar, {alpha : 1}, 0.5, {ease : FlxEase.cubeInOut});

		// controlsStrings = CoolUtil.coolTextFile(Paths.txt('controls'));
		super.create();

		// openSubState(new OptionsSubState());
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!usable) return;

		if (controls.BACK)
			if (fromFreeplay)
				FlxG.switchState(new PlayState());
			else
				FlxG.switchState(new MainMenuState());

		if (controls.UP_P)
			changeSelection(-1);
		if (controls.DOWN_P)
			changeSelection(1);
		 
		for (i in 0...optionsAlphabets.members.length) {
			(cast (optionsAlphabets.members[i], FNFOption)).up(elapsed);
		}
		if (optionsAlphabets.members[curSelected] != null) (cast (optionsAlphabets.members[curSelected], FNFOption)).updateSelected(elapsed);
	}

	function waitingInput():Void
	{
		if (FlxG.keys.getIsDown().length > 0)
		{
			PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxG.keys.getIsDown()[0].ID, null);
		}
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
	public var ghreuighesioghseuiogseruiogbseruigbseruiogbretgubgiobreg:FlxTween;
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
		if (!animate) return;
		if (ghreuighesioghseuiogseruiogbseruigbseruiogbretgubgiobreg != null) ghreuighesioghseuiogseruiogbseruigbseruiogbretgubgiobreg.cancel();
		FlxTween.tween(optionsAlphabets, {y: (FlxG.height / 2) - (69 / 2) - (curSelected * 80)}, 0.1, {ease : FlxEase.quadInOut});
		// optionsAlphabets.y = ;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}
}
