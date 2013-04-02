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
					cbuf += cchar;
					
				} else if (cchar == " " || cchar == "(" || cchar == ")") {
					cbuf = StrUtil.trim(cbuf);
					if (cbuf.length > 0) {
						if ( StrUtil.isNumeric(cbuf) ) {
							tok.push(new Token(Token.TYPE_NUM, null, Number(cbuf)));
						} else {
							tok.push(new Token(Token.TYPE_VAR, cbuf));
						}
					}
					if (cchar == "(") {
						tok.push(new Token(Token.TYPE_POPEN, null));
					}
					if (cchar == ")") {
						tok.push(new Token(Token.TYPE_PCLOSE, null));
					}
					cbuf = "";
					
				} else {
					cbuf += cchar;
					
				}
				
				
			}
			
			return tok;
		}
		
	}

}