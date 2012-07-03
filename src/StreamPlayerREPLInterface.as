package  {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import r1.deval.D;
	public class StreamPlayerREPLInterface extends EventDispatcher {
		
		public var prototype:*;
		
		public static var HELP_TEXT = 
			"KEYWORD LIST:\n\n" +
			"LOAD url depth(optional) params[vxp](optional)\n\tv--verbose   x--crosssite   p--proxy\n" +
			"STOPLOAD\n" +
			"CLEAR\n" +
			"PLAY\n" +
			"PLAYF \"query\"\n" +
			"PAUSE\n" +
			"VOLUME (0.0-1.0)\n" +
			"RANDOM\n" +
			"REMOVE query(* for all)\n";
		;
		
		public function eval(msg:String) {
			try {
				D.eval(msg, { }, this);
			} catch (e:Error) {
				print("Invalid command. ''HELP'' for command list.");
				trace(e.message);
			}
		}
		
		public function list() {
			this.dispatchEvent(new SPEvt(SPEvt.LIST));
		}
		
		public function remove(tar:String, opts:String = "") {
			this.dispatchEvent(new SPEvt(SPEvt.REMOVE,{tar:tar, opts:opts}));
		}
		
		public function listfav() {
			this.dispatchEvent(new SPEvt(SPEvt.LIST_FAV));
		}
		
		public function clear() {
			this.dispatchEvent(new SPEvt(SPEvt.CLEAR_SCREEN_EVT));
		}
		
		public function print(msg:String) {
			this.dispatchEvent(new SPEvt(SPEvt.PRINT_EVT,{msg:msg}));
		}
		
		public function help() {
			this.dispatchEvent(new SPEvt(SPEvt.HELP_EVT));
		}
		
		public function stopload() {
			this.dispatchEvent(new SPEvt(SPEvt.STOP_CRAWLER));
		}
		
		public function play() {
			this.dispatchEvent(new SPEvt(SPEvt.PLAY));
		}
		
		public function playf(tar:String) {
			this.dispatchEvent(new SPEvt(SPEvt.PLAY_SPECIFIC, { tar:tar } ));
		}
		
		public function pause() {
			this.dispatchEvent(new SPEvt(SPEvt.PAUSE));
		}
		
		public function volume(vol:Number) {
			this.dispatchEvent(new SPEvt(SPEvt.VOLUME, {volume:vol}));
		}
		
		public function random() {
			this.dispatchEvent(new SPEvt(SPEvt.PLAY_RANDOM_SONG));
		}
		
		public function load(url:String, depth:Number = 5, opts:String = "") {
			this.dispatchEvent(new SPEvt(SPEvt.LOAD_SITE_EVT, { url:url, depth:depth, opts:opts } ));
		}
		
	}

}