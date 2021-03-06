package io.axel {
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.system.ApplicationDomain;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getTimer;
	
	import io.axel.base.AxDrawable;
	import io.axel.base.AxEntity;
	import io.axel.base.AxUpdatable;
	import io.axel.camera.AxCamera;
	import io.axel.collision.AxCollider;
	import io.axel.collision.AxGridCollider;
	import io.axel.collision.AxGroupCollider;
	import io.axel.input.AxKey;
	import io.axel.input.AxKeyboard;
	import io.axel.input.AxMouse;
	import io.axel.render.AxColor;
	import io.axel.render.AxShader;
	import io.axel.resource.AxResource;
	import io.axel.sound.AxAudioManager;
	import io.axel.state.AxStateStack;
	import io.axel.tilemap.AxTilemap;
	import io.axel.util.AxCache;
	import io.axel.util.AxLogger;
	import io.axel.util.AxPauseState;
	import io.axel.util.debug.AxDebugger;

	/**
	 * The general game class that your base class should extends. Contains all the properties of the game,
	 * including both the stage object and stage3d object. Also contains most of the generic game utilities.
	 */
	public class Ax extends Sprite {
		public static const LIBRARY_NAME:String = "Axel";
		public static const LIBRARY_VERSION:String = "0.9.4 r3";
		
		/**
		 * Whether or not the game is running is debug mode.
		 */
		public static var debug:Boolean;
		/**
		 * The framerate requested when creating the game. This is the framerate that the game will try
		 * to set the player to be.
		 *
		 * @default 60
		 */
		public static var requestedFramerate:uint;
		/**
		 * The framerate the game will be lowered to when your game loses focus, so when players are in
		 * another window it doesn't use as many resources. Set this to the same value as the requested
		 * framerate in order to disable lowering the framerate when losing focus.
		 *
		 * @default 20
		 */
		public static var unfocusedFramerate:uint;
		/**
		 * The stack of states in the game. The top state is always updated and drawn. States that are not
		 * the top state will only be updated if persistantUpdate is true, and will only be drawn if
		 * persistantDraw is true.
		 */
		public static var states:AxStateStack;
		/**
		 * Read-only. The root flash Stage object.
		 */
		public static var stage2D:Stage;
		/**
		 * Read-only. The root flash Stage3D object.
		 */
		public static var stage3D:Stage3D;
		/**
		 * Read-only. The Stage3D context.
		 */
		public static var context:Context3D;
		/**
		 * The zoom level of the game. Manipulate this using Ax.zoom. Allows you to dynamically zoom in and out
		 * during your game.
		 *
		 * @default 1
		 */
		protected static var worldZoom:Number;

		/**
		 * Read-only. Internal timer to run internal heartbeat function about once a second.
		 */
		public static var heartbeatTimer:Number = 1;
		/**
		 * Read-only. The timestamp for the current frame. Use this instead of getTimer().
		 */
		public static var now:uint = 0;
		/**
		 * Read-only. The timestamp for the previous frame.
		 */
		public static var then:uint = 0;
		/**
		 * Read-only. The time when the current "second" began. Used to detect once 1 second worth of time has passed in order
		 * to calculate frames per second.
		 */
		public static var frameStart:uint = 0;
		/**
		 * Read-only. The current fps rate.
		 * @default
		 */
		public static var fps:uint = 0;
		/**
		 * Read-only. The amount of time that has passed between the last frame and the current frame. You should always multiply
		 * by this when moving objects based on velocity. This way, even if the fps rate drops, your movement will still be consistent.
		 * For example, rather than moving 2 pixels every frame (which is 120 pixels every second at 60fps, but only 60 pixels every
		 * second at 30fps), you should move 120 * Ax.dt per frame, which will move you 120 pixels every second regardless of fps.
		 * If you set fixed framerate to true, this will always return 1/framerate.
		 */
		public static var dt:Number = 0;
		/**
		 * Read-only. Counts the number of frames since the current "second" began in order to calculate fps.
		 * @default
		 */
		public static var frames:uint = 0;
		/**
		 * Whether or not we're operating in fixed framerate mode. This ensures that Ax.dt always returns 1/framerate. This allows you
		 * to give the option of switching back and forth by fixed and variable by multiply by Ax.dt but toggling this flag.
		 */
		public static var fixedTimestep:Boolean;

		/**
		 * Read-only. Width of the game, specified in the super of your main class.
		 */
		public static var width:uint;
		/**
		 * Read-only. Height of the game, specified in the super of your main class.
		 */
		public static var height:uint;

		/**
		 * Read-only. The keyboard object. Use this to figure out if specific keys were pressed, released, or being held.
		 */
		public static var keys:AxKeyboard;
		/**
		 * Read-only. The mouse object. Use this to figure out if mouse buttons were pressed, released, or being held.
		 */
		public static var mouse:AxMouse;
		/**
		 * Read-only. The camera object. Use this set the bounds where your camera can move, set it to follow objects, etc.
		 */
		public static var camera:AxCamera;

		/**
		 * Read-only. The sound manager.
		 */
		public static var sound:AxAudioManager;
		/**
		 * Read-only. The music manager.
		 */
		public static var music:AxAudioManager;
		/**
		 * The background color of the game. The alpha component is ignored, as the background is always opaque.
		 * 
		 * @default (1, 1, 1)
		 */
		public static var background:AxColor;

		/**
		 * A debug flag. Set this to true to draw the bounding boxes of all objects.
		 * TODO: Make this work again.
		 *
		 * @default false
		 */
		public static var showBounds:Boolean = false;

		/**
		 * Read-only. The render mode of the game, either "Software Mode" or "Hardware Mode" and is determined whether the
		 * player's computer supports hardware rendering. If it is "Software Mode", all rendering will be done on the CPU
		 * and will be very slow. This value can be read through <code>Ax.mode</code>.
		 */
		protected static var renderMode:String;
		
		/**
		 * Read-only. The game debugger. If open, this displays stats such as your current frames per second, how many
		 * update/draws calls are being made per frame (and how long each takes). By default, you can open this using the
		 * forward slash key '/'.
		 */
		public static var debugger:AxDebugger;
		/**
		 * Determines whether the debugger is enabled. By default, when running in debug mode, this is true. Otherwise, in release
		 * mode, this is false. You can set it to always be enabled by setting this to true.
		 */
		public static var debuggerEnabled:Boolean;
		
		/**
		 * The initial state that the game will begin in.
		 * */
		protected static var requestedState:Class;
		/**
		 * The initial width the game will start with, 0 meaning stage width.
		 * 
		 * @default 0
		 */
		protected static var requestedWidth:uint;
		/**
		 * The initial height the game will start with, 0 meaning stage height.
		 * 
		 * @default 0
		 */
		protected static var requestedHeight:uint;
		
		/**
		 * The width of the visible area on the screen, affected by zoom. If your width is 400, and zoom is 2x, this will be 200.
		 */
		public static var viewWidth:uint;
		/**
		 * The height of the visible area on the screen, affected by zoom. If your height is 400, and zoom is 2x, this will be 200.
		 */
		public static var viewHeight:uint;
		
		/**
		 * The state that the game pushes when paused (eg. when the game loses focus). If null, will not push any state. If you change
		 * this, you should <strong>always</strong> set it to a class that extends org.axgl.util.AxPauseState.
		 */
		public static var pauseState:Class;
		/**
		 * Boolean indicating whether all library initialization has completed.
		 */
		public static var initialized:Boolean;
		/**
		 * Boolean indicating whether the game is currently paused.
		 */
		public static var paused:Boolean;
		/**
		 * The current shader currently being used for drawing.
		 */
		public static var shader:AxShader;
		/**
		 * A logger that sends messages both to the flash console and to the browser console when embedded in a webpage.
		 */
		public static var logger:AxLogger;
		/**
		 * A reference to the main game engine. You should rarely need access to this.
		 */
		public static var engine:Ax;
		/**
		 * Whether or not to enable subpixel zoom. Setting this to true allows you to zoom at non-integer levels, and will
		 * draw entities between pixels. For example, when set to false, if your zoom level is 4 and your sprite moves
		 * to the right, it will move in 4 pixel increments. With subpixelZoom, it will move in 1 pixel increments. You
		 * must be careful when setting this to true. If you have a tileset or sprite sheet with no space between the frames,
		 * the texture will bleed and you may see artifacts at the edges of sprites. To fix that, each frame in a sprite sheet
		 * should have a 1px border that is the same pixel as the one next to it. When dealing with sprites, you can also use
		 * a 1px transparent border around each frame.
		 * TODO: Implement option to automatically alter spritesheets to add the border.
		 */
		public static var subpixelZoom:Boolean;
		/**
		 * Whether or not to assume textures have premultiplied alpha, and to unpremultiply it in the shader.
		 */
		public static var premultipliedAlpha:Boolean = false;
		/**
		 * A class that is updated after the state stack is updated. Allows you to have logic that runs an update function
		 * every frame after the state stack is updated, regardless of what is on the stack stack.
		 */
		public static var postUpdater:AxUpdatable;
		/**
		 * A class that is drawn after the state stack is draw. Allows you to have logic that runs a draw function
		 * every frame after the state stack is updated, regardless of what is on the stack stack.
		 */
		public static var postDrawer:AxDrawable;

		/**
		 * Creates the game engine.
		 */
		public function Ax(initialState:Class = null, width:uint = 0, height:uint = 0, zoom:uint = 1, framerate:uint = 60, fixedTimestep:Boolean = false, premultipliedAlpha:Boolean = true) {
			if (zoom < 1) {
				throw new Error("Zoom level must be an integer greater than 0");
			}
			if (framerate > 60) {
				throw new Error("Flash does not support framerates above 60");
			}
			
			Ax.engine = this;
			Ax.premultipliedAlpha = premultipliedAlpha;
			
			Ax.requestedState = initialState;
			Ax.requestedWidth = width;
			Ax.requestedHeight = height;
			Ax.requestedFramerate = framerate;
			Ax.fixedTimestep = fixedTimestep;
			
			Ax.states = new AxStateStack;
			Ax.worldZoom = zoom;
			Ax.unfocusedFramerate = 20;
			Ax.background = new AxColor(0.5, 0.5, 0.5);

			Ax.sound = new AxAudioManager;
			Ax.music = new AxAudioManager;

			var debugStacktrace:String = new Error().getStackTrace();
			Ax.debug = debugStacktrace != null && debugStacktrace.search(/:[0-9]+]$/m) > -1;
			Ax.debuggerEnabled = Ax.debug;
			
			Ax.pauseState = AxPauseState;
			Ax.initialized = false;
			Ax.paused = false;
			Ax.logger = new AxLogger;
			Ax.subpixelZoom = true;

			addEventListener(Event.ADDED_TO_STAGE, onStageInitialized);
		}

		/**
		 * Callback once the game stage has been initialized. Sets up the stage and system on completion.
		 *
		 * @param event The ADDED_TO_STAGE event.
		 */
		protected function onStageInitialized(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, onStageInitialized);
			stageSetup();
			systemSetup();
		}

		/**
		 * Sets up the stage properties. Also attempts to create the context for the stage3D object.
		 *
		 * @throws Error If stage3D is not available.
		 * @throws Error If there is an error creating a stage3D object.
		 */
		protected function stageSetup():void {
			stage2D = stage;
			stage2D.scaleMode = StageScaleMode.NO_SCALE;
			stage2D.align = StageAlign.TOP_LEFT;

			if (!ApplicationDomain.currentDomain.hasDefinition("flash.display.Stage3D")) {
				throw new Error("Stage3D is not available!");
			}

			var stage3D:Stage3D = stage2D.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, onStageCreate);
			stage3D.addEventListener(ErrorEvent.ERROR, function(e:Event):void {
				throw new Error("Error encountered while setting up Stage3D: " + e);
			});
			stage3D.requestContext3D();
		}

		/**
		 * Sets up listeners and global objects used by the game engine.
		 */
		protected function systemSetup():void {
			// Create keyboard and bind key events
			keys = new AxKeyboard;
			stage2D.addEventListener(KeyboardEvent.KEY_DOWN, keys.onKeyDown);
			stage2D.addEventListener(KeyboardEvent.KEY_UP, keys.onKeyUp);

			// Create mouse and bind mouse events
			mouse = new AxMouse;
			stage2D.addEventListener(MouseEvent.MOUSE_DOWN, mouse.onMouseDown);
			stage2D.addEventListener(MouseEvent.MOUSE_UP, mouse.onMouseUp);
			
			// Bind touch evenets
			stage2D.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			stage2D.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			stage2D.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);

			// Bind focus and unfocus events
			stage2D.addEventListener(Event.DEACTIVATE, onFocusLost);
			stage2D.addEventListener(Event.ACTIVATE, onFocusGained);
		}

		/**
		 * Callback when a touch event begins.
		 *
		 * @param event The touch event.
		 */
		protected function onTouchBegin(event:TouchEvent):void {
			trace("TOUCH BEGIN");
			// TODO: Implement actual touch controls
			// For now, touching controls mouse x/y
			mouse.update(event.stageX, event.stageY);
		}

		/**
		 * Callback when a touch event moves.
		 *
		 * @param event The touch event.
		 */
		protected function onTouchMove(event:TouchEvent):void {
			trace("TOUCH MOVE");
			// TODO: Implement actual touch controls
			// For now, touching controls mouse x/y
			mouse.update(event.stageX, event.stageY);
		}

		/**
		 * Callback when a touch event ends.
		 *
		 * @param event The touch event.
		 */
		protected function onTouchEnd(event:TouchEvent):void {
			trace("TOUCH END");
			// TODO: Implement actual touch controls
			// For now, touching controls mouse x/y
			mouse.update(event.stageX, event.stageY);
		}

		/**
		 * Callback when the game loses focus.
		 *
		 * @param event The focus event.
		 */
		protected function onFocusLost(event:Event):void {
			keys.releaseAll();
			mouse.releaseAll();
			stage2D.frameRate = unfocusedFramerate;
			if (initialized && pauseState != null && !paused) {
				paused = true;
				states.push(new pauseState);
			}
		}

		/**
		 * Callback when the game gains focus.
		 *
		 * @param event The focus event.
		 */
		protected function onFocusGained(event:Event):void {
			stage2D.frameRate = requestedFramerate;
			if (initialized && pauseState != null && paused && states.current is AxPauseState) {
				paused = false;
				states.pop();
			}
		}

		/**
		 * Callback when the 3D context is created. Sets up the Stage3D object, configures the
		 * backbuffer, creates the main frame listener, and pushes the initial state on the stack.
		 *
		 * @param event
		 */
		protected function onStageCreate(event:Event):void {
			removeEventListener(Event.CONTEXT3D_CREATE, onStageCreate);

			stage3D = event.target as Stage3D;
			context = stage3D.context3D;

			if (context == null) {
				return;
			}

			if (context.driverInfo == Context3DRenderMode.SOFTWARE || context.driverInfo.indexOf('oftware') > -1) {
				renderMode = "Software Mode";
			} else {
				renderMode = "Hardware Mode";
			}

			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			
			// Initialize the game based on requested parameters
			initialize();
		}
		
		/**
		 * This function is called once the engine is completely set up.  Any initialization (such as initializing a dialog
		 * system), should also occur in this function. This ensures that the stage is set up before any graphics are uploaded
		 * to the GPU. 
		 */
		public function create():void {
			// override as needed
		}
		
		/**
		 * Initializes your game and begins execution of initialState. If you leave width and height as 0, it will initialize
		 * the width and height to be the stage width and height (usually the size of your embedded SWF). Zoom is the initial
		 * zoom level, and can be dynamically adjusted at any time via Ax.zoom to zoom in and out. Framerate is the framerate
		 * you'd like the game to run at. Flash currently caps this at 60.
		 * 
		 * TODO: zoom is not currently fully supported
		 *
		 * @param initialState The initial state that your game should start in, subclass of AxState.
		 * @param width The width of your game window (0 to use stage width)
		 * @param height The height of your game window (0 to use stage height)
		 * @param zoom The initial zoom level of your game.
		 * @param framerate The framerate your game should run at.
		 */
		protected function initialize():void {
			stage.frameRate = requestedFramerate;
			
			Ax.width = requestedWidth == 0 ? stage2D.stageWidth : requestedWidth;
			Ax.height = requestedHeight == 0 ? stage2D.stageHeight : requestedHeight;
			
			context.configureBackBuffer(Ax.width, Ax.height, 16, false);
			context.enableErrorChecking = true;
			
			AxCache.reset();
			AxResource.initialize();
			camera = new AxCamera;
			camera.initialize();
			debugger = new AxDebugger;
			logger.log(LIBRARY_NAME + " " + LIBRARY_VERSION + " successfully loaded");
			logger.console = true;
			
			// Handle game initialization
			create();
			
			states.push(new requestedState());
			initialized = true;
		}

		/**
		 * The current rendering mode ("Software Mode" or "Hardware Mode").
		 *
		 * @return The rendering mode.
		 *
		 * @see #renderMode
		 */
		public static function get mode():String {
			return renderMode;
		}

		/**
		 * The main game loop callback that is executed once per frame. Handles updating the
		 * game logic.
		 *
		 * @param event The enter frame event.
		 */
		protected function onEnterFrame(event:Event):void {
			debugger.markFrameStart();
			updateTimer();
			
			var timer:uint = getTimer();
			update();
			debugger.setUpdateTime(getTimer() - timer);
			
			timer = getTimer();
			draw();	
			debugger.setDrawTime(getTimer() - timer);
			
			states.disposeDestroyedStates();
			
			heartbeatTimer -= dt;
			if (heartbeatTimer <= 0) {
				heartbeatTimer = 1;
				heartbeat();
			}
			
			debugger.markFrameEnd();
			
			if ((keys.pressed(AxKey.GRAVE) || keys.pressed(AxKey.BACKSLASH)) && debuggerEnabled) {
				debugger.active = !debugger.active;
				debugger.heartbeat();
			}
		}
		
		/**
		 * Internal heartbeat function executed about once a second.
		 */
		protected function heartbeat():void {
			debugger.heartbeat();
		}

		/**
		 * Updates the timer and framerate.
		 */
		protected function updateTimer():void {
			frames++;
			then = now;
			now = getTimer();
			
			dt = then == 0 ? 0 : (now - then) / 1000;
			if (fixedTimestep) {
				dt = 1 / requestedFramerate;
			}

			var duration:uint = now - frameStart;
			if (duration >= 1000) {
				fps = Math.round(frames / duration * 1000);
				frames = 0;
				frameStart = now;
			}
		}

		/**
		 * Updates the active states, camera, mouse, and sounds.
		 */
		public function update():void {
			if (debugger.active) {
				debugger.update();
			}
			
			states.update();
			if (postUpdater != null) {
				postUpdater.update();
			}
			camera.update();
			mouse.update(mouseX, mouseY);
			sound.update();
			music.update();
		}

		/**
		 * Draws the active states.
		 */
		public function draw():void {
			context.clear(background.red, background.green, background.blue);
			context.setCulling(Context3DTriangleFace.NONE);
			context.setDepthTest(false, Context3DCompareMode.ALWAYS);

			states.draw();
			if (postDrawer != null) {
				postDrawer.draw();
			}
			camera.draw();
			
			if (debugger.active) {
				debugger.draw();
			}
			
			context.present();
		}

		/**
		 * Sets the zoom level. This value must be greater than zero, and must be and integer. Passing a
		 * non-integer will cause it to set the zoom level to next largest integer.
		 *
		 * @param worldZoom The new zoom level.
		 */
		public static function set zoom(worldZoom:Number):void {
			if (worldZoom <= 0) {
				throw new Error("Zoom level must be greater than 0");
			}
			Ax.worldZoom = Ax.subpixelZoom ? worldZoom : Math.ceil(worldZoom);
			camera.calculateZoomMatrix();
		}

		/**
		 * Gets the current zoom level.
		 *
		 * @return The zoom level.
		 */
		public static function get zoom():Number {
			return Ax.worldZoom;
		}
		
		
		/**
		 * Overlaps all objects in source against all objects in target. Returns true if any of them overlap.
		 * If you pass a callback function, calls that function passing the two overlapping objects every
		 * time an overlap is found. The function definition should look as follows:
		 *
		 * <listing version="3.0">
		 * function overlapCallback(source:AxEntity, target:AxEntity):void {
		 * 		trace(source, "collided against", target);
		 * }
		 * </listing>
		 *
		 * For performance reasons, you should group as many things together because overlapping and colliding
		 * are computationally expensive.
		 *
		 * @param source The source entity (eg. AxSprite, AxTilemap, AxGroup).
		 * @param target The target entity (eg. AxSprite, AxTilemap, AxGroup).
		 * @param callback The callback function to call on overlapping entities.
		 *
		 * @return Whether or not any pair of entities overlapped.
		 */
		public static function overlap(source:AxEntity, target:AxEntity, callback:Function = null, collision:AxCollider = null):Boolean {
			return overlapOrCollide(source, target, callback, collision, false);
		}
		
		/**
		 * Collides all objects in source against all objects in target. Returns true if any of them overlap.
		 * If you pass a callback function, calls that function passing the two overlapping objects every
		 * time an overlap is found. In addition, if any two solid objects collide, this will separate them,
		 * so that solid objects are not within other solid objects. Use this to make your entities collide
		 * against walls/floors/etc.
		 *
		 * The callback function definition should look as follows:
		 *
		 * <listing version="3.0">
		 * function overlapCallback(source:AxEntity, target:AxEntity):void {
		 * 		trace(source, "collided against", target);
		 * }
		 * </listing>
		 *
		 * For performance reasons, you should group as many things together because overlapping and colliding
		 * are computationally expensive.
		 *
		 * @param source The source entity (eg. AxSprite, AxTilemap, AxGroup).
		 * @param target The target entity (eg. AxSprite, AxTilemap, AxGroup).
		 * @param callback The callback function to call on overlapping entities.
		 *
		 * @return Whether or not any pair of entities overlapped.
		 */
		public static function collide(source:AxEntity, target:AxEntity, callback:Function = null, collision:AxCollider = null):Boolean {
			return overlapOrCollide(source, target, callback, collision, true);
		}
		
		protected static function overlapOrCollide(source:AxEntity, target:AxEntity, callback:Function, collision:AxCollider, collide:Boolean):Boolean {
			if (collision == null) {
				if (source is AxTilemap || target is AxTilemap) {
					collision = new AxGroupCollider;
				} else {
					collision = new AxGridCollider(Ax.viewWidth, Ax.viewHeight) 
				}
			} else {
				collision.reset();
			}
			
			collision.setCallback(callback);
			collision.build(source, target);
			return collide ? collision.collide() : collision.overlap();
		}
	}
}
