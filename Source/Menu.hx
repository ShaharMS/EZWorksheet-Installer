package;

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

    var sidemenu:SideMenu;

    public function new() {
        super();

        title = new TextField();
        title.text = "EZWorksheet Installer";
        title.x = 10;
        title.y = 10;
        title.defaultTextFormat = new TextFormat("_sans" , 24, 0xCAFFFFFF, true);
        title.width = title.textWidth + 4;

        description = new TextField();
        description.text = "Welcome to the EZWorksheet installer!\n\n" +
            "If its your first time around, thank you for installing EZWorksheet:)\n\n" +
            "To continue, please choose an option from the side menu.";

        description.x = 10;
        description.y = 50;
        description.width = app.window.width - 150;
        description.height = 200;
        description.defaultTextFormat = new TextFormat("_sans" , 13, 0xCAFFFFFF);
        description.wordWrap = true;
        description.multiline = true;
        description.selectable = false;
        description.mouseEnabled = false;

        addChild(title);
        addChild(description);

        sidemenu = new SideMenu(115);

        var installButton:Button = new Button();
        installButton.text = "Install";
        installButton.width = 105;
        installButton.height = 21;
        installButton.onClick = e -> {parent.addChild(new Installer()); parent.removeChild(this);};
        sidemenu.push(installButton);
        var quickUpdate = new Button();
        quickUpdate.text = "Auto Update";
        quickUpdate.width = 105;
        quickUpdate.height = 21;
        //quickUpdate.customStyle.fontSize = 8;
        quickUpdate.onClick = e -> {parent.addChild(new AutoUpdater()); parent.removeChild(this);};
        sidemenu.push(quickUpdate);
        var updateButton:Button = new Button();
        updateButton.text = "Update";
        updateButton.width = 105;
        updateButton.height = 21;
        sidemenu.push(updateButton);
        var uninstallButton:Button = new Button();
        uninstallButton.text = "Uninstall";
        uninstallButton.width = 105;
        uninstallButton.height = 21;
        sidemenu.push(uninstallButton);

        var exitButton:Button = new Button();
        exitButton.text = "Exit";
        exitButton.width = 105;
        exitButton.height = 21;
        exitButton.onClick = e -> {Sys.exit(0);};
        sidemenu.pushBottom(exitButton);
        var helpButton:Button = new Button();
        helpButton.text = "Help";
        helpButton.width = 105;
        helpButton.height = 21;
        helpButton.onClick = e -> {Lib.getURL(new URLRequest("http://ezworksheet.com/help.html"));};
        sidemenu.pushBottom(helpButton);

        addChild(sidemenu);

        

    }
}