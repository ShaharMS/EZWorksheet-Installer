package exceptions;

import haxe.Exception;

/**
    Throw this error when youre trying to to use a platfom specific feature, but cant find the platform
**/
class UnknownSystemException extends Exception
{
    public function new() {
        super("Unknown system");
    }
}