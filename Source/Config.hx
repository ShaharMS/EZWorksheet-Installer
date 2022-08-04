package;

import haxe.Http;
import sys.io.Process;
import exceptions.UnknownSystemException;
using StringTools;

final backgroundColor:Int = 0xFF333333;
final fontColor:Int = 0xEEFFFFFF;
final fontSize:Int = 14;
final fontName:String = "_sans";
final downloadLink:String = "https://spacebubble.io/apps/ezworksheet/program/";
final appVersionLink:String = "https://spacebubble.io/apps/ezworksheet/api/version";
final appVersionListLink:String = "https://spacebubble.io/apps/ezworksheet/api/versionList";
final versionSave = "version.txt";
final installerFolder = "installer";

final programFolder = switch Sys.systemName() {
	case "Windows": getWindowsDocumentsFolder() + "\\EZWorksheet\\app\\";
	case "Mac": Sys.getEnv("$HOME") + "/Documents/EZWorksheet/app/";
	case "Linux": "~/.local/share/EZWorksheet/app/";
	default: throw new UnknownSystemException();
};

function getWindowsDocumentsFolder() {
	#if windows
	var p = new Process("powershell", ["[Environment]::GetFolderPath(\"MyDocuments\")"]);
	return '${p.stdout.readLine()}';
	#end
	return "";
}

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