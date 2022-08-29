package;

import openfl.Lib;
import graphics.SideMenu;
import haxe.Http;
import haxe.io.BytesInput;
import haxe.ui.components.Button;
import haxe.ui.components.DropDown;
import haxe.zip.Reader;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.text.TextField;
import openfl.text.TextFormat;
import sys.FileSystem;
import sys.io.File;

class Installer extends Sprite {
	var sidemenu:SideMenu;
	var currentSeg:Int = 1;

	public var FIX = false;
	public var CUSTOM_PATH:String = "";
	public var VERSION:String = "";
	public function new() {
		super();

		sidemenu = new SideMenu(SIDEBAR_WIDTH);

		var exitButton:Button = new Button();
		exitButton.text = "Exit";
		exitButton.width = SIDEBAR_WIDTH - 10;
		exitButton.height = 21;
		exitButton.onClick = e -> {
			parent.addChild(new Menu());
			parent.removeChild(this);
		};
		sidemenu.pushBottom(exitButton);
		var nextButton:Button = new Button();
		nextButton.text = "Next >";
		nextButton.width = SIDEBAR_WIDTH - 10;
		nextButton.height = 21;
		nextButton.onClick = e -> moveForward();
		sidemenu.pushBottom(nextButton);
		var backButton:Button = new Button();
		backButton.text = "< Back";
		backButton.width = SIDEBAR_WIDTH - 10;
		backButton.height = 21;
		backButton.onClick = e -> moveBackwards();
		sidemenu.pushBottom(backButton);
		var helpButton:Button = new Button();
		helpButton.text = "Help";
		helpButton.width = SIDEBAR_WIDTH - 10;
		helpButton.height = 21;
		helpButton.onClick = e -> Lib.getURL(new URLRequest("ezworksheet.spacebubble.io/installer/help"));
		sidemenu.pushBottom(helpButton);

		addChild(sidemenu);
		addChild(new Segment1(this));
	}

	public function moveForward() {
		if (currentSeg >= 4) return;
		currentSeg++;
		switch currentSeg {
			case 1: {app.window.onResize.removeAll(); removeChildren(); addChild(sidemenu); addChild(new Segment1(this));}
			case 2: {app.window.onResize.removeAll(); removeChildren(); addChild(sidemenu); addChild(new Segment2(this));}
			case 3: {app.window.onResize.removeAll(); removeChildren(); addChild(sidemenu); addChild(new Segment3(this));}
			case 4: {app.window.onResize.removeAll(); removeChildren(); addChild(sidemenu); addChild(new Segment4(this));}
		}
	}

	public function moveBackwards() {
		if (currentSeg <= 1) return;
		currentSeg--;
		switch currentSeg {
			case 1: {app.window.onResize.removeAll(); removeChildren(); addChild(sidemenu); addChild(new Segment1(this));}
			case 2: {app.window.onResize.removeAll(); removeChildren(); addChild(sidemenu); addChild(new Segment2(this));}
			case 3: {app.window.onResize.removeAll(); removeChildren(); addChild(sidemenu); addChild(new Segment3(this));}
			case 4: {app.window.onResize.removeAll(); removeChildren(); addChild(sidemenu); addChild(new Segment4(this));}
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
		title.height = title.textHeight + 4;
		title.multiline = true;
		title.wordWrap = true;

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
		addEventListener(Event.ADDED_TO_STAGE, e -> {
			getVersionList((array) -> {
				for (string in array) {
					dropdown.dataSource.add({text: string});
				}
			});
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
		dropdown.width = 110;

		fixDescription = new TextField();
		fixDescription.text = "This version is already installed. Proceed to fix your installation.";
		fixDescription.x = 125;
		fixDescription.y = dropdown.y;
		fixDescription.width = 180;
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

		app.window.onResize.add(reposition);
	}

	function reposition(w:Int, h:Int) {
		title.width = w - SIDEBAR_WIDTH - 10;
		title.height = title.textHeight + 4;

		description.y = Math.max(title.y + title.height, 60);
		description.width = w - SIDEBAR_WIDTH - 10;
		description.height = description.textHeight + 4;
		dropdown = new DropDown();

		//removeChild(dropdown);
		//removeChild(fixDescription);
		dropdown.y = description.y + description.textHeight + 20;
		dropdown.width = Math.min(110, w - SIDEBAR_WIDTH - 10) + 10;

		fixDescription.x = Math.min(110, w - SIDEBAR_WIDTH - 10) + 15;
		fixDescription.y = dropdown.y;
		fixDescription.width = Math.max(180, w - SIDEBAR_WIDTH - dropdown.x - fixDescription.width);
		fixDescription.height = fixDescription.textHeight + 4;
		//addChild(dropdown);
		//addChild(fixDescription);
		verDescription.y = dropdown.y + 40;
		verDescription.width = w - SIDEBAR_WIDTH - 10;
		verDescription.height = verDescription.textHeight + 4;
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
		title.height = title.textHeight + 4;
		title.multiline = true;
		title.wordWrap = true;

		description = new TextField();
		description.text = "To install the program to the default directory, just skip this step. Otherwise, choose the directory where you want to install the program in. When installation ends, a folder will be created in the chosen directory, with the name of the version.";
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
		path.onClick = e -> {
			var f = new openfl.filesystem.File();
			f.addEventListener(Event.SELECT, (ev) -> {
				trace(f.nativePath, f.name);
				path.text = f.nativePath;
				installer.CUSTOM_PATH = path.text != programFolder ? path.text : "";
			});
			f.browseForDirectory("Select Installation Directory");
		}

		addChild(title);
		addChild(description);
		addChild(path);

		app.window.onResize.add(reposition);
	}

	function reposition(w:Int, h:Int) {
		name = "Seg1";
		title.width = title.textWidth + 4;
		title.height = title.textHeight + 4;

		description.y = Math.max(60, title.y + title.height);
		description.width = w - SIDEBAR_WIDTH - 10;
		description.height = description.textHeight + 4;

		path = new haxe.ui.components.TextField();
		path.y = description.y + description.height + 16;
		path.width = w - SIDEBAR_WIDTH - 10;
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
		addEventListener(Event.ADDED_TO_STAGE, e -> startInstallWithSaveAndBar(s, installer.VERSION, textField, this.parent, this));
	
		app.window.onResize.add(reposition);
	}

	function reposition(w:Int, h:Int) {}
}

class Segment4 extends Sprite {
	public function new(installer:Installer) {
		super();
		name = "Seg4";
	}
}
