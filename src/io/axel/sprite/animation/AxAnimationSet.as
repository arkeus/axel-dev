package io.axel.sprite.animation {
	import io.axel.render.AxTexture;

	/**
	 * A class holding the animations for a single AxSprite.
	 */
	public class AxAnimationSet {
		/** The current animation this sprite is playing. */
		public var animation:AxAnimation;
		/** All registered animations of this set. This is a map from animation name to animation. */
		public var animations:Object;
		/** The current frame of the animation. */
		public var frame:uint;
		/** The spritesheet used for calculating spritesheet animations. */
		public var animationTexture:AxAnimationTexture;
		/** The location (in whatever texture is being used) where the current frame resides. */
		public var uvOffset:Vector.<Number>;
		
		public function AxAnimationSet() {
			animation = null;
			animations = {};
			frame = 0;
			animationTexture = null;
			uvOffset = new Vector.<Number>(4, true);
		}
		
		/**
		 * Given a texture, calculates the dimensions used in order to calculate the position of each frame for animations in this
		 * set.
		 * 
		 * @param texture The AxTexture to be used to calculate frame dimensions.
		 */
		public function buildAnimationTexture(texture:AxTexture, frameWidth:uint = 0, frameHeight:uint = 0):void {
			animationTexture = new AxAnimationTexture(texture, frameWidth, frameHeight);
		}
		
		/**
		 * Adds a new animation to this set. The <code>name</code> of the animation is what you will use to access it via the <code>play</code>
		 * function. The <code>frames</code> is an array that lists the frames of the animation in the order they will play. <code>Framerate</code> is
		 * how fast the animation will play; it indicates how many frames will be played per second. If you have a 5 frame animation with a
		 * framerate of 10, it will play the animation twice per second. The <code>looped</code> parameter indicates whether or not this
		 * animation should stop at the end of the animation, or if it should loop repeatedly.
		 * 
		 * @param name The name of the animation.
		 * @param frames The array of frames that make up the animation.
		 * @param framerate The framerate at which the animation should play.
		 * @param looped Whether or not the animation should loop.
		 *
		 * @return The animation set.
		 */
		public function add(name:String, frames:Array, framerate:uint = 15, looped:Boolean = true, callback:Function = null):AxAnimationSet {
			animations[name] = new AxSpritesheetAnimation(name, frames, framerate < 1 ? 15 : framerate, animationTexture, looped, callback);
			return this;
		}
		
		public function addAtlas(name:String, frames:Array, framerate:uint = 15, looped:Boolean = true, callback:Function = null):AxAnimationSet {
			animations[name] = new AxAtlasAnimation(name, frames, framerate < 1 ? 15 : framerate, animationTexture, looped, callback);
			return this;
		}
		
		/**
		 * Tells this set to immediately start playing the animation that you passed. If that animation is already playing,
		 * this call will do nothing. If you want to stop the animation and instead show a static frame, use the <code>show</code>
		 * method on AxSprite instead.
		 * 
		 * @param name The name of the animation to play.
		 * @param reset Whether or not to force reset the animation from scratch.
		 */
		public function play(name:String, reset:Boolean = false):void {
			if ((reset || animation == null || (animation != null && animation.name != name)) && animations[name] != null) {
				animation = animations[name];
				animation.activate();
				frame = 0;
			}
		}
		
		/**
		 * Stops the current animation (if one is playing), and sets the frame to the passed frame.
		 * 
		 * @param frame The frame that should show.
		 */
		public function show(frame:uint):void {
			animation = null;
			this.frame = frame;
		}
		
		public function get current():AxAnimation {
			return animation;
		}
		
		/**
		 * Advances the animation set by the passed amount of time.
		 */
		public function advance(dt:Number):void {
			if (animation != null) {
				animation.advance(dt, uvOffset);
			} else {
				uvOffset[0] = (frame % animationTexture.framesPerRow) * animationTexture.uvWidth;
				uvOffset[1] = Math.floor(frame / animationTexture.framesPerRow) * animationTexture.uvHeight;
			}
		}
		
		/**
		 * Gets an animation by name.
		 * 
		 * @param name The name of the animation to get.
		 * 
		 * @return The animation with the given name, or null if none exists.
		 */
		public function get(name:String):AxSpritesheetAnimation {
			return animations[name];
		}
		
		/**
		 * Dispose the animation set.
		 */
		public function dispose():void {
			for (var animationName:String in animations) {
				animations[animationName].dispose();
			}
			animations = null;
			animation = null;
			uvOffset = null;
		}
	}
}
