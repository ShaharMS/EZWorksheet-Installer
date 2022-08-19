package;


import openfl.system.Capabilities;
import sys.io.Process;
import sys.io.File;
import sys.FileSystem;
import openfl.display.Sprite;
import openfl.text.TextFormat;
import haxe.ui.Toolkit;
class Main extends Sprite
{
	public static var TEST:Bool = false;

	public static var mode(default, null):InstallerMode = MANUAL;

	public static final textFormat:TextFormat = new TextFormat(fontName, fontSize, fontColor);
	
	public function new()
	{
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
		if (!FileSystem.exists("/currentVersion.txt")) {
			var handle = File.write(versionSave);
			handle.writeString("N/A");
			handle.close();
		}

		final args = Sys.args();
		for (arg in args) {
			switch arg {
				case "-manualUpdate": mode = UPDATE;
				case "-autoUpdate": mode = AUTOUPDATE;
				case "-firstInstall" | "-firstRun" | "-first": mode = INSTALL;
				case "-uninstall": mode = UNINSTALL;
				case "-regular" | "-manual": mode = MANUAL;
				case "-test": TEST = true;
			}
		}
		super();
		switch mode {
			case INSTALL: addChild(new Installer());
			case UNINSTALL: addChild(new UnInstaller());
			case UPDATE: addChild(new Updater());
			case AUTOUPDATE: addChild(new AutoUpdater());
			case MANUAL: addChild(new Menu());
		}
	}
}

enum InstallerMode {
	AUTOUPDATE;
	UPDATE;
	INSTALL;
	UNINSTALL;
	MANUAL;
}