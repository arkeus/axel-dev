package io.axel.sprite.animation {
	import io.axel.render.AxTexture;

	public class AxSpritesheet {
		public var frameWidth:uint;
		public var frameHeight:uint;
		public var framesPerRow:uint;
		public var uvWidth:Number;
		public var uvHeight:Number;
		
		public function AxSpritesheet(texture:AxTexture, frameWidth:uint = 0, frameHeight:uint = 0) {
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
