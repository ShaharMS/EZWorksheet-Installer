package;

import openfl.display.DisplayObjectContainer;
import sys.io.File;
import haxe.zip.Reader;
import openfl.events.Event;
import openfl.events.ErrorEvent;
import openfl.events.ProgressEvent;
import openfl.net.URLLoaderDataFormat;
import openfl.display.Shape;
import openfl.text.TextField;
import openfl.display.Sprite;
import haxe.io.BytesInput;
import openfl.net.URLRequest;
import openfl.text.TextFormat;
import sys.FileSystem;
import haxe.Http;
import sys.io.Process;
import exceptions.UnknownSystemException;
using StringTools;

final backgroundColor:Int = 0xFF333333;
final fontColor:Int = 0xEEFFFFFF;
final fontSize:Int = 14;
final fontName:String = "_sans";
final downloadLink:String = "https://ezworksheet.spacebubble.io/app/";
final appVersionLink:String = "https://ezworksheet.spacebubble.io/api/version";
final appVersionListLink:String = "https://ezworksheet.spacebubble.io/api/versionList";
final installerVersionLink:String = "https://ezworksheet.spacebubble.io/api/installerVersion";
final installerFolder = "installer";
final version = "beta-1.0.0";

final programFolder = switch Sys.systemName() {
	case "Windows": openfl.filesystem.File.documentsDirectory.nativePath + "\\EZWorksheet\\app\\";
	default: openfl.filesystem.File.documentsDirectory.nativePath + "/EZWorksheet/app/";
};

final fallbackProgramFolder = switch Sys.systemName() {
	case "Windows": openfl.filesystem.File.userDirectory.nativePath + "\\EZWorksheet\\app\\";
	default: openfl.filesystem.File.userDirectory.nativePath + "/EZWorksheet/app/";
};

final fallbackWithoutPostfix:String = openfl.filesystem.File.userDirectory.nativePath;

function getVersionList(callback:(Array<String>) -> Void) {
	var httpreq = new Http(appVersionListLink);

	httpreq.onData = function(data) {
		callback(data.replace("\r", "").split("\n"));
	};
	httpreq.onError = function(error) {
		callback([]);
	};
	httpreq.request();
}

function hasProgram(version:String) {
	var exists = FileSystem.exists(programFolder + version);
	if (!exists) exists = FileSystem.exists(fallbackProgramFolder + version);
	return exists;
}

function startInstallWithSaveAndBar(progressBar:Shape, version:String, infoText:TextField, parent:DisplayObjectContainer, container:Sprite) {
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
		container.removeChild(progressBar);

		infoText.text = 'Installing And Extracting\n\nversion $version...';
		infoText.width = infoText.textWidth + 50;
		infoText.height = 200;
		infoText.defaultTextFormat = new TextFormat(null, null, null, null, null, null, null, null, CENTER);
		infoText.multiline = true;
		infoText.wordWrap = true;
		// center the text
		infoText.x = app.window.width / 2 - infoText.width / 2;
		infoText.y = app.window.height / 2 - infoText.textHeight / 2;
		// check for tests
		if (Main.TEST) {
			parent.addChild(new Main());
			parent.removeChild(container);
			return;
		}
		var input = new BytesInput(request.data);
		var reader = new Reader(input);
		var entries = reader.read();
		var writeFolder = programFolder;
		try {
			writeProgram(programFolder, entries);
		} catch (e) {
			#if windows
			infoText.text = '
				Notice! you have the Windows setting Controlled Access enabled.
				\n
				\n 
				The program will try to reinstall in this directory:
				\n
				\n + 
				${fallbackWithoutPostfix}';
			infoText.width = app.window.width - 50;
			infoText.height = infoText.textHeight;
			// center the text
			infoText.x = app.window.width / 2 - infoText.textWidth / 2;
			infoText.y = app.window.height / 2 - infoText.textHeight / 2;
			#end
			writeFolder = fallbackProgramFolder;
			writeProgram(fallbackProgramFolder, entries);
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

function getInstalledVersions() {
	var files:Array<String> = [];
	//first. check if the program is installed in the default program directory
	try {
		files = FileSystem.readDirectory(programFolder);
	} catch (e) {
		trace("Unable to find versions in " + programFolder + ": " + e.message);
		try {
			files = FileSystem.readDirectory(fallbackProgramFolder);
		} catch (e) trace("Unable to find versions in " + programFolder + ": " + e.message);
	}
	return files;
	
}