package io.axel.sound {
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import io.axel.Ax;

	/**
	 * A sound object. For simple use cases, this class will be completely managed by Axel. However,
	 * whenever you play a sound or music you will get the instance of this class returned to you in
	 * order to do more advanced effects.
	 */
	public class AxSound {
		/** The internal flash sound object. */
		public var sound:Sound;
		/** The internal flash sound channel. */
		public var soundChannel:SoundChannel;
		/** The internal flash sound transform. */
		public var soundTransform:SoundTransform;

		/**
		 * The sound manager this sound belongs to.
		 */
		public var manager:AxAudioManager;
		/**
		 * The requested volume of the sound, between 0 and 1. The current volume can be accessed through the
		 * volume property, which will be 0 if the sound is muted. This will always contained the requested
		 * volume, even when muted.
		 * @default 1
		 */
		public var requestedVolume:Number;
		/**
		 * The number of times this sound should loop. 0 means no looping.
		 */
		public var loops:uint;
		/**
		 * The time (in ms) of how far into the sound it should start playing. If looped, it will loop to this
		 * point in the song.
		 * @default 0
		 */
		public var start:Number;
		/**
		 * The panning of the sound between -1 (left) and 1 (right). 0 means balanced in the middle.
		 */
		public var panning:Number;
		public var deltaVolume:Number;

		/**
		 * Creates a new sound object, but does not start playing the sound.
		 *
		 * @param sound The embedded sound file to play.
		 * @param volume The volume to play the sound at.
		 * @param loop Whether or not the sound should loop.
		 * @param start The time (in ms) of how far into the sound it should start playing.
		 * @param panning The panning of the sound between -1 (left) and 1 (right). 0 means balanced in the middle.
		 */
		public function AxSound(manager:AxAudioManager, sound:Class, volumeLevel:Number = 1, loops:uint = 0, start:Number = 0, panning:Number = 0) {
			this.manager = manager;
			this.sound = new sound();
			this.requestedVolume = volumeLevel;
			this.loops = loops;
			this.start = start;
			this.panning = panning;
			this.soundTransform = new SoundTransform(volumeLevel, panning);
		}

		/**
		 * Plays the sound. If loop is true, will repeat once it reaches the end. This method does nothing if
		 * you have no sound card or you run out of available sound channels. The maximum amount of sounds you
		 * can play at once is 32.
		 *
		 * @return
		 */
		public function play():void {
			soundChannel = sound.play(start, loops, soundTransform);
			if (soundChannel == null) {
				destroy();
				return;
			}
			soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		}
		
		public function set volume(volumeLevel:Number):void {
			soundTransform.volume = volumeLevel;
			if (soundChannel != null) {
				soundChannel.soundTransform = soundTransform;
			}
		}
		
		public function get volume():Number {
			return soundTransform.volume;
		}
		
		public function mute():AxSound {
			volume = 0;
			return this;
		}
		
		public function unmute():AxSound {
			volume = requestedVolume;
			return this;
		}
		
		public function fadeOut(duration:Number, targetVolume:Number = 0):AxSound {
			deltaVolume = -(volume - targetVolume) / duration * Ax.dt;
			return this;
		}
		
		public function fadeIn(duration:Number, targetVolume = NaN):AxSound {
			deltaVolume = (targetVolume || requestedVolume) / duration * Ax.dt;
			return this;
		}
		
		public function update():void {
			if (deltaVolume > 0) {
				volume += deltaVolume;
				if (volume > requestedVolume) {
					volume = requestedVolume;
					deltaVolume = 0;
				}
			} else if (deltaVolume < 0) {
				volume += deltaVolume;
				if (volume < 0) {
					volume = 0;
					deltaVolume = 0;
				}
			}
		}
		
		/**
		 * Sound completion callback.
		 * 
		 * @param event The sound completion event.
		 */
		private function onSoundComplete(event:Event):void {
			destroy();
		}
		
		/**
		 * Destroys the sound, freeing up resources used.
		 */
		public function destroy():void {
			if (soundChannel != null) {
				soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
				soundChannel.stop();
				soundChannel = null;
			}
			sound = null;
			soundTransform = null;
			manager.remove(this);
		}
	}
}
