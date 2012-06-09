package  {
	import flash.events.Event;

	public class SPEvt extends Event {
		
		public var info:Object;
		
		public function SPEvt(type:String, info:Object = null) {
			super(type);
			this.info = info;
		}
		
		public static var CLEAR_SCREEN_EVT:String = "clear_screen";
		public static var PRINT_EVT:String = "print_to_screen";
		public static var LOAD_SITE_EVT:String = "load_site";
		public static var HELP_EVT:String = "halp";
		
	}

}