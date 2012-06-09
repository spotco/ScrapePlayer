package  {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import r1.deval.D;
	public class StreamPlayerREPLInterface extends EventDispatcher {
		
		public var prototype:*;
		
		public static var HELP_TEXT = 
			"KEYWORD LIST:\n" +
			"LOAD url depth(optional)\n" +
			"PRINT msg\n" +
			"CLEAR"
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
		
		public function load(url:String, depth:Number = 1) {
			this.dispatchEvent(new SPEvt(SPEvt.LOAD_SITE_EVT, { url:url, depth:depth } ));
		}
		
	}

}