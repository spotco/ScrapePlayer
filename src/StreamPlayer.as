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
		"Welcome to ScrapePlayer.";
		
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
			this.crawler.addEventListener(SPEvt.SONG_FOUND, function(e:SPEvt) {
				//trace("["+e.info.path+"]");
				songlib.add_song(e.info.url, e.info.filename, e.info.path);
				Lang.add_to_loaded(e.info.filename);
			});
			
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
			
			
			Lang._f_load = function(a:Array) {
				var url:String = "";
				var depth:Number = 5;
				var opts:Array = [];
				
				if (a.length >= 2 && (a[1].type == Token.TYPE_STR || a[1].type == Token.TYPE_VAR) ) {
					url = a[1].val;
				}
				
				if (a.length >= 3 && a[2].type == Token.TYPE_NUM ) {
					depth = a[2].val;
				}
				load_site_evth(url, depth, opts);
			}
			
			Lang._f_play = function(source:String, method:String, target:String) {
				//TODO -- work!
				songlib.play();
			}
			
			Lang._f_plist_add = function(match:String) {
				return songlib.ftop_add_to_playlist(match);
			}
			
			Lang._f_pause = function() {
				songlib.pause();
			}
			Lang._f_stopload = function() {
				crawler.stop();
			}
			Lang._f_volume = function(a:Array) {
				var volume:Number = 1;
				if (a.length >= 2 && a[1].type == Token.TYPE_NUM) {
					volume = a[1].val;
				}
				songlib.volume(volume);
			}
			
			Lang._f_speed = function(a:Array) {
				var tar:int = int(a[1].val);
				if (tar && tar > 0) {
					songlib.set_listspeed(tar);
					crawler.set_listspeed(tar);
					view.msg_to_screen("LISTSPEED set to "+tar+".");
				} else {
					view.msg_to_screen("Invalid LISTSPEED.");
				}
			}
			
			Lang._f_top_list_folders = function(a:Array) {
				return songlib.ftop_list_folders();
			};
			
			Lang._f_top_list_files = function(param:String, target:String) {
				if (param == "c") {
					return songlib.ftop_list_files();
					
				} else if (param == "a") {
					return songlib.fall_list_matching_files("");
					
				} else if (param == "f") {
					return songlib.fall_list_matching_files(target);
					
				}
				
			}
			
			Lang._f_top_push = function(a:Array) {
				var suc:Boolean = songlib.ftop_push(a[1].val);
				return suc?1:0;
			}
			
			Lang._f_top_pop = function(a:Array) {
				var suc:Boolean = songlib.ftop_pop();
				return suc?1:0;
			}
			
			Lang._f_top_dir = function(a:Array) {
				return songlib.ftop_dir();
			}
			
			view.msg_to_screen(WELCOME_MESSAGE);
			this.addEventListener(Event.ADDED_TO_STAGE, function() { stage.focus = view.get_input_focus_object(); } );
		}
		
		private function load_site_evth(url:String,depth:Number,opts:Array) {
			var verbose:Boolean = opts.indexOf("v") != -1;
			var cross_site:Boolean = opts.indexOf("x") != -1;
			var proxy:Boolean = opts.indexOf("p") != -1;
			
			crawler.start_crawl(url, depth, {verbose:verbose, cross_site:cross_site, proxy:proxy});
		}
		
	}
}