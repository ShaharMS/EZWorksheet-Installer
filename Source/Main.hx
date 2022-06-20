package;


import sys.io.File;
import sys.FileSystem;
import openfl.display.Sprite;
import openfl.text.TextFormat;
class Main extends Sprite
{
	public static var mode(default, null):InstallerMode = AUTOUPDATE;

	public static final textFormat:TextFormat = new TextFormat(fontName, fontSize, fontColor);
	
	public function new()
	{
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