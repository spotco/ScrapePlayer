package  {
	import adobe.utils.CustomActions;
	import com.adobe.errors.IllegalStateError;
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
			try {
				return eval(lsts);
			} catch (e:Error) {
				msgout(e.message + "trace:");
				msgout(e.getStackTrace());
				return new Token(Token.TYPE_NUM, 0);
			}
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
			return new Token((s is String)?Token.TYPE_STR:Token.TYPE_NUM, s);
		}
		
		public static function expr2str(e,depth:int = 0):String { //token or array of tokens
			var buf:String = "";
			if (e is Token) {
				if (e.type == Token.TYPE_NUM) {
					return printf("$%s", e.val);
				} else if (e.type == Token.TYPE_STR) {
					return printf("\'%s\'", e.val);
				} else if (e.type == Token.TYPE_VAR) {
					return printf("@%s", e.val);
				}
			} else if (e is Array) {
				buf += "[";
				(e as Array).forEach(function(i,ct) {
					buf += expr2str(i) + ((ct<e.length-1)?",":"");
				});
				buf += "]";
				return buf;
			} else {
				msgout("unknown e in expr2str:"+ e);
			}
			return "ERR";
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
			"/":function(a:Array) {
				return new Token(Token.TYPE_NUM, VAL(a[1]).val / VAL(a[2]).val);
			},
			"%":function(a:Array) {
				return new Token(Token.TYPE_NUM, VAL(a[1]).val % VAL(a[2]).val);
			},
			"^":function(a:Array) {
				return new Token(Token.TYPE_NUM, Math.pow(VAL(a[1]).val , VAL(a[2]).val));
			},
			"floor":function(a:Array) {
				return new Token(Token.TYPE_NUM, Math.floor(VAL(a[1]).val));
			},
			"ceil":function(a:Array) {
				return new Token(Token.TYPE_NUM, Math.ceil(VAL(a[1]).val));
			},
			"round":function(a:Array) {
				return new Token(Token.TYPE_NUM, Math.round(VAL(a[1]).val));
			},
			"apply":function(a:Array) {
				var aargs:Array = VAL(a[2]);
				var aargs_cpy:Array = [];
				aargs_cpy.push(VAL(a[1]));
				for (var i:int = 0; i < aargs.length; i++) {
					aargs_cpy.push(aargs[i]);
				}
				return VAL(a[1])(aargs_cpy);
			},
			"top":Lang.top,
			"par":Lang.par,
			"let":function(a:Array) {
				if (VARS[a[1].val] is Function) {
					msgout("ERROR::let::cannot overwrite builtins");
					return a;
				}
				VARS[a[1].val] = a[2];
				return a[2];
			},
			"printh":function(a:Array) {
				return VARS["print"](a, true);
			},
			"print":function(a:Array, hold:Boolean = false ) {
				for (var i:int = 1; i < a.length; i++) {	
					if (a[i] is Token) {
						if ((a[i] as Token).type == Token.TYPE_VAR) {
							if (hold) {
								msgout(expr2str(a[i]));
								
							} else {
								var e =  VAL(a[i]);
								if (e is Function) {
									msgout(printf("@BUILTIN(%s)", a[i].val));
								} else if (e is Array || e is Token) {
									msgout(expr2str(e));
								} else {
									throw new IllegalStateError("ERROR::print::unknown token: "+e);
								}	
							}
						} else {
							msgout(expr2str(a[i]));
						}
					} else if (a[i] is Array) {
						msgout(expr2str(a[i]));
						
					} else {
						throw new IllegalStateError("ERROR::print::printing nontoken: "+e);
					}
				}
				return par(a);
			},
			"nth":function(a:Array) {
				var target = VAL(a[1]);
				if (a.length == 3 && a[2] is Token && a[2].type == Token.TYPE_NUM && (target is Array || target is Token && target.type == Token.TYPE_STR)) {
					if (target is Array) {
						if (a[2].val >= VAL(a[1]).length) {
							msgout("ERROR::nth::array out of bounds");
							return a;
						} else {
							return target[a[2].val];
						}
					} else if (target is Token) {
						target = target.val;
						if (a[2].val >= target.length) {
							msgout("ERROR::nth::string out of bounds");
							return a;
						} else {
							return new Token(Token.TYPE_STR,target.charAt(a[2].val));
						}
					}
				} else {
					msgout("ERROR::nth::param error (nth array i)");
					return a;
				}
			},
			"val":function(a:Array) {
				return VAL(a[1]);
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
				return new Token(Token.TYPE_NUM,0);
			},
			"apply":function(a:Array) {
				return VAL(a[1])(a[2]);
			},
			"env":function(a:Array) {
				var lst = [];
				for (var k in VARS) {
					var v = VARS[k];
					lst.push(new Token(Token.TYPE_VAR, k)); //todo: apply print (env, hold eval on tokens
				}
				return lst;
			},
			"push":function(a:Array) {
				
				return a;
			},
			"pop":function(a:Array) {
				
				return a;
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
			var curframe = [];
			for (var i:int = 0; i < lsts.length; i++) {
				var cobj = lsts[i];
				if (cobj is Array) {
					curframe.push(eval(cobj));
				} else if (cobj is Token) {
					curframe.push(cobj);
				}
			}
			return VARS[top(curframe).val](curframe);
		}
	}

}