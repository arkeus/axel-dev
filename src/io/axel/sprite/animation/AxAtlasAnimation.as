package io.axel.sprite.animation {
	public class AxAtlasAnimation implements AxAnimation {
		/** The name of the animation, used when you want to play the animation. */
		public var _name:String;
		/** The list of frames in the animation. */
		public var frames:Vector.<Array>;
		/** The framerate the animation should play at. */
		public var framerate:uint;
		/** Whether or not this animation is looped. */
		public var _looped:Boolean;
		/** Callback that is called when (and every time) the animation finishes. */
		public var _callback:Function;
		/** Read-only. Delay in time between animation frames. */
		public var animationDelay:Number;
		/** Read-only. The timer for playing the current animation. */
		public var animationTimer:Number;
		/** The current frame of the animation. */
		public var _frame:uint;
		/** The texture used for calculating animation frames. */
		public var texture:AxAnimationTexture;
		
		public function AxAtlasAnimation(name:String, frames:Array, framerate:uint, texture:AxAnimationTexture, looped:Boolean = true, callback:Function = null) {
			this._name = name;
			this.frames = validateFrames(frames);
			this.framerate = framerate;
			this.texture = texture;
			this._looped = looped;
			this._callback = callback;
			this.animationDelay = 1 / framerate;
			this.animationTimer = 0;
			this._frame = 0;
		}
		
		public function advance(dt:Number, uvOffset:Vector.<Number>):void {
			animationTimer += dt;
			while (animationTimer >= animationDelay) {
				animationTimer -= animationDelay;
				if (_frame + 1 < frames.length || looped) {
					_frame = (_frame + 1) % frames.length;
				}
				uvOffset[0] = frames[_frame][0] / texture.texture.width;
				uvOffset[1] = frames[_frame][1] / texture.texture.height;
				if (_frame + 1 == frames.length && callback != null) {
					callback();
				}
			}
		}
		
		public function activate():void {
			animationDelay = 1 / framerate;
			animationTimer = animationDelay;
		}
		
		public function get name():String {
			return _name;
		}
		
		public function get length():uint {
			return frames.length;
		}
		
		public function get looped():Boolean {
			return _looped;
		}
		
		public function get callback():Function {
			return _callback;
		}
		
		public function get frame():uint {
			return _frame;
		}
		
		private function validateFrames(frames:Array):Vector.<Array> {
			var result:Vector.<Array> = new Vector.<Array>;
			for each (var frame:Array in frames) {
				if (frame.length != 2) {
					throw new ArgumentError("Invalid frame in atlas animation: " + frame);
				}
				result.push(frame);
			}
			return result;
		}
		
		public function dispose():void {
			frames = null;
		}
	}
}
