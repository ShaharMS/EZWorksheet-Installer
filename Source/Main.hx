package;

import openfl.display.Sprite;

class Main extends Sprite
{
	public static var mode(default, null):InstallerMode = MANUAL;
	
	public function new()
	{
		final args = Sys.args();
		for (arg in args) {
			switch arg {
				case "-manualUpdate": mode = UPDATE;
				case "-autoUpdate": mode = AUTOUPDATE;
				case "-firstInstall" | "-firstRun" | "-first": mode = INSTALL;
				case "-uninstall": mode = UNINSTALL;
			}
		}
		super();
		switch mode {
			case INSTALL: addChild(new Installer());
			case UNINSTALL: addChild(new UnInstaller());
			case UPDATE: addChild(new Updater());
			case AUTOUPDATE: addChild(new AutoUpdater());
			case MANUAL: 
		}
		if (mode != MANUAL) {
			
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