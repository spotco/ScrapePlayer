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
			
			/**
			repl.addEventListener(SPEvt.CLEAR_SCREEN_EVT, clear_screen_evth);
			repl.addEventListener(SPEvt.PRINT_EVT, print_to_screen_evth);
			repl.addEventListener(SPEvt.HELP_EVT, help_evth);
			repl.addEventListener(SPEvt.LOAD_SITE_EVT, function(e:SPEvt) { dispatchEvent(new SPEvt(SPEvt.LOAD_SITE_EVT,e.info)); } );
			repl.addEventListener(SPEvt.STOP_CRAWLER, function(e:SPEvt) { dispatchEvent(new SPEvt(SPEvt.STOP_CRAWLER, e.info)); } );
			repl.addEventListener(SPEvt.PLAY_RANDOM_SONG, function(e:SPEvt) { dispatchEvent(new SPEvt(SPEvt.PLAY_RANDOM_SONG,e.info)); } );
			repl.addEventListener(SPEvt.PLAY, function(e:SPEvt) { dispatchEvent(new SPEvt(SPEvt.PLAY)); } );
			repl.addEventListener(SPEvt.PAUSE, function(e:SPEvt) { dispatchEvent(new SPEvt(SPEvt.PAUSE)); } );
			repl.addEventListener(SPEvt.VOLUME, function(e:SPEvt) { dispatchEvent(new SPEvt(SPEvt.VOLUME, e.info)); } );
			repl.addEventListener(SPEvt.PLAY_SPECIFIC, function(e:SPEvt) { dispatchEvent(new SPEvt(SPEvt.PLAY_SPECIFIC, e.info)); } );
			repl.addEventListener(SPEvt.LIST, function(e:SPEvt) { dispatchEvent(new SPEvt(SPEvt.LIST, e.info)); } );
			repl.addEventListener(SPEvt.REMOVE, function(e:SPEvt) { dispatchEvent(new SPEvt(SPEvt.REMOVE, e.info)); } );
			repl.addEventListener(SPEvt.LIST_FAV, function(e:SPEvt) { dispatchEvent(new SPEvt(SPEvt.LIST_FAV, e.info)); } );
			repl.addEventListener(SPEvt.LISTSPEED, function(e:SPEvt) { dispatchEvent(new SPEvt(SPEvt.LISTSPEED, e.info)); });
			 */
			Lang._f_clear = clear_screen;
			Lang._f_out = msg_to_screen;
			Lang._f_list = function() {
				dispatchEvent(new SPEvt(SPEvt.LIST));
			}
			Lang._f_load = function(s) {
				trace(s);
				dispatchEvent(new SPEvt(SPEvt.LOAD_SITE_EVT,{"url":s,"depth":5,"opts":[]}));
			}
			Lang._f_play = function() {
				dispatchEvent(new SPEvt(SPEvt.PLAY));
			}
			Lang._f_pause = function() {
				dispatchEvent(new SPEvt(SPEvt.PAUSE));
			}
			Lang._f_stopload = function() {
				 dispatchEvent(new SPEvt(SPEvt.STOP_CRAWLER));
			}
			Lang._f_volume = function(v) {
				 dispatchEvent(new SPEvt(SPEvt.VOLUME, {"volume":v}));
			}
			
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
			Lang._f_out(printf(":=%s\n",Lang.expr2str(Lang.parseval(input_text))));
		}
		
	}
}