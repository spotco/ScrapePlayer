package  {
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	public class StreamPlayerControls extends EventDispatcher {
		
		private static var PAD:Number = 20;
		private static var OUT_HEI:Number = 380;
		private static var IN_HEI = 40;
		
		private var output_log:TextField;
		private var temp_out_line:TextField;
		private var input_line:TextField;
		private var repl:StreamPlayerREPLInterface;
		
		public function StreamPlayerControls(p:StreamPlayer) {
			output_log = UILib.MAKE_DYN_TEXT(PAD, PAD, StreamPlayer.WID - PAD * 2, OUT_HEI);
			temp_out_line = UILib.MAKE_DYN_TEXT(PAD, OUT_HEI + PAD, StreamPlayer.WID-PAD*2, IN_HEI);
			input_line = UILib.MAKE_INPUT_TEXT(PAD, OUT_HEI + PAD*1.5 + IN_HEI, StreamPlayer.WID-PAD*2, IN_HEI);
			p.addChild(output_log);
			p.addChild(temp_out_line);
			p.addChild(input_line);
			
			repl = new StreamPlayerREPLInterface();
			
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
			
			
			
			if (Main.MOBILE_UI) {
				make_mobile_ui(p);
			}
		}
		
		private function make_mobile_ui(p:StreamPlayer) {
			var load:Sprite = new Sprite();
			load.graphics.beginFill(0xFF0000);
			load.graphics.drawCircle(0, 0, 50);
			p.addChild(load);
			
			
			var play:Sprite = new Sprite();
			play.graphics.beginFill(0x00FF00);
			play.graphics.drawCircle(0, 0, 50);
			p.addChild(play);
			
			load.x = StreamPlayer.WID - 100;
			load.y = 60;
			
			play.x = StreamPlayer.WID - 100;
			play.y = 170;
			
			load.addEventListener(MouseEvent.CLICK, function(e) {
				dispatchEvent(new SPEvt(SPEvt.LOAD_SITE_EVT,{ url:"spotcos.com/misc", depth:5, opts:""}));
			});
			
			play.addEventListener(MouseEvent.CLICK, function(e) {
				dispatchEvent(new SPEvt(SPEvt.PLAY_RANDOM_SONG));
			});
			
			CLib.add_mouse_over(load);
			CLib.add_mouse_over(play);
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
			var eval_stmnt:String = "";
			var tokens:Array = input_text.split(" ");
			tokens.map(function(t) { t.replace(" ", ""); } );
			
			if (tokens[1] && tokens[1].charAt(0) == "\"" && tokens[tokens.length - 1].charAt(tokens[tokens.length - 1].length-1) == "\"") {
				eval_stmnt = tokens[0] + "(";
				for (var i = 1; i < tokens.length; i++) {
					eval_stmnt += tokens[i];
					eval_stmnt += " ";
				}
				eval_stmnt += ");";
			} else {
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
			}
			trace(eval_stmnt);
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
		
	}

}