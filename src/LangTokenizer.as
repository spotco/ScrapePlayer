package  {
	
	public class LangTokenizer {
				
		public static function tokenize(st:String):Vector.<Token> {
			
			var tok:Vector.<Token> = new Vector.<Token>();
			var cbuf:String = "";
			var strmode:Boolean = false;
			
			for (var i:int = 0; i < st.length; i++) {
				var cchar:String = st.charAt(i);
				if (cchar == "'" || cchar == "\"") {
					if (!strmode) {
						cbuf = "";
						strmode = true;
						
					} else {
						tok.push(new Token(Token.TYPE_STR, cbuf));
						cbuf = "";
						strmode = false;
						
					}
					
				} else if (strmode) {
					if (cchar == ":") {
						cbuf += ";";
					} else {
						cbuf += cchar;
					}
					
				} else if (cchar == " " || cchar == "(" || cchar == ")") {
					cbuf = StrUtil.trim(cbuf);
					if (cbuf.length > 0) {
						if ( StrUtil.isNumeric(cbuf) ) {
							tok.push(new Token(Token.TYPE_NUM,Number(cbuf)));
						} else {
							tok.push(new Token(Token.TYPE_VAR, cbuf));
						}
					}
					if (cchar == "(") {
						tok.push(new Token(Token.TYPE_POPEN));
					}
					if (cchar == ")") {
						tok.push(new Token(Token.TYPE_PCLOSE));
					}
					cbuf = "";
					
				} else {
					cbuf += cchar;
					
				}
			}
			
			cbuf = StrUtil.trim(cbuf);
			if (cbuf.length != 0) {
				if (StrUtil.isNumeric(cbuf)) {
					tok.push(new Token(Token.TYPE_NUM, Number(cbuf)));
				} else {
					tok.push(new Token(Token.TYPE_VAR, cbuf));
				}
			}
			
			return tok;
		}
		
		public static function balance(tok:Vector.<Token>):void {
			if (tok.length > 0 && tok[0].type != Token.TYPE_POPEN) {
				tok.unshift(new Token(Token.TYPE_POPEN));
			}
			var stackdepth:int = 0;
			for (var i:int = 0; i < tok.length; i++) {
				if (tok[i].type == Token.TYPE_POPEN) {
					stackdepth++;
				} else if (tok[i].type == Token.TYPE_PCLOSE) {
					stackdepth--;
				}
			}
			while (stackdepth > 0) {
				stackdepth--;
				tok.push(new Token(Token.TYPE_PCLOSE));
			}
		}
		
		public static function to_lists(tok:Vector.<Token>):Array {
			return  tok_to_list_lvl(sublst(tok,0));
		}
		
		private static function tok_to_list_lvl(tok:Vector.<Token>):Array {
			var clist:Array = [];
			
			for (var i:int = 0; i < tok.length; i++) {
				var ctok:Token = tok[i];
				if (ctok.type == Token.TYPE_POPEN) {
					
					var sublst:Vector.<Token> = sublst(tok, i);
					clist.push(tok_to_list_lvl(sublst));
					i += sublst.length;
					
				} else if (ctok.type == Token.TYPE_NUM || ctok.type == Token.TYPE_VAR || ctok.type == Token.TYPE_STR) {
					clist.push(ctok);
				}
			}
			
			return clist;
		}
		
		private static function sublst(tok:Vector.<Token>, start:int):Vector.<Token> {
			var sublst:Vector.<Token> = new Vector.<Token>();
			var depth:int = 0;
			for (var i:int = start; i < tok.length; i++) {
				var ctok:Token = tok[i];
				if (ctok.type == Token.TYPE_POPEN) {
					depth++;
					if (depth != 1) {
						sublst.push(ctok);
					}
				} else if (ctok.type == Token.TYPE_PCLOSE) {
					depth--;
					if (depth != 0) {
						sublst.push(ctok);
					}
				} else {
					sublst.push(ctok);
				}
				
				if (depth == 0) {
					break;
				}
				
			}
			
			return sublst;
		}
		
	}

}