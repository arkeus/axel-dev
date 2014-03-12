package io.axel.sound {
	/**
	 * A manager used for playing and keeping track of audio.
	 */
	public class AxAudioManager {
		public var sounds:Vector.<AxSound>;
		public var muted:Boolean;
		public var volume:Number;
		
		public function AxAudioManager() {
			this.sounds = new Vector.<AxSound>;
			this.muted = false;
			this.volume = 1;
		}
		
		public function update():void {
			for (var i:uint = 0; i < sounds.length; i++) {
				sounds[i].update();
			}
		}
		
		public function mute():void {
			this.muted = true;
			for (var i:uint = 0; i < sounds.length; i++) {
				sounds[i].mute();
			}
		}
		
		public function unmute():void {
			this.muted = false;
			for (var i:uint = 0; i < sounds.length; i++) {
				sounds[i].unmute();
			}
		}
		
		public function play(soundFile:Class, volumeLevel:Number = 1, start:Number = 0, pan:Number = 0):AxSound {
			var soundObject:AxSound = create(soundFile, volumeLevel, 0, start, pan);
			soundObject.play();
			return soundObject;
		}
		
		public function repeat(soundFile:Class, volumeLevel:Number = 1, start:Number = 0, pan:Number = 0):AxSound {
			var soundObject:AxSound = create(soundFile, volumeLevel, uint.MAX_VALUE, start, pan);
			soundObject.play();
			return soundObject;
		}
		
		public function create(soundFile:Class, volumeLevel:Number = 1, loops:uint = 0, start:Number = 0, pan:Number = 0):AxSound {
			var soundObject:AxSound = new AxSound(this, soundFile, volumeLevel * volume, loops, start, pan);
			if (muted) {
				soundObject.mute();
			}
			sounds.push(soundObject);
			return soundObject;
		}
		
		public function fadeOut(duration:Number = 1):AxAudioManager {
			for (var i:uint = 0; i < sounds.length; i++) {
				sounds[i].fadeOut(duration);
			}
			return this;
		}
		
		public function fadeIn(soundFile:Class, duration:Number = 1, volumeLevel:Number = 1, loops:uint = 0, start:Number = 0, pan:Number = 0):AxSound {
			var soundObject:AxSound = create(soundFile, volumeLevel, 0, start, pan);
			soundObject.fadeIn(duration);
			soundObject.play();
			return soundObject;
		}
		
		public function remove(sound:AxSound):void {
			var index:int = sounds.indexOf(sound);
			if (index >= 0) {
				sounds.splice(index, 1);
			}
		}
	}
}
