package {
	import com.adobe.net.URI;
	import flash.display.*;
	import flash.events.Event;
 
	[SWF(backgroundColor = "#FFFFFF", frameRate = "60", width = "500", height = "500")]
	
	public class Main extends Sprite {
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			this.stage.addChild(new StreamPlayer(500, 500));
		}
		
	}
	
}