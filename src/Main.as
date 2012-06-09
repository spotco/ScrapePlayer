package 
{
	import com.adobe.net.URI;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.media.*;
	import flash.net.*;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.xml.*;
	import r1.deval.D;
 
	[SWF(backgroundColor = "#FFFFFF", frameRate = "60", width = "500", height = "500")]
	
	public class Main extends Sprite {
		public var prototype:*;
		default xml namespace = new Namespace("http://www.w3.org/1999/xhtml");
		private var output_log:TextField;
		private var input_line:TextField;
		
		/**
		 * TODO:
			 * Parse hrefs, remove javascript links
			 * better UI
		 */
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function makeui():void {
			this.output_log = CLib.MAKE_DYN_TEXT(20, 20, 460, 380);
			this.input_line = CLib.MAKE_INPUT_TEXT(20, 420, 460, 40);
			this.stage.addChild(output_log);
			this.stage.addChild(input_line);
			this.input_line.addEventListener(KeyboardEvent.KEY_UP, function(e:KeyboardEvent) {
				if (e.keyCode == Keyboard.ENTER && input_line.text.length > 0) {
					terminal_input();
				}
			});
		}
		
		private function terminal_input():void {
			var input_text:String = input_line.text;
			input_line.text = "";
			try {
				var eval_stmnt:String = "";
				var tokens:Array = input_text.split(" ");
				tokens.forEach(function(val:String, ind:int, arr:Array) {
					if (!Boolean(val.match(/^[0-9]+.?[0-9]*$/)) && ind != 0) {
						eval_stmnt += "\""+val+"\"";
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
				
				trace(eval_stmnt);
				
				D.eval(eval_stmnt, { }, this);
			} catch (e:Error) {
				print("Invalid command. ''help'' for command list.");
				trace(e.message);
			}
		}
		
		public function clear() {
			output_log.text = "";
			output_log.scrollV = output_log.maxScrollV;
		}
		
		public function print(msg:String) {
			output_log.text += msg;
			output_log.text += "\n";
			output_log.scrollV = output_log.maxScrollV;
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			makeui();
			
			//var url:String = "http://spotcos.com/misc/streamplayer/";
			//
			//var uri:URI = new URI(url);
			//uri.chdir("101%20Main%20Theme.mp3");
			//
			//trace(uri.authority);
			//trace(uri.toString());
			
			//var x:XML = new XML("<html><head></head><body><p><a href=\"lol\"></a></p></body></html>");
			//for each(var x:XML in x.descendants("a")) {
				//trace(x.toXMLString());
			//}
			

			var urlRequest:URLRequest = new URLRequest("http://ocremix.org/remix/OCR02286/");
			var urlLoader:URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, http_request_success);
			configureErrors(urlLoader);
			urlLoader.load(urlRequest);
			
			//play_sound();
		}
		
		private function configureErrors(dispatcher:IEventDispatcher):void {
			dispatcher.addEventListener(NetStatusEvent.NET_STATUS, http_error_handle);
			dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, http_error_handle);
			dispatcher.addEventListener(IOErrorEvent.IO_ERROR,http_error_handle);
		}
		
		private function http_request_success(e:Event):void {
			trace("success");
			XML.ignoreWhitespace = false;
			XML.prettyPrinting = false;
			
			var x:XML = new XML(e.target.data);
			for each(var x:XML in x.descendants("a")) {
				print(x.@href);
			}
		}
		
		private function http_error_handle(e:Event):void {
			trace("network error:" + e.toString());
		}
		
		private function play_sound():void {
			var s:Sound = new Sound(); 
			var req:URLRequest = new URLRequest("http://ocremix.org/remix/OCR02286/");
			s.addEventListener(HTTPStatusEvent.HTTP_STATUS, function(e:HTTPStatusEvent) { trace(e); } );
			var context:SoundLoaderContext = new SoundLoaderContext(2000, true); 
			s.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent) { trace(e.toString()); } );
			s.load(req, context); 
			s.play();
		}
		
	}
	
}