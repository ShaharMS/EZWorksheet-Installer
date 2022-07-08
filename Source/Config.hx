package;

import openfl.events.ProgressEvent;
import openfl.net.URLRequest;
import exceptions.UnknownSystemException;
import openfl.display.Shape;
import sys.FileSystem;
import openfl.system.System;

final backgroundColor:Int = 0xFF333333;
final fontColor:Int = 0xEEFFFFFF;
final fontSize:Int = 14;
final fontName:String = "_sans";
final downloadLink:String = "https://spacebubble.io/apps/ezworksheet/program/";
final appVersionLink:String = "https://spacebubble.io/apps/ezworksheet/api/version";
final versionSave = "version.txt";
final installerFolder = "installer";
final programFolder = switch Sys.systemName() {
    case "Windows": Sys.getEnv("%USERPROFILE%") + "/Documents/EZWorksheet/app";
    case "Mac": Sys.getEnv("$HOME") + "/Documents/EZWorksheet/app";
    case "Linux": "~/.local/share/EZWorksheet/app";
    default: throw new UnknownSystemException();
};

function startDownloadWithSaveAndBar(progressBar:Shape, version:String) {

    var request = new openfl.net.URLLoader( new URLRequest('${downloadLink}${Sys.systemName()}/${version}.zip'));

    request.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent) {
        progressBar.graphics.clear();
		progressBar.graphics.lineStyle(1, 0x000000);
		progressBar.graphics.drawRect(0, 0, 200, 30);
        progressBar.graphics.lineStyle(0);
        progressBar.graphics.beginFill(0x0FD623);
        progressBar.graphics.drawRect(0, 0, e.bytesLoaded / e.bytesTotal * 100, 10);
        progressBar.graphics.endFill();
    });
}