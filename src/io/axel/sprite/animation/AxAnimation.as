package io.axel.sprite.animation {
	public interface AxAnimation {
		function advance(dt:Number, uvOffset:Vector.<Number>):void;
		function activate():void;
		function get length():uint;
		function get looped():Boolean;
		function get callback():Function;
	}
}
