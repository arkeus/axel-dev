package io.axel.sprite.animation {
	public class AxAtlasAnimation {
		/** The name of the animation, used when you want to play the animation. */
		public var name:String;
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
		public var frame:uint;
		/** The spritesheet used for calculating animation frames. */
		public var spritesheet:AxSpritesheet;
		
		public function AxAtlasAnimation(name:String, frames:Array, framerate:uint, spritesheet:AxSpritesheet, looped:Boolean = true, callback:Function = null) {
			this.name = name;
			this.frames = Vector.<Array>(frames);
			this.framerate = framerate;
			this.spritesheet = spritesheet;
			this._looped = looped;
			this._callback = callback;
			this.animationDelay = 1 / framerate;
			this.animationTimer = 0;
			this.frame = 0;
		}
	}
}
