package;

import haxe.Timer;
import exceptions.DeletionUnavailableException;
import haxe.io.Path;
import openfl.desktop.NativeProcess;
import openfl.desktop.NativeProcessStartupInfo;
import haxe.Exception;
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

import openfl.filesystem.File as OFLFile;

#if (haxe < version("4.2.0"))
class Config {
#end
#if (haxe < version("4.2.0")) public static #end final backgroundColor:Int = 0xFF333333;
#if (haxe < version("4.2.0")) public static #end final fontColor:Int = 0xEEFFFFFF;
#if (haxe < version("4.2.0")) public static #end final fontSize:Int = 14;
#if (haxe < version("4.2.0")) public static #end final fontName:String = "_sans";
#if (haxe < version("4.2.0")) public static #end final downloadLink:String = "https://ezworksheet.spacebubble.io/app/";
#if (haxe < version("4.2.0")) public static #end final appVersionLink:String = "https://ezworksheet.spacebubble.io/api/version";
#if (haxe < version("4.2.0")) public static #end final appVersionListLink:String = "https://ezworksheet.spacebubble.io/api/versionList";
#if (haxe < version("4.2.0")) public static #end final installerVersionLink:String = "https://ezworksheet.spacebubble.io/api/installerVersion";
#if (haxe < version("4.2.0")) public static #end final installerFolder = "installer";
#if (haxe < version("4.2.0")) public static #end final version = "beta-1.0.0"; 
#if (haxe < version("4.2.0")) public static #end final SIDEBAR_WIDTH = 115;

#if (haxe < version("4.2.0")) public static #end final executableName = "EZWorksheet" + switch Sys.systemName() {
	case "Windows": ".exe";
	case "Mac": ".dmg";
	case "Linux": "";
	default: "";
};
#if (haxe < version("4.2.0")) public static #end final installerName = "EZWorksheet-Installer" + switch Sys.systemName() {
	case "Windows": ".exe";
	case "Mac": ".dmg";
	case "Linux": "";
	default: "";
};
#if (haxe < version("4.2.0")) public static #end final programFolder = switch Sys.systemName() {
	case "Windows": openfl.filesystem.File.documentsDirectory.nativePath + "\\EZWorksheet\\app\\";
	default: openfl.filesystem.File.documentsDirectory.nativePath + "/EZWorksheet/app/";
};

#if (haxe < version("4.2.0")) public static #end final fallbackProgramFolder = switch Sys.systemName() {
	case "Windows": openfl.filesystem.File.userDirectory.nativePath + "\\EZWorksheet\\app\\";
	default: openfl.filesystem.File.userDirectory.nativePath + "/EZWorksheet/app/";
};
#if (haxe < version("4.2.0")) public static #end final programWithoutPostfix:String = Path.join([openfl.filesystem.File.documentsDirectory.nativePath, "/EZWorksheet/"]);
#if (haxe < version("4.2.0")) public static #end final fallbackWithoutPostfix:String = Path.join([openfl.filesystem.File.userDirectory.nativePath, "/EZWorksheet/"]);

#if (haxe < version("4.2.0")) public static #end function getVersionList(callback:(Array<String>) -> Void) {
	var httpreq = new Http(appVersionListLink);

	httpreq.onData = function(data) {
		callback(data.replace("\r", "").split("\n"));
	};
	httpreq.onError = function(error) {
		callback([]);
	};
	httpreq.request();
}

#if (haxe < version("4.2.0")) public static #end function hasProgram(version:String) {
	var exists = FileSystem.exists(programFolder + version);
	if (!exists) exists = FileSystem.exists(fallbackProgramFolder + version);
	return exists;
}

#if (haxe < version("4.2.0")) public static #end function startInstallWithSaveAndBar(progressBar:Shape, version:String, infoText:TextField, parent:DisplayObjectContainer, container:Sprite) {
	var request = new openfl.net.URLLoader();
	request.dataFormat = URLLoaderDataFormat.BINARY;
	#if !hl
	request.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent) {
		progressBar.graphics.clear();
		progressBar.graphics.lineStyle(1, 0x000000);
		progressBar.graphics.drawRect(0, 0, 200, 30);
		progressBar.graphics.lineStyle(0);
		progressBar.graphics.beginFill(0x0FD623);
		progressBar.graphics.drawRect(0, 0, e.bytesLoaded / e.bytesTotal * 200, 30);
		progressBar.graphics.endFill();
	});
	#else
	new Timer(16).run = function () {
		progressBar.graphics.clear();
		progressBar.graphics.lineStyle(1, 0x000000);
		progressBar.graphics.drawRect(0, 0, 200, 30);
		progressBar.graphics.lineStyle(0);
		progressBar.graphics.beginFill(0x0FD623);
		progressBar.graphics.drawRect(0, 0, request.bytesLoaded / request.bytesTotal * 200, 30);
		progressBar.graphics.endFill();
	}
	#end
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
			try {
				writeFolder = fallbackProgramFolder;
				writeProgram(fallbackProgramFolder, entries);
			} catch (e) throw new DeletionUnavailableException();
			
		}
		infoText.text = 'Done! App Found at:\n\n' + writeFolder + version;
		infoText.width = infoText.textWidth + 4;
		infoText.height = infoText.textHeight + 4;
		infoText.setTextFormat(new TextFormat(null, 12), 21, infoText.text.length);
		// center the text
		infoText.x = app.window.width / 2 - infoText.width / 2;
		infoText.y = app.window.height / 2 - infoText.height / 2;
	});

	request.load(new URLRequest('${downloadLink}${Sys.systemName()}/${version}.zip'));
}

// create a function that recursively deletes a directory and all of its contents
#if (haxe < version("4.2.0")) public static #end function deleteDirectory(dir:String, ?onRemovedDirectory:String->Void, ?onRemovedFile:String -> Void) {
	var files = FileSystem.readDirectory(dir);
	for (f in files) {
		if (FileSystem.isDirectory(dir + "\\" + f)) {
			deleteDirectory(dir + "\\" + f);
			if (onRemovedDirectory != null) onRemovedDirectory(f);
		} else {
			FileSystem.deleteFile(dir + "\\" + f);
			if (onRemovedFile != null) onRemovedFile(f);
		}
	}
	FileSystem.deleteDirectory(dir);
}

#if (haxe < version("4.2.0")) public static #end function writeProgram(folder:String, entries:haxe.ds.List<haxe.zip.Entry>) {
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

#if (haxe < version("4.2.0")) public static #end function makeUserFolder(folder:String) {
	if (folder.split('\\')[-2] != 'Users') {
		return makeUserFolder(folder.substring(0, folder.lastIndexOf('\\')));
	}
	return folder;
}

#if (haxe < version("4.2.0")) public static #end function getInstalledVersions() {
	var files:Array<String> = [];
	//first. check if the program is installed in the default program directory
	if (FileSystem.isDirectory(programFolder)) {
		files = FileSystem.readDirectory(programFolder);
	} else {
		trace("Unable to find versions in " + programFolder + ": - Using fallback directory: " + fallbackProgramFolder);
		try {
			files = FileSystem.readDirectory(fallbackProgramFolder);
		} catch (e) trace("Unable to find versions in " + programFolder + ": " + e.message);
	}
	return files;
	
}

#if (haxe < version("4.2.0")) public static #end function uninstallVersions(versions:Array<String>, onRemovedVersion:String -> Void, onRemovedFile:String -> Void, onError:Exception -> Void) {
	try {
		var directory = FileSystem.readDirectory(programFolder);
		for (folder in directory) {
			if (!versions.contains(folder)) continue;
			try {
				deleteDirectory(programFolder + folder, onRemovedFile, onRemovedFile);
			} catch (e) throw new DeletionUnavailableException();
			onRemovedVersion(folder);
		}
	} catch (e) {
		trace("Unable to find versions in " + programFolder + ": (" + e.message + ") - Using fallback directory: " + fallbackProgramFolder);
		try {
			var directory = FileSystem.readDirectory(fallbackProgramFolder);
			for (folder in directory) {
				trace(folder);
				if (!versions.contains(folder))
					continue;
				deleteDirectory(fallbackProgramFolder + folder, onRemovedFile, onRemovedFile);
				onRemovedVersion(folder);
			}
		} catch (e) {
			onError(e);
		}
	}
}
#if (haxe < version("4.2.0")) public static #end function getProgramFolder() {
		if (FileSystem.isDirectory(programFolder)) return programFolder;
		return fallbackProgramFolder;
}
#if (haxe < version("4.2.0"))
}
#end