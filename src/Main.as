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
			 * -Favorites sites list
			 * -Play songs continuously
			 * -Play,pause,volume UI
			 * -List all songs
			 * -Delete songs
			 * -Search songs
			 * -Mobile UI
		 */
		
		public static var PROXY_URL:String = "http://spotcos.com/misc/streamplayer/proxy.php";
		public static var MOBILE_UI:Boolean = false;


		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.stage.addChild(new StreamPlayer(1000, 500));
		}
		
	}
	
}