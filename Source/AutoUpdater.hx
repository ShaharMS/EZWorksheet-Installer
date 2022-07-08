package;

import openfl.display.Shape;
import haxe.Timer;
import sys.io.File;
import haxe.Http;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.Lib.application as app;

/**
 * The auto updater doesnt require any user interaction, and just downloads stuff.
 * 
 * JUst to make stuff comfortable, it resizes and moves itself to the top left corner of the screen.
 */
class AutoUpdater extends Sprite {
    
    var titleField:TextField = new TextField();

    public function new() {
        super();
        app.window.x = 5;
        app.window.y = 35;
        app.window.width = 250;
        app.window.height = 100;

        titleField.defaultTextFormat = Main.textFormat;
        titleField.text = "Checking for updates...";
        titleField.width = titleField.textWidth;
        titleField.height = titleField.textHeight;

        titleField.x = (app.window.width - titleField.width) / 2;
        titleField.y = (app.window.height - titleField.height) / 2;
        addChild(titleField);
        var httpReq = new Http(appVersionLink);

        httpReq.onError = function(e:String) {
            titleField.text = "Error: " + e;
        }

        httpReq.onData = function (data:String) {
            Timer.delay(() -> {
				var handle = File.read(versionSave);
				final installedVersion = handle.readLine();
				handle.close();
				if (installedVersion != data) {
					titleField.text = "Downloading version " + data + "...";
					titleField.width = titleField.textWidth;
					titleField.x = app.window.width / 2 - titleField.textWidth / 2;
                    titleField.y = app.window.height / 4 - titleField.textHeight / 2;

                    var s = new Shape();
                    s.graphics.lineStyle(1, 0x000000);
                    s.graphics.drawRect(0, 0, 200, 30);
                    s.x = app.window.width / 2 - s.width / 2;
                    s.y = app.window.height / 4 * 3 - s.height / 2;
                    addChild(s);

                    startDownloadWithSaveAndBar(s, data);

				} else
					Sys.exit(0);
            }, 500);
        }

        httpReq.request();
    }
}