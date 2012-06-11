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
			 * -Play songs continuously
			 * -Add same server policy
			 * -Play,pause,volume UI
			 * -List all songs
			 * -Delete songs
			 * -Better crawling defaults
			 * -Search songs
			 * -Redesign UI
		 */
		
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