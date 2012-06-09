package  {
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.events.*;
	import com.adobe.net.URI;
	
	public class StreamPlayerCrawler extends EventDispatcher {
		
		private var visited_hash:Object = { };
		private var url_base:String = "";
		
		public function clear_visited() {
			visited_hash = { };
		}
		
		public function set_url_base(url:String) {
			var t:URI = new URI(url);
			url_base = t.authority;
		}
		
		public function crawl(url:String, depth:int) {
			//if (t.charAt(t.length - 1) == "/") {
				//t = t.substr(0, t.length - 1);
			//}
			if (visited_hash[url] != null) {
				trace("already visited: " + url);
				return;
			} else {
				visited_hash[url] = true;
			}
			if (url.match(/^http:\/\/.+\/[^\/]+\.[^\/]+$/)) { //TODO add ind.php?query check
				var filetype = url.substring(url.lastIndexOf(".") + 1, url.length);
				if (filetype != "html" && filetype != "php") {
					if (filetype == "mp3") {
						dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:url } ));
					}
					return;
				}
			}
			if (url.indexOf(url_base) < 0) {
				return;
			}

			var urlRequest:URLRequest = new URLRequest(url);
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, function(e:Event) {
				http_request_success(e.target.data,url,depth);
			});
			configureErrors(urlLoader);
			urlLoader.load(urlRequest);
		}
		
		private function configureErrors(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(NetStatusEvent.NET_STATUS, http_error_handle);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, http_error_handle);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR,http_error_handle);
		}
		
		private function http_request_success(html:String, base_url:String, depth:Number):void {
			var tags:Array = html.match(/<[^<]+?>/g);
			tags = tags.filter(
				function(t, ind, arr) { 
					return t.match(/href=\".*\"/) != null; 
				} 
			);
						
			tags = tags.map(
				function(t) {
					var href = t.match(/href=\"[^\"]*\"/).pop();
					return href.slice(href.indexOf("\"")+1,href.lastIndexOf("\"")); 
				} 
			);
			
			var unq = { };
			tags = tags.filter(
				function(t, ind, arr) {
					var is_unq = unq[t] == null;
					unq[t] = true;
					return is_unq && t.match(/(javascript:|mailto:)/) == null;
				}
			);
			
			var links:Array = tags.map(
				function(t) {
					while (t.charAt(0) == "/") {
						t = t.substr(1, t.length);
					}
					if (t.indexOf("http://") >= 0 || t.indexOf("https://") >= 0) {
						return t;
					} else {
						if (base_url.charAt(base_url.length - 1) == "/") {
							return base_url + t;
						} else {
							return base_url + "/" + t;
						}
						
					}
				}
			);
			
			//trace("at: " + base_url);
			
			links.forEach(function(e) { 
				if (depth > 0) {
					crawl(e, depth - 1);
				}
				//dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:e } ));
			} );
		}
		
		private function http_error_handle(e:Event):void {
			trace("network error:" + e.toString());
		}
		
	}

}