package;

import Config.uninstallVersions;
import haxe.MainLoop;
import haxe.ui.components.CheckBox;
import haxe.ui.containers.HBox;
import haxe.ui.containers.ScrollView;
import Config.getInstalledVersions;
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
using StringTools;

class UnInstaller extends Sprite {
	var sidemenu:SideMenu;
	var currentSeg:Int = 1;

	public var VERSIONS:Array<String> = [];
	public function new() {
		super();
		sidemenu = new SideMenu(SIDEBAR_WIDTH);

		var exitButton:Button = new Button();
		exitButton.text = "Menu";
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
		addChild(new USegment1(this));
	}

	public function moveForward() {
		if (currentSeg >= 2) return;
		currentSeg++;
		switch currentSeg {
			case 1: {removeChildren(); addChild(sidemenu); addChild(new USegment1(this));}
			case 2: {removeChildren(); addChild(sidemenu); addChild(new USegment2(this));}
		}
	}

	public function moveBackwards() {
		if (currentSeg <= 1) {removeChildren(); parent.addChild(new Menu()); parent.removeChild(this);};
		currentSeg--;
		switch currentSeg {
			case 1: {removeChildren(); addChild(sidemenu); addChild(new USegment1(this));}
			case 2: {removeChildren(); addChild(sidemenu); addChild(new USegment2(this));}
		}
	}
}

class USegment1 extends Sprite {

	var title:TextField;
	var description:TextField;
	var scrollview:ScrollView;
	var hbox:HBox;
	public function new(uninstaller:UnInstaller) {
		super();
		name = "Seg1";
		title = new TextField();
		title.text = "Choose versions to uninstall:";
		title.x = 10;
		title.y = 10;
		title.defaultTextFormat = new TextFormat("_sans", 24, 0xCAFFFFFF, true);
		title.width = app.window.width - SIDEBAR_WIDTH - 10;
		title.height = title.textHeight + 4;
		title.multiline = true;
		title.wordWrap = true;

		description = new TextField();
		description.text = "Tick the checkboxes behind the versions below to uninstall those versions.\n\nIf you came here to remove the program, thank you for using it thus far :)";
		description.x = 10;
		description.y = title.y + title.height + 20;
		description.width = app.window.width - SIDEBAR_WIDTH - 10;
		description.height = description.textHeight + 4;
		description.defaultTextFormat = new TextFormat("_sans", 13, 0xCAFFFFFF);
		//mark the "Personal data should not be deleted" text with bold
		var text = "Tick the checkboxes behind the versions below to uninstall those versions.";
		description.setTextFormat(new TextFormat("_sans", 13, 0xCAFFFFFF, true), description.text.indexOf(text), description.text.indexOf(text) + text.length);
		description.wordWrap = true;
		description.multiline = true;
		description.selectable = false;
		description.mouseEnabled = false;

		scrollview = new ScrollView();
		scrollview.width = app.window.width - SIDEBAR_WIDTH;
		hbox = new HBox();
		hbox.continuous = true;
		hbox.width = app.window.width - 135;
		for (version in getInstalledVersions()) {
			var checkbox = new CheckBox();
			checkbox.text = version;
			if (uninstaller.VERSIONS.contains(version)) checkbox.selected = true;
			checkbox.onChange = e -> {
				if (checkbox.selected) uninstaller.VERSIONS.push(version);
				else uninstaller.VERSIONS.remove(version);		
			}
			hbox.addComponent(checkbox);
		}
		scrollview.addComponent(hbox);
		scrollview.y = description.y + description.height + 20;
		scrollview.height = app.window.height - scrollview.y - 10;
		scrollview.width = app.window.width - SIDEBAR_WIDTH - 10;
		scrollview.customStyle.backgroundOpacity = 0;
		scrollview.borderSize = 0;
		addChild(title);
		addChild(description);
		addChild(scrollview);

		app.window.onResize.add(reposition);
	}

	function reposition(w:Int, h:Int) {
		title.width = w - SIDEBAR_WIDTH - 10;
		title.height = title.textHeight + 4;

		description.y = title.y + title.height + 20;
		description.width = w - SIDEBAR_WIDTH - 10;
		description.height = description.textHeight + 4;

		hbox.width = w - 135;
		scrollview.y = description.y + description.height + 20;
		scrollview.height = h - scrollview.y - 10;
		scrollview.width = w - SIDEBAR_WIDTH - 10;
	}
}

class USegment2 extends Sprite {
	var infoText:TextField;

	public function new(uninstaller:UnInstaller) {
		super();
		infoText = new TextField();
		infoText.defaultTextFormat = new TextFormat("_sans", 14, 0xCAFFFFFF, null, null, null, null, null, "center");
		infoText.text = "Starting removal of version " + uninstaller.VERSIONS[0];
		addChild(infoText);
		app.window.onResize.add(reposition);
		uninstallVersions(uninstaller.VERSIONS, (ver) -> {
			infoText.text = "Starting removal of version " + ver;
			reposition(app.window.width, app.window.height);
		}, (file) -> {
			infoText.text = "Deleting " + file;
			reposition(app.window.width, app.window.height);
		}, (e) -> {
			infoText.text = "Error: " + e.message;
		});
		var versions = uninstaller.VERSIONS.toString();
		infoText.text = "Done!\n\nUninstalled Versions:\n\n" + versions.substring(1, versions.length - 1).replace(",", ", ");
		reposition(app.window.width, app.window.height);
	}

	function reposition(w:Int, h:Float) {
		infoText.width = infoText.textWidth + 4;
		infoText.height = infoText.textHeight + 4;
		infoText.x = w / 2 - infoText.width / 2 - SIDEBAR_WIDTH / 2;
		infoText.y = h / 2 - infoText.height / 2;
	}
}
