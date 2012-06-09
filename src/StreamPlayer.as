package  {
	import flash.display.Sprite;
	
	public class StreamPlayer extends Sprite {
		
		public static var WID:int;
		public static var HEI:int;
		
		private var view:StreamPlayerControls;
		private var crawler:StreamPlayerCrawler;
		
		
		public function StreamPlayer(WID:int, HEI:int) {
			StreamPlayer.WID = WID;
			StreamPlayer.HEI = HEI;
			
			this.view = new StreamPlayerControls(this);
			this.view.addEventListener(SPEvt.LOAD_SITE_EVT, load_site_evth);
			
			this.crawler = new StreamPlayerCrawler;
			this.crawler.addEventListener(SPEvt.PRINT_EVT, function(e:SPEvt) {
				view.msg_to_screen(e.info.msg);
			});
		}
		
		private function load_site_evth(e:SPEvt) {
			var url:String = e.info.url;
			var depth:Number = e.info.depth;
			crawler.clear_visited();
			crawler.set_url_base(url);
			crawler.crawl(url, depth);
		}
		
	}

}