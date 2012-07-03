package  {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	public class StreamPlayerMusicLib extends EventDispatcher {
		
		private var sc:SoundChannel;
		private var current_song:Sound;
		private var pause_point:Number = 0.00;
		private var current_song_filename:String = "";
		private var vol:Number = 1.0;
		public var is_playing:Boolean = false;
		
		private var songs:Array = new Array();
		private var sound_pos_disp_updater:Timer;
		
		public function StreamPlayerMusicLib() {
			this.sound_pos_disp_updater = new Timer(500);
			this.sound_pos_disp_updater.addEventListener(TimerEvent.TIMER, function(e) {
				if (is_playing && sc && current_song) {
					dispatchEvent(new SPEvt(SPEvt.SONG_POS_UPDATE, { cur:CLib.getdisplaytime(sc.position), max:CLib.getdisplaytime(current_song.length), filename:current_song_filename } ));
				}
			});
			this.sound_pos_disp_updater.start();
		}
		
		public function add_song(url:String, filename:String) {
			songs.push(new FileData(url, filename));
			
		}
		
		public function get_num_songs():int {
			return songs.length;
		}
		
		public function pause() {
			if (sc && current_song) {
				this.pause_point = sc.position;
				this.sc.stop();
				this.is_playing = false;
			}
		}
		
		public function play() {
			if (this.current_song && !this.is_playing) {
				if (this.pause_point == 0.00) {
					sc = current_song.play();
					sc.soundTransform = new SoundTransform(vol);
				} else {
					sc = current_song.play(pause_point);
					sc.soundTransform = new SoundTransform(vol);
					pause_point = 0.00;
				}
				
				this.is_playing = true;
				
				if (!sc.hasEventListener(Event.SOUND_COMPLETE)) {
					sc.addEventListener(Event.SOUND_COMPLETE, function(e) { play_random() } );
				}	
			} else if (!this.is_playing && current_song == null) {
				play_random();
			}
		}
		
		public function list_all() {
			var lister:Timer = new Timer(1);
			var i:int = 0;
			lister.addEventListener(TimerEvent.TIMER, function(e) {
				if (i < songs.length) {
					dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:songs[i].filename } ));
				} else {
					dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:songs.length + " songs total." } ));
					lister.stop();
				}
				i++;
			});
			lister.start();
		}
		
		public function remove(tar:String) {
			if (tar == "*") {
				songs = new Array;
				dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:"Removed all." } ));
				return;
			}
			tar = tar.toLowerCase();
			songs = songs.filter(function(t) {
				if (t.filename.toLowerCase().indexOf(tar) >= 0) {
					dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:"Removed:"+t.filename } ));
					return false;
				} else {
					return true;
				}
			});
		}
		
		public function play_specific(tar:String) {
			tar = tar.toLowerCase();
			var found:FileData = null;
			for each(var i:FileData in this.songs) {
				if (i.filename.toLowerCase().indexOf(tar) >= 0) {
					found = i;
					break;
				}
			}
			
			if (found) {
				if (sc) {
					sc.stop();
				}
				if (current_song && current_song.isBuffering) {
					current_song.close();
				}
				this.pause_point = 0.0;
				this.is_playing = false;
				stream(found.url, found.filename);
			} else {
				dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:"Song not found." } ));
				return;
			}
			
		}
		
		public function volume(vol:Number) {
			if (this.sc) {
				this.vol = vol;
				this.sc.soundTransform = new SoundTransform(vol);
			}
		}
		
		public function play_random() {
			if (this.get_num_songs() == 0) {
				dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:"No songs loaded." } ));
				return;
			}
			if (sc) {
				sc.stop();
			}
			if (current_song && current_song.isBuffering) {
				try {
					current_song.close();
				} catch (e:Error) {
					dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:"Error on stream close:"+e.message } ));
				}
			}
			
			this.is_playing = false;
			this.pause_point = 0.0;
			var tar:FileData = songs[Math.floor(Math.random()*songs.length)];
			stream(tar.url,tar.filename);
		}
		
		private function stream(url:String, filename:String) {
			var req:URLRequest = new URLRequest(url);
			var con:SoundLoaderContext = new SoundLoaderContext(2000, false);
			this.current_song = new Sound();
			this.current_song.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) {
				dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:"Stream error:"+e.text } ));
			});
			
			this.current_song.load(req, con);
			var self = this.current_song;
			this.current_song.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent) {
				if (self == current_song) {
					dispatchEvent(new SPEvt(SPEvt.SONG_STREAMING, { progress: Math.floor((Number(e.bytesLoaded) / Number(e.bytesTotal))*100), filename:filename } ));
				}
			});
			this.current_song_filename = filename;
			play();
		}
		

		
	}

}

internal class FileData {
	public var url:String;
	public var filename:String;
	public function FileData(url:String, filename:String) {
		this.url = url;
		this.filename = filename;
	}
}