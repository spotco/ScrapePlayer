package com {

	public class Prioritizable
	{
		public var priority:int;

		public function Prioritizable(priority:int = -1)
		{
			this.priority = priority;
		}

		public function toString():String
		{
			return "[Prioritizable, priority=" + priority + "]";
		}
	}
}