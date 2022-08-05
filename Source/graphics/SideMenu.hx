package graphics;

import openfl.display.DisplayObject;
import openfl.display.Sprite;

/**
	A side menu to push buttons to.
**/
class SideMenu extends Sprite {
	var w:Float = 0;

	var step:Float = -1;

	var bottomStep:Float = -1;

	public var objects:Array<{side:Int, object:Sprite}> = [];


	var pwwidth:Float = app.window.width;
	var pwheight:Float = app.window.height;
	public function new(width:Float) {
		super();

		w = width;
		// draw a one pixel black line from the top to the bottom of the menu
		this.graphics.beginFill(0x000000);
		this.graphics.lineStyle(1, 0x000000);
		this.graphics.drawRect(0, 0, 1, app.window.height);
		this.x = app.window.width - width;
		this.y = 0;

		app.window.onResize.add((w, h) -> {
			this.x = app.window.width - width;
			this.graphics.beginFill(0x000000);
			this.graphics.lineStyle(1, 0x000000);
			this.graphics.drawRect(0, 0, 1, app.window.height);
			for (o in objects) {
				if (o.side == 0) continue;
				o.object.y += h - pwheight;
			}
			pwheight = h;
			pwwidth = w;
		});
	}

	public function push(object:Sprite):SideMenu {
		// center the object in the menu
		object.x = w / 2 - object.width / 2 + 2;
		if (step == -1)
			step = object.x;
		object.y = step;
		step += object.height + 5;
		objects.push({side: 0, object: object});
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

	// pushGroup is a convenience function to push a group of buttons
	public function pushGroup(objects:Array<Sprite>):SideMenu {
		for (o in objects) {
			push(o);
		}
		return this;
	}

	// make a function the pushes a Sprite, but positons it at the bottom of the menu
	public function pushBottom(object:Sprite):SideMenu {
		object.x = w / 2 - object.width / 2 + 2;
		if (bottomStep == -1)
			bottomStep = object.x + object.height;
		object.y = app.window.height - bottomStep;
		bottomStep += object.height + 5;
		objects.push({side: 1, object: object});
		addChild(object);
		return this;
	}
}