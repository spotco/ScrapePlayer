package  {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	public class StreamPlayerMusicLib extends EventDispatcher {
		
		private var sc:SoundChannel;
		private var current_song:Sound;
		private var pause_point:Number = 0.00;
		private var current_song_filename:String = "";
		private var vol:Number = 1.0;
		
		private var listspeed:int = 1;
		
		public var is_playing:Boolean = false;
		
		private var songs:Array = new Array();
		private var sound_pos_disp_updater:Timer;
		
		//folder tree stuff
		private var folder_root:FolderNode = new FolderNode(".");
		private var cur_folder_stack:Vector.<FolderNode> = new Vector.<FolderNode>();
		
		private function top():FolderNode { return cur_folder_stack[cur_folder_stack.length-1] }
		public function ftop_push(cd:String):Boolean {
			var cur:FolderNode = top();
			if (cur.subfolders[cd]) {
				cur_folder_stack.push(cur.subfolders[cd]);
				return true;
			} else {
				return false;
			}
		}
		public function ftop_pop():Boolean {
			if (cur_folder_stack.length > 1) {
				cur_folder_stack.pop();
				return true;
			} else {
				return false;
			}
		}
		public function ftop_list_folders():Vector.<String> {
			var tmp:Vector.<String> = new Vector.<String>();
			var cur:FolderNode = top();
			for (var k in cur.subfolders) {
				tmp.push(k);
			}
			return tmp;
		}
		public function ftop_list_files():Vector.<String> {
			var tmp:Vector.<String> = new Vector.<String>();
			var cur:FolderNode = top();
			for each(var k:FileData in cur.songs) {
				tmp.push(k.filename);
			}
			return tmp;
		}
		public function ftop_name():String {
			return top().name;
		}
		public function ftop_dir():Vector.<String> {
			var tmp:Vector.<String> = new Vector.<String>();
			for (var i:int = cur_folder_stack.length - 1; i >= 0; i--) {
				tmp.push(cur_folder_stack[i].name);
			}
			return tmp;
		}
		
		public function ftop_add_to_playlist(match:String) {
			var cur:Vector.<String> = ftop_list_files();
			var rtval:Array = [];
			cur.forEach(function(i) {
				if (i.indexOf(match) != -1) {
					Lang.add_to_playlist(i);
					rtval.push(i);
				}
			});
			return rtval;
		}
		//end folder tree stuff
		
		public function StreamPlayerMusicLib() {
			cur_folder_stack.push(folder_root);
			this.sound_pos_disp_updater = new Timer(500);
			this.sound_pos_disp_updater.addEventListener(TimerEvent.TIMER, function(e) {
				if (is_playing && sc && current_song) {
					dispatchEvent(new SPEvt(SPEvt.SONG_POS_UPDATE, { cur:CLib.getdisplaytime(sc.position), max:CLib.getdisplaytime(current_song.length), filename:current_song_filename } ));
				}
			});
			this.sound_pos_disp_updater.start();
		}
		
		public function set_listspeed(t:int) {
			listspeed = t;
		}
		
		public function add_song(url:String, filename:String, path:Array) {
			var cursong:FileData = new FileData(url, filename);
			
			var curnode:FolderNode = folder_root;
			for (var i:int = 0; i < path.length; i++) {
				if (!curnode.subfolders[path[i]]) {
					curnode.subfolders[path[i]] = new FolderNode(path[i]);
				}
				curnode = curnode.subfolders[path[i]];
				
			}
			//trace(path);
			curnode.songs.push(cursong);
			songs.push(cursong);
		}
		
		public function get_num_songs():int {
			return songs.length;
		}
		
		public function pause() {
			if (sc && current_song) {
				this.pause_point = sc.position;
				this.sc.stop();
				this.is_playing = false;
			}
		}
		
		public function play() {
			if (this.current_song && !this.is_playing) {
				if (this.pause_point == 0.00) {
					sc = current_song.play();
					sc.soundTransform = new SoundTransform(vol);
				} else {
					sc = current_song.play(pause_point);
					sc.soundTransform = new SoundTransform(vol);
					pause_point = 0.00;
				}
				
				this.is_playing = true;
				
				if (!sc.hasEventListener(Event.SOUND_COMPLETE)) {
					sc.addEventListener(Event.SOUND_COMPLETE, function(e) { play_random() } );
				}	
			} else if (!this.is_playing && current_song == null) {
				play_random();
			}
		}
		
		public function play_specific(tar:String) {
			tar = tar.toLowerCase();
			var found:FileData = null;
			for each(var i:FileData in this.songs) {
				if (i.filename.toLowerCase().indexOf(tar) >= 0) {
					found = i;
					break;
				}
			}
			
			if (found) {
				if (sc) {
					sc.stop();
				}
				if (current_song && current_song.isBuffering) {
					current_song.close();
				}
				this.pause_point = 0.0;
				this.is_playing = false;
				stream(found.url, found.filename);
			} else {
				dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:"Song not found." } ));
				return;
			}
			
		}
		
		public function play_random() {
			if (this.get_num_songs() == 0) {
				dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:"No songs loaded." } ));
				return;
			}
			if (sc) {
				sc.stop();
			}
			if (current_song && current_song.isBuffering) {
				try {
					current_song.close();
				} catch (e:Error) {
					dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:"Error on stream close:"+e.message } ));
				}
			}
			
			this.is_playing = false;
			this.pause_point = 0.0;
			var tar:FileData = songs[Math.floor(Math.random()*songs.length)];
			stream(tar.url,tar.filename);
		}
		
		public function fall_list_matching_files(tar:String):Vector.<String> {
			var tmp:Vector.<String> = new Vector.<String>();
			for (var i:int = 0; i < songs.length; i++) {
				if (songs[i].filename.toLowerCase().indexOf(tar) != -1) {
					tmp.push(songs[i].filename);
				}
			}
			return tmp;
		}
		
		public function remove(tar:String) {
			if (tar == "*") {
				songs = new Array;
				dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:"Removed all." } ));
				return;
			}
			tar = tar.toLowerCase();
			songs = songs.filter(function(t) {
				if (t.filename.toLowerCase().indexOf(tar) >= 0) {
					dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:"Removed:"+t.filename } ));
					return false;
				} else {
					return true;
				}
			});
		}
		
		public function volume(vol:Number) {
			if (this.sc) {
				this.vol = vol;
				this.sc.soundTransform = new SoundTransform(vol);
			}
		}
		
		private function stream(url:String, filename:String) {
			var req:URLRequest = new URLRequest(url);
			var con:SoundLoaderContext = new SoundLoaderContext(2000, false);
			this.current_song = new Sound();
			this.current_song.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent) {
				dispatchEvent(new SPEvt(SPEvt.PRINT_EVT, { msg:"Stream error:"+e.text } ));
			});
			
			this.current_song.load(req, con);
			var self = this.current_song;
			this.current_song.addEventListener(ProgressEvent.PROGRESS, function(e:ProgressEvent) {
				if (self == current_song) {
					dispatchEvent(new SPEvt(SPEvt.SONG_STREAMING, { progress: Math.floor((Number(e.bytesLoaded) / Number(e.bytesTotal))*100), filename:filename } ));
				}
			});
			this.current_song_filename = filename;
			play();
		}
		
		/*
		public function _test_traversal() {
			trace("BEGIN TRAVERSAL");
			var stack:Array = [folder_root.name];
			for (var key in folder_root.subfolders) {
				stack.push(key);
				_test_traversal_rec(folder_root[key], stack);
				stack.pop();
			}
			trace("END TRAVERSAL");
		}
		
		public function _test_traversal_rec(cur:FolderNode, stack:Array) {
			for each(var s in cur.songs) {
				trace(String(stack).replace(",", "->") + ":=>" + s.filename);
			}
			for (var key in cur.subfolders) {
				stack.push(key);
				_test_traversal_rec(cur.subfolders[key], stack);
				stack.pop();
			}
		}
		*/
		

		
	}

}

internal class FolderNode {
	public var subfolders = {};
	public var songs:Vector.<FileData> = new Vector.<FileData>();
	public var name:String = "";
	public function FolderNode(s:String) {
		this.name = s;
	}
	public function toString():String {
		return name;
	}
}

internal class FileData {
	public var url:String;
	public var filename:String;
	public function FileData(url:String, filename:String) {
		this.url = url;
		this.filename = filename;
	}
}