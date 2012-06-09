package  {
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	public class StreamPlayerControls extends EventDispatcher {
		
		private static var PAD:Number = 20;
		private static var OUT_HEI:Number = 380;
		private static var IN_HEI = 40;
		
		private var output_log:TextField;
		private var input_line:TextField;
		private var repl:StreamPlayerREPLInterface;
		
		public function StreamPlayerControls(p:StreamPlayer) {
			output_log = UILib.MAKE_DYN_TEXT(PAD, PAD, StreamPlayer.WID-PAD*2, OUT_HEI);
			input_line = UILib.MAKE_INPUT_TEXT(PAD, OUT_HEI + PAD*2, StreamPlayer.WID-PAD*2, IN_HEI);
			p.addChild(output_log);
			p.addChild(input_line);
			
			repl = new StreamPlayerREPLInterface();
			
			input_line.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
				if (e.keyCode == Keyboard.ENTER && input_line.text.length > 0) {
					terminal_input();
				}
			});
			
			repl.addEventListener(SPEvt.CLEAR_SCREEN_EVT, clear_screen_evth);
			repl.addEventListener(SPEvt.PRINT_EVT, print_to_screen_evth);
			repl.addEventListener(SPEvt.HELP_EVT, help_evth);
			repl.addEventListener(SPEvt.LOAD_SITE_EVT, load_site_evth);
		}
		
		public function clear_screen() {
			output_log.text = "";
			output_log.scrollV = output_log.maxScrollV;
		}
		
		public function msg_to_screen(msg:String) {
			output_log.appendText(msg);
			output_log.appendText("\n");
			output_log.scrollV = output_log.maxScrollV;
		}
		
		private function terminal_input():void {
			var input_text:String = input_line.text;
			input_line.text = "";
			var eval_stmnt:String = "";
			var tokens:Array = input_text.split(" ");
			tokens.forEach(function(val:String, ind:int, arr:Array) {
				if (!Boolean(val.match(/^[0-9]+.?[0-9]*$/)) && ind != 0) {
					eval_stmnt += "\""+val+"\"";
				} else if (ind == 0) {
					eval_stmnt += val.toLowerCase();
				} else {
					eval_stmnt += val;
				}
				
				if (ind == 0) {
					eval_stmnt += "(";
				} else if (ind != arr.length - 1) {
					eval_stmnt += ",";
				}
			});
			eval_stmnt += ");"
			
			repl.eval(eval_stmnt);
		}
				
		private function clear_screen_evth(e:SPEvt) {
			clear_screen();
		}
		
		private function print_to_screen_evth(e:SPEvt) {
			msg_to_screen(e.info.msg);
		}
		
		private function help_evth(e:SPEvt) {
			clear_screen();
			msg_to_screen(StreamPlayerREPLInterface.HELP_TEXT);
		}
		
		private function load_site_evth(e:SPEvt) {
			dispatchEvent(new SPEvt(SPEvt.LOAD_SITE_EVT,e.info));
		}
		
	}

}