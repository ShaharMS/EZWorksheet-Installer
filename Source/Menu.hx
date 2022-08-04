package;

import graphics.SideMenu;
import graphics.Button;
import openfl.text.TextFormat;
import openfl.text.TextField;
import openfl.display.Sprite;

class Menu extends Sprite {
    
    var title:TextField;
    var description:TextField;

    var sidemenu:SideMenu;

    public function new() {
        super();

        app.window.height = 300;
        app.window.width = 450;


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
        description.defaultTextFormat = new TextFormat("_sans" , 12, 0xCAFFFFFF);
        description.wordWrap = true;
        description.multiline = true;
        description.selectable = false;
        description.mouseEnabled = false;

        addChild(title);
        addChild(description);

        sidemenu = new SideMenu(100);

        var installButton:Button = new Button("Install");
        installButton.width = 90;
        installButton.onClick = e -> {parent.addChild(new Installer()); parent.removeChild(this);};
        sidemenu.push(installButton);
        var quickUpdate = new Button("Quick Update");
        quickUpdate.width = 90;
        quickUpdate.onClick = e -> {parent.addChild(new AutoUpdater()); parent.removeChild(this);};
        sidemenu.push(quickUpdate);
        var updateButton:Button = new Button("Update");
        updateButton.width = 90;
        sidemenu.push(updateButton);
        var uninstallButton:Button = new Button("Uninstall");
        uninstallButton.width = 90;
        sidemenu.push(uninstallButton);

        var exitButton:Button = new Button("Exit");
        exitButton.width = 90;
        sidemenu.pushBottom(exitButton);
        var helpButton:Button = new Button("Help");
        helpButton.width = 90;
        sidemenu.pushBottom(helpButton);

        addChild(sidemenu);

        

    }
}