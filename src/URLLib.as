package  {
	import com.adobe.net.URI;
	public class URLLib {
		
		public static function html_get_tags(html:String):Array {
			return html.match(/<[^<]+?>/g);
		}
		
		public static function tags_get_hrefs(tags:Array):Array {
			tags = tags.filter(
				function(t, ind, arr) { 
					return t.match(/href=\".*\"/) != null; 
				} 
			);
						
			tags = tags.map(
				function(t) {
					var href = t.match(/href=\"[^\"]*\"/).pop();
					return href.slice(href.indexOf("\"") + 1, href.lastIndexOf("\""));
				} 
			);
			return tags;
		}
		
		public static function hrefs_make_absolute(hrefs:Array, base_url:String):Array {
			return hrefs.map(
				function(t:String, ind:int, a:Array) {
					var base:URI = new URI(base_url);
					base.chdir(t);
					return base.toString();
				}
			);
		}
		
		
		public static function filter_unique_and_valid(a:Array):Array {
			var unq:Object = { };
			a = a.filter(
				function(t:String, ind:int, arr:Array) {
					var is_unq:Boolean = (unq[t] == null);
					unq[t] = true;
					return is_unq && t.match(/(javascript:|mailto:)/) == null;
				}
			);
			return a;
		}
		
	}

}