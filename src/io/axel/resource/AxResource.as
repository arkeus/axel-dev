package io.axel.resource {
	import io.axel.text.AxFont;

	/**
	 * Resources used internally within the Axel library.
	 */
	public class AxResource {
		/* The small axel icon */
		[Embed(source = "icon.png")] public static const ICON:Class;
		
		/* Default AxButton background */
		[Embed(source = "button.png")] public static const BUTTON:Class;
		
		/* Built in Axel font */
		[Embed(source = "font.png")] public static const FONT_BITMAP:Class;
		public static var font:AxFont;
		
		public static function initialize():void {
			font = AxFont.fromBitmap(FONT_BITMAP, 0, 0);
		}
	}
}