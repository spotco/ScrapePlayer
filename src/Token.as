package  {
	public class Token {
		
		public static var TYPE_POPEN:int = 1;
		public static var TYPE_PCLOSE:int = 2;
		public static var TYPE_VAR:int = 3;
		public static var TYPE_NUM:int = 4;
		public static var TYPE_STR:int = 5;
		
		public var type:int;
		public var val:String;
		public var numval:Number;
		
		public function Token(type:int,val:String,numval:Number = 0) {
			this.type = type;
			this.val = val;
			this.numval = numval;
		}
		
		public function toString():String {
			if (type == TYPE_POPEN || type == TYPE_PCLOSE) {
				return "{type:" + Token.type_enum_to_str(type) + "}";
				
			} else if (type == TYPE_VAR) {
				return "{type:" + Token.type_enum_to_str(type) + ",val:" + val + "}";
				
			} else if (type == TYPE_NUM) {
				return "{type:" + Token.type_enum_to_str(type) + ",numval:" + numval + "}";
				
			} else if (type == TYPE_STR) {
				return "{type:" + Token.type_enum_to_str(type) + ",val:\"" + val + "\"}";
				
			} else {
				return "ERROR";
			}
		}
		
		public static function type_enum_to_str(i:int):String {
			return {1:"POPEN", 2:"PCLOSE", 3:"VAR", 4:"NUM", 5:"STR" } [i];
		}
		
	}

}