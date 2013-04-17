package  {
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import com.adobe.errors.IllegalStateError;
	
	public class StreamPlayerControls extends EventDispatcher {
		
		private static var PAD:Number = 20;
		private static var OUT_HEI:Number = 380;
		private static var IN_HEI = 40;
		
		private var output_log:TextField;
		private var temp_out_line:TextField;
		private var input_line:TextField;
		
		public function StreamPlayerControls(p:StreamPlayer) {
			output_log = UILib.MAKE_DYN_TEXT(PAD, PAD, StreamPlayer.WID - PAD * 2, OUT_HEI);
			temp_out_line = UILib.MAKE_DYN_TEXT(PAD, OUT_HEI + PAD, StreamPlayer.WID-PAD*2, IN_HEI);
			input_line = UILib.MAKE_INPUT_TEXT(PAD, OUT_HEI + PAD*1.5 + IN_HEI, StreamPlayer.WID-PAD*2, IN_HEI);
			p.addChild(output_log);
			p.addChild(temp_out_line);
			p.addChild(input_line);
			
			input_line.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
				if (e.keyCode == Keyboard.ENTER && input_line.text.length > 0) {
					terminal_input();
				} else if (e.keyCode == Keyboard.UP) {
					input_stack_prev();
				} else if (e.keyCode == Keyboard.DOWN) {
					input_stack_next();
				}
			});
			
			input_line.background = true;
			input_line.backgroundColor = 0xDDDDDD;
		}
		
		public function get_input_focus_object():InteractiveObject {
			return this.input_line;
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
		
		public function msg_to_tmp(msg:String) {
			temp_out_line.text = msg;
		}
		
		//0 recent,  len earliest
		private var input_stack:Array = new Array();
		private var input_stack_hist:int = -1;
		
		private function input_stack_prev() {
			if (input_stack_hist + 1 < input_stack.length) {
				input_stack_hist++;
			}
			if (input_stack[input_stack_hist]) {
				input_line.text = input_stack[input_stack_hist];
				input_line.setSelection(input_line.text.length, input_line.text.length);
			}
		}
		
		private function input_stack_next() {
			if (input_stack_hist -1 >= -1) {
				input_stack_hist--;
			}
			if (input_stack[input_stack_hist]) {
				input_line.text = input_stack[input_stack_hist];
				input_line.setSelection(input_line.text.length, input_line.text.length);
			} else {
				input_line.text = "";
			}
		}
			
		private function terminal_input():void {
			var input_text:String = input_line.text;
			input_stack.unshift(input_text);
			input_stack_hist = -1;
			input_line.text = "";
			Lang.out(printf(":=%s\n",Lang.expr2str(Lang.parseval(input_text))));
		}
		
	}
}