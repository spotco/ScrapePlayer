package  { 
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class UILib {
		
		[Embed(source='../resc/DisplayOTF.otf', embedAsCFF="false", fontName='Menu', fontFamily="Menu", mimeType='application/x-font')]
		public static var GAMEFONT:Class;
		
		private static function make_text_format():TextFormat {
			var tf:TextFormat = new TextFormat();
			tf.leftMargin = 10;
			tf.rightMargin = 10;
			tf.font = "Menu";
			if (Main.MOBILE_UI) {
				tf.size = 30;
			} else {
				tf.size = 20;
			}
			
			tf.color = 0x000000;
			return tf;
		}
		
		public static function MAKE_DYN_TEXT(x:Number, y:Number, wid:Number, hei:Number):TextField {
			var txt:TextField = make_text("", x, y, wid, hei);
			txt.type = TextFieldType.DYNAMIC;
			txt.defaultTextFormat = make_text_format();
			return txt;
		}
		
		public static function MAKE_INPUT_TEXT(x:Number, y:Number, wid:Number, hei:Number):TextField {
			var txt:TextField = make_text("", x, y, wid, hei);
			txt.type = TextFieldType.INPUT;
			txt.defaultTextFormat = make_text_format();
			return txt;
		}
		
		private static function make_text(text:String, x:Number, y:Number, wid:Number, hei:Number):TextField {
			var ntx:TextField = new TextField;
			ntx.text = text;
			ntx.width = wid;
			ntx.height = hei;
			ntx.x = x;
			ntx.y = y;
			ntx.embedFonts = true;
			//ntx.border = true;
			ntx.antiAliasType = AntiAliasType.ADVANCED;
			return ntx;
		}
		
	}

}