package laerm;

import js.lib.Uint8Array;

abstract class Spectrum {

    public final radio : Radio;

    public var color_bg : String;
    public var color_fg : String;

    function new( radio : Radio ) {
        this.radio = radio;
    }

    abstract public function render( timeData : Uint8Array ) : Void;
}