package;

import Config.getVersionList;
import haxe.ui.components.DropDown;
import openfl.text.TextFormat;
import openfl.text.TextField;
import graphics.Button;
import graphics.SideMenu;
import openfl.display.Sprite;

class Installer extends Sprite {
	var sidemenu:SideMenu;
	var currentSeg:Int = 0;

	public function new() {
		super();

		sidemenu = new SideMenu(100);

		var exitButton:Button = new Button("Exit");
		exitButton.width = 90;
		exitButton.onClick = e -> {
			parent.removeChild(this);
			parent.addChild(new Menu());
		};
		sidemenu.pushBottom(exitButton);
		var nextButton:Button = new Button("Next >");
		nextButton.width = 90;
		nextButton.onClick = e -> {
			if (currentSeg >= 4) return;
			currentSeg++;
			switch currentSeg {
				case 1: {removeChildren(); addChild(sidemenu); addChild(new Segment1());}
				case 2: {removeChildren(); addChild(sidemenu); addChild(new Segment2());}
				case 3: {removeChildren(); addChild(sidemenu); addChild(new Segment3());}
				case 4: {removeChildren(); addChild(sidemenu); addChild(new Segment4());}
			}
		};
		sidemenu.pushBottom(nextButton);
		var backButton:Button = new Button("< Back");
		backButton.width = 90;
		backButton.onClick = e -> {
			if (currentSeg <= 1) return;
			currentSeg--;
			switch currentSeg {
				case 1: {removeChildren(); addChild(sidemenu); addChild(new Segment1());}
				case 2: {removeChildren(); addChild(sidemenu); addChild(new Segment2());}
				case 3: {removeChildren(); addChild(sidemenu); addChild(new Segment3());}
				case 4: {removeChildren(); addChild(sidemenu); addChild(new Segment4());}
			}
		};
		sidemenu.pushBottom(backButton);
		var helpButton:Button = new Button("Help");
		helpButton.width = 90;
		sidemenu.pushBottom(helpButton);

		addChild(sidemenu);
		addChild(new Segment1());
	}
}

class Segment1 extends Sprite {

	var title:TextField;
	var description:TextField;
	var dropdown:DropDown;
	public function new() {
		super();
		name = "Seg1";
		title = new TextField();
		title.text = "Choose a version:";
		title.x = 10;
		title.y = 10;
		title.defaultTextFormat = new TextFormat("_sans", 24, 0xCAFFFFFF, true);
		title.width = title.textWidth + 4;

		dropdown = new DropDown();
		getVersionList((array) -> {
			for (string in array) {
				dropdown.dataSource.add({text: string});
			}
		});

		//"center" the dropdown
		dropdown.x = (app.window.width - dropdown.width) / 2 - 50;
		dropdown.y = title.y + title.height + 10;
		addChild(dropdown);

		description = new TextField();
		description.text = "Welcome to the EZWorksheet installer!\n\n"
			+ "If its your first time around, thank you for installing EZWorksheet:)\n\n"
			+ "To continue, please choose an option from the side menu.";

		description.x = 10;
		description.y = 50;
		description.width = app.window.width - 150;
		description.height = 200;
		description.defaultTextFormat = new TextFormat("_sans", 12, 0xCAFFFFFF);
		description.wordWrap = true;
		description.multiline = true;
		description.selectable = false;
		description.mouseEnabled = false;

		addChild(title);
	}
}

class Segment2 extends Sprite {
	public function new() {
		super();
		name = "Seg2";
	}
}

class Segment3 extends Sprite {
	public function new() {
		super();
		name = "Seg3";
	}
}

class Segment4 extends Sprite {
	public function new() {
		super();
		name = "Seg4";
	}
}
