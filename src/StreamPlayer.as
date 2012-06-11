package  {
	import com.adobe.net.URI;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class StreamPlayer extends Sprite {
		
		public static var WID:int;
		public static var HEI:int;
		public static var WELCOME_MESSAGE:String = "" +
		"Welcome to ScrapePlayer 0.1!\nTry loading with spotcos.com/misc\n\n" +
		"Load a directory with:\n" +
		"\tload  url  params(optional)\n\n" +
		"Stop scraping with:\n" +
		"\tstop\n\n" +
		"And play a random song with:\n" +
		"\tplay\n\n";
		
		private var view:StreamPlayerControls;
		private var crawler:StreamPlayerCrawler;
		private var songlib:StreamPlayerMusicLib;
		
		public function StreamPlayer(WID:int, HEI:int) {
			StreamPlayer.WID = WID;
			StreamPlayer.HEI = HEI;
			
			this.songlib = new StreamPlayerMusicLib();
			
			this.view = new StreamPlayerControls(this);
			this.view.addEventListener(SPEvt.LOAD_SITE_EVT, load_site_evth);
			this.view.addEventListener(SPEvt.STOP_CRAWLER, stop_crawler_evth);
			this.view.addEventListener(SPEvt.PLAY_RANDOM_SONG, play_song_evth);
			
			this.crawler = new StreamPlayerCrawler;
			this.crawler.addEventListener(SPEvt.PRINT_EVT, function(e:SPEvt) {
				view.msg_to_screen(e.info.msg);
			});
			this.crawler.addEventListener(SPEvt.MSG_TO_TMP, function(e:SPEvt) {
				view.msg_to_tmp(e.info.msg);
			});
			this.crawler.addEventListener(SPEvt.SONG_FOUND, function(e:SPEvt) {
				songlib.add_song(e.info.url, e.info.filename);
			});
			
			this.songlib.addEventListener(SPEvt.SONG_STREAMING, function(e:SPEvt) {
				view.msg_to_tmp("LOADED: "+e.info.progress+"% NOW PLAYING: "+e.info.filename);
			});
			
			view.msg_to_screen(WELCOME_MESSAGE);
			this.addEventListener(Event.ADDED_TO_STAGE, function() { stage.focus = view.get_input_focus_object(); } );
		}
		
		private function load_site_evth(e:SPEvt) {
			var url:String = e.info.url;
			var depth:Number = e.info.depth;
			var verbose:Boolean = e.info.opts.indexOf("v") != -1;
			var cross_site:Boolean = e.info.opts.indexOf("x") != -1;
			
			crawler.start_crawl(url, depth, {verbose:verbose, cross_site:cross_site});
		}
		
		private function stop_crawler_evth(e:SPEvt) {
			crawler.stop();
		}
		
		private function play_song_evth(e:SPEvt) {
			if (songlib.get_num_songs() == 0) {
				view.msg_to_screen("No loaded songs.");
			} else {
				songlib.play_random();
			}
		}
		
	}
}