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
		
		static function VAL(a) {
			return VARS[a] == null?a:VARS[a];
		}

		static var VARS = {
			"+":function(a:Array) {
				if (a.length < 1) eval_error("+, 1 param required");
				var s = VAL(a[0]); for (var i:int = 1; i < a.length; i++) s += VAL(a[i]); return s;
			},
			"-":function(a:Array) {
				if (a.length < 1) eval_error("-, 1 param required");
				var s = VAL(a[0]); for (var i:int = 1; i < a.length; i++) s -= VAL(a[i]); return s;
			},
			"*":function(a:Array) {
				if (a.length < 2) eval_error("*, 2 param required");
				var s = VAL(a[0]); for (var i:int = 1; i < a.length; i++) s *= VAL(a[i]); return s;
			},
			"/":function(a:Array) {
				if (a.length < 2) eval_error("/, 2 param required");
				var s = VAL(a[0]); for (var i:int = 1; i < a.length; i++) s /= VAL(a[i]); return s;
			},
			"let":function(a:Array) {
				if (a.length < 2) eval_error("let, 2 param required");
				if (StrUtil.isNumeric(a[0])) eval_error("let non numeric variable");
				VARS[a[0]] = VAL(a[1]);
				return VAL(a[1]);
			},
			"print":function(a:Array) {
				for (var i:int = 0; i < a.length; i++) print_msg("[" + i + "]:" + VAL(a[i]));
				return 0;
			},
			"eval":function(a:Array) {
				return eval(VAL(a[0]));
			},
			"ifeval":function(a:Array) {
				if (a.length < 2) eval_error("ifeval, 2 param required");
				if (VAL(a[0])) return eval(VAL(a[1]));
				return null;
			},
			"clear":function(a:Array) {
				for (var i:int = 0; i < a.length; i++) VARS[a[i]] = undefined;
			}
		};
		
		/**
		 * count to 100
		let a 0
		let incr "let a (+ a 1:print a:eval loop"
		let loop "ifeval (+ a -100) incr"
		eval loop
		 */
		
		private function terminal_input():void {
			var input_text:String = input_line.text;
			input_stack.unshift(input_text);
			input_stack_hist = -1;
			input_line.text = "";
			
			eval(input_text);
		}
		
		public static function eval(input_text:String) {
			input_text.split(";").filter(function(i) {
				return StrUtil.trim(i).length > 0;
			}).forEach(function(i) {
				var tok:Vector.<Token> = LangTokenizer.tokenize(i);
				LangTokenizer.balance(tok);
				
				try {
					return run(tok);
				} catch (e) {
					trace(e);
				}
			});
			

		}

		
		public static function run(tok:Vector.<Token>) {
			//trace(tok);
			
			var curframe:StackFrame = new StackFrame();
			var top:Boolean = false;
			
			while (tok.length) {
				var ctoken:Token = tok.shift();
				if (top) {
					if (ctoken.type == Token.TYPE_VAR) {
						curframe.fn = ctoken.val;
					} else {
						eval_error("expected function name, was:"+Token.type_enum_to_str(ctoken.type));
					}
					top = false;
					
				} else if (ctoken.type == Token.TYPE_POPEN) {
					curframe.next = new StackFrame();
					curframe.next.prev = curframe;
					curframe = curframe.next;
					top = true;
					
				} else if (ctoken.type == Token.TYPE_PCLOSE) {
					var targetfn = VARS[curframe.fn];
					if (targetfn == null) {
						eval_error("variable:" + curframe.next + " not found");
					} else if (!(targetfn is Function)) {
						eval_error("variable:" + curframe.next + " not function");
					}
					var evaled = targetfn(curframe.vars);
					curframe = curframe.prev;
					curframe.next = null;
					curframe.vars.push(evaled);
					
				} else {
					if (ctoken.type == Token.TYPE_NUM) {
						curframe.vars.push(ctoken.numval);
						
					} else if (ctoken.type == Token.TYPE_STR) {
						curframe.vars.push(ctoken.val);
						
					} else {
						curframe.vars.push(ctoken.val);
						
					}
				}
			}
			
			return curframe.vars[0];
		}
		
		public static function print_msg(msg:String) {
			trace(msg);
		}
		
		public static function eval_error(msg:String) {
			throw new IllegalStateError(msg);
		}
		
	}
}

internal class StackFrame {
	public var next:StackFrame;
	public var prev:StackFrame;
	public var vars:Array = [];
	public var fn:String;
	
	public function toString():String {
		return "{vars:" + vars + ", next:" + next + ", prev:" + prev + "}";
	}
}