package  {
	public class Lang {
		
		static var out:Function;
		
		public static function set_out(f:Function) {
			out = f;
		}
		
		public static function msgout(msg:String) {
			out(msg);
		}
		
		public static function parseval(input_text:String) {
			var tok:Vector.<Token> = LangTokenizer.tokenize(input_text);
			LangTokenizer.balance(tok);
			var lsts = LangTokenizer.to_lists(tok);
			//try {
				return eval(lsts);
			//} catch (e) {
				msgout(e);
			//}
		}
		
		static function VAL(a) {
			return VARS[a.val] == null?a:VARS[a.val];
		}
		
		public static function top(a:Array):Token {
			return a[0];
		}
		
		public static function par(a:Array):Array {
			var tmp:Array = [];
			for (var i:int = 1; i < a.length; i++) tmp.push(a[i]);
			return tmp;
		}
		
		public static function reduce(a:Array, fn:Function) {
			var s = VAL(a[1]).val;
			for (var i:int = 2; i < a.length; i++) {
				s = fn(s,VAL(a[i]).val);
			}
			return new Token(VAL(a[1]).type, s);
		}

		static var VARS = {
			"+":function(a:Array) {
				var s = VAL(a[1]); 
				if (s.type == Token.TYPE_NUM || a.type == Token.TYPE_STR) 
					return reduce(a, function(a, b) { return a + b; } );
				return a;
			},
			"*":function(a:Array) {
				var s = VAL(a[1]); 
				if (s.type == Token.TYPE_NUM || a.type == Token.TYPE_STR) 
					return reduce(a, function(a, b) { return a * b; } );
				return a;
			},
			"apply":function(a:Array) {
				var aargs:Array = VAL(a[2]);
				aargs.unshift(VAL(a[1]));
				return VAL(a[1])(aargs);
			},
			"top":Lang.top,
			"par":Lang.par,
			"let":function(a:Array) {
				VARS[a[1].val] = a[2];
				return a[2];
			},
			"print":function(a:Array) {
				for (var i:int = 1; i < a.length; i++) {
					var e =  VAL(a[i]);
					if (e is Token) {
						msgout("[" + i + "]:" + VAL(e));
					} else {
						msgout("[" + i + "]:["+e+"]");
					}
					
				}
				return par(a);
			},
			"eval":function(a:Array) {
				return eval(VAL(a[1]));
			},
			"nop":function(a:Array) {
				return par(a);
			},
			"clear":function(a:Array) {
				for (var i:int = 1; i < a.length; i++) VARS[a[i].val] = undefined;
				return par(a);
			},
			"ifeval":function(a:Array) {
				if (VAL(a[1]).val) {
					var aargs:Array = [new Token(Token.TYPE_VAR, "eval"),VAL(a[2])];
					trace(aargs);
					return VARS["eval"](aargs);
				}
				return 0;
			},
			"env":function(a:Array) {
				var ct = 0;
				var lst = [];
				for (var i in VARS) {
					msgout("["+ct+"]:"+i+" ("+VARS[i]+")");
					lst.push(new Token(Token.TYPE_STR,i));
					ct++;
				}
				return lst;
			},
			
			"play":function(a:Array) {
				msgout("playing:" + a[1].val);
			},
			"pause":function(a:Array) {
				msgout("playing:" + a[1].val);
			},
			"load":function(a:Array) {
				msgout("playing:" + a[1].val);
			},
			"stopload":function(a:Array) {
				msgout("playing:" + a[1].val);
			},
			"volume":function(a:Array) {
				msgout("playing:" + a[1].val);
			}
		};
		
		public static function eval(lsts:Array) {
			var curframe:StackFrame = new StackFrame();
			for (var i:int = 0; i < lsts.length; i++) {
				var cobj = lsts[i];
				if (cobj is Array) {
					curframe.vars.push(eval(cobj));
				} else if (cobj is Token) {
					curframe.vars.push(cobj);
				}
			}
			return VARS[top(curframe.vars).val](curframe.vars);
		}
		
	}

}

internal class StackFrame {
	public var next:StackFrame;
	public var prev:StackFrame;
	public var vars:Array = [];
	
	public function toString():String {
		return "{vars:" + vars + ", next:" + next + ", prev:" + prev + "}";
	}
}