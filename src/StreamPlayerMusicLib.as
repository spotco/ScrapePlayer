package  {
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.net.URLRequest;
	
	public class StreamPlayerMusicLib extends EventDispatcher {
		
		private var sc:SoundChannel;
		
		private var songs:Array = new Array();
		
		public function add_song(url:String, filename:String) {
			songs.push(new FileData(url, filename));
		}
		
		public function get_num_songs():int {
			return songs.length;
		}
		
		public function play_random():String {
			if (sc) {
				sc.stop();
			}
			var tar:FileData = songs[Math.floor(Math.random()*songs.length)];
			stream(tar.url,tar.filename);
			return tar.filename;
		}
		
		private function stream(url:String, filename:String) {
			var req:URLRequest = new URLRequest(url);
			var con:SoundLoaderContext = new SoundLoaderContext(2000, false);
			var sound:Sound = new Sound();
			
			sound.load(req, con);
			sound.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent) { 
				dispatchEvent(new SPEvt(SPEvt.SONG_STREAMING, { progress: Math.floor((Number(e.bytesLoaded) / Number(e.bytesTotal))*100), filename:filename } ));
			});
			sc = sound.play();
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