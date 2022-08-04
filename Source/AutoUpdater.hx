package;

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

					startInstallWithSaveAndBar(s, data, titleField);
				} else
					Sys.exit(0);
			}, 500);
		}

		httpReq.request();
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
            //center the text
            infoText.x = app.window.width / 2 - infoText.width / 2;
            infoText.y = app.window.height / 2 - infoText.textHeight / 2;
			//check for tests
			if (Sys.args().contains("-test") || Main.TEST) return;
            var input = new BytesInput(request.data);
            var reader = new Reader(input);
            var entries = reader.read();
			var writeFolder = programFolder;
            if (FileSystem.exists(programFolder + "\\" + version) || FileSystem.exists(Sys.getEnv("USERPROFILE") + "\\EZWorksheet\\app\\" + version)) {
                infoText.text = 'Version $version already installed.\n\nYou are up to date :)';
				infoText.width = infoText.textWidth / 3 * 2;
				infoText.height = 200;
				// center the text
				infoText.x = app.window.width / 2 - infoText.textWidth / 2;
				infoText.y = app.window.height / 2 - infoText.textHeight / 2;
				Sys.sleep(1.5);
				Sys.exit(0);
            }
			try {
				writeProgram(programFolder, entries);
			} catch(e)	{
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
				infoText.x = app.window.width / 2 - infoText.textWidth / 2;
				infoText.y = app.window.height / 2 - infoText.textHeight / 2;

				writeFolder = Sys.getEnv("USERPROFILE") + "\\EZWorksheet\\app\\";
				writeProgram(Sys.getEnv("USERPROFILE") + "\\EZWorksheet\\app\\", entries);
			}
            infoText.text = 'Done! App Found at:\n\n' + writeFolder + version;
            infoText.setTextFormat(new TextFormat(null, 12), 21, infoText.text.length);
            //center the text
            infoText.x = app.window.width / 2 - infoText.textWidth / 2;
            infoText.y = app.window.height / 2 - infoText.textHeight / 2;
		});

		request.load(new URLRequest('${downloadLink}${Sys.systemName()}/${version}.zip'));
	}

    //create a function that recursively deletes a directory and all of its contents
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