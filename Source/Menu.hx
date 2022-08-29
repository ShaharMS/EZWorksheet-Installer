package;

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

    public function new() {
        super();

        title = new TextField();
        title.text = "EZWorksheet Installer";
        title.x = 10;
        title.y = 10;
        title.defaultTextFormat = new TextFormat("_sans" , 24, 0xCAFFFFFF, true);
        title.width = title.textWidth + 4;
        title.wordWrap = true;
        title.multiline = true;

        description = new TextField();
        description.text = "Welcome to the EZWorksheet installer!\n\n" +
            "If its your first time around, thank you for installing EZWorksheet:)\n\n" +
            "To continue, please choose an option from the side menu.";

        description.x = 10;
        description.y = 50;
        description.width = app.window.width - SIDEBAR_WIDTH - 35;
        description.height = 200;
        description.defaultTextFormat = new TextFormat("_sans" , 13, 0xCAFFFFFF);
        description.wordWrap = true;
        description.multiline = true;
        description.selectable = false;
        description.mouseEnabled = false;
		addChild(title);
		addChild(description);

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
		desc2.addEventListener(MouseEvent.CLICK, e -> Lib.getURL(new URLRequest("https://ezworksheet.spacebubble.io/installer/download")));
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
            app.window.onResize.removeAll(); 
            parent.addChild(new Installer()); 
            parent.removeChild(this);};

        sidemenu.push(installButton);

        var updateButton = new Button();
        updateButton.text = "Update";
        updateButton.width = SIDEBAR_WIDTH - 10;
        updateButton.height = 21;
        updateButton.onClick = e -> {
            app.window.onResize.removeAll(); 
            parent.addChild(new Updater()); 
            parent.removeChild(this);};

        sidemenu.push(updateButton);

        var uninstallButton:Button = new Button();
        uninstallButton.text = "Uninstall";
        uninstallButton.width = SIDEBAR_WIDTH - 10;
        uninstallButton.height = 21;
        uninstallButton.onClick = e -> {
            app.window.onResize.removeAll(); 
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
    }
}