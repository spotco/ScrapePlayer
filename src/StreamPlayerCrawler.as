package  {
	import com.PriorityQueue;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.*;
	import com.adobe.net.URI;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	public class StreamPlayerCrawler extends EventDispatcher {
		
		private var KILL:Boolean = true;
		
		private var to_visit:PriorityQueue;
		private var request_sender_timer:Timer;
		private var visited_hash:Object = { };
		private var url_base:String = "";
		private var listspeed:int = 1;
		
		public function start_crawl(url:String, depth:int, opts:Object) {
			visited_hash = { };
			url_base = url;
			
			KILL = false;
			
			to_visit = new PriorityQueue();
			if (request_sender_timer != null) {
				request_sender_timer.stop();
			}
			
			request_sender_timer = new Timer(1);
			request_sender_timer.addEventListener(TimerEvent.TIMER, send_top_request);
			request_sender_timer.start();
			
			if (url.indexOf("http://") < 0 && url.indexOf("https://") < 0) {
				url = "http://" + url;
			}
			
			if (url.match(/^http:\/\/.+\/[^\/]+\.[^\/]+$/) == null && url.charAt(url.length - 1) != "/") {
				url = url + "/";
			}
			
			crawl(url, depth, opts);
		}
		
		public function set_listspeed(t:int) {
			listspeed = t;
		}
		
		public function stop() {
			KILL = true;
		}
		
		private function send_top_request(e:Event) {
			for (var i = 0; i < listspeed; i++) {
				if (KILL) {
					request_sender_timer.stop();
					request_sender_timer.reset();
					request_sender_timer.removeEventListener(TimerEvent.TIMER, send_top_request);
					msg_to_tmp("");
					msg_out("CRAWL STOPPED.");
				} else if (to_visit.size != 0) {
					var next:ToVisitNode = to_visit.dequeue() as ToVisitNode;
					crawl(next.url, next.depth, next.opts);
				}
			}
		}
		
		
		
		private function crawl(url:String, depth:int, opts:Object) {
			if (visited_hash[url] != null) {
				return;
			} else {
				visited_hash[url] = true;
			}
			
			var curi:URI = new URI(url);
			
			if (!curi.isDirectory() && !curi.isOfFileType("html") && !curi.isOfFileType("php")) {
				if (curi.isOfFileType("mp3")) {
					if (opts.verbose) {
						msg_out("MUSIC FILE: " + url);
					} else {
						msg_out("FILE: " + curi.getFilename());
					}
					dispatchEvent(new SPEvt(SPEvt.SONG_FOUND, { url:url, filename:curi.getFilename() } ));
				} else {
					msg_out("FILE: " + url, opts);
				}
				return;
			} else if (!opts.cross_site && url.indexOf(url_base) < 0) {
				msg_out("CROSS SITE: " + url, opts);
				return;
			} else {
				msg_out("VISITING: " + url, opts);
			}
			
			msg_to_tmp( "QUEUE:("+to_visit.size+") REQUEST TO: " + url);
						
			var urlRequest:URLRequest;
			
			if (opts.proxy || !Main.LOCAL) {
				var urlRequest:URLRequest = new URLRequest(Main.PROXY_URL);
				urlRequest.method = flash.net.URLRequestMethod.POST;
				var params:URLVariables = new URLVariables();
				params.url = url;
				params.nocache = new Date().toDateString;
				urlRequest.data = params;
			} else {
				urlRequest = new URLRequest(url);
			}
			
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, function(e:Event) {
				crawl_request_success(e.target.data,url,depth,opts);
			});
			configureErrors(urlLoader,opts);
			urlLoader.load(urlRequest);
		}
		
		private function crawl_request_success(html:String, base_url:String, depth:Number, opts:Object):void {
			//trace(html);
			var tags:Array = URLLib.html_get_tags(html);
			var hrefs:Array = URLLib.tags_get_hrefs(tags);
			hrefs = URLLib.filter_unique_and_valid(hrefs);
			hrefs = URLLib.hrefs_make_absolute(hrefs, base_url);
			
			hrefs.forEach(function(url) {
				if (depth > 0) {
					to_visit.enqueue(new ToVisitNode(url, depth - 1, opts));
				}
			} );
		}
		
		private function msg_out(msg:String, opts:Object = null) {
			if (opts == null) {
				opts = { verbose:true };
			}
			
			if (opts.verbose) {
				dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:msg } ));
			}
		}
		
		private function msg_to_tmp(msg:String) {
			dispatchEvent(new SPEvt(SPEvt.MSG_TO_TMP, { msg:msg } ));
		}
		
		private function configureErrors(dispatcher:IEventDispatcher, opts:Object):void {
			dispatcher.addEventListener(NetStatusEvent.NET_STATUS, function(e) { http_error_handle(e, opts); } );
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(e) { http_error_handle(e, opts); });
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR, function(e) { http_error_handle(e, opts); });
		}
		
		private function http_error_handle(e, opts):void {
			if (!KILL) {
				msg_out(e.text,opts);
			}
		}
		
	}

}