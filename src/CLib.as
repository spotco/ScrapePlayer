package  
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.ui.MouseCursor;
	
	public class CLib 
	{
		
		public static function add_mouse_over(o:DisplayObject) {
			o.addEventListener(MouseEvent.ROLL_OVER, function() {
				flash.ui.Mouse.cursor = flash.ui.MouseCursor.BUTTON;
			});
			o.addEventListener(MouseEvent.ROLL_OUT, function() {
				flash.ui.Mouse.cursor = flash.ui.MouseCursor.AUTO;
			});
		}
	
		public static function getdisplaytime(n:Number):String {
			var min:Number = Math.floor(n/(60*1000));
			var displaytime:String = min + ":";
			var sectotal:Number = Math.floor(n/1000);
			if (sectotal%60 < 10) {
				displaytime += "0"+(sectotal%60);
			} else {
				displaytime += (sectotal%60);
			}
			return displaytime;
		}
		
	}

}