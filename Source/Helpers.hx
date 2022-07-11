package;

import openfl.ui.MouseCursor;
import openfl.ui.Mouse;
import openfl.events.MouseEvent;
import openfl.display.DisplayObject;
import openfl.text.TextField;
import openfl.display.Sprite;

/**
    A simple button with an offwhite background
    and a border.

    The button's label is a TextField object
**/
class Button extends Sprite {

    public var textField:TextField;

    public var oldCallback:(MouseEvent) -> Void;
    public var onClick(default, set):(MouseEvent) -> Void = (e) -> {trace("Button clicked");};

    public var onHover:(MouseEvent) -> Void = (e) -> {trace("Button hovered");};

    public function new(text:String) {
        super();
        oldCallback = onClick;
		this.useHandCursor = true;

        this.textField = new TextField();
        this.textField.text = text;
        this.textField.multiline = true;    
        this.textField.selectable = false;
        this.textField.mouseEnabled = false;
        this.textField.defaultTextFormat = new openfl.text.TextFormat("_sans", 12, 0x000000, null, null, null, null, null, "center");
        this.textField.width = this.textField.textWidth + 4;
        this.textField.height = this.textField.textHeight + 4;

        addChild(this.textField);

        //draw a button with graphics
        this.graphics.beginFill(0xADADAD);
        this.graphics.lineStyle(1, 0x000000);
        this.graphics.drawRect(0, 0, width, height);

        addEventListener(MouseEvent.CLICK, oldCallback);
        //add event listeners to change the button's appearance on hover and the mouses cursor
        addEventListener(MouseEvent.MOUSE_OVER, e -> {
            this.graphics.clear();
            this.graphics.beginFill(0xFFFFFF);
            this.graphics.lineStyle(1, 0x000000);
            this.graphics.drawRect(0, 0, width, height);
            Mouse.cursor = MouseCursor.BUTTON;
            onHover(e);
            
        });
        addEventListener(MouseEvent.MOUSE_OUT, e -> {
            this.graphics.clear();
            this.graphics.beginFill(0xADADAD);
            this.graphics.lineStyle(1, 0x000000);
            this.graphics.drawRect(0, 0, width, height);
            Mouse.cursor = MouseCursor.AUTO;
        });

        addEventListener(MouseEvent.MOUSE_DOWN, e -> {
			this.graphics.clear();
			this.graphics.beginFill(0x7B7B7B);
			this.graphics.lineStyle(1, 0x000000);
			this.graphics.drawRect(0, 0, width, height);
			this.graphics.endFill();
        });
    }

    function set_onClick(callback:(MouseEvent) -> Void) {
        this.removeEventListener(MouseEvent.CLICK, oldCallback);
        this.addEventListener(MouseEvent.CLICK, callback);
        oldCallback = callback;
        return callback;
    }

    override function set_width(value:Float):Float {
        //redraw the button with new width and height
        this.graphics.clear();
        this.graphics.beginFill(0xADADAD);
        this.graphics.lineStyle(1, 0x000000);
        this.graphics.drawRect(0, 0, value, height);
        this.textField.width = value;
        this.textField.text = this.textField.text;
        return value;
    }

    override function set_height(value:Float):Float {
        //redraw the button with new width and height
        this.graphics.clear();
        this.graphics.beginFill(0xADADAD);
        this.graphics.lineStyle(1, 0x000000);
        this.graphics.drawRect(0, 0, width, value);
        this.textField.height = value;
        this.textField.text = this.textField.text;
        return value;
    }
}

/**
    A side menu to push buttons to.
**/
class SideMenu extends Sprite {

    var w:Float = 0;

    var step:Float = -1;

    var bottomStep:Float = -1;

    public var objects:Array<Sprite> = [];

    public function new(width:Float) {
        super();

        w = width;
        //draw a one pixel black line from the top to the bottom of the menu
        this.graphics.beginFill(0x000000);
        this.graphics.lineStyle(1, 0x000000);
        this.graphics.drawRect(0, 0, 1, app.window.height);
        this.x = app.window.width - width;
        this.y = 0;
    }

    public function push(object:Sprite):SideMenu {
        //center the object in the menu
        object.x = w / 2 - object.width / 2 + 2;
        if (step == -1) step = object.x;
        object.y = step;
        step += object.height + 5;
        objects.push(object);
        addChild(object);
        return this;
    }

    public function pop():SideMenu {
        var object:DisplayObject = getChildAt(numChildren - 1);
        removeChild(object);
        step -= object.height + 5;
        objects.pop();
        return this;
    }

    //pushGroup is a convenience function to push a group of buttons
    public function pushGroup(objects:Array<Sprite>):SideMenu {
        for (o in objects) {
            push(o);
        }
        return this;
    }

    //make a function the pushes a Sprite, but positons it at the bottom of the menu
    public function pushBottom(object:Sprite):SideMenu {
        object.x = w / 2 - object.width / 2 + 2;
        if (bottomStep == -1) bottomStep = object.x + object.height;
        object.y = app.window.height - bottomStep;
        bottomStep += object.height + 5;
        objects.push(object);
        addChild(object);
        return this;
    }

}