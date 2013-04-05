package  {
	import com.adobe.net.URI;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class StreamPlayer extends Sprite {
		
		public static var WID:int;
		public static var HEI:int;
		public static var WELCOME_MESSAGE:String = "" +
		"(let a 5";
		
		private var view:StreamPlayerControls;
		private var crawler:StreamPlayerCrawler;
		private var songlib:StreamPlayerMusicLib;
		
		private var cur_time:String = "";
		private var max_time:String = "";
		private var cur_progress:String = "";
		private var cur_name:String = "";
		
		public function StreamPlayer(WID:int, HEI:int) {
			StreamPlayer.WID = WID;
			StreamPlayer.HEI = HEI;
			
			this.songlib = new StreamPlayerMusicLib();
			
			this.view = new StreamPlayerControls(this);
			
			this.crawler = new StreamPlayerCrawler;
			this.crawler.addEventListener(SPEvt.PRINT_EVT, function(e:SPEvt) { view.msg_to_screen(e.info.msg); });
			this.crawler.addEventListener(SPEvt.MSG_TO_TMP, function(e:SPEvt) { view.msg_to_tmp(e.info.msg); });
			this.crawler.addEventListener(SPEvt.SONG_FOUND, function(e:SPEvt) { songlib.add_song(e.info.url, e.info.filename,e.info.path); });
			
			this.songlib.addEventListener(SPEvt.SONG_STREAMING, function(e:SPEvt) { 
				cur_progress = String(e.info.progress);
				cur_name = e.info.filename;
				view.msg_to_tmp("LOADED: "+cur_progress+"%   "+cur_time+" / "+max_time+"   PLAYING: "+cur_name);
			});
			this.songlib.addEventListener(SPEvt.SONG_POS_UPDATE, function(e:SPEvt) {
				cur_time = e.info.cur;
				max_time = e.info.max;
				cur_name = e.info.filename;
				view.msg_to_tmp("LOADED: "+cur_progress+"%   "+cur_time+" / "+max_time+"   PLAYING: "+cur_name);
			});
			this.songlib.addEventListener(SPEvt.PRINT_EVT, function(e:SPEvt) { view.msg_to_screen(e.info.msg); } );
			
			this.view.addEventListener(SPEvt.LOAD_SITE_EVT, load_site_evth);
			this.view.addEventListener(SPEvt.STOP_CRAWLER, function(e){ crawler.stop() });
			this.view.addEventListener(SPEvt.PLAY_RANDOM_SONG, function(e) { songlib.play_random() });
			this.view.addEventListener(SPEvt.PAUSE, function(e:SPEvt) { songlib.pause(); } );
			this.view.addEventListener(SPEvt.PLAY, function(e:SPEvt) { songlib.play(); } );
			this.view.addEventListener(SPEvt.VOLUME, function(e:SPEvt) { songlib.volume(e.info.volume); } );
			this.view.addEventListener(SPEvt.PLAY_SPECIFIC, function(e:SPEvt) { songlib.play_specific(e.info.tar); } );
			this.view.addEventListener(SPEvt.LIST, function(e:SPEvt) { songlib.list(e.info.tar) } );
			this.view.addEventListener(SPEvt.REMOVE, function(e:SPEvt) { songlib.remove(e.info.tar); } );
			this.view.addEventListener(SPEvt.LIST_FAV, function(e:SPEvt) { print_list_fav(); } );
			this.view.addEventListener(SPEvt.LISTSPEED, function(e:SPEvt) {
				var tar:int = int(e.info.listspeed);
				if (tar && tar > 0) {
					songlib.set_listspeed(tar);
					crawler.set_listspeed(tar);
					view.msg_to_screen("LISTSPEED set to "+tar+".");
				} else {
					view.msg_to_screen("Invalid LISTSPEED.");
				}
			});
			
			this.view.addEventListener(SPEvt.TEST, function(e:SPEvt) { 
				if (e.info.val == 1) songlib.ftop_push(e.info.msg);
				else if (e.info.val == 2) songlib.ftop_pop();
				else if (e.info.val == 3) songlib.ftop_list_folders();
				else if (e.info.val == 4) songlib.ftop_list_files();
			});
			
			view.msg_to_screen(WELCOME_MESSAGE);
			this.addEventListener(Event.ADDED_TO_STAGE, function() { stage.focus = view.get_input_focus_object(); } );
			
			Lang.set_out(msg_out);
		}
		
		public function msg_out(msg:String) {
			view.msg_to_screen(msg);
		}
		
		private function print_list_fav() {
			var l:URLLoader = new URLLoader();
			l.addEventListener(Event.COMPLETE, function(e:Event) {
				view.clear_screen();
				view.msg_to_screen(e.target.data);
			});
			l.load(new URLRequest(Main.FAVLIST_URL));
		}
		
		private function load_site_evth(e:SPEvt) {
			var url:String = e.info.url;
			var depth:Number = e.info.depth;
			var verbose:Boolean = e.info.opts.indexOf("v") != -1;
			var cross_site:Boolean = e.info.opts.indexOf("x") != -1;
			var proxy:Boolean = e.info.opts.indexOf("p") != -1;
			
			crawler.start_crawl(url, depth, {verbose:verbose, cross_site:cross_site, proxy:proxy});
		}
		
	}
}