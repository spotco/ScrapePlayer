package  
{
	public class StrUtil {
	
	public static function trim(str:String):String{
		return str.replace(/^\s*(.*?)\s*$/g, "$1");
	}

	public static function isNumeric(str:String):Boolean {
		return !isNaN( Number( str ) );
	}
	
	}

}