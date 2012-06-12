package  {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import r1.deval.D;
	public class StreamPlayerREPLInterface extends EventDispatcher {
		
		public var prototype:*;
		
		public static var HELP_TEXT = 
			"KEYWORD LIST:\n" +
			"LOAD url depth(optional) params[vxp](optional)\n\tv--verbose   x--crosssite   p--proxy\n" +
			"STOP\n" +
			"CLEAR\n" +
			"PLAY";
		;
		
		public function eval(msg:String) {
			try {
				D.eval(msg, { }, this);
			} catch (e:Error) {
				print("Invalid command. ''HELP'' for command list.");
				trace(e.message);
			}
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
		
		public function stop() {
			this.dispatchEvent(new SPEvt(SPEvt.STOP_CRAWLER));
		}
		
		public function play() {
			this.dispatchEvent(new SPEvt(SPEvt.PLAY_RANDOM_SONG));
		}
		
		public function load(url:String, depth:Number = 5, opts:String = "") {
			this.dispatchEvent(new SPEvt(SPEvt.LOAD_SITE_EVT, { url:url, depth:depth, opts:opts } ));
		}
		
	}

}