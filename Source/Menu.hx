package;

import haxe.io.Path;
import sys.thread.Thread;
import sys.FileSystem;
import sys.io.File;
import haxe.MainLoop;
import sys.io.Process;
import haxe.ui.components.DropDown;
import openfl.ui.Mouse;
import openfl.events.MouseEvent;
import openfl.events.Event;
import haxe.Http;
import openfl.net.URLRequest;
import openfl.Lib;
import graphics.SideMenu;
import haxe.ui.components.Button;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;

class Menu extends Sprite {
    
    var title:TextField;
    var description:TextField;
    var desc2:TextField;
    var sidemenu:SideMenu;
    var versionDropdown:DropDown;
    var launch:Button;
    var shortcut:Button;

    public function new() {
        super();

        title = new TextField();
        title.text = "EZWorksheet Installer";
        title.x = 10;
        title.y = 10;
        title.defaultTextFormat = new TextFormat("_sans" , 24, 0xCAFFFFFF, true);
		title.width = app.window.width - SIDEBAR_WIDTH - 10;
		title.height = title.textHeight + 4;
        title.wordWrap = true;
        title.multiline = true;

        description = new TextField();
        description.text = "Welcome to the EZWorksheet installer!\n\n" +
            "If it's your first time around, thank you for installing EZWorksheet :)\n\n" +
            "To continue, please choose an option from the side menu.\n\n" + 
            "To launch the app, choose a version from the dropdown below, and press \"Launch\"";

        description.x = 10;
		description.y = title.y + title.height;
		description.width = app.window.width - SIDEBAR_WIDTH - 10;
		description.height = description.textHeight + 40;
        description.defaultTextFormat = new TextFormat("_sans" , 13, 0xCAFFFFFF);
        description.wordWrap = true;
        description.multiline = true;
        description.selectable = false;
        description.mouseEnabled = false;
		addChild(title);
		addChild(description);

        versionDropdown = new DropDown();
		for (version in getInstalledVersions()) {
			versionDropdown.dataSource.add({text: version});
		}
        versionDropdown.y = description.y + description.height + 30;
        versionDropdown.x = 10;
        versionDropdown.width = 110;
        versionDropdown.height = 30;
        addChild(versionDropdown);
        launch = new Button();
        launch.text = 'Launch';
        launch.verticalAlign = "center";
        launch.x = 125;
        launch.y = versionDropdown.y;
		launch.height = versionDropdown.height != 0 ? versionDropdown.height : 30;
        launch.onClick = e -> {
            Thread.create(() -> {
			    try {
                    
					trace(programFolder + versionDropdown.selectedItem.text);
					Sys.setCwd(programFolder + versionDropdown.selectedItem.text + #if windows "\\" #else "/" #end + versionDropdown.selectedItem.text);
                    trace(Sys.getCwd());
					var process = new Process("./" + executableName, [
						'-writelogs=${FileSystem.absolutePath("log.txt")}',
						'-fonts=${Path.join([programWithoutPostfix, '/fonts/'])}'
					], true);
			    } catch (e) {
					try {
						trace(fallbackProgramFolder + versionDropdown.selectedItem.text + #if windows "\\" #else "/" #end + versionDropdown.selectedItem.text + #if windows "\\" #else "/" #end + executableName);
						Sys.setCwd(fallbackProgramFolder + versionDropdown.selectedItem.text + #if windows "\\" #else "/" #end + versionDropdown.selectedItem.text);
						var process = new Process("./" + executableName, [
                            '-writelogs=${FileSystem.absolutePath("log.txt")}', 
                            '-fonts=${Path.join([fallbackWithoutPostfix, '/fonts/'])}'
                        ], true);
					} catch (e) {trace(e);}
                }
            });
        }
		addChild(launch);

        shortcut = new Button();
		shortcut.text = 'Create Shortcut to version: ';
		shortcut.verticalAlign = "center";
		shortcut.x = 10;
		shortcut.y = versionDropdown.y + 35;
		shortcut.height = versionDropdown.height != 0 ? versionDropdown.height : 30;
        shortcut.onClick = e -> {
            try {
			    var handle = File.write("assets/make-shortcut.ps1");
                handle.writeString('
                    function createShortcut {
                        param ([string]${"$"}StartPath, [string]${"$"}TargetFile, [string]${"$"}ShortcutFile, [string]${"$"}IconPath)
                        ${"$"}WScriptShell = New-Object -ComObject WScript.Shell
                        ${"$"}Shortcut = ${"$"}WScriptShell.CreateShortcut(${"$"}ShortcutFile)
                        ${"$"}Shortcut.TargetPath = ${"$"}TargetFile
                        ${"$"}Shortcut.IconLocation = ${"$"}IconPath
                        ${"$"}Shortcut.WorkingDirectory = ${"$"}StartPath
                        ${"$"}Shortcut.Arguments = \'-writelogs=${FileSystem.absolutePath("log.txt")}\'+\'-fonts=${Path.join([fallbackWithoutPostfix, '/fonts/'])}\'+-installer=${Path.join([Sys.programPath().substring(0, Sys.programPath().length - 10), installerName])}\'\'
                        ${"$"}Shortcut.Save()
                    }
                    
                    createShortcut \"${Path.join([getProgramFolder(), versionDropdown.selectedItem.text, versionDropdown.selectedItem.text])}\" \"${Path.join([getProgramFolder(), versionDropdown.selectedItem.text, versionDropdown.selectedItem.text, executableName])}\" \"${Path.join([openfl.filesystem.File.desktopDirectory.nativePath, "EZWorksheet.lnk"])}\" \"${FileSystem.absolutePath("assets/icon.ico")}\" 
                    createShortcut \"${Path.join([getProgramFolder(), versionDropdown.selectedItem.text, versionDropdown.selectedItem.text])}\" \"${Path.join([getProgramFolder(), versionDropdown.selectedItem.text, versionDropdown.selectedItem.text, executableName])}\" \"${Path.join([openfl.filesystem.File.userDirectory.nativePath, "AppData", "Roaming", "Microsoft", "Windows", "Start Menu", "Programs", "EZWorksheet", 'EZWorksheet.lnk'])}\" \"${FileSystem.absolutePath("assets/icon.ico")}\" 
                    '                    
                    );
                handle.close();
                var p = new Process("powershell", ["-File", FileSystem.absolutePath("assets/make-shortcut.ps1")]);
                var ec = p.exitCode();
                trace(ec, p.stderr.readAll().toString(), p.stdout.readAll().toString());
            } catch (e) trace(e);
        }
		versionDropdown.onChange = e -> shortcut.text = 'Create Shortcut to version: ${versionDropdown.selectedItem.text}';
        addChild(shortcut);

        desc2 = new TextField();
        desc2.text = "A New Version Of The Installer Is Available.\nClick This Link To Update";
        desc2.defaultTextFormat = new TextFormat("_sans", 12, 0x00EEFF, true, false, false, null , null, "center");
        desc2.width = app.window.width - SIDEBAR_WIDTH - 25;
        desc2.x = 10;
        desc2.height = desc2.textHeight + 4;
        desc2.y = app.window.height - 70;
        desc2.visible = false;
        desc2.wordWrap = true;
        desc2.multiline = true;
		desc2.addEventListener(MouseEvent.CLICK, e -> Lib.getURL(new URLRequest("https://ezworksheet.spacebubble.io/")));
        desc2.addEventListener(MouseEvent.MOUSE_OVER, e -> Mouse.cursor = BUTTON);
		desc2.addEventListener(MouseEvent.MOUSE_OUT, e -> Mouse.cursor = AUTO);
        addChild(desc2);

		var httpReq = new Http(installerVersionLink);
		httpReq.onData = (data:String) -> {
			if (data != version) {
                desc2.visible = true;
                desc2.text += ' (version: $data)';
            }
            trace(data);
		};
        httpReq.onError = (e) -> trace(e);

        sidemenu = new SideMenu(SIDEBAR_WIDTH);

        var installButton:Button = new Button();
        installButton.text = "Install";
        installButton.width = SIDEBAR_WIDTH - 10;
        installButton.height = 21;
        installButton.onClick = e -> {
			app.window.onResize.remove(reposition); 
            parent.addChild(new Installer()); 
            parent.removeChild(this);};

        sidemenu.push(installButton);

        var updateButton = new Button();
        updateButton.text = "Update";
        updateButton.width = SIDEBAR_WIDTH - 10;
        updateButton.height = 21;
        updateButton.onClick = e -> {
			app.window.onResize.remove(reposition); 
            parent.addChild(new Updater()); 
            parent.removeChild(this);};

        sidemenu.push(updateButton);

        var uninstallButton:Button = new Button();
        uninstallButton.text = "Uninstall";
        uninstallButton.width = SIDEBAR_WIDTH - 10;
        uninstallButton.height = 21;
        uninstallButton.onClick = e -> {
            app.window.onResize.remove(reposition); 
            parent.addChild(new UnInstaller()); 
            parent.removeChild(this);};
            
        sidemenu.push(uninstallButton);

        var exitButton:Button = new Button();
        exitButton.text = "Exit";
        exitButton.width = SIDEBAR_WIDTH - 10;
        exitButton.height = 21;
        exitButton.onClick = e -> {
            Sys.exit(0);
        };

        sidemenu.pushBottom(exitButton);
        
        var helpButton:Button = new Button();
        helpButton.text = "Help";
        helpButton.width = SIDEBAR_WIDTH - 10;
        helpButton.height = 21;
        helpButton.onClick = e -> {
            Lib.getURL(new URLRequest("https://ezworksheet.spacebubble.io/installer/help"));
        };
        sidemenu.pushBottom(helpButton);

        addChild(sidemenu);

		addEventListener(Event.ADDED_TO_STAGE, e -> httpReq.request());
        app.window.onResize.add(reposition);
    }

    function reposition(w:Int, h:Int) {
        title.width = w - SIDEBAR_WIDTH - 10;
		title.height = title.textHeight + 4;

		description.y = title.y + title.height;
		description.width = w - SIDEBAR_WIDTH - 10;
		description.height = description.textHeight + 4;

		desc2.width = w - SIDEBAR_WIDTH - 25;
		desc2.height = desc2.textHeight + 4;
		desc2.y = Math.max(h - 70, description.y + description.height);

		versionDropdown.y = description.y + description.height + 30;
		versionDropdown.width = 110;
		launch.y = versionDropdown.y;
		launch.height = versionDropdown.height != 0 ? versionDropdown.height : 30;
		shortcut.y = versionDropdown.y + 35;
    }
}