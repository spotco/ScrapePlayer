package  {
	public class StreamPlayerMusicLib {
		
		public function StreamPlayerMusicLib() {
			
		}
		
		private function play_sound():void {
			var s:Sound = new Sound(); 
			var req:URLRequest = new URLRequest("http://ocremix.org/remix/OCR02286/");
			s.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(e:HTTPStatusEvent) { trace(e); } );
			var context:SoundLoaderContext = new SoundLoaderContext(2000, true); 
			s.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent) { trace(e.toString()); } );
			s.load(req, context); 
			s.play();
		}
		
	}

}