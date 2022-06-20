package;

import openfl.display.Sprite;
import openfl.Lib.application as app;

/**
 * The auto updater doesnt require any user interaction, and just downloads stuff.
 * 
 * JUst to make stuff comfortable, it resizes and moves itself to the top left corner of the screen.
 */
class AutoUpdater extends Sprite {
    
    public function new() {
        super();
        app.window.x = 5;
        app.window.y = 35;
        app.window.width = 250;
        app.window.height = 100;
    }
}