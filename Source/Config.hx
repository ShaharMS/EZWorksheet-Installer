package;

import openfl.Lib;
import exceptions.UnknownSystemException;
import openfl.display.Shape;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.ProgressEvent;
import openfl.net.URLLoaderDataFormat;
import openfl.net.URLRequest;
import openfl.system.System;
import sys.FileSystem;

final backgroundColor:Int = 0xFF333333;
final fontColor:Int = 0xEEFFFFFF;
final fontSize:Int = 14;
final fontName:String = "_sans";
final downloadLink:String = "https://spacebubble.io/apps/ezworksheet/program/";
final appVersionLink:String = "https://spacebubble.io/apps/ezworksheet/api/version";
final versionSave = "version.txt";
final installerFolder = "installer";

final programFolder = switch Sys.systemName() {
		case "Windows": "C:/Users/" + Sys.getEnv("USERNAME") + "/Documents/EZWorksheet/app/";
		case "Mac": Sys.getEnv("$HOME") + "/Documents/EZWorksheet/app/";
		case "Linux": "~/.local/share/EZWorksheet/app/";
		default: throw new UnknownSystemException();
	};