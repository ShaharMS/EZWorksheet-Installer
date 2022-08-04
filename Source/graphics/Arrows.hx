package graphics;

import openfl.display.Shape;
import openfl.display.BitmapData;

/**
    A class with static methods to generate arrowheads;
**/
class Arrows {
    
    public static function getUpwardsArrowHead(width:Int, height:Int, color:Int):Shape {
        var shape:Shape = new Shape();
        shape.graphics.beginFill(color);
        shape.graphics.moveTo(0, 0);
        shape.graphics.lineTo(width, 0);
        shape.graphics.lineTo(width / 2, height);
        shape.graphics.lineTo(0, 0);
        shape.graphics.endFill();

        return shape;
    }

    public static function getDownwardsArrowHead(width:Int, height:Int, color:Int):Shape {
        var shape:Shape = new Shape();
        shape.graphics.beginFill(color);
        shape.graphics.moveTo(0, height);
        shape.graphics.lineTo(width, height);
        shape.graphics.lineTo(width / 2, 0);
        shape.graphics.lineTo(0, height);
        shape.graphics.endFill();

        return shape;
    }

    public static function getLeftwardsArrowHead(width:Int, height:Int, color:Int):Shape {
        var shape:Shape = new Shape();
        shape.graphics.beginFill(color);
        shape.graphics.moveTo(0, 0);
        shape.graphics.lineTo(0, height);
        shape.graphics.lineTo(width, height / 2);
        shape.graphics.lineTo(0, 0);
        shape.graphics.endFill();

        return shape;
    }

    public static function getRightwardsArrowHead(width:Int, height:Int, color:Int):Shape {
        var shape:Shape = new Shape();
        shape.graphics.beginFill(color);
        shape.graphics.moveTo(width, 0);
        shape.graphics.lineTo(width, height);
        shape.graphics.lineTo(0, height / 2);
        shape.graphics.lineTo(width, 0);
        shape.graphics.endFill();

        return shape;
    }

    public static function getBiDiVerticalArrow(width:Int, gap:Int, heightPerArrow:Int, color:Int):Shape {
        var shape:Shape = new Shape();

        shape.graphics.beginFill(color);
        shape.graphics.moveTo(0, heightPerArrow / 2 + gap / 2);
        shape.graphics.lineTo(width, heightPerArrow / 2 + gap / 2);
        shape.graphics.lineTo(width / 2, heightPerArrow / 2 + gap / 2 + heightPerArrow);
        shape.graphics.lineTo(0, heightPerArrow / 2 + gap / 2);

        shape.graphics.moveTo(0, heightPerArrow / 2 - gap / 2);
        shape.graphics.lineTo(width, heightPerArrow / 2 - gap / 2);
        shape.graphics.lineTo(width / 2, heightPerArrow / 2 - gap / 2 - heightPerArrow);
        shape.graphics.lineTo(0, heightPerArrow / 2 - gap / 2);
        shape.graphics.endFill();

        return shape;
    }

    public static function getBiDiHorizontalArrow(height:Int, gap:Int, widthPerArrow:Int, color:Int):Shape {
        var shape:Shape = new Shape();

        shape.graphics.beginFill(color);
        shape.graphics.moveTo(widthPerArrow / 2 + gap / 2, 0);
        shape.graphics.lineTo(widthPerArrow / 2 + gap / 2, height);
        shape.graphics.lineTo(widthPerArrow / 2 + gap / 2 + widthPerArrow, height / 2);
        shape.graphics.lineTo(widthPerArrow / 2 + gap / 2, 0);

        shape.graphics.moveTo(widthPerArrow / 2 - gap / 2, 0);
        shape.graphics.lineTo(widthPerArrow / 2 - gap / 2, height);
        shape.graphics.lineTo(widthPerArrow / 2 - gap / 2 - widthPerArrow, height / 2);
        shape.graphics.lineTo(widthPerArrow / 2 - gap / 2, 0);
        shape.graphics.endFill();

        return shape;
    }


}