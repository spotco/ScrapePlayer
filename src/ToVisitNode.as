package  {
	import com.Prioritizable;

	public class ToVisitNode extends Prioritizable {
		
		public var url:String;
		public var depth:Number;
		public var opts:Object;
		
		public function ToVisitNode(url:String, depth:Number, opts:Object) {
			super(depth);
			this.url = url;
			this.depth = depth;
			this.opts = opts;
		}
		
	}

}