package;

import openfl.display.Sprite;

class Main extends Sprite
{
	
	public function new()
	{
		final args = Sys.args();
		for (arg in args) {
			switch arg {
				case "-justUpdate": Sys.exit(0);
			}
		}
		super();
	}
}
