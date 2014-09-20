package io.axel.sprite.animation {
	import io.axel.render.AxTexture;

	/**
	 * A descriptor containing information about a texture, along with attributes required to build animations
	 * from it.
	 */
	public class AxAnimationTexture {
		public var texture:AxTexture;
		public var frameWidth:uint;
		public var frameHeight:uint;
		public var framesPerRow:uint;
		public var uvWidth:Number;
		public var uvHeight:Number;

		public function AxAnimationTexture(texture:AxTexture, frameWidth:uint = 0, frameHeight:uint = 0) {
			this.texture = texture;
			if (frameWidth == 0 || frameHeight == 0) {
				this.frameWidth = texture.rawWidth;
				this.frameHeight = texture.rawHeight;
			} else {
				this.frameWidth = frameWidth;
				this.frameHeight = frameHeight;
			}
			this.uvWidth = this.frameWidth / texture.width;
			this.uvHeight = this.frameHeight / texture.height;
			framesPerRow = Math.max(1, Math.floor(texture.rawWidth / this.frameWidth));
		}
	}
}
