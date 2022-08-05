package;

import sys.io.File;
import openfl.net.URLRequest;
import Config.fallbackProgramFolder;
import haxe.zip.Reader;
import haxe.io.BytesInput;
import openfl.events.Event;
import openfl.events.ErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.URLLoaderDataFormat;
import openfl.display.Shape;
import haxe.Http;
import sys.FileSystem;
import Config.hasProgram;
import Config.getVersionList;
import haxe.ui.components.DropDown;
import openfl.text.TextFormat;
import openfl.text.TextField;
import haxe.ui.components.Button;
import graphics.SideMenu;
import openfl.display.Sprite;

class Installer extends Sprite {
	var sidemenu:SideMenu;
	var currentSeg:Int = 1;

	public var FIX = false;
	public var CUSTOM_PATH:String = "";
	public var VERSION:String = "";
	public function new() {
		super();

		sidemenu = new SideMenu(100);

		var exitButton:Button = new Button();
		exitButton.text = "Exit";
		exitButton.width = 90;
		exitButton.height = 21;
		exitButton.onClick = e -> {
			parent.addChild(new Menu());
			parent.removeChild(this);
		};
		sidemenu.pushBottom(exitButton);
		var nextButton:Button = new Button();
		nextButton.text = "Next >";
		nextButton.width = 90;
		nextButton.height = 21;
		nextButton.onClick = e -> moveForward();
		sidemenu.pushBottom(nextButton);
		var backButton:Button = new Button();
		backButton.text = "< Back";
		backButton.width = 90;
		backButton.height = 21;
		backButton.onClick = e -> moveBackwards();
		sidemenu.pushBottom(backButton);
		var helpButton:Button = new Button();
		helpButton.text = "Help";
		helpButton.width = 90;
		helpButton.height = 21;
		sidemenu.pushBottom(helpButton);

		addChild(sidemenu);
		addChild(new Segment1(this));
	}

	public function moveForward() {
		if (currentSeg >= 4) return;
		currentSeg++;
		switch currentSeg {
			case 1: {removeChildren(); addChild(sidemenu); addChild(new Segment1(this));}
			case 2: {removeChildren(); addChild(sidemenu); addChild(new Segment2(this));}
			case 3: {removeChildren(); addChild(sidemenu); addChild(new Segment3(this));}
			case 4: {removeChildren(); addChild(sidemenu); addChild(new Segment4(this));}
		}
	}

	public function moveBackwards() {
		if (currentSeg <= 1) return;
		currentSeg--;
		switch currentSeg {
			case 1: {removeChildren(); addChild(sidemenu); addChild(new Segment1(this));}
			case 2: {removeChildren(); addChild(sidemenu); addChild(new Segment2(this));}
			case 3: {removeChildren(); addChild(sidemenu); addChild(new Segment3(this));}
			case 4: {removeChildren(); addChild(sidemenu); addChild(new Segment4(this));}
		}
	}
}

class Segment1 extends Sprite {

	var title:TextField;
	var description:TextField;
	var verDescription:TextField;
	var fixDescription:TextField;
	var dropdown:DropDown;
	public function new(installer:Installer) {
		super();
		name = "Seg1";
		title = new TextField();
		title.text = "Choose a version:";
		title.x = 10;
		title.y = 10;
		title.defaultTextFormat = new TextFormat("_sans", 24, 0xCAFFFFFF, true);
		title.width = title.textWidth + 4;

		description = new TextField();
		description.text = "When choosing a version, the installer will check if that version is already installed. If it is, it will ask you if you want to fix your installation. If you choose to fix your installation, it will delete all files in the installation folder and download the new version. Personal data should not be deleted.";
		description.x = 10;
		description.y = 60;
		description.width = app.window.width - 130;
		description.height = 200;
		description.defaultTextFormat = new TextFormat("_sans", 13, 0xCAFFFFFF);
		//mark the "Personal data should not be deleted" text with bold
		description.setTextFormat(new TextFormat("_sans", 13, 0xCAFFFFFF, true), description.text.indexOf("Personal data should not be deleted"), description.text.indexOf("Personal data should not be deleted") + "Personal data should not be deleted".length);
		description.wordWrap = true;
		description.multiline = true;
		description.selectable = false;
		description.mouseEnabled = false;

		dropdown = new DropDown();
		getVersionList((array) -> {
			for (string in array) {
				dropdown.dataSource.add({text: string});
			}
		});
		dropdown.x = 10;
		dropdown.y = description.y + description.textHeight + 20;
		dropdown.onChange = e -> {
			if (dropdown.selectedIndex == -1) return;
			var version = dropdown.selectedItem.text;
			if (version == "") return;
			if (version.indexOf("alpha") != -1) {
				verDescription.text = " * This version is an alpha version. Features may be missing, buggy and unstable. If a non-alpha version is available, it's recommended to use that version.";
			} else if (version.indexOf("beta") != -1) {
				verDescription.text = " * This version is a beta version. Some Features may be unstable. If a non-beta version is available, it's recommended to use that version.";
			} else {
				verDescription.text = "";
			}
			fixDescription.visible = hasProgram(version);
			installer.FIX = hasProgram(version);
			installer.VERSION = version;
		};

		fixDescription = new TextField();
		fixDescription.text = "This version is already installed. Proceed to fix your installation.";
		fixDescription.x = 110;
		fixDescription.y = dropdown.y;
		fixDescription.width = app.window.width - 220;
		fixDescription.height = 100;
		fixDescription.defaultTextFormat = new TextFormat("_sans", 12, 0xCAFF0000);
		fixDescription.wordWrap = true;
		fixDescription.multiline = true;
		fixDescription.selectable = false;
		fixDescription.mouseEnabled = false;
		fixDescription.visible = false;

		verDescription = new TextField();
		verDescription.text = "";
		verDescription.x = 10;
		verDescription.y = dropdown.y + 40;
		verDescription.width = app.window.width - 130;
		verDescription.height = 200;
		verDescription.defaultTextFormat = new TextFormat("_sans", 11, 0xCAFFFFFF);
		verDescription.wordWrap = true;
		verDescription.multiline = true;
		verDescription.selectable = false;
		verDescription.mouseEnabled = false;

		addChild(title);
		addChild(description);
		addChild(dropdown);
		addChild(fixDescription);
		addChild(verDescription);
	}
}

class Segment2 extends Sprite {
	var title:TextField;
	var description:TextField;
	var path:haxe.ui.components.TextField;

	public function new(installer:Installer) {
		super();
		name = "Seg2";
		if (installer.FIX) {
			installer.moveForward();
		}
		name = "Seg1";
		title = new TextField();
		title.text = "Choose Program Path:";
		title.x = 10;
		title.y = 10;
		title.defaultTextFormat = new TextFormat("_sans", 24, 0xCAFFFFFF, true);
		title.width = title.textWidth + 4;

		description = new TextField();
		description.text = "To install the program to the default directory, just skip this step. Otherwise, choose the directory where you want to install the progra in. When installation ends, a folder will be created in the chosen directory, with the name of the version.";
		description.x = 10;
		description.y = 60;
		description.width = app.window.width - 130;
		description.height = 200;
		description.defaultTextFormat = new TextFormat("_sans", 13, 0xCAFFFFFF);
		description.wordWrap = true;
		description.multiline = true;
		description.selectable = false;
		description.mouseEnabled = false;

		path = new haxe.ui.components.TextField();
		path.text = programFolder;
		path.x = 10;
		path.y = description.y + description.textHeight + 20;
		path.width = app.window.width - 130;
		path.verticalAlign = "center";
		path.onChange = e -> {
			installer.CUSTOM_PATH = path.text != programFolder ? path.text : "";
		};

		addChild(title);
		addChild(description);
		addChild(path);
	}
}

class Segment3 extends Sprite {
	var textField:TextField;
	public function new(installer:Installer) {
		super();
		name = "Seg3";
		var s = new Shape();
		textField = new TextField();
		textField.defaultTextFormat = new TextFormat("_sans", 16, 0xCAFFFFFF);
		s.graphics.lineStyle(1, 0x000000);
		s.graphics.drawRect(0, 0, 200, 30);
		s.x = app.window.width / 2 - s.width / 2 - 50;
		s.y = app.window.height / 4 * 3 - s.height / 2;
		addChild(s);
		addChild(textField);
		startInstallWithSaveAndBar(s, installer.VERSION, textField);
	}

	function startInstallWithSaveAndBar(progressBar:Shape, version:String, infoText:TextField) {
		var request = new openfl.net.URLLoader();

		request.dataFormat = URLLoaderDataFormat.BINARY;
		request.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent) {
			progressBar.graphics.clear();
			progressBar.graphics.lineStyle(1, 0x000000);
			progressBar.graphics.drawRect(0, 0, 200, 30);
			progressBar.graphics.lineStyle(0);
			progressBar.graphics.beginFill(0x0FD623);
			progressBar.graphics.drawRect(0, 0, e.bytesLoaded / e.bytesTotal * 200, 30);
			progressBar.graphics.endFill();
		});

		request.addEventListener(ErrorEvent.ERROR, function(e:ErrorEvent) {
			progressBar.graphics.clear();
			progressBar.graphics.lineStyle(1, 0x000000);
			progressBar.graphics.drawRect(0, 0, 200, 30);
			progressBar.graphics.lineStyle(0);
			progressBar.graphics.beginFill(0xFF0000);
			progressBar.graphics.drawRect(0, 0, 200, 10);
			progressBar.graphics.endFill();

			infoText.text = "Error: " + e.text + "Type: " + e.type;
		});

		request.addEventListener(Event.COMPLETE, function(e:Event) {
			removeChild(progressBar);

			infoText.text = 'Installing And Extracting\n\nversion $version...';
			infoText.width = infoText.textWidth + 50;
			infoText.height = 200;
			infoText.defaultTextFormat = new TextFormat(null, null, null, null, null, null, null, null, CENTER);
			infoText.multiline = true;
			infoText.wordWrap = true;
			// center the text
			infoText.x = app.window.width / 2 - infoText.width / 2 - 50;
			infoText.y = app.window.height / 2 - infoText.textHeight / 2;
			// check for tests
			if (Sys.args().contains("-test") || Main.TEST)
				return;
			var input = new BytesInput(request.data);
			var reader = new Reader(input);
			var entries = reader.read();
			var writeFolder = programFolder;
			try {
				writeProgram(programFolder, entries);
			} catch (e) {
				infoText.text = '
				Notice! you have the Windows setting Controlled Access enabled.
				\n
				\n 
				The program will try to reinstall in this directory:
				\n
				\n + 
				${Sys.getEnv("USERPROFILE")}';
				infoText.width = app.window.width - 50;
				infoText.height = infoText.textHeight;
				// center the text
				infoText.x = app.window.width / 2 - infoText.textWidth / 2 - 50;
				infoText.y = app.window.height / 2 - infoText.textHeight / 2;

				writeFolder = Sys.getEnv("USERPROFILE") + "\\EZWorksheet\\app\\";
				writeProgram(Sys.getEnv("USERPROFILE") + "\\EZWorksheet\\app\\", entries);
			}
			infoText.text = 'Done! App Found at:\n\n' + writeFolder + version;
			infoText.setTextFormat(new TextFormat(null, 12), 21, infoText.text.length);
			// center the text
			infoText.x = app.window.width / 2 - infoText.textWidth / 2;
			infoText.y = app.window.height / 2 - infoText.textHeight / 2;
		});

		request.load(new URLRequest('${downloadLink}${Sys.systemName()}/${version}.zip'));
	}

	// create a function that recursively deletes a directory and all of its contents
	function deleteDirectory(dir:String) {
		var files = FileSystem.readDirectory(dir);
		for (f in files) {
			if (FileSystem.isDirectory(dir + "\\" + f)) {
				deleteDirectory(dir + "\\" + f);
				trace("Deleted " + dir + "\\" + f);
			} else {
				FileSystem.deleteFile(dir + "\\" + f);
				trace("Deleted " + dir + "\\" + f);
			}
		}
		FileSystem.deleteDirectory(dir);
	}

	function writeProgram(folder:String, entries:haxe.ds.List<haxe.zip.Entry>) {
		for (entry in entries) {
			var data = Reader.unzip(entry);
			if (entry.fileName.substring(entry.fileName.lastIndexOf('/') + 1) == '' && entry.data.toString() == '') {
				sys.FileSystem.createDirectory(folder + entry.fileName);
				trace("Created directory " + entry.fileName);
			} else {
				var f = File.write(folder + entry.fileName, true);
				f.write(data);
				f.close();
				trace("Created file " + entry.fileName);
			}
		}
	}

	function makeUserFolder(folder:String) {
		if (folder.split('\\')[-2] != 'Users') {
			return makeUserFolder(folder.substring(0, folder.lastIndexOf('\\')));
		}
		return folder;
	}
}

class Segment4 extends Sprite {
	public function new(installer:Installer) {
		super();
		name = "Seg4";
	}
}
