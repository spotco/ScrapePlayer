package  {
	import adobe.utils.CustomActions;
	import com.adobe.errors.IllegalStateError;
	public class Lang {
		
		public static var _f_out:Function;
		public static var _f_clear:Function;
		public static var _f_play:Function;
		public static var _f_load:Function;
		public static var _f_volume:Function;
		public static var _f_pause:Function;
		public static var _f_stopload:Function;
		public static var _f_speed:Function;
		
		public static var _f_top_list_folders:Function;
		public static var _f_top_list_files:Function;
		public static var _f_top_push:Function;
		public static var _f_top_pop:Function;
		public static var _f_top_dir:Function;
		
		public static var _f_plist_add:Function;
		
		public static function msgout(msg:String) {
			_f_out(msg);
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
		
		static function FSTACK() {
			var searchst:Array = [];
			searchst.push(VARS);
			STACK.forEach(function(i) { searchst.push(i) } );
			return searchst;
		}
		
		static function VAL(a) {
			var searchst:Array = FSTACK();
			searchst.push(VARS);
			STACK.forEach(function(i) { searchst.push(i) } );
			for (var i = searchst.length - 1; i >= 0; i--) {
				if (searchst[i][a.val] != null) {
					return searchst[i][a.val];
				}
			}
			return a;
		}
		
		static function STACKTOP_GET(s:String) {
			var searchst:Array = FSTACK();
			for (var i = searchst.length - 1; i >= 0; i--) {
				if (searchst[i][s] != null) {
					return searchst[i][s];
				}
			}
			return s;
		}
		
		static function STACKTOP() {
			return STACK.length == 0?VARS:STACK[STACK.length-1];
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
		
		public static function add_to_loaded(s:String) {
			VARS["_LOADED"].push(new Token(Token.TYPE_STR, s));
		}
		
		public static function add_to_playlist(s:String) {
			VARS["_PLAYLIST"].push(new Token(Token.TYPE_STR, s));
		}

		static var STACK:Array = [];
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
				if (STACKTOP()[a[1].val] is Function) {
					msgout("ERROR::let::cannot overwrite builtins");
					return a;
				}
				STACKTOP()[a[1].val] = a[2];
				return a[2];
			},
			"letg":function(a:Array) {
				VARS[a[1].val] = a[2];
				return a[2];
			},
			"printh":function(a:Array) {
				return STACKTOP_GET("print")(a, true);
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
			"arr::nth":function(a:Array) {
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
			"arr::push":function(a:Array) {
				var tar:Array = VAL(a[1]);
				var rtval:Array = [];
				for (var i:int = 0; i < tar.length; i++) {
					rtval.push(tar[i]);
				}
				rtval.push(a[2]);
				return rtval;
			},
			"arr::pop":function(a:Array) {
				var tar:Array = VAL(a[1]);
				var rtval:Array = [];
				for (var i:int = 0; i < tar.length; i++) {
					rtval.push(tar[i]);
				}
				rtval.pop();
				return rtval;
			},
			"arr::len":function(a:Array) {
				return new Token(Token.TYPE_NUM,VAL(a[1]).length);
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
			"unlet":function(a:Array) {
				for (var i:int = 1; i < a.length; i++) STACKTOP()[a[i].val] = undefined;
				return par(a);
			},
			"ifeval":function(a:Array) {
				if (VAL(a[1]).val) {
					var aargs:Array = [new Token(Token.TYPE_VAR, "eval"),VAL(a[2])];
					return STACKTOP_GET("eval")(aargs);
				}
				return new Token(Token.TYPE_NUM,0);
			},
			"apply":function(a:Array) {
				return VAL(a[1])(a[2]);
			},
			"env":function(a:Array) {
				var lst = [];
				for (var k in STACKTOP()) {
					var v = STACKTOP()[k];
					lst.push(new Token(Token.TYPE_VAR, k));
				}
				return lst;
			},
			"push":function(a:Array) {
				STACK.push( { } );
				return new Token(Token.TYPE_NUM,STACK.length);
			},
			"pop":function(a:Array) {
				if (STACK.length == 0) {
					msgout("ERROR::pop::stack at bottom");
				} else {
					STACK.pop();
				}
				return new Token(Token.TYPE_NUM,STACK.length);
			},
			"play":function(a:Array) {
				//l -- current added
				//a -- all
				//r -- random
				//f -- find
				//play (l|a)(r|f) target
				var source:String = "a";
				var method:String = "r";
				var target:String = "";
				if (a.length >= 2) {
					source = a[1].val;
				}
				if (a.length >= 3) {
					method = a[2].val;
				}
				if (a.length >= 4) {
					target = a[3].val;
				}
				_f_play(source,method,target);
				return a;
			},
			"pause":function(a:Array) {
				_f_pause();
				return a;
			},
			"load":function(a:Array) {
				_f_load(a);
				return a;
			},
			"stopload":function(a:Array) {
				_f_stopload();
				return a;
			},
			"volume":function(a:Array) {
				_f_volume(a);
				return a;
			},
			"clear":function(a:Array) {
				_f_clear();
				return a;
			},
			"listspeed":function(a:Array) {
				_f_speed(a);
				return a;
			},
			"ls":function(a:Array) {
				//c -- current directory
				//a -- all
				//f -- find
				//ls (c | a | f) target
				var param:String = "c";
				var target:String = "";
				if ( a.length >= 2 ) {
					param = a[1].val;
				}
				if ( a.length >= 3) {
					target = a[2].val;
				}
				
				var folders:Vector.<String>;	
				folders = _f_top_list_files(param,target);
				var rtval:Array = [];
				folders.forEach(function(i) {
					rtval.push(new Token(Token.TYPE_STR, i));
				})
				return rtval;
			},
			"lsf":function(a:Array) {
				var folders:Vector.<String>;	
				folders = _f_top_list_folders(a);
				var rtval:Array = [];
				folders.forEach(function(i) {
					rtval.push(new Token(Token.TYPE_STR, i));
				})
				return rtval;
			},
			"cd":function(a:Array) {
				var suc:Number;
				if (a[1].val == "..") {
					suc = _f_top_pop(a);
				} else {
					suc = _f_top_push(a);
				}
				
				if (suc == 0) {
					msgout("ERROR:cd failed");
				}
				return new Token(Token.TYPE_NUM, suc);
			},
			"pwd":function(a:Array) {
				var s:Vector.<String> = _f_top_dir(a);
				var tmp:Array = [];
				s.forEach(function(i) {
					tmp.push(new Token(Token.TYPE_STR, i));
				});
				return tmp;
			},
			"plist::add":function(a:Array) {
				var match:String = "";
				if (a.length >= 2 && match != "*") {
					match = a[1].val;
				}
				a = _f_plist_add(match);
				for (var i:int = 0; i < a.length; i++) {
					a[i] = new Token(Token.TYPE_STR, a[i]);
				}
				return a;
			},
			"plist::remove":function(a:Array) {
				var match:String = "";
				if (a.length >= 2 && match != "*") {
					match = a[1].val;
					match = match.toLowerCase();
				}
				var removed:Array = [];
				VARS["_PLAYLIST"] = VARS["_PLAYLIST"].filter(function(i) {
					var nom:String = i.val;
					if (nom.indexOf(match) != -1) {
						removed.push(i);
						return false;
					} else {
						return true;
					}
				});
				return removed;
			},
			"_LOADED":[],
			"_PLAYLIST":[]
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
			var f = STACKTOP_GET(top(curframe).val);
			if (f is Function) {
				return f(curframe);
			} else {
				msgout("ERROR::Not a function");
				return new Token(Token.TYPE_NUM, 0);
			}
		}
	}

}