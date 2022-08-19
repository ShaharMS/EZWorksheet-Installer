package;

import sys.io.Process;
import openfl.text.TextFormat;
import sys.FileSystem;
import openfl.text.TextFieldAutoSize;
import haxe.io.BytesInput;
import haxe.io.Input;
import haxe.zip.Reader;
import haxe.zip.Uncompress;
import openfl.net.URLRequest;
import openfl.net.URLLoaderDataFormat;
import openfl.events.ProgressEvent;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import haxe.Http;
import haxe.Timer;
import openfl.Lib.application as app;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.text.TextField;
import sys.io.File;

using StringTools;

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

		httpReq.onData = function(data:String) {
			Timer.delay(() -> {
				if (!hasProgram(data)) {
					titleField.text = "Downloading version " + data + "...";
					titleField.width = titleField.textWidth;
					titleField.x = app.window.width / 2 - titleField.textWidth / 2;
					titleField.y = app.window.height / 4 - titleField.textHeight / 2;

					var s = new Shape();
					s.graphics.lineStyle(1, 0x000000);
					s.graphics.drawRect(0, 0, 200, 30);
					s.x = app.window.width / 2 - s.width / 2;
					s.y = app.window.height / 4 * 3 - 15;
					addChild(s);

					startInstallWithSaveAndBar(s, data, titleField, this.parent, this);
				} else
					titleField.text = "You Are Up To Date :)";
					Timer.delay(() -> {
						if (Main.TEST) {
							parent.addChild(new Main());
							parent.removeChild(this);
						} else Sys.exit(0);
					}, 2000);
			}, 500);
		}

		httpReq.request();
	}

	
}