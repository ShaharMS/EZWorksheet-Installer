package;

import haxe.io.Path;
import openfl.display.StageScaleMode;
import haxe.ui.Toolkit;
import openfl.display.Sprite;
import openfl.system.Capabilities;
import openfl.text.TextFormat;
import sys.FileSystem;
import sys.io.File;
import sys.io.Process;

class Main extends Sprite {
	public static var TEST:Bool = false;
	public static var mode(default, null):InstallerMode = MANUAL;

	public static final textFormat:TextFormat = new TextFormat(fontName, fontSize, fontColor);

	public function new() {
		Toolkit.init();
		Toolkit.theme = "dark";
		app.window.focus();
		if (app.window.width != 500) {
			app.window.width = 500;
			app.window.height = 400;
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
			case INSTALL: addChild(new Installer());
			case UNINSTALL: addChild(new UnInstaller());
			case UPDATE: addChild(new Updater());
			case MANUAL: addChild(new Menu());
		}


		if (!FileSystem.exists(Path.join([openfl.filesystem.File.userDirectory.nativePath, "AppData", "Roaming", "Microsoft", "Windows", "Start Menu", "Programs", "EZWorksheet", 'EZWorksheet.lnk']))) {
            FileSystem.createDirectory(Path.join([
				openfl.filesystem.File.userDirectory.nativePath,
				"AppData",
				"Roaming",
				"Microsoft",
				"Windows",
				"Start Menu",
				"Programs",
				"EZWorksheet"
			]));
        }

		var handle = File.write("assets/add-installer-to-start-menu.ps1");
		handle.writeString('
                    function createShortcut {
                        param ([string]${"$"}StartPath, [string]${"$"}TargetFile, [string]${"$"}ShortcutFile, [string]${"$"}IconPath)
                        ${"$"}WScriptShell = New-Object -ComObject WScript.Shell
                        ${"$"}Shortcut = ${"$"}WScriptShell.CreateShortcut(${"$"}ShortcutFile)
                        ${"$"}Shortcut.TargetPath = ${"$"}TargetFile
                        ${"$"}Shortcut.IconLocation = ${"$"}IconPath
                        ${"$"}Shortcut.WorkingDirectory = ${"$"}StartPath
                        ${"$"}Shortcut.Save()
                    }
                    
                    createShortcut \"${Sys.programPath().substring(0, Sys.programPath().length - 10)}\" \"${Path.join([Sys.programPath().substring(0, Sys.programPath().length - 10), installerName])}\" \"${Path.join([openfl.filesystem.File.userDirectory.nativePath, "AppData", "Roaming", "Microsoft", "Windows", "Start Menu", "Programs", "EZWorksheet", 'EZWorksheet Installer.lnk'])}\" \"${FileSystem.absolutePath("assets/installerIcon.ico")}\" 
                    ');
		handle.close();
		var p = new Process("powershell", ["-File", FileSystem.absolutePath("assets/add-installer-to-start-menu.ps1")]);
		var ec = p.exitCode();
		trace(ec, p.stderr.readAll().toString(), p.stdout.readAll().toString());
	}
}

enum InstallerMode {
	UPDATE;
	INSTALL;
	UNINSTALL;
	MANUAL;
}
