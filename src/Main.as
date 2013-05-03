package {
	import com.adobe.net.URI;
	import com.PriorityQueue;
	import flash.display.*;
	import flash.events.Event;
 
	[SWF(backgroundColor = "#FFFFFF", frameRate = "60", width = "1000", height = "500")]
	
	public class Main extends Sprite {
		
		/**
		 * WELP IT WORKS
		 * TODO:
			 * -man function
			 * -string array filter
		 */
		
		public static var PROXY_URL:String = "http://spotcos.com/misc/scrapeplayer/proxy.php";
		public static var FAVLIST_URL:String = "http://spotcos.com/misc/scrapeplayer/fav.txt";
		public static var MOBILE_UI:Boolean = false;
		public static var LOCAL:Boolean = true;
		
		public function Main():void {
			LOCAL = loaderInfo.url.indexOf("file:") == 0;
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.stage.addChild(new StreamPlayer(1000, 500));
		}
		
	}
	
}