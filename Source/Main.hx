package;

import haxe.ui.Toolkit;
import openfl.display.Sprite;
import openfl.system.Capabilities;
import openfl.text.TextFormat;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

class Main extends Sprite {
	public static var TEST:Bool = true;
	public static var mode(default, null):InstallerMode = MANUAL;

	public static final textFormat:TextFormat = new TextFormat(fontName, fontSize, fontColor);

	public function new() {
		Toolkit.init();
		Toolkit.theme = "dark";
		app.window.focus();
		if (app.window.width != 410) {
			app.window.width = 410;
			app.window.height = 300;
			var screenWidth = Capabilities.screenResolutionX;
			var screenHeight = Capabilities.screenResolutionY;
			app.window.x = Std.int((screenWidth - app.window.width) / 2);
			app.window.y = Std.int((screenHeight - app.window.height) / 2);
		}

		final args = Sys.args();
		for (arg in args) {
			switch arg {
				case "-autoUpdate" | "-update":
					mode = UPDATE;
				case "-firstInstall" | "-firstRun" | "-first":
					mode = INSTALL;
				case "-uninstall":
					mode = UNINSTALL;
				case "-regular" | "-manual":
					mode = MANUAL;
				case "-test":
					TEST = true;
			}
		}
		super();
		switch mode {
			case INSTALL:
				addChild(new Installer());
			case UNINSTALL:
				addChild(new UnInstaller());
			case UPDATE:
				addChild(new Updater());
			case MANUAL:
				addChild(new Menu());
		}
	}
}

enum InstallerMode {
	UPDATE;
	INSTALL;
	UNINSTALL;
	MANUAL;
}
