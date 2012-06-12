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
		public static var MSG_TO_TMP:String = "msg_to_temp";
		public static var STOP_CRAWLER:String = "stop_crawler";
		public static var SONG_FOUND:String = "song_found";
		public static var PLAY_RANDOM_SONG:String = "play_random_song";
		public static var SONG_STREAMING:String = "song_streaming";
		public static var CHANGE_VOLUME:String = "change_volume";
		public static var PLAY:String = "play";
		public static var PAUSE:String = "pause"
		public static var VOLUME:String = "volume";
		public static var PLAY_SPECIFIC:String = "play_specific";
		public static var LIST:String = "list";
		public static var REMOVE:String = "remove";
		public static var LIST_FAV:String = "list_fav";
		public static var SONG_POS_UPDATE:String = "song_pos_update";
		
	}

}